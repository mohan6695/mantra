/// App-wide constants for the mantra counter application.
class AppConstants {
  AppConstants._();

  // ── Audio ──────────────────────────────────────────────
  static const int sampleRate = 16000;
  static const int frameSize = 512; // ~32ms per frame at 16kHz
  static const int mfccCoefficients = 40;
  static const int melFilters = 40;
  static const double preEmphasis = 0.97;

  // ── KWS Model (legacy — kept for fallback) ────────────
  static const String modelAsset = 'assets/models/kws.tflite';
  static const double defaultConfidenceThreshold = 0.82;
  static const int backgroundClassIndex = -1;

  // ── Refractory gate (ms) — overridden by calibration ──
  static const int defaultRefractoryMs = 800;
  static const int minRefractoryMs = 400;
  static const int maxRefractoryMs = 3000;

  // ── VAD ────────────────────────────────────────────────
  static const double defaultEnergyThreshold = 0.01;
  static const double zcrThreshold = 0.30;

  // ── Ensemble Detector (6-signal) ──────────────────────
  /// Signal weights (S1–S6, must sum to 1.0).
  static const double ensembleW1Dtw = 0.30;
  static const double ensembleW2Duration = 0.10;
  static const double ensembleW3Rhythm = 0.25;
  static const double ensembleW4Spectral = 0.15;
  static const double ensembleW5Contour = 0.10;
  static const double ensembleW6Vuv = 0.10;

  /// Ensemble thresholds.
  static const double ensembleAcceptThreshold = 0.62;
  static const double ensembleBorderlineThreshold = 0.45;

  /// DTW rejection distance (higher = more lenient).
  static const double dtwRejectionDistance = 150.0;

  /// Energy contour rejection distance (1D DTW).
  static const double contourRejectionDistance = 5.0;

  /// Rhythm EMA alpha (higher = faster adaptation).
  static const double rhythmAlpha = 0.25;

  /// Max gap before rhythm lock resets (ms).
  static const int rhythmMaxGapMs = 15000;

  /// Rolling template bank size.
  static const int maxRollingTemplates = 20;

  /// Minimum calibration recordings needed.
  static const int minCalibrationRecordings = 2;

  /// Calibration SharedPreferences key.
  static const String calibrationProfileKey = 'ensemble_calibration_profile';

  // ── Sync ───────────────────────────────────────────────
  static const String cfWorkerBaseUrl =
      'https://mantra-api.YOUR_SUBDOMAIN.workers.dev';
  static const String cfKvConfigUrl =
      'https://mantra-api.YOUR_SUBDOMAIN.workers.dev/config';
  static const Duration syncRetryInterval = Duration(minutes: 15);

  // ── Notifications ─────────────────────────────────────
  static const int targetReachedNotifId = 1001;
  static const int milestoneNotifId = 1002;
  static const int reminderNotifId = 1003;

  // ── Milestones ────────────────────────────────────────
  static const List<int> milestoneCounts = [108, 1008, 10008, 100008];

  // ── Platform channels ─────────────────────────────────
  static const String audioMethodChannel = 'com.mantra/audio';
  static const String audioEventChannel = 'com.mantra/detections';
  static const String verseMethodChannel = 'com.mantra/verse_audio';
  static const String verseEventChannel = 'com.mantra/verse_events';
}
