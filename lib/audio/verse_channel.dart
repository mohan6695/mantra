import 'dart:async';
import 'package:flutter/services.dart';
import '../core/constants.dart';

// ──────────────────────────────────────────────────────────
// Word event models (from native WordBoundaryDetector)
// ──────────────────────────────────────────────────────────

/// Types of word boundary events.
enum WordEventType { wordStart, wordAdvance, linePause }

/// A single word-boundary event from the native audio engine.
class WordEvent {
  final WordEventType type;
  final int wordIndex;
  final DateTime timestamp;
  final int? wordDurationMs;
  final int? pauseDurationMs;
  final double? energy;

  const WordEvent({
    required this.type,
    required this.wordIndex,
    required this.timestamp,
    this.wordDurationMs,
    this.pauseDurationMs,
    this.energy,
  });

  factory WordEvent.fromMap(Map<dynamic, dynamic> map) {
    final typeStr = map['type'] as String;
    final type = switch (typeStr) {
      'word_start' => WordEventType.wordStart,
      'word_advance' => WordEventType.wordAdvance,
      'line_pause' => WordEventType.linePause,
      _ => WordEventType.wordAdvance,
    };

    return WordEvent(
      type: type,
      wordIndex: map['wordIndex'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      wordDurationMs: map['wordDuration'] as int?,
      pauseDurationMs: map['pauseDuration'] as int?,
      energy: (map['energy'] as num?)?.toDouble(),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Verse audio channel — Dart ↔ Native bridge
// ──────────────────────────────────────────────────────────

/// Platform channel interface for verse (long mantra) tracking.
class VerseAudioChannel {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.verseMethodChannel);
  static const EventChannel _eventChannel =
      EventChannel(AppConstants.verseEventChannel);

  /// Stream of word boundary events from the native audio engine.
  static Stream<WordEvent> get wordEventStream =>
      _eventChannel.receiveBroadcastStream().map(
            (event) => WordEvent.fromMap(event as Map<dynamic, dynamic>),
          );

  /// Start the verse audio engine.
  ///
  /// [totalWords] — Number of words in the verse being tracked.
  /// [sensitivity] — Detection sensitivity (0.0 = very lenient, 1.0 = strict).
  static Future<void> startEngine({
    required int totalWords,
    double sensitivity = 0.5,
  }) async {
    await _channel.invokeMethod('startVerse', {
      'totalWords': totalWords,
      'sensitivity': sensitivity,
    });
  }

  /// Stop the verse audio engine.
  static Future<void> stopEngine() async {
    await _channel.invokeMethod('stopVerse');
  }

  /// Update sensitivity while engine is running.
  static Future<void> updateSensitivity(double sensitivity) async {
    await _channel.invokeMethod('updateSensitivity', {
      'sensitivity': sensitivity,
    });
  }
}
