import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/providers.dart';
import '../../core/sarvam_config.dart';
import '../../data/local/database.dart';
import '../../audio/audio_channel.dart';
import '../../audio/detection_isolate.dart';
import '../../audio/hybrid_detection.dart';
import '../../audio/mantra_matcher.dart';

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
  final int asrVerifiedCount; // Detections verified by Sarvam ASR
  final bool isAsrEnabled;

  const SessionActive({
    required this.sessionId,
    required this.mantra,
    required this.targetCount,
    required this.currentCount,
    this.asrVerifiedCount = 0,
    this.isAsrEnabled = false,
  });

  SessionActive copyWith({int? currentCount, int? asrVerifiedCount}) =>
      SessionActive(
        sessionId: sessionId,
        mantra: mantra,
        targetCount: targetCount,
        currentCount: currentCount ?? this.currentCount,
        asrVerifiedCount: asrVerifiedCount ?? this.asrVerifiedCount,
        isAsrEnabled: isAsrEnabled,
      );

  double get asrAccuracy =>
      currentCount > 0 ? asrVerifiedCount / currentCount : 0.0;
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
// Detection processor provider
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
  StreamSubscription? _detectionSub;
  StreamSubscription? _messageSub;
  HybridDetector? _hybridDetector;
  Timer? _asrFlushTimer;
  int _asrVerifiedCount = 0;

  SessionNotifier(this._ref) : super(const SessionIdle());

  Future<void> startSession({
    required MantraConfigTableData mantra,
    required int targetCount,
  }) async {
    final sessionId = const Uuid().v4();
    final db = _ref.read(appDatabaseProvider);
    final sarvamConfig = _ref.read(sarvamConfigProvider);

    // Create session in SQLite
    await db.insertSession(SessionsTableCompanion.insert(
      id: sessionId,
      mantraId: mantra.id,
      startedAt: DateTime.now(),
      targetCount: targetCount,
      endedAt: const Value.absent(),
      isSynced: const Value(false),
      achievedCount: const Value(0),
    ));

    // Initialize detection processor
    final processor = _ref.read(detectionProcessorProvider);
    processor.initialize(
      sessionId: sessionId,
      mantraId: mantra.id,
      targetCount: targetCount,
      refractoryMs: mantra.refractoryMs,
      confidenceThreshold: mantra.sensitivity,
    );

    // Initialize hybrid detector if Sarvam is configured
    _asrVerifiedCount = 0;
    if (sarvamConfig.isReady) {
      _hybridDetector = HybridDetector(
        sarvamConfig: sarvamConfig,
        mantras: [
          {
            'name': mantra.name,
            'devanagari': mantra.devanagari,
            'romanized': mantra.romanized,
          }
        ],
      );

      // Start native audio buffering for ASR
      await AudioBufferManager.startBuffering();

      // Periodically flush buffer to ASR for verification
      _asrFlushTimer =
          Timer.periodic(const Duration(seconds: 5), (_) => _flushAndVerify());
    }

    // Listen for count updates from processor
    _messageSub = processor.messages.listen((msg) {
      switch (msg) {
        case CountUpdate(:final count):
          if (state is SessionActive) {
            state = (state as SessionActive)
                .copyWith(currentCount: count, asrVerifiedCount: _asrVerifiedCount);
          }
        case TargetReached():
          // Will be handled by session screen for UI celebration
          break;
        case MilestoneReached():
          // Will be handled by notification service
          break;
      }
    });

    // Listen for native detection events and forward to processor
    _detectionSub = AudioChannel.detectionStream.listen((event) {
      processor.onDetectionEvent(
        mantraIndex: event.mantraIndex,
        confidence: event.confidence,
        timestamp: event.timestamp,
      );
    });

    // Start native audio engine
    await AudioChannel.startEngine(
      mantras: [
        {
          'name': mantra.name,
          'id': mantra.id,
          'sensitivity': mantra.sensitivity,
        }
      ],
      threshold: mantra.sensitivity,
    );

    state = SessionActive(
      sessionId: sessionId,
      mantra: mantra,
      targetCount: targetCount,
      currentCount: 0,
      asrVerifiedCount: 0,
      isAsrEnabled: sarvamConfig.isReady,
    );
  }

  /// Flush the audio buffer and send to Sarvam for ASR verification.
  Future<void> _flushAndVerify() async {
    if (_hybridDetector == null) return;
    try {
      final wavBytes = await AudioBufferManager.flushBuffer();
      if (wavBytes == null || wavBytes.isEmpty) return;

      final detection = await _hybridDetector!.verifyAudioChunk(wavBytes);
      if (detection != null && detection.isAsrVerified) {
        _asrVerifiedCount++;
        if (state is SessionActive) {
          state = (state as SessionActive)
              .copyWith(asrVerifiedCount: _asrVerifiedCount);
        }
        debugPrint(
            'ASR verified detection #$_asrVerifiedCount: '
            '${detection.transcript}');
      }
    } catch (e) {
      debugPrint('ASR flush error: $e');
    }
  }

  Future<void> endSession() async {
    final current = state;
    if (current is! SessionActive) return;

    await AudioChannel.stopEngine();
    _detectionSub?.cancel();
    _messageSub?.cancel();
    _asrFlushTimer?.cancel();

    // Clean up ASR resources
    if (_hybridDetector != null) {
      await AudioBufferManager.stopBuffering();
      _hybridDetector!.dispose();
      _hybridDetector = null;
    }

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
  }

  void onCountUpdate(int count) {
    if (state is SessionActive) {
      state = (state as SessionActive).copyWith(currentCount: count);
    }
  }

  @override
  void dispose() {
    _detectionSub?.cancel();
    _messageSub?.cancel();
    _asrFlushTimer?.cancel();
    _hybridDetector?.dispose();
    super.dispose();
  }
}
