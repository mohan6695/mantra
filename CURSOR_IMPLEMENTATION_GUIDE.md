# MANTRA APP — COMPLETE CURSOR IMPLEMENTATION GUIDE
# Single file containing all context, architecture, and implementation inputs
# Generated: March 2026
# Stack: Flutter + Native Kotlin/Swift + TFLite KWS + drift/SQLite + Supabase + Cloudflare Workers

================================================================================
SECTION 0: PROJECT OVERVIEW & CURSOR INSTRUCTIONS
================================================================================

You are implementing a production-ready mantra chanting counter app.
Read ALL sections before writing any code. Follow the architecture exactly.
Implement one section at a time in the order listed below.

CORE PRINCIPLES:
- Everything on the counting critical path is on-device, offline, <15ms latency
- Audio NEVER leaves device for counting purposes
- Sync to cloud is async, non-blocking, fire-and-forget
- All ML runs on-device via TFLite (no cloud API for detection)
- App works 100% offline; cloud is optional enhancement only

PRIORITIES (in order): Accuracy > Latency > Scalability > App Size

================================================================================
SECTION 1: DIRECTORY STRUCTURE
================================================================================

mantra/
├── pubspec.yaml
├── README.md
│
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── constants.dart              # App-wide constants
│   │   ├── providers.dart              # Root Riverpod providers
│   │   └── router.dart                 # App routing (go_router)
│   │
│   ├── audio/
│   │   ├── audio_channel.dart          # Platform channel interface (Dart side)
│   │   ├── detection_isolate.dart      # Refractory gate + counter logic
│   │   └── kws_engine.dart             # TFLite interpreter wrapper
│   │
│   ├── data/
│   │   ├── local/
│   │   │   ├── database.dart           # drift schema + database class
│   │   │   ├── database.g.dart         # GENERATED — run build_runner
│   │   │   └── daos/
│   │   │       ├── mantra_dao.dart
│   │   │       ├── session_dao.dart
│   │   │       └── detection_dao.dart
│   │   │
│   │   └── remote/
│   │       ├── supabase_service.dart   # Auth + profile sync
│   │       ├── sync_service.dart       # Session sync queue handler
│   │       └── config_service.dart     # Fetch mantra config from CF KV
│   │
│   ├── features/
│   │   ├── calibration/
│   │   │   ├── calibration_screen.dart
│   │   │   └── calibration_provider.dart
│   │   │
│   │   ├── session/
│   │   │   ├── session_screen.dart     # Active chanting UI
│   │   │   ├── session_provider.dart
│   │   │   └── widgets/
│   │   │       ├── ring_progress.dart  # Animated progress ring
│   │   │       └── counter_display.dart
│   │   │
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── dashboard_provider.dart
│   │   │   └── widgets/
│   │   │       ├── streak_card.dart
│   │   │       ├── heatmap_calendar.dart
│   │   │       └── mantra_stats_card.dart
│   │   │
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── settings_provider.dart
│   │
│   └── notifications/
│       └── notification_service.dart
│
├── android/app/src/main/kotlin/com/mantra/
│   ├── audio/
│   │   ├── AudioEngine.kt              # AudioRecord + MFCC + VAD
│   │   └── VadGate.kt                  # Energy + ZCR gate
│   └── MainActivity.kt
│
├── ios/Runner/
│   ├── audio/
│   │   ├── AudioEngine.swift           # AVAudioEngine + MFCC + VAD
│   │   └── VadGate.swift
│   └── AppDelegate.swift
│
├── assets/
│   ├── models/
│   │   └── kws.tflite                  # Trained INT8 model (download from CF R2 on first launch)
│   └── audio_samples/                  # Sample chant references (optional UX aid)
│
└── tools/training/                     # Offline Python pipeline (not shipped)
    ├── collect_samples.py
    ├── augment.py
    ├── extract_mfcc.py
    ├── train_kws.py
    └── quantize_export.py

================================================================================
SECTION 2: pubspec.yaml
================================================================================

name: mantra_counter
description: Offline mantra chanting counter. On-device KWS with TFLite.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: '>=3.19.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.4
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0
  tflite_flutter: ^0.10.4
  flutter_background_service: ^5.0.5
  flutter_local_notifications: ^17.2.3
  timezone: ^0.9.4
  permission_handler: ^11.3.1
  supabase_flutter: ^2.5.4
  connectivity_plus: ^6.0.3
  shared_preferences: ^2.2.3
  workmanager: ^0.5.2
  http: ^1.2.2
  crypto: ^3.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  drift_dev: ^2.18.0
  build_runner: ^2.4.12
  riverpod_generator: ^2.4.3

flutter:
  uses-material-design: true
  assets:
    - assets/models/
    - assets/audio_samples/

