import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';
import '../../audio/audio_channel.dart';
import '../../audio/calibration_profile.dart';
import '../../audio/detection_isolate.dart';
import '../../audio/ensemble_detector.dart';
import '../../audio/signal_processors.dart' show SignalScore;
import '../../audio/stt_detection_service.dart';

// ──────────────────────────────────────────
// Session state
// ──────────────────────────────────────────

sealed class SessionState {
  const SessionState();
}

class SessionIdle extends SessionState {
  const SessionIdle();
}

class SessionActive extends SessionState {
  final String sessionId;
  final MantraConfigTableData mantra;
  final int targetCount;
  final int currentCount;
  final int totalEvaluated;
  final int totalRejected;
  final bool isPaused;
  final String recognizedText;
  final bool isSttMode;

  const SessionActive({
    required this.sessionId,
    required this.mantra,
    required this.targetCount,
    required this.currentCount,
    this.totalEvaluated = 0,
    this.totalRejected = 0,
    this.isPaused = false,
    this.recognizedText = '',
    this.isSttMode = false,
  });

  SessionActive copyWith({
    int? currentCount,
    int? totalEvaluated,
    int? totalRejected,
    bool? isPaused,
    String? recognizedText,
  }) =>
      SessionActive(
        sessionId: sessionId,
        mantra: mantra,
        targetCount: targetCount,
        currentCount: currentCount ?? this.currentCount,
        totalEvaluated: totalEvaluated ?? this.totalEvaluated,
        totalRejected: totalRejected ?? this.totalRejected,
        isPaused: isPaused ?? this.isPaused,
        recognizedText: recognizedText ?? this.recognizedText,
        isSttMode: isSttMode,
      );

  /// Acceptance rate: accepted / evaluated.
  double get acceptanceRate =>
      totalEvaluated > 0 ? currentCount / totalEvaluated : 0.0;
}

class SessionCompleted extends SessionState {
  final String sessionId;
  final MantraConfigTableData mantra;
  final int achievedCount;
  final int targetCount;

  const SessionCompleted({
    required this.sessionId,
    required this.mantra,
    required this.achievedCount,
    required this.targetCount,
  });
}

// ──────────────────────────────────────────
// Providers
// ──────────────────────────────────────────

final detectionProcessorProvider = Provider<DetectionProcessor>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final processor = DetectionProcessor(db: db);
  ref.onDispose(() => processor.dispose());
  return processor;
});

// ──────────────────────────────────────────
// Session notifier
// ──────────────────────────────────────────

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref);
});

class SessionNotifier extends StateNotifier<SessionState> {
  final Ref _ref;
  StreamSubscription? _segmentSub;
  StreamSubscription? _messageSub;
  StreamSubscription? _sttSub;
  EnsembleDetector? _ensembleDetector;
  EnsembleCalibrationProfile? _calibration;
  SttDetectionService? _sttService;
  bool _useSimpleMode = false;
  bool _useSttMode = false;
  int _minSegmentDurationMs = 500;
  int _maxSegmentDurationMs = 10000;

  SessionNotifier(this._ref) : super(const SessionIdle());

