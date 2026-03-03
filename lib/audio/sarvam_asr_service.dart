/// Sarvam.ai ASR (Automatic Speech Recognition) service.
///
/// Provides two integration paths:
/// 1. REST API — for short mantra verification (2-10s audio chunks)
/// 2. WebSocket — for real-time verse tracking (streaming)
///
/// Both use the Saaras v3 model with verbatim mode for exact word matching.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../core/sarvam_config.dart';

// ──────────────────────────────────────────────────────────
// ASR result models
// ──────────────────────────────────────────────────────────

/// Result from a single ASR transcription request.
class AsrResult {
  final String transcript;
  final String? languageCode;
  final double? languageProbability;
  final List<AsrWordTimestamp> wordTimestamps;
  final String requestId;
  final Duration processingTime;

  const AsrResult({
    required this.transcript,
    this.languageCode,
    this.languageProbability,
    this.wordTimestamps = const [],
    this.requestId = '',
    this.processingTime = Duration.zero,
  });

  /// Whether the result has word-level timing data.
  bool get hasTimestamps => wordTimestamps.isNotEmpty;

  /// Transcript split into individual words (lowercase, trimmed).
  List<String> get words =>
      transcript.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
}

/// Word-level timestamp from Sarvam's `with_timestamps` option.
class AsrWordTimestamp {
  final String word;
  final double startTimeSeconds;
  final double endTimeSeconds;

  const AsrWordTimestamp({
    required this.word,
    required this.startTimeSeconds,
    required this.endTimeSeconds,
  });

  Duration get startTime =>
      Duration(milliseconds: (startTimeSeconds * 1000).round());
  Duration get endTime =>
      Duration(milliseconds: (endTimeSeconds * 1000).round());
  Duration get duration => endTime - startTime;
}

/// Streaming transcript fragment from WebSocket.
class StreamingTranscript {
  final String type; // 'speech_start', 'speech_end', 'transcript'
  final String? text;
  final String? requestId;
  final double? audioDuration;
  final double? processingLatency;

  const StreamingTranscript({
    required this.type,
    this.text,
    this.requestId,
    this.audioDuration,
    this.processingLatency,
  });

  bool get isSpeechStart => type == 'speech_start';
  bool get isSpeechEnd => type == 'speech_end';
  bool get isTranscript => type == 'transcript';
}

// ──────────────────────────────────────────────────────────
// Sarvam ASR Service
// ──────────────────────────────────────────────────────────

class SarvamAsrService {
  final SarvamConfig config;
  HttpClient? _httpClient;
  WebSocket? _webSocket;
  StreamSubscription? _wsSub;
  final StreamController<StreamingTranscript> _streamController =
      StreamController<StreamingTranscript>.broadcast();

  SarvamAsrService({required this.config}) {
    _httpClient = HttpClient();
  }

  /// Stream of real-time transcripts (WebSocket mode).
  Stream<StreamingTranscript> get transcriptStream => _streamController.stream;

  // ── REST API: Short mantra verification ──────────────────

  /// Transcribe a short audio clip (≤30s) via REST API.
  ///
  /// Returns an [AsrResult] with transcript and optional word timestamps.
  /// The audio should be 16kHz PCM (WAV format).
  Future<AsrResult> transcribe({
    required Uint8List audioBytes,
    String? languageCode,
    bool withTimestamps = true,
    String format = 'wav',
  }) async {
    if (!config.hasValidKey) {
      throw Exception('Sarvam API key not configured');
    }

    final stopwatch = Stopwatch()..start();

    final uri = Uri.parse(SarvamConstants.restEndpoint);
    final request = await _httpClient!.postUrl(uri);

    // Multipart form data
    final boundary =
        '----SarvamBoundary${DateTime.now().millisecondsSinceEpoch}';
    request.headers.set('api-subscription-key', config.apiKey!);
    request.headers
        .set('Content-Type', 'multipart/form-data; boundary=$boundary');

    final body = StringBuffer();

    // File field
    body.writeln('--$boundary');
    body.writeln(
        'Content-Disposition: form-data; name="file"; filename="audio.$format"');
    body.writeln('Content-Type: audio/$format');
    body.writeln();

    // Model field
    final modelPart = '--$boundary\r\n'
        'Content-Disposition: form-data; name="model"\r\n\r\n'
        '${config.model}\r\n';

    // Mode field
    final modePart = '--$boundary\r\n'
        'Content-Disposition: form-data; name="mode"\r\n\r\n'
        '${config.mode}\r\n';

    // Language field
    final lang = languageCode ?? config.languageCode;
    final langPart = '--$boundary\r\n'
        'Content-Disposition: form-data; name="language_code"\r\n\r\n'
        '$lang\r\n';

    // Timestamps field
    final tsPart = '--$boundary\r\n'
        'Content-Disposition: form-data; name="with_timestamps"\r\n\r\n'
        '${withTimestamps}\r\n';

    // Build multipart body
    final preFile = '--$boundary\r\n'
        'Content-Disposition: form-data; name="file"; filename="audio.$format"\r\n'
        'Content-Type: audio/$format\r\n\r\n';
    final postFile = '\r\n$modelPart$modePart$langPart$tsPart--$boundary--\r\n';

    final preBytes = utf8.encode(preFile);
    final postBytes = utf8.encode(postFile);

    request.contentLength = preBytes.length + audioBytes.length + postBytes.length;
    request.add(preBytes);
    request.add(audioBytes);
    request.add(postBytes);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    stopwatch.stop();

    if (response.statusCode != 200) {
      throw Exception(
          'Sarvam API error ${response.statusCode}: $responseBody');
    }

    final json = jsonDecode(responseBody) as Map<String, dynamic>;

    // Parse word timestamps if present
    final timestamps = <AsrWordTimestamp>[];
    if (json['timestamps'] != null) {
      final ts = json['timestamps'] as Map<String, dynamic>;
      final words = (ts['words'] as List?)?.cast<String>() ?? [];
      final starts =
          (ts['start_time_seconds'] as List?)?.cast<num>() ?? [];
      final ends =
          (ts['end_time_seconds'] as List?)?.cast<num>() ?? [];

      for (int i = 0; i < words.length; i++) {
        timestamps.add(AsrWordTimestamp(
          word: words[i],
          startTimeSeconds:
              i < starts.length ? starts[i].toDouble() : 0.0,
          endTimeSeconds: i < ends.length ? ends[i].toDouble() : 0.0,
        ));
      }
    }

    return AsrResult(
      transcript: json['transcript'] as String? ?? '',
      languageCode: json['language_code'] as String?,
      languageProbability:
          (json['language_probability'] as num?)?.toDouble(),
      wordTimestamps: timestamps,
      requestId: json['request_id'] as String? ?? '',
      processingTime: stopwatch.elapsed,
    );
  }