================================================================================
SECTION 3: CORE CONSTANTS (lib/core/constants.dart)
================================================================================

class AppConstants {
  // Audio
  static const int SAMPLE_RATE = 16000;
  static const int FRAME_SIZE = 512;           // ~32ms per frame at 16kHz
  static const int MFCC_COEFFICIENTS = 40;
  static const int MEL_FILTERS = 40;
  static const double PRE_EMPHASIS = 0.97;

  // KWS Model
  static const String MODEL_ASSET = 'assets/models/kws.tflite';
  static const double DEFAULT_CONFIDENCE_THRESHOLD = 0.82;
  static const int BACKGROUND_CLASS_INDEX = -1; // last class in model output

  // Refractory gate (ms) — overridden by per-user calibration
  static const int DEFAULT_REFRACTORY_MS = 800;
  static const int MIN_REFRACTORY_MS = 400;
  static const int MAX_REFRACTORY_MS = 3000;

  // VAD
  static const double DEFAULT_ENERGY_THRESHOLD = 0.01;  // tuned at calibration
  static const double ZCR_THRESHOLD = 0.30;

  // Sync
  static const String CF_WORKER_BASE_URL = 'https://mantra-api.YOUR_SUBDOMAIN.workers.dev';
  static const String CF_KV_CONFIG_URL = 'https://mantra-api.YOUR_SUBDOMAIN.workers.dev/config';
  static const Duration SYNC_RETRY_INTERVAL = Duration(minutes: 15);

  // Notifications
  static const int TARGET_REACHED_NOTIF_ID = 1001;
  static const int MILESTONE_NOTIF_ID = 1002;
  static const int REMINDER_NOTIF_ID = 1003;

  // Milestones
  static const List<int> MILESTONE_COUNTS = [108, 1008, 10008, 100008];
}

================================================================================
SECTION 4: DATABASE SCHEMA (lib/data/local/database.dart)
================================================================================

IMPLEMENT EXACTLY AS FOLLOWS using drift:

-- Tables:

1. MantraConfigTable
   - id: INTEGER PRIMARY KEY AUTOINCREMENT
   - name: TEXT NOT NULL                    -- "Om Namah Shivaya"
   - devanagari: TEXT NOT NULL             -- "ॐ नमः शिवाय"
   - romanized: TEXT NOT NULL             -- phonetic guide
   - targetCount: INTEGER NOT NULL DEFAULT 108
   - sensitivity: REAL NOT NULL DEFAULT 0.82
   - refractoryMs: INTEGER NOT NULL DEFAULT 800
   - isActive: BOOLEAN NOT NULL DEFAULT true
   - sortOrder: INTEGER NOT NULL DEFAULT 0

2. SessionsTable
   - id: TEXT PRIMARY KEY                  -- UUID
   - mantraId: INTEGER FK MantraConfigTable.id
   - startedAt: DATETIME NOT NULL
   - endedAt: DATETIME NULLABLE
   - targetCount: INTEGER NOT NULL
   - achievedCount: INTEGER NOT NULL DEFAULT 0
   - isSynced: BOOLEAN NOT NULL DEFAULT false

3. DetectionsTable
   - id: INTEGER PRIMARY KEY AUTOINCREMENT
   - sessionId: TEXT FK SessionsTable.id
   - detectedAt: DATETIME NOT NULL
   - confidence: REAL NOT NULL
   - engine: TEXT NOT NULL DEFAULT 'tflite'

4. DailyStatsTable
   - mantraId: INTEGER FK MantraConfigTable.id
   - date: TEXT NOT NULL                   -- ISO date "2026-03-02"
   - totalCount: INTEGER NOT NULL DEFAULT 0
   - sessionsCount: INTEGER NOT NULL DEFAULT 0
   - streakDays: INTEGER NOT NULL DEFAULT 0
   - PRIMARY KEY (mantraId, date)

5. PendingSyncsTable
   - id: INTEGER PRIMARY KEY AUTOINCREMENT
   - sessionId: TEXT NOT NULL
   - payload: TEXT NOT NULL               -- JSON blob
   - createdAt: DATETIME NOT NULL
   - retryCount: INTEGER NOT NULL DEFAULT 0
   - lastAttemptAt: DATETIME NULLABLE

// After defining tables, implement AppDatabase class with:
// - schemaVersion: 1
// - insertDefaultMantras() — seeds 5 common mantras on first install
// - Expose DAOs for each table

