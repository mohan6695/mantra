import 'dart:async';
import 'package:flutter/services.dart';
import '../core/constants.dart';

/// Represents a single mantra detection event from native audio pipeline.
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

/// Calibration profile for a user's voice characteristics.
class CalibrationProfile {
  final double energyThreshold;
  final int refractoryMs;

  const CalibrationProfile({
    required this.energyThreshold,
    required this.refractoryMs,
  });

  Map<String, dynamic> toMap() => {
        'energyThreshold': energyThreshold,
        'refractoryMs': refractoryMs,
      };
}

/// Dart-side interface to native audio engines via platform channels.
class AudioChannel {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.audioMethodChannel);
  static const EventChannel _eventChannel =
      EventChannel(AppConstants.audioEventChannel);

  /// Stream of detection events from the native audio pipeline.
  static Stream<DetectionEvent> get detectionStream =>
      _eventChannel.receiveBroadcastStream().map(
            (event) => DetectionEvent.fromMap(event as Map<dynamic, dynamic>),
          );

  /// Start the native audio engine with given mantras and confidence threshold.
  static Future<void> startEngine({
    required List<Map<String, dynamic>> mantras,
    required double threshold,
  }) async {
    await _channel.invokeMethod('start', {
      'mantras': mantras,
      'threshold': threshold,
    });
  }

  /// Stop the native audio engine.
  static Future<void> stopEngine() async {
    await _channel.invokeMethod('stop');
  }

  /// Update calibration data on the native engine.
  static Future<void> updateCalibration(CalibrationProfile profile) async {
    await _channel.invokeMethod('updateCalibration', profile.toMap());
  }
}
