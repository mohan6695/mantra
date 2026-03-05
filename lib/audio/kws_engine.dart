/// Template-based mantra detection engine.
///
/// Replaces the previous TFLite KWS stub with a DTW template matcher
/// powered by calibration profiles. No ML model files needed — all
/// matching is done against the user's own voice recordings.
///
/// This is the Dart-side counterpart to the native MFCC extractor.
/// The native engine extracts features; this engine matches them.

import 'calibration_profile.dart';
import 'ensemble_detector.dart';
import 'signal_processors.dart';

/// Engine that manages calibration profiles and provides per-mantra
/// detection capability via the ensemble detector.
class TemplateEngine {
  EnsembleCalibrationProfile? _profile;
  EnsembleDetector? _detector;
  bool _isReady = false;

  bool get isReady => _isReady && _profile != null && _detector != null;

  /// Load calibration profile and initialize ensemble detector.
  void loadProfile(EnsembleCalibrationProfile profile) {
    _profile = profile;
    _detector = EnsembleDetector(calibration: profile);
    _isReady = profile.isValid;
  }

  /// Evaluate an audio segment through the 6-signal ensemble.
  /// Returns null if engine is not ready.
  EnsembleResult? evaluate(AudioSegment segment) {
    if (!isReady || _detector == null) return null;
    return _detector!.evaluate(segment);
  }

  /// Stream of all ensemble results (for diagnostics / UI).
  Stream<EnsembleResult>? get results => _detector?.results;

  /// Reset rhythm lock after a long pause.
  void resetRhythm() => _detector?.resetRhythm();

  /// Current calibration profile (if loaded).
  EnsembleCalibrationProfile? get profile => _profile;

  /// Detection stats.
  int get totalEvaluated => _detector?.totalEvaluated ?? 0;
  int get totalAccepted => _detector?.totalAccepted ?? 0;

  void dispose() {
    _detector?.dispose();
    _detector = null;
    _isReady = false;
  }
}