DEFAULT MANTRA SEEDS (call insertDefaultMantras() on first launch):
[
  { name: "Om Namah Shivaya",       devanagari: "ॐ नमः शिवाय",        romanized: "Om Na-mah Shi-vaa-ya",   targetCount: 108 },
  { name: "Om Mani Padme Hum",      devanagari: "ॐ मणि पद्मे हूँ",     romanized: "Om Ma-ni Pad-me Hum",    targetCount: 108 },
  { name: "Hare Krishna",           devanagari: "हरे कृष्ण",           romanized: "Ha-re Krish-na",         targetCount: 108 },
  { name: "Om Shanti",              devanagari: "ॐ शान्ति",            romanized: "Om Shan-ti",             targetCount: 108 },
  { name: "Om Gam Ganapataye",      devanagari: "ॐ गं गणपतये नमः",    romanized: "Om Gam Ga-na-pa-ta-ye",  targetCount: 108 }
]

================================================================================
SECTION 5: NATIVE AUDIO ENGINE
================================================================================

--- ANDROID: android/app/src/main/kotlin/com/mantra/audio/AudioEngine.kt ---

Implement:
1. Class AudioEngine(methodChannel: MethodChannel)
2. Uses AudioRecord with:
   - SAMPLE_RATE = 16000
   - CHANNEL_IN_MONO
   - ENCODING_PCM_16BIT
   - bufferSize = AudioRecord.getMinBufferSize(...) * 2
3. Runs in dedicated HandlerThread ("AudioEngineThread")
4. Per frame (512 samples):
   a. Call VadGate.isVoiceActive(frame) → if false, skip
   b. Extract MFCC (implement in-class):
      - Pre-emphasis: y[n] = x[n] - 0.97 * x[n-1]
      - Hamming window: w[n] = 0.54 - 0.46 * cos(2π*n/(N-1))
      - FFT (512-point) — use KissFFT or JTransforms (add to gradle)
      - 40 Mel filterbanks (300Hz to 8000Hz)
      - Log of filterbank energies
      - DCT to get 40 MFCC coefficients
      - Normalize: subtract calibration mean, divide by calibration std
      - Return FloatArray(40)
   c. Feed into TFLite interpreter → get output FloatArray(numMantras + 1)
   d. maxClass = argmax(output)
   e. If maxClass != backgroundIndex AND output[maxClass] > threshold:
      - Call methodChannel.invokeMethod("onDetection", mapOf("index" to maxClass, "confidence" to output[maxClass], "timestamp" to System.currentTimeMillis()))
5. Methods: start(mantras: List<Map>, threshold: Float), stop(), updateCalibration(energyThreshold: Float, mean: FloatArray, std: FloatArray)

--- ANDROID: VadGate.kt ---

object VadGate {
  var energyThreshold: Double = 0.01
  var zcrThreshold: Double = 0.30

  fun isVoiceActive(frame: ShortArray): Boolean {
    val energy = frame.map { it.toDouble().pow(2) }.average() / 32768.0.pow(2)
    val zcr = frame.zipWithNext().count { (a, b) -> (a >= 0) != (b >= 0) }.toDouble() / frame.size
    return energy > energyThreshold && zcr < zcrThreshold
  }
}

--- iOS: ios/Runner/audio/AudioEngine.swift ---

Implement equivalent using:
- AVAudioEngine with inputNode
- installTap(onBus:bufferSize:format:) for 512-sample callbacks
- Same MFCC pipeline (use vDSP from Accelerate framework for FFT — much faster than manual)
- AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
  — This ensures background audio works on iOS without silent track hack
- FlutterMethodChannel to send detection events to Dart

--- iOS: VadGate.swift ---

Implement same energy + ZCR logic in Swift using vDSP for efficiency.

================================================================================
SECTION 6: FLUTTER AUDIO CHANNEL (lib/audio/audio_channel.dart)
================================================================================

class AudioChannel {
  static const MethodChannel _channel = MethodChannel('com.mantra/audio');

  // Receives detection events from native as stream
  static Stream<DetectionEvent> get detectionStream =>
    EventChannel('com.mantra/detections').receiveBroadcastStream()
        .map((event) => DetectionEvent.fromMap(event));

  static Future<void> startEngine({
    required List<MantraConfig> mantras,
    required double threshold,
  }) async {
    await _channel.invokeMethod('start', {
      'mantras': mantras.map((m) => m.toMap()).toList(),
      'threshold': threshold,
    });
  }

  static Future<void> stopEngine() async {
    await _channel.invokeMethod('stop');
  }

  static Future<void> updateCalibration(CalibrationProfile profile) async {
    await _channel.invokeMethod('updateCalibration', profile.toMap());
  }
}

class DetectionEvent {
  final int mantraIndex;
  final double confidence;
  final DateTime timestamp;
  DetectionEvent.fromMap(Map<dynamic, dynamic> map) :
    mantraIndex = map['index'],
    confidence = map['confidence'],
    timestamp = DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
}

