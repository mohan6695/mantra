import 'dart:async';
import '../core/constants.dart';
import '../data/local/database.dart';

/// Messages sent from the detection isolate to the UI isolate.
sealed class DetectionMessage {}

class CountUpdate extends DetectionMessage {
  final int count;
  CountUpdate(this.count);
}

class TargetReached extends DetectionMessage {
  final int count;
  TargetReached(this.count);
}

class MilestoneReached extends DetectionMessage {
  final int lifetimeCount;
  MilestoneReached(this.lifetimeCount);
}

/// Manages detection gating and counting logic.
/// Designed to run processing off the UI thread.
///
/// Receives DetectionEvents, applies refractory gate, updates counter,
/// and sends results back to UI via a stream.
class DetectionProcessor {
  final AppDatabase db;
  final StreamController<DetectionMessage> _messageController =
      StreamController<DetectionMessage>.broadcast();

  DateTime? _lastDetectionTime;
  int _sessionCount = 0;
  late String _sessionId;
  // ignore: unused_field
  late int _mantraId;
  late int _targetCount;
  late int _refractoryMs;
  late double _confidenceThreshold;

  DetectionProcessor({required this.db});

  /// Stream of messages to the UI layer.
  Stream<DetectionMessage> get messages => _messageController.stream;

  /// Initialize for a new session.
  void initialize({
    required String sessionId,
    required int mantraId,
    required int targetCount,
    required int refractoryMs,
    double confidenceThreshold = AppConstants.defaultConfidenceThreshold,
  }) {
    _sessionId = sessionId;
    _mantraId = mantraId;
    _targetCount = targetCount;
    _refractoryMs = refractoryMs;
    _confidenceThreshold = confidenceThreshold;
    _sessionCount = 0;
    _lastDetectionTime = null;
  }

  /// Process a raw detection event from the native audio engine.
  Future<void> onDetectionEvent({
    required int mantraIndex,
    required double confidence,
    required DateTime timestamp,
  }) async {
    // ── REFRACTORY GATE ──
    // Prevents double-counting when a single chant spans multiple frames.
    if (_lastDetectionTime != null) {
      final elapsed =
          timestamp.difference(_lastDetectionTime!).inMilliseconds;
      if (elapsed < _refractoryMs) return; // REJECT — too soon
    }

    // ── CONFIDENCE CHECK ──
    if (confidence < _confidenceThreshold) return;

    // ── VALID DETECTION ──
    _lastDetectionTime = timestamp;
    _sessionCount++;

    // Async DB write — non-blocking fire-and-forget
    db.insertDetection(DetectionsTableCompanion.insert(
      sessionId: _sessionId,
      detectedAt: timestamp,
      confidence: confidence,
    ));

    // Notify UI
    _messageController.add(CountUpdate(_sessionCount));

    // Target check
    if (_sessionCount == _targetCount) {
      _messageController.add(TargetReached(_sessionCount));
    }

    // Milestone check (async, non-blocking)
    _checkMilestones();
  }

  Future<void> _checkMilestones() async {
    // Sum today's total + current session
    // This is approximate — a full query would be more accurate
    for (final milestone in AppConstants.milestoneCounts) {
      if (_sessionCount == milestone) {
        _messageController.add(MilestoneReached(milestone));
        break;
      }
    }
  }

  int get currentCount => _sessionCount;

  void dispose() {
    _messageController.close();
  }
}
