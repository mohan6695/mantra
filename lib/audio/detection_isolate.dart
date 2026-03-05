import 'dart:async';
import '../core/constants.dart';
import '../data/local/database.dart';
import 'ensemble_detector.dart';

/// Messages sent from the detection processor to the UI layer.
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

/// Per-detection diagnostic info exposed to UI / debug overlay.
class DetectionDiagnostic extends DetectionMessage {
  final EnsembleResult result;
  DetectionDiagnostic(this.result);
}

/// Manages counting, DB persistence, and UI messaging for accepted detections.
///
/// The heavy lifting (refractory gating, 6-signal scoring, edge-case handling)
/// is done upstream by [EnsembleDetector]. This processor only handles:
///   - Counting accepted detections
///   - Writing detections to the local SQLite database
///   - Emitting [DetectionMessage]s to the UI layer
///   - Checking target & milestone progress
class DetectionProcessor {
  final AppDatabase db;
  final StreamController<DetectionMessage> _messageController =
      StreamController<DetectionMessage>.broadcast();

  int _sessionCount = 0;
  String _sessionId = '';
  int _mantraId = 0;
  int _targetCount = 0;
  bool _targetReachedEmitted = false;

  DetectionProcessor({required this.db});

  /// Stream of messages to the UI layer.
  Stream<DetectionMessage> get messages => _messageController.stream;

  /// Initialize for a new session.
  void initialize({
    required String sessionId,
    required int mantraId,
    required int targetCount,
    int initialCount = 0,
  }) {
    _sessionId = sessionId;
    _mantraId = mantraId;
    _targetCount = targetCount;
    _sessionCount = initialCount;
    _targetReachedEmitted = initialCount >= targetCount;
  }

  /// Directly set the count (for manual increment/decrement).
  void adjustCount(int newCount) {
    _sessionCount = newCount;
    _messageController.add(CountUpdate(_sessionCount));
    // Re-check target (could un-reach if decremented)
    if (!_targetReachedEmitted && _sessionCount >= _targetCount) {
      _targetReachedEmitted = true;
      _messageController.add(TargetReached(_sessionCount));
    }
  }

  /// Process an accepted ensemble result.
  ///
  /// Only call this with results where `result.isAccepted == true`.
  /// The caller ([NativeSegmentReceiver] or [SessionNotifier]) is
  /// responsible for filtering.
  Future<void> onAcceptedDetection(EnsembleResult result) async {
    _sessionCount++;

    // Async DB write — non-blocking fire-and-forget
    db.insertDetection(DetectionsTableCompanion.insert(
      sessionId: _sessionId,
      detectedAt: result.timestamp,
      confidence: result.ensembleScore,
    ));

    // Notify UI of new count
    _messageController.add(CountUpdate(_sessionCount));

    // Emit diagnostic for debug overlay
    _messageController.add(DetectionDiagnostic(result));

    // Target check — emit once
    if (!_targetReachedEmitted && _sessionCount >= _targetCount) {
      _targetReachedEmitted = true;
      _messageController.add(TargetReached(_sessionCount));
    }

    // Milestone check
    _checkMilestones();
  }

  /// Process any ensemble result (for diagnostic overlay).
  /// Does NOT increment counter — only emits diagnostic.
  void onEnsembleResult(EnsembleResult result) {
    _messageController.add(DetectionDiagnostic(result));
  }

  Future<void> _checkMilestones() async {
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