================================================================================
SECTION 7: DETECTION ISOLATE (lib/audio/detection_isolate.dart)
================================================================================

// Runs in separate Dart isolate — never touches UI thread
// Receives DetectionEvents, applies refractory gate, updates counter

class DetectionIsolate {
  final AppDatabase db;
  final SendPort uiSendPort;

  DateTime? _lastDetectionTime;
  int _sessionCount = 0;
  late String _sessionId;
  late MantraConfig _activeMantra;
  late int _targetCount;
  late int _refractoryMs;

  void initialize({
    required String sessionId,
    required MantraConfig mantra,
    required int targetCount,
    required int refractoryMs,
  }) {
    _sessionId = sessionId;
    _activeMantra = mantra;
    _targetCount = targetCount;
    _refractoryMs = refractoryMs;
    _sessionCount = 0;
    _lastDetectionTime = null;
  }

  void onDetectionEvent(DetectionEvent event) {
    // REFRACTORY GATE — prevents double-counting
    final now = DateTime.now();
    if (_lastDetectionTime != null) {
      final elapsed = now.difference(_lastDetectionTime!).inMilliseconds;
      if (elapsed < _refractoryMs) return; // REJECT
    }

    // CONFIDENCE CHECK
    if (event.confidence < AppConstants.DEFAULT_CONFIDENCE_THRESHOLD) return;

    // VALID DETECTION
    _lastDetectionTime = now;
    _sessionCount++;

    // Async DB write — non-blocking
    db.detectionDao.insert(DetectionEntry(
      sessionId: _sessionId,
      detectedAt: now,
      confidence: event.confidence,
      engine: 'tflite',
    ));

    // Notify UI isolate
    uiSendPort.send({'type': 'COUNT_UPDATE', 'count': _sessionCount});

    // Target check
    if (_sessionCount == _targetCount) {
      uiSendPort.send({'type': 'TARGET_REACHED', 'count': _sessionCount});
    }

    // Milestone check
    final lifetimeTotal = _getLifetimeTotalFromDB(); // async query
    if (AppConstants.MILESTONE_COUNTS.contains(lifetimeTotal)) {
      uiSendPort.send({'type': 'MILESTONE', 'count': lifetimeTotal});
    }
  }
}

================================================================================
SECTION 8: TFLite ENGINE WRAPPER (lib/audio/kws_engine.dart)
================================================================================

// Handles model loading, inference, and model update logic

class KWSEngine {
  late Interpreter _interpreter;
  List<Object> _inputStates = []; // for streaming state-external model
  bool _isLoaded = false;

  Future<void> loadModel() async {
    // First try local file (downloaded from CF R2)
    final appDir = await getApplicationDocumentsDirectory();
    final modelFile = File('${appDir.path}/models/kws.tflite');

    if (await modelFile.exists()) {
      _interpreter = await Interpreter.fromFile(modelFile);
    } else {
      // Fall back to bundled asset (older version)
      _interpreter = await Interpreter.fromAsset(AppConstants.MODEL_ASSET);
    }

    // Enable NNAPI (Android) / CoreML (iOS) hardware acceleration
    final options = InterpreterOptions()..useNnApiForAndroid = true;
    _isLoaded = true;
  }

  // Run inference on single MFCC frame
  // Returns List<double> — confidence per class
  List<double> infer(List<double> mfccFrame) {
    final input = [mfccFrame]; // shape [1, 40]
    final output = List.filled(/* numClasses */ 6, 0.0);
    _interpreter.run(input, output);
    return output;
  }

  // Check remote for model update
  // Downloads new model to appDir/models/kws_v{N}.tflite
  // Atomically replaces current on success
  Future<void> checkAndUpdateModel(String remoteVersion, String downloadUrl) async {
    // Implementation: HTTP GET downloadUrl → save to temp file
    // Verify SHA256 hash → atomically move to final path
    // Reload interpreter from new file
  }
}

================================================================================
SECTION 9: SESSION PROVIDER (lib/features/session/session_provider.dart)
================================================================================

// Riverpod provider managing active session state

@riverpod
class SessionNotifier extends _$SessionNotifier {
  @override
  SessionState build() => SessionState.idle();

  Future<void> startSession({
    required MantraConfig mantra,
    required int targetCount,
  }) async {
    final sessionId = const Uuid().v4();
    final db = ref.read(appDatabaseProvider);

    // Create session in SQLite
    await db.sessionDao.insert(SessionEntry(
      id: sessionId,
      mantraId: mantra.id,
      startedAt: DateTime.now(),
      targetCount: targetCount,
      achievedCount: 0,
      isSynced: false,
    ));

    // Start native audio engine
    await AudioChannel.startEngine(
      mantras: [mantra],
      threshold: mantra.sensitivity,
    );

    // Initialize detection isolate
    ref.read(detectionIsolateProvider).initialize(
      sessionId: sessionId,
      mantra: mantra,
      targetCount: targetCount,
      refractoryMs: mantra.refractoryMs,
    );

    state = SessionState.active(
      sessionId: sessionId,
      mantra: mantra,
      targetCount: targetCount,
      currentCount: 0,
    );
  }