  /// Load calibration profile from SharedPreferences.
  Future<EnsembleCalibrationProfile?> _loadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.calibrationProfileKey);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return EnsembleCalibrationProfile.fromJson(map);
    } catch (e) {
      debugPrint('Failed to load calibration: $e');
      return null;
    }
  }

  Future<void> startSession({
    required MantraConfigTableData mantra,
    required int targetCount,
    int initialCount = 0,
    String? existingSessionId,
  }) async {
    final sessionId = existingSessionId ?? const Uuid().v4();
    final db = _ref.read(appDatabaseProvider);

    // Create session in SQLite (only for new sessions)
    if (existingSessionId == null) {
      await db.insertSession(SessionsTableCompanion.insert(
        id: sessionId,
        mantraId: mantra.id,
        startedAt: DateTime.now(),
        targetCount: targetCount,
        endedAt: const Value.absent(),
        isSynced: const Value(false),
        achievedCount: Value(initialCount),
      ));
    }

    // Load calibration profile
    _calibration = await _loadCalibration();
    final hasValidCalibration = _calibration != null &&
        _calibration!.isValid &&
        _calibration!.templates.isNotEmpty;

    // ── Detection mode selection ──
    // Priority: 1. STT word matching (default)
    //           2. Ensemble (if calibrated)
    //           3. Simple energy (fallback)

    // Try STT first (best accuracy — actually matches spoken words)
    _sttService = SttDetectionService();
    final sttAvailable = await _sttService!.initialize();

    if (sttAvailable) {
      _useSttMode = true;
      _useSimpleMode = false;
      debugPrint('Using STT word-matching mode');
    } else if (hasValidCalibration) {
      _useSttMode = false;
      _useSimpleMode = false;
      _ensembleDetector = EnsembleDetector(calibration: _calibration!);
      debugPrint('STT unavailable — using ensemble mode');
    } else {
      _useSttMode = false;
      _useSimpleMode = true;
      _minSegmentDurationMs = (mantra.refractoryMs * 0.6).round().clamp(400, 2000);
      _maxSegmentDurationMs = (mantra.refractoryMs * 6).round().clamp(3000, 15000);
      debugPrint('STT unavailable, no calibration — using simple energy mode');
    }

    // Create minimal calibration for native engine (needed for non-STT modes)
    if (!_useSttMode && _calibration == null) {
      _calibration = EnsembleCalibrationProfile(
        templates: [],
        energyThreshold: AppConstants.defaultEnergyThreshold,
        meanDurationMs: 2000,
        stdDurationMs: 500,
        meanGapMs: 1000,
        refractoryMs: mantra.refractoryMs,
        globalMeanMfcc: Float64List.fromList(List.filled(13, 0.0)),
        mfccDim: 13,
        createdAt: DateTime.now(),
      );
    }

    // Initialize detection processor (counting + DB)
    final processor = _ref.read(detectionProcessorProvider);
    processor.initialize(
      sessionId: sessionId,
      mantraId: mantra.id,
      targetCount: targetCount,
      initialCount: initialCount,
    );

    // Listen for count updates from processor
    _messageSub = processor.messages.listen((msg) {
      switch (msg) {
        case CountUpdate(:final count):
          if (state is SessionActive) {
            state = (state as SessionActive).copyWith(
              currentCount: count,
              totalEvaluated: _ensembleDetector?.totalEvaluated ?? 0,
              totalRejected: _ensembleDetector?.totalRejected ?? 0,
            );
          }
        case TargetReached():
          break;
        case MilestoneReached():
          break;
        case DetectionDiagnostic():
          break;
      }
    });

    // ── Start detection ──
    if (_useSttMode) {
      // STT mode: use speech_to_text for recognition + word matching.
      // Do NOT start native AudioEngine — it conflicts with SpeechRecognizer mic.
      _sttService!.configure(
        devanagari: mantra.devanagari,
        romanized: mantra.romanized,
        refractoryMs: mantra.refractoryMs,
      );

      _sttSub = _sttService!.events.listen((event) {
        switch (event) {
          case SttMantraDetected(:final matchResult):
            debugPrint('STT mantra detected: ${matchResult.confidence}');
            final result = EnsembleResult(
              ensembleScore: matchResult.confidence,
              verdict: DetectionVerdict.accepted,
              signals: const <SignalScore>[],
              timestamp: DateTime.now(),
              durationMs: 0,
            );
            processor.onAcceptedDetection(result);
          case SttRecognizedText(:final text, isFinal: _):
            // Update recognized text in UI state
            if (state is SessionActive) {
              state = (state as SessionActive).copyWith(
                recognizedText: text,
              );
            }
          case SttStatusChanged():
            break;
          case SttErrorEvent(:final message):
            debugPrint('STT error in session: $message');
        }
      });

      await _sttService!.startListening();
    } else {
      // Non-STT modes: use native AudioEngine
      await AudioChannel.updateEnsembleCalibration(_calibration!);
      await AudioChannel.startEngine(
        mantras: [
          {
            'name': mantra.name,
            'id': mantra.id,
            'sensitivity': mantra.sensitivity,
          }
        ],
        threshold: mantra.sensitivity,
        mode: 'ensemble',
      );

      if (_useSimpleMode) {
        _segmentSub = AudioChannel.rawEventStream.listen(
          (event) {
            final confidence = (event['confidence'] as num?)?.toDouble() ?? 0.0;
            final durationMs = (event['durationMs'] as num?)?.toInt() ?? 0;
            final timestamp = (event['timestamp'] as num?)?.toInt() ??
                DateTime.now().millisecondsSinceEpoch;

            if (durationMs < _minSegmentDurationMs || durationMs > _maxSegmentDurationMs) {
              return;
            }

            final result = EnsembleResult(
              ensembleScore: confidence,
              verdict: DetectionVerdict.accepted,
              signals: const <SignalScore>[],
              timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
              durationMs: durationMs,
            );
            processor.onAcceptedDetection(result);
          },
          onError: (e) => debugPrint('Raw event stream error: $e'),
        );
      } else {
        _segmentSub = AudioChannel.segmentStream.listen(
          (segment) {
            if (_ensembleDetector == null) return;
            final result = _ensembleDetector!.evaluate(segment);
            if (result.isAccepted) {
              processor.onAcceptedDetection(result);
            }
          },
          onError: (e) => debugPrint('Segment stream error: $e'),
        );
      }
    }

    state = SessionActive(
      sessionId: sessionId,
      mantra: mantra,
      targetCount: targetCount,
      currentCount: initialCount,
      isSttMode: _useSttMode,
    );
  }

  /// Pause audio detection (keeps session alive, stops mic).
  Future<void> pauseSession() async {
    if (state is! SessionActive) return;
    if (_useSttMode) {
      await _sttService?.pauseListening();
    } else {
      _segmentSub?.cancel();
      _segmentSub = null;
      await AudioChannel.stopEngine();
    }
    state = (state as SessionActive).copyWith(isPaused: true);
    debugPrint('Session paused');
  }

  /// Resume audio detection after pause.
  Future<void> resumeSession() async {
    final current = state;
    if (current is! SessionActive || !current.isPaused) return;

    if (_useSttMode) {
      await _sttService?.resumeListening();
    } else {
      // Restart native engine
      await AudioChannel.startEngine(
        mantras: [
          {
            'name': current.mantra.name,
            'id': current.mantra.id,
            'sensitivity': current.mantra.sensitivity,
          }
        ],
        threshold: current.mantra.sensitivity,
        mode: 'ensemble',
      );

      // Re-subscribe to segment stream
      final processor = _ref.read(detectionProcessorProvider);
      if (_useSimpleMode) {
        _segmentSub = AudioChannel.rawEventStream.listen(
          (event) {
            final confidence = (event['confidence'] as num?)?.toDouble() ?? 0.0;
            final durationMs = (event['durationMs'] as num?)?.toInt() ?? 0;
            final timestamp = (event['timestamp'] as num?)?.toInt() ??
                DateTime.now().millisecondsSinceEpoch;
            if (durationMs < _minSegmentDurationMs || durationMs > _maxSegmentDurationMs) {
              return;
            }
            final result = EnsembleResult(
              ensembleScore: confidence,
              verdict: DetectionVerdict.accepted,
              signals: const <SignalScore>[],
              timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
              durationMs: durationMs,
            );
            processor.onAcceptedDetection(result);
          },
          onError: (e) => debugPrint('Raw event stream error: $e'),
        );
      } else {
        _segmentSub = AudioChannel.segmentStream.listen(
          (segment) {
            if (_ensembleDetector == null) return;
            final result = _ensembleDetector!.evaluate(segment);
            if (result.isAccepted) {
              processor.onAcceptedDetection(result);
            }
          },
          onError: (e) => debugPrint('Segment stream error: $e'),
        );
      }
    }

    state = current.copyWith(isPaused: false);
    debugPrint('Session resumed');
  }

  /// Manually increment count by 1.
  void incrementCount() {
    final current = state;
    if (current is! SessionActive) return;
    final processor = _ref.read(detectionProcessorProvider);
    final now = DateTime.now();
    final result = EnsembleResult(
      ensembleScore: 1.0,
      verdict: DetectionVerdict.accepted,
      signals: const [SignalScore(name: 'manual', score: 1.0)],
      timestamp: now,
      durationMs: 0,
    );
    processor.onAcceptedDetection(result);
  }

  /// Manually decrement count by 1 (min 0).
  void decrementCount() {
    final current = state;
    if (current is! SessionActive) return;
    if (current.currentCount <= 0) return;
    final processor = _ref.read(detectionProcessorProvider);
    processor.adjustCount(current.currentCount - 1);
    state = current.copyWith(currentCount: current.currentCount - 1);
  }

  Future<void> endSession() async {
    final current = state;
    if (current is! SessionActive) return;

    // Stop listening first
    _segmentSub?.cancel();
    _segmentSub = null;
    _messageSub?.cancel();
    _messageSub = null;
    _sttSub?.cancel();
    _sttSub = null;

    // Stop STT or native engine
    if (_useSttMode) {
      await _sttService?.stopListening();
      _sttService?.dispose();
      _sttService = null;
    } else {
      await AudioChannel.stopEngine();
    }

    // Clean up ensemble detector
    _ensembleDetector?.dispose();
    _ensembleDetector = null;

    final db = _ref.read(appDatabaseProvider);
    final now = DateTime.now();

    await db.markSessionEnded(
      current.sessionId,
      now,
      current.currentCount,
    );

    // Update daily stats
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await db.upsertDailyStat(
      mantraId: current.mantra.id,
      date: today,
      countToAdd: current.currentCount,
    );

    state = SessionCompleted(
      sessionId: current.sessionId,
      mantra: current.mantra,
      achievedCount: current.currentCount,
      targetCount: current.targetCount,
    );

    debugPrint(
      'Session ended: ${current.currentCount}/${current.targetCount} '
      '(mode: ${_useSttMode ? "stt" : _useSimpleMode ? "simple" : "ensemble"})',
    );
  }

  /// Restart a completed session with the same mantra (count reset to 0).
  Future<void> restartSession() async {
    final current = state;
    MantraConfigTableData? mantra;
    int target = 108;

    if (current is SessionCompleted) {
      mantra = current.mantra;
      target = current.targetCount;
    } else if (current is SessionActive) {
      // End current first
      await endSession();
      mantra = current.mantra;
      target = current.targetCount;
    }

    if (mantra == null) return;
    state = const SessionIdle();
    await startSession(mantra: mantra, targetCount: target);
  }

  /// Continue a completed session (keep the count, resume listening).
  Future<void> continueSession() async {
    final current = state;
    if (current is! SessionCompleted) return;
    state = const SessionIdle();
    await startSession(
      mantra: current.mantra,
      targetCount: current.targetCount,
      initialCount: current.achievedCount,
      existingSessionId: current.sessionId,
    );
  }

  /// Reset count to 0 within the active session.
  void resetCount() {
    final current = state;
    if (current is! SessionActive) return;
    final processor = _ref.read(detectionProcessorProvider);
    processor.adjustCount(0);
    state = current.copyWith(currentCount: 0);
  }

  /// Force session to idle state (e.g. when navigating to a different mantra).
  Future<void> forceIdle() async {
    final current = state;
    if (current is SessionActive) {
      await endSession();
    }
    state = const SessionIdle();
  }

  /// Reset rhythm lock (e.g. after user takes a deliberate pause).
  void resetRhythm() => _ensembleDetector?.resetRhythm();

  void onCountUpdate(int count) {
    if (state is SessionActive) {
      state = (state as SessionActive).copyWith(currentCount: count);
    }
  }

  @override
  void dispose() {
    _segmentSub?.cancel();
    _messageSub?.cancel();
    _sttSub?.cancel();
    _ensembleDetector?.dispose();
    _sttService?.dispose();
    super.dispose();
  }
}
