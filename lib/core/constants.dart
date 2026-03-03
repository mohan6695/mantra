/// App-wide constants for the mantra counter application.
class AppConstants {
  AppConstants._();

  // Audio
  static const int sampleRate = 16000;
  static const int frameSize = 512; // ~32ms per frame at 16kHz
  static const int mfccCoefficients = 40;
  static const int melFilters = 40;
  static const double preEmphasis = 0.97;

  // KWS Model
  static const String modelAsset = 'assets/models/kws.tflite';
  static const double defaultConfidenceThreshold = 0.82;
  static const int backgroundClassIndex = -1; // last class in model output

  // Refractory gate (ms) — overridden by per-user calibration
  static const int defaultRefractoryMs = 800;
  static const int minRefractoryMs = 400;
  static const int maxRefractoryMs = 3000;

  // VAD
  static const double defaultEnergyThreshold = 0.01;
  static const double zcrThreshold = 0.30;

  // Sync
  static const String cfWorkerBaseUrl =
      'https://mantra-api.YOUR_SUBDOMAIN.workers.dev';
  static const String cfKvConfigUrl =
      'https://mantra-api.YOUR_SUBDOMAIN.workers.dev/config';
  static const Duration syncRetryInterval = Duration(minutes: 15);

  // Notifications
  static const int targetReachedNotifId = 1001;
  static const int milestoneNotifId = 1002;
  static const int reminderNotifId = 1003;

  // Milestones
  static const List<int> milestoneCounts = [108, 1008, 10008, 100008];

  // Platform channels
  static const String audioMethodChannel = 'com.mantra/audio';
  static const String audioEventChannel = 'com.mantra/detections';
  static const String verseMethodChannel = 'com.mantra/verse_audio';
  static const String verseEventChannel = 'com.mantra/verse_events';
}