  Future<void> endSession() async {
    if (state is! ActiveSession) return;
    final active = state as ActiveSession;

    await AudioChannel.stopEngine();

    final db = ref.read(appDatabaseProvider);
    await db.sessionDao.markEnded(
      sessionId: active.sessionId,
      endedAt: DateTime.now(),
      achievedCount: active.currentCount,
    );

    // Update daily stats
    await db.dailyStatsDao.upsert(
      mantraId: active.mantra.id,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      countToAdd: active.currentCount,
    );

    // Queue sync
    ref.read(syncServiceProvider).queueSync(active.sessionId);

    state = SessionState.completed(
      sessionId: active.sessionId,
      mantra: active.mantra,
      achievedCount: active.currentCount,
      targetCount: active.targetCount,
    );
  }

  void onCountUpdate(int count) {
    if (state is ActiveSession) {
      state = (state as ActiveSession).copyWith(currentCount: count);
    }
  }
}

================================================================================
SECTION 10: SESSION SCREEN (lib/features/session/session_screen.dart)
================================================================================

IMPLEMENT the following UI components:

1. MantraSelector
   - Dropdown/bottom sheet to pick active mantra
   - Shows devanagari + romanized text

2. RingProgressWidget
   - Custom painter drawing arc progress (0 to targetCount)
   - Animates smoothly on each count update (AnimatedBuilder)
   - Shows current count in center (large font)
   - Shows target count below
   - Color transitions: deepPurple → gold when near target

3. SessionControls
   - START button → calls sessionProvider.startSession()
   - PAUSE/RESUME button → calls AudioChannel.pauseEngine() / resumeEngine()
   - STOP button → calls sessionProvider.endSession()

4. CounterDisplay
   - Shows current count vs target (e.g., "54 / 108")
   - Animates count increment with bounce effect

5. LiveFeedback
   - Small waveform or pulse animation when voice is detected
   - Confidence bar (small, below ring) — shows last detection confidence

ON TARGET_REACHED:
- Full-screen celebration overlay (confetti or lotus animation)
- Haptic feedback (HapticFeedback.heavyImpact())
- Show local notification

================================================================================
SECTION 11: CALIBRATION SCREEN (lib/features/calibration/calibration_screen.dart)
================================================================================

IMPLEMENT calibration flow (runs on first launch AND accessible from settings):

Step 1 — Microphone check
  - Request mic permission
  - Show live audio level meter (bar graph using amplitude)
  - Confirm mic is working

Step 2 — Voice sample recording (per mantra, 3 chants each)
  For each active mantra:
    - Show mantra text (devanagari + romanized)
    - Prompt: "Chant this 3 times naturally"
    - Record 3 chant cycles
    - Measure:
      a. Mean energy amplitude → energyThreshold = 0.6 * meanEnergy
      b. Inter-chant gap (ms) → refractoryMs = 0.8 * meanGap
      c. Verify TFLite model detects correctly for this voice

Step 3 — Save calibration profile
  - Save to SQLite profiles table
  - Save to SharedPreferences (for quick access without DB query)
  - Send to AudioChannel.updateCalibration()
  - Sync calibration profile to Supabase (background)

Step 4 — Confirmation
  - Show summary: "Your voice calibrated. Energy: X, Gap: Xms"
  - Proceed to Dashboard

================================================================================
SECTION 12: DASHBOARD (lib/features/dashboard/dashboard_screen.dart)
================================================================================

IMPLEMENT using drift reactive streams:

1. TodayCard
   - Today's total count per mantra
   - Progress toward daily target
   - Reactive stream: db.dailyStatsDao.watchToday()

2. StreakCard
   - Current streak (consecutive days with completed target)
   - Best streak ever
   - Flame icon, animated when streak > 7 days

3. HeatmapCalendar
   - GitHub-style contribution heatmap (last 90 days)
   - Color intensity by count/day
   - Use fl_chart or custom CustomPainter

4. PerMantraStats
   - List of each mantra:
     - Lifetime count
     - This week count
     - Best session count
     - Average pace (chants/minute)

5. RecentSessions
   - Last 10 sessions with mantra, date, count vs target, duration

ALL queries MUST use drift reactive streams (watchX) — not one-time queries.
Dashboard must update in real-time without manual refresh.

