/// Hybrid detection orchestrator.
///
/// Combines on-device energy-based VAD (instant, free) with
/// Sarvam.ai cloud ASR (accurate, paid) for high-accuracy mantra detection.
///
/// Pipeline:
///   1. Native AudioEngine detects voice activity (energy + ZCR)
///   2. Audio buffer accumulates PCM frames during voice activity
///   3. On silence gap → send buffered audio to Sarvam REST API
///   4. MantraMatcher compares transcript to expected mantra text
///   5. If match → emit verified detection with real confidence
///   6. If no Sarvam key → fall back to energy-only mode (legacy)

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../core/sarvam_config.dart';
import 'sarvam_asr_service.dart';
import 'mantra_matcher.dart';

// ──────────────────────────────────────────────────────────
// Audio buffer manager
// ──────────────────────────────────────────────────────────

/// Manages PCM audio buffering on the native side and retrieves
/// chunks for ASR processing.
class AudioBufferManager {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.audioMethodChannel);

  /// Request the native side to start buffering audio frames.
  static Future<void> startBuffering() async {
    await _channel.invokeMethod('startBuffering');
  }

  /// Retrieve buffered audio as WAV bytes and clear the buffer.
  /// Returns null if no audio was buffered.
  static Future<Uint8List?> flushBuffer() async {
    final result = await _channel.invokeMethod<Uint8List>('flushBuffer');
    return result;
  }

  /// Stop buffering and discard any accumulated audio.
  static Future<void> stopBuffering() async {
    await _channel.invokeMethod('stopBuffering');
  }
}

// ──────────────────────────────────────────────────────────
// Verified detection event
// ──────────────────────────────────────────────────────────

/// A detection verified by ASR — much higher confidence than energy-only.
class VerifiedDetection {
  /// Index of the matched mantra in the config list.
  final int mantraIndex;

  /// Confidence from ASR + fuzzy matching (0.0 to 1.0).
  final double confidence;

  /// Timestamp of detection.
  final DateTime timestamp;

  /// Whether this was verified by cloud ASR, or energy-only fallback.
  final bool isAsrVerified;

  /// Transcript from ASR (null if energy-only).
  final String? transcript;

  /// Match details (null if energy-only).
  final MantraMatchResult? matchResult;

  const VerifiedDetection({
    required this.mantraIndex,
    required this.confidence,
    required this.timestamp,
    this.isAsrVerified = false,
    this.transcript,
    this.matchResult,
  });
}

// ──────────────────────────────────────────────────────────
// Hybrid detector
// ──────────────────────────────────────────────────────────

class HybridDetector {
  final SarvamConfig sarvamConfig;
  final MantraMatcher matcher;
  final List<Map<String, String>> mantras; // [{name, devanagari, romanized}]

  SarvamAsrService? _asrService;
  final StreamController<VerifiedDetection> _detectionController =
      StreamController<VerifiedDetection>.broadcast();

  /// Whether we're in ASR-enhanced mode or energy-only fallback.
  bool get isAsrEnabled => sarvamConfig.isReady;

  /// Stream of verified detections.
  Stream<VerifiedDetection> get detections => _detectionController.stream;

  HybridDetector({
    required this.sarvamConfig,
    required this.mantras,
    this.matcher = const MantraMatcher(),
  }) {
    if (sarvamConfig.isReady) {
      _asrService = SarvamAsrService(config: sarvamConfig);
    }
  }

  /// Process a batch of buffered audio — called when energy-based VAD
  /// detects end of a phrase (silence after voice activity).
  Future<VerifiedDetection?> verifyAudioChunk(Uint8List wavAudio) async {
    if (_asrService == null || !sarvamConfig.isReady) return null;

    try {
      final result = await _asrService!.transcribe(
        audioBytes: wavAudio,
        withTimestamps: true,
      );

      if (result.transcript.isEmpty) return null;

      final match = matcher.matchBestMantra(
        transcript: result.transcript,
        mantras: mantras,
      );

      if (match == null) {
        debugPrint(
            'HybridDetector: ASR transcript "${result.transcript}" — no match');
        return null;
      }

      final detection = VerifiedDetection(
        mantraIndex: match.mantraIndex,
        confidence: match.result.confidence,
        timestamp: DateTime.now(),
        isAsrVerified: true,
        transcript: result.transcript,
        matchResult: match.result,
      );

      _detectionController.add(detection);
      debugPrint(
          'HybridDetector: VERIFIED "${result.transcript}" → '
          'mantra[${match.mantraIndex}] @ ${(match.result.confidence * 100).toInt()}%');
      return detection;
    } catch (e) {
      debugPrint('HybridDetector: ASR error: $e');
      return null;
    }
  }

  /// Energy-only fallback detection — used when Sarvam is not configured.
  void emitEnergyFallback({
    required int mantraIndex,
    required double confidence,
  }) {
    _detectionController.add(VerifiedDetection(
      mantraIndex: mantraIndex,
      confidence: confidence,
      timestamp: DateTime.now(),
      isAsrVerified: false,
    ));
  }

  void dispose() {
    _asrService?.dispose();
    _detectionController.close();
  }
}