  // ── WebSocket: Real-time streaming ──────────────────────

  /// Connect to Sarvam's streaming STT WebSocket.
  ///
  /// Emits [StreamingTranscript] events via [transcriptStream].
  /// Send audio chunks via [sendAudioChunk].
  Future<void> connectStreaming({
    String? languageCode,
    bool highVadSensitivity = true,
    bool vadSignals = true,
  }) async {
    if (!config.hasValidKey) {
      throw Exception('Sarvam API key not configured');
    }

    final lang = languageCode ?? config.languageCode;
    final uri = Uri.parse(
      '${SarvamConstants.wsEndpoint}'
      '?language-code=$lang'
      '&model=${config.model}'
      '&mode=${config.mode}'
      '&sample_rate=16000'
      '&input_audio_codec=pcm_s16le'
      '&high_vad_sensitivity=$highVadSensitivity'
      '&vad_signals=$vadSignals',
    );

    _webSocket = await WebSocket.connect(
      uri.toString(),
      headers: {'Api-Subscription-Key': config.apiKey!},
    );

    _wsSub = _webSocket!.listen(
      (data) {
        try {
          final json = jsonDecode(data as String) as Map<String, dynamic>;
          final type = json['type'] as String? ?? 'transcript';

          if (type == 'data') {
            final inner = json['data'] as Map<String, dynamic>?;
            if (inner != null) {
              _streamController.add(StreamingTranscript(
                type: 'transcript',
                text: inner['transcript'] as String?,
                requestId: inner['request_id'] as String?,
                audioDuration:
                    (inner['metrics']?['audio_duration'] as num?)
                        ?.toDouble(),
                processingLatency:
                    (inner['metrics']?['processing_latency'] as num?)
                        ?.toDouble(),
              ));
            }
          } else {
            _streamController.add(StreamingTranscript(type: type));
          }
        } catch (e) {
          debugPrint('Sarvam WS parse error: $e');
        }
      },
      onError: (e) => debugPrint('Sarvam WS error: $e'),
      onDone: () => debugPrint('Sarvam WS closed'),
    );

    debugPrint('Sarvam WS connected: ${uri.toString().split('?').first}');
  }

  /// Send a chunk of PCM audio data to the streaming WebSocket.
  ///
  /// [pcmData] should be 16kHz 16-bit signed LE PCM.
  void sendAudioChunk(Uint8List pcmData) {
    if (_webSocket == null) return;

    final base64Audio = base64Encode(pcmData);
    final message = jsonEncode({
      'audio': {
        'data': base64Audio,
        'sample_rate': '16000',
        'encoding': 'audio/pcm_s16le',
      }
    });

    _webSocket!.add(message);
  }

  /// Flush the streaming buffer — force immediate transcription.
  void flush() {
    if (_webSocket == null) return;
    _webSocket!.add(jsonEncode({'flush': true}));
  }

  /// Disconnect the streaming WebSocket.
  Future<void> disconnectStreaming() async {
    _wsSub?.cancel();
    await _webSocket?.close();
    _webSocket = null;
  }

  /// Dispose all resources.
  void dispose() {
    disconnectStreaming();
    _httpClient?.close();
    _streamController.close();
  }
}