================================================================================
SECTION 13: SUPABASE AUTH + SYNC (lib/data/remote/supabase_service.dart)
================================================================================

Supabase Setup:
- Project URL: YOUR_SUPABASE_URL
- Anon Key: YOUR_SUPABASE_ANON_KEY
- Initialize in main.dart before runApp()

Auth methods to implement:
  - signUp(email, password) → creates user + profile row
  - signIn(email, password)
  - signInWithGoogle() → Google OAuth
  - signInWithApple() → Apple OAuth (iOS)
  - signOut()
  - getCurrentUser() → User?
  - get isAuthenticated → bool

Supabase PostgreSQL Schema (run in Supabase SQL editor):

  CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    display_name TEXT,
    energy_threshold FLOAT DEFAULT 0.01,
    refractory_ms INT DEFAULT 800,
    preferred_reminder_time TIME DEFAULT '06:00',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
  );

  CREATE TABLE sessions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    mantra_name TEXT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    target_count INT NOT NULL,
    achieved_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
  );

  CREATE TABLE daily_stats (
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    mantra_name TEXT NOT NULL,
    date DATE NOT NULL,
    total_count INT NOT NULL DEFAULT 0,
    sessions_count INT NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, mantra_name, date)
  );

  -- Row Level Security
  ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
  ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
  ALTER TABLE daily_stats ENABLE ROW LEVEL SECURITY;

  CREATE POLICY "Users own their data" ON profiles FOR ALL USING (auth.uid() = id);
  CREATE POLICY "Users own their sessions" ON sessions FOR ALL USING (auth.uid() = user_id);
  CREATE POLICY "Users own their stats" ON daily_stats FOR ALL USING (auth.uid() = user_id);

================================================================================
SECTION 14: SYNC SERVICE (lib/data/remote/sync_service.dart)
================================================================================

IMPLEMENT offline-first sync queue:

class SyncService {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  // Called after session ends — adds to pending_syncs queue
  Future<void> queueSync(String sessionId) async {
    final session = await _db.sessionDao.getById(sessionId);
    final payload = jsonEncode(session.toSyncMap());
    await _db.pendingSyncsDao.insert(
      PendingSyncEntry(sessionId: sessionId, payload: payload, createdAt: DateTime.now())
    );
    _tryProcessQueue(); // fire and forget
  }

  // Process all pending syncs — called on connectivity restore + app foreground
  Future<void> _tryProcessQueue() async {
    final pending = await _db.pendingSyncsDao.getPending(maxRetries: 3);
    for (final item in pending) {
      try {
        final cfWorkerUrl = '${AppConstants.CF_WORKER_BASE_URL}/sync/session';
        final token = _supabase.auth.currentSession?.accessToken;
        if (token == null) continue;

        final response = await http.post(
          Uri.parse(cfWorkerUrl),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: item.payload,
        );

        if (response.statusCode == 200) {
          await _db.pendingSyncsDao.markSynced(item.id);
          await _db.sessionDao.markSynced(item.sessionId);
        } else {
          await _db.pendingSyncsDao.incrementRetry(item.id);
        }
      } catch (_) {
        await _db.pendingSyncsDao.incrementRetry(item.id);
      }
    }
  }
}

// Register Workmanager periodic task for background sync
// frequency: Duration(minutes: 15)
// Only runs if pending syncs exist + connectivity available

================================================================================
SECTION 15: CLOUDFLARE WORKER (deploy separately)
================================================================================

// workers/mantra-api/index.ts

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // Rate limiting via CF
    const ip = request.headers.get('CF-Connecting-IP');

    // CORS
    if (request.method === 'OPTIONS') return new Response(null, {
      headers: { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Methods': 'POST, GET' }
    });

    // Config endpoint — served from KV
    if (url.pathname === '/config') {
      const config = await env.MANTRA_KV.get('app_config', 'json');
      return Response.json(config, {
        headers: { 'Cache-Control': 'public, max-age=3600' }
      });
    }

    // Session sync endpoint
    if (url.pathname === '/sync/session' && request.method === 'POST') {
      // Validate Supabase JWT
      const authHeader = request.headers.get('Authorization');
      if (!authHeader?.startsWith('Bearer ')) return new Response('Unauthorized', { status: 401 });

      const token = authHeader.split(' ')[1];
      const user = await verifySupabaseJWT(token, env.SUPABASE_JWT_SECRET);
      if (!user) return new Response('Unauthorized', { status: 401 });

      const body = await request.json();

      // Forward to Supabase PostgreSQL
      const result = await insertSessionToSupabase(user.sub, body, env);
      return Response.json({ success: true });
    }

    return new Response('Not Found', { status: 404 });
  },

  // Daily cron — send reminders to users with no session today
  async scheduled(event: ScheduledEvent, env: Env): Promise<void> {
    const usersToRemind = await getUsersWithoutTodaySession(env);
    for (const user of usersToRemind) {
      await sendFCMPush(user.fcm_token, {
        title: 'Time for your mantra 🙏',
        body: `Your 108 chants await today.`
      }, env.FCM_SERVER_KEY);
    }
  }
}

