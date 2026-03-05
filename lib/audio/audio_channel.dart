import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import 'calibration_profile.dart';
import 'signal_processors.dart';

// ──────────────────────────────────────────────────────────
// Legacy detection event  (kept for backward compatibility)
// ──────────────────────────────────────────────────────────

/// Represents a single mantra detection event from native audio pipeline.
@Deprecated('Use AudioSegment + EnsembleDetector instead')
class DetectionEvent {
  final int mantraIndex;
  final double confidence;
  final DateTime timestamp;

  DetectionEvent({
    required this.mantraIndex,
    required this.confidence,
    required this.timestamp,
  });

  factory DetectionEvent.fromMap(Map<dynamic, dynamic> map) {
    return DetectionEvent(
      mantraIndex: map['index'] as int,
      confidence: (map['confidence'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Platform channel interface
// ──────────────────────────────────────────────────────────

/// Dart-side interface to native audio engines via platform channels.
///
/// The native engine is responsible for:
///   - Microphone capture (16 kHz, mono, 16-bit PCM)
///   - MFCC extraction per detected audio segment
///   - VAD-based segmentation (energy gate + silence gap)
///   - Sending AudioSegment maps over the EventChannel
///
/// Dart side handles all ensemble scoring via [EnsembleDetector].
class AudioChannel {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.audioMethodChannel);
  static const EventChannel _eventChannel =
      EventChannel(AppConstants.audioEventChannel);

  // ── Segment stream (new ensemble path) ─────────────────

  /// Stream of pre-processed AudioSegments from native audio engine.
  /// Each event is a Map containing MFCC frames, energy contour,
  /// voiced/unvoiced pattern, duration, etc.
  static Stream<AudioSegment> get segmentStream =>
      _eventChannel.receiveBroadcastStream().map((event) {
        if (event is Map<dynamic, dynamic>) {
          return AudioSegment.fromNative(event);
        }
        throw FormatException('Expected Map from native, got ${event.runtimeType}');
      });

  /// Raw event stream for callers that need to handle parsing themselves.
  static Stream<Map<dynamic, dynamic>> get rawEventStream =>
      _eventChannel.receiveBroadcastStream().where((e) => e is Map).cast();

  // ── Engine lifecycle ──────────────────────────────────

  /// Start the native audio engine in ensemble-detection mode.
  ///
  /// [mode] can be:
  ///   - 'ensemble' (default) — sends AudioSegment maps
  ///   - 'calibration' — sends calibration sample maps with raw features
  ///   - 'mic_test' — sends level updates only
  static Future<void> startEngine({
    List<Map<String, dynamic>> mantras = const [],
    double threshold = 0.5,
    String mode = 'ensemble',
  }) async {
    await _channel.invokeMethod('start', {
      'mantras': mantras,
      'threshold': threshold,
      'mode': mode,
    });
    debugPrint('AudioChannel: engine started (mode=$mode)');
  }

  /// Stop the native audio engine.
  static Future<void> stopEngine() async {
    await _channel.invokeMethod('stop');
    debugPrint('AudioChannel: engine stopped');
  }

  // ── Calibration ────────────────────────────────────────

  /// Send full ensemble calibration profile to the native engine.
  ///
  /// The native engine uses this to configure:
  ///   - Energy threshold for VAD gating
  ///   - Refractory period between segments
  ///   - Expected duration range for segment extraction
  static Future<void> updateEnsembleCalibration(
      EnsembleCalibrationProfile profile) async {
    await _channel.invokeMethod('updateCalibration', {
      'energyThreshold': profile.energyThreshold,
      'refractoryMs': profile.refractoryMs,
      'meanDurationMs': profile.meanDurationMs,
      'stdDurationMs': profile.stdDurationMs,
      'meanGapMs': profile.meanGapMs,
      'mfccDim': profile.mfccDim,
    });
    debugPrint('AudioChannel: ensemble calibration updated');
  }

  /// Legacy calibration update (energy + refractory only).
  @Deprecated('Use updateEnsembleCalibration instead')
  static Future<void> updateCalibration({
    required double energyThreshold,
    required int refractoryMs,
  }) async {
    await _channel.invokeMethod('updateCalibration', {
      'energyThreshold': energyThreshold,
      'refractoryMs': refractoryMs,
    });
  }

  // ── Calibration recording ──────────────────────────────

  /// Start recording a calibration sample. Native engine will collect
  /// a single chant's worth of audio and extract MFCC features.
  static Future<void> startCalibrationRecording() async {
    await _channel.invokeMethod('startCalibrationRecording');
  }

  /// Stop recording and retrieve the calibration sample.
  ///
  /// Returns a Map with keys:
  ///   - 'mfccFrames': List<List<double>> — MFCC feature matrix
  ///   - 'energyContour': List<double> — frame-level energy
  ///   - 'voicedPattern': List<bool> — voiced/unvoiced per frame
  ///   - 'durationMs': int — total duration
  ///   - 'peakEnergy': double — peak energy in segment
  static Future<Map<String, dynamic>?> stopCalibrationRecording() async {
    final result = await _channel
        .invokeMapMethod<String, dynamic>('stopCalibrationRecording');
    return result;
  }

  /// Get live audio level (0.0 to 1.0) for mic check UI.
  static Future<double> getLiveLevel() async {
    final level = await _channel.invokeMethod<double>('getLiveLevel');
    return level ?? 0.0;
  }
}
