import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';
import '../../audio/audio_channel.dart';
import '../../audio/detection_isolate.dart';

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

  const SessionActive({
    required this.sessionId,
    required this.mantra,
    required this.targetCount,
    required this.currentCount,
  });

  SessionActive copyWith({int? currentCount}) => SessionActive(
        sessionId: sessionId,
        mantra: mantra,
        targetCount: targetCount,
        currentCount: currentCount ?? this.currentCount,
      );
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

  SessionNotifier(this._ref) : super(const SessionIdle());

  Future<void> startSession({
    required MantraConfigTableData mantra,
    required int targetCount,
  }) async {
    final sessionId = const Uuid().v4();
    final db = _ref.read(appDatabaseProvider);

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

    // Listen for count updates from processor
    _messageSub = processor.messages.listen((msg) {
      switch (msg) {
        case CountUpdate(:final count):
          if (state is SessionActive) {
            state = (state as SessionActive).copyWith(currentCount: count);
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
    );
  }

  Future<void> endSession() async {
    final current = state;
    if (current is! SessionActive) return;

    await AudioChannel.stopEngine();
    _detectionSub?.cancel();
    _messageSub?.cancel();

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
    super.dispose();
  }
}