// Wrangler config (wrangler.toml):
// name = "mantra-api"
// main = "src/index.ts"
// kv_namespaces = [{ binding = "MANTRA_KV", id = "YOUR_KV_ID" }]
// [triggers] crons = ["0 0 * * *"]   # daily at midnight UTC

================================================================================
SECTION 16: NOTIFICATIONS (lib/notifications/notification_service.dart)
================================================================================

class NotificationService {
  static Future<void> init() async {
    // Initialize flutter_local_notifications
    // Request permission (iOS)
    // Set up notification channels (Android)
  }

  static Future<void> showTargetReached({
    required String mantraName,
    required int count,
  }) async {
    // Show immediate notification
    // title: "Target Reached! 🙏"
    // body: "$mantraName — $count chants completed"
    // Play subtle chime sound
    // Channel: high importance, sound, vibration
  }

  static Future<void> showMilestone(int lifetimeCount) async {
    // title: "Milestone! ✨"
    // body: "$lifetimeCount lifetime chants across all mantras"
  }

  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // Cancel existing reminder
    // Schedule daily at user's preferred time
    // Only if no session recorded today (check SQLite before firing)
  }
}

================================================================================
SECTION 17: TRAINING PIPELINE (tools/training/ — Python, dev-only)
================================================================================

--- collect_samples.py ---
Records N samples per mantra from microphone
Usage: python collect_samples.py --mantra "Om Namah Shivaya" --samples 500
Output: data/raw/{mantra_slug}/{001..500}.wav

--- augment.py ---
For each .wav file, generates augmented variants:
  - Add white noise (SNR: 5dB, 10dB, 20dB)
  - Pitch shift: -2, -1, +1, +2 semitones (use librosa)
  - Speed: 0.8x, 0.9x, 1.1x, 1.2x (use librosa)
  - Room impulse response convolution (use pyroomacoustics)
  - Resulting: ~10 augmented variants per original = 5000 samples per mantra
Output: data/augmented/{mantra_slug}/

--- train_kws.py ---
Model architecture:
  Input: MFCC [batch, 40] per frame
  Backbone: MobileNetV3-Small (adapted for 1D audio — use Conv1D variant)
  Head: Multi-Head Attention (2 heads, 64 dim) + GlobalAveragePooling + Dense
  Output: Softmax over N+1 classes (N mantras + background)

Training:
  - lr: 1e-3, batch: 64, epochs: 50
  - ReduceLROnPlateau, EarlyStopping
  - Class weights for background (to reduce FAR)
  - Target validation accuracy: >96%

--- quantize_export.py ---
  converter = tf.lite.TFLiteConverter.from_keras_model(model)
  converter.optimizations = [tf.lite.Optimize.DEFAULT]
  converter.target_spec.supported_types = [tf.int8]
  converter.representative_dataset = representative_data_gen
  tflite_model = converter.convert()
  with open('kws.tflite', 'wb') as f:
      f.write(tflite_model)
  # Target size: < 400KB

================================================================================
SECTION 18: MAIN.DART BOOTSTRAP
================================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase init
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Timezone init (for scheduled notifications)
  await initializeLocalTimeZone();

  // Notification service init
  await NotificationService.init();

  // Workmanager init (background sync)
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    'mantra-sync',
    'syncPendingSessions',
    frequency: Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  // Background service (audio engine persistence)
  await FlutterBackgroundService.configure(...);

  runApp(ProviderScope(child: MantraApp()));
}

// App entry checks:
// 1. If no Supabase session → show AuthScreen
// 2. If Supabase session but no calibration → show CalibrationScreen
// 3. Otherwise → show DashboardScreen

================================================================================
SECTION 19: APP SIZE OPTIMIZATION CHECKLIST
================================================================================

BUILD COMMANDS:
  Android: flutter build appbundle --release --obfuscate --split-debug-info=build/debug/
  iOS:     flutter build ipa --release --obfuscate --split-debug-info=build/debug/

ANDROID gradle optimizations (android/app/build.gradle):
  android {
    buildTypes {
      release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
      }
    }
    splits {
      abi { enable true; reset(); include "arm64-v8a", "armeabi-v7a"; universalApk false }
    }
  }

MODEL DELIVERY:
  - Do NOT bundle kws.tflite in initial APK
  - Download from Cloudflare R2 on first launch
  - R2 bucket: mantra-models / kws_v1.tflite (INT8, ~300-400KB)
  - Verify SHA256 hash before loading
  - Cache permanently in getApplicationDocumentsDirectory()

ASSETS:
  - All icons as SVG (not PNG) — use flutter_svg
  - Any raster images as WebP
  - Remove all unused flutter/material icon glyphs via flutter pub run build_runner

EXPECTED SIZES:
  Play Store displayed: ~4-5MB (post-AAB optimization)
  First-run model download: ~350KB (background, seamless)
  iOS App Store: ~6-8MB

================================================================================
SECTION 20: EDGE CASE HANDLING CHECKLIST
================================================================================

Cursor: Ensure ALL of these are handled in detection_isolate.dart:

1. PAUSE MID-CHANT
   → VAD silence window: 1500ms threshold
   → Refractory clock does NOT reset on silence
   → Next complete utterance resumes counting normally

2. LOW/WHISPERED VOICE
   → VAD energy threshold set to 60% of calibrated mean (not 100%)
   → Allows softer chanting after initial calibration
   → TFLite model still fires if phoneme pattern matches

3. FAST CHANTING (< refractory gap)
   → First chant: PASS → count++
   → Subsequent within refractory window: REJECT silently
   → App counts at user's natural sustainable pace

4. BACKGROUND NOISE (TV, people talking)
   → ZCR gate in VAD (TV speech has high ZCR distinct from mantra)
   → Background class in KWS model absorbs ambient speech
   → Confidence threshold 0.82 prevents false positives

5. APP BACKGROUNDED
   → Android: foreground service keeps audio alive (notification shown)
   → iOS: AVAudioSession category .record keeps mic active
   → Counting continues uninterrupted

6. DEVICE LOCK SCREEN
   → Same as backgrounded — works on both platforms

7. MULTIPLE MANTRAS
   → All mantra keyword classes loaded in single TFLite model
   → argmax over output gives mantraIndex (not just boolean detection)
   → Each mantra has its own session/target

8. NETWORK LOSS
   → 100% local counting — no impact
   → Sync queue in SQLite, retried on reconnect

9. SESSION CRASH / FORCE KILL
   → Session row in SQLite has startedAt but no endedAt
   → On next launch: detect orphaned sessions, mark endedAt = lastDetection
   → Partial counts preserved, not lost

10. FIRST LAUNCH (no calibration)
    → Block session start until calibration complete
    → Show clear CTA on dashboard

================================================================================
SECTION 21: ENVIRONMENT VARIABLES / SECRETS
================================================================================

Create lib/core/env.dart (git-ignored):

class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const cfWorkerBaseUrl = String.fromEnvironment('CF_WORKER_URL');
  static const r2ModelBaseUrl = String.fromEnvironment('R2_MODEL_URL');
}

Build with:
  flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx ...

Cloudflare Worker secrets (wrangler secret put):
  SUPABASE_JWT_SECRET
  FCM_SERVER_KEY
  SUPABASE_SERVICE_KEY

================================================================================
SECTION 22: IMPLEMENTATION ORDER FOR CURSOR
================================================================================

Implement in EXACTLY this order to avoid dependency issues:

Phase 1 — Foundation
  1. pubspec.yaml
  2. lib/core/constants.dart
  3. lib/data/local/database.dart → run build_runner
  4. lib/main.dart (bootstrap only, placeholder screens)

Phase 2 — Native Audio
  5. android/audio/VadGate.kt
  6. android/audio/AudioEngine.kt
  7. ios/audio/VadGate.swift
  8. ios/audio/AudioEngine.swift
  9. lib/audio/audio_channel.dart

Phase 3 — ML Engine
  10. lib/audio/kws_engine.dart
  11. lib/audio/detection_isolate.dart

Phase 4 — Session Flow
  12. lib/features/session/session_provider.dart
  13. lib/features/session/session_screen.dart (UI)
  14. lib/notifications/notification_service.dart

Phase 5 — Dashboard
  15. lib/features/dashboard/dashboard_provider.dart
  16. lib/features/dashboard/dashboard_screen.dart

Phase 6 — Calibration
  17. lib/features/calibration/calibration_screen.dart

Phase 7 — Auth + Sync
  18. lib/data/remote/supabase_service.dart
  19. lib/data/remote/sync_service.dart
  20. Cloudflare Worker (deploy separately with wrangler)

Phase 8 — Polish
  21. lib/features/settings/settings_screen.dart
  22. lib/core/router.dart (go_router setup)
  23. Size optimizations (build.gradle, AAB)

================================================================================
END OF IMPLEMENTATION GUIDE
================================================================================
