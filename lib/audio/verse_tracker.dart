import 'dart:async';
import '../data/models/verse_mantra.dart';
import 'verse_channel.dart';

// ──────────────────────────────────────────────────────────
// Verse tracking state
// ──────────────────────────────────────────────────────────

/// Immutable state of the verse tracker at any point.
class VerseTrackingState {
  /// The verse being tracked.
  final VerseMantra verse;

  /// Current word position (global index, 0 = not started, 1+ = word N).
  /// A value of totalWords means the verse is complete.
  final int currentWordIndex;

  /// Whether the user is currently speaking (voice detected).
  final bool isVoiceActive;

  /// History of word timings for analytics.
  final List<WordTiming> wordTimings;

  /// Whether the verse has been fully completed.
  bool get isComplete => currentWordIndex >= verse.totalWords;

  /// Progress as a fraction (0.0 to 1.0).
  double get progress =>
      verse.totalWords > 0 ? currentWordIndex / verse.totalWords : 0.0;

  /// Current line index (which line we're on).
  int get currentLineIndex {
    if (currentWordIndex <= 0) return 0;
    final idx = currentWordIndex.clamp(0, verse.totalWords - 1);
    return verse.wordAt(idx)?.lineIndex ?? 0;
  }

  /// Words completed count.
  int get wordsCompleted => currentWordIndex;

  const VerseTrackingState({
    required this.verse,
    this.currentWordIndex = 0,
    this.isVoiceActive = false,
    this.wordTimings = const [],
  });

  VerseTrackingState copyWith({
    int? currentWordIndex,
    bool? isVoiceActive,
    List<WordTiming>? wordTimings,
  }) {
    return VerseTrackingState(
      verse: verse,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      isVoiceActive: isVoiceActive ?? this.isVoiceActive,
      wordTimings: wordTimings ?? this.wordTimings,
    );
  }
}

/// Timing data for a single word — used for analytics and validation.
class WordTiming {
  final int wordIndex;
  final DateTime timestamp;
  final int durationMs;
  final int pauseBeforeMs;

  const WordTiming({
    required this.wordIndex,
    required this.timestamp,
    required this.durationMs,
    required this.pauseBeforeMs,
  });
}

// ──────────────────────────────────────────────────────────
// Verse tracker
// ──────────────────────────────────────────────────────────

/// Manages word-by-word tracking through a verse mantra.
///
/// Receives [WordEvent]s from the native audio engine and maps
/// them to positions in the predefined verse text. Supports:
/// - Automatic tracking via audio word boundary detection
/// - Manual tap-to-advance (user taps current word)
/// - Manual position correction (user taps any word to re-sync)
class VerseTracker {
  final VerseMantra verse;
  final StreamController<VerseTrackingState> _stateController =
      StreamController<VerseTrackingState>.broadcast();

  VerseTrackingState _state;
  StreamSubscription? _eventSub;

  VerseTracker({required this.verse})
      : _state = VerseTrackingState(verse: verse);

  /// Stream of tracking state updates.
  Stream<VerseTrackingState> get stateStream => _stateController.stream;

  /// Current state snapshot.
  VerseTrackingState get currentState => _state;

  /// Start listening to native word events.
  void startListening() {
    _eventSub = VerseAudioChannel.wordEventStream.listen(_onWordEvent);
  }

  /// Stop listening.
  void stopListening() {
    _eventSub?.cancel();
    _eventSub = null;
  }

  /// Handle a word event from the native audio engine.
  void _onWordEvent(WordEvent event) {
    if (_state.isComplete) return;

    switch (event.type) {
      case WordEventType.wordStart:
        // User started speaking — mark voice active and advance if at start
        if (_state.currentWordIndex == 0) {
          _advanceTo(1, event);
        }
        _updateState(_state.copyWith(isVoiceActive: true));
        break;

      case WordEventType.wordAdvance:
        // Word boundary detected — advance to next word
        final nextIndex = _state.currentWordIndex + 1;
        if (nextIndex <= verse.totalWords) {
          _advanceTo(nextIndex, event);
        }
        break;

      case WordEventType.linePause:
        // Long pause — still advance, but also mark voice inactive
        final nextIndex = _state.currentWordIndex + 1;
        if (nextIndex <= verse.totalWords) {
          _advanceTo(nextIndex, event);
        }
        _updateState(_state.copyWith(isVoiceActive: false));
        break;
    }
  }

  /// Manually advance to a specific word (user tapped it to re-sync).
  void jumpToWord(int globalIndex) {
    if (globalIndex < 0 || globalIndex > verse.totalWords) return;
    _state = _state.copyWith(currentWordIndex: globalIndex);
    _stateController.add(_state);
  }

  /// Manually advance one word (tap-to-advance mode).
  void advanceOneWord() {
    if (_state.isComplete) return;
    final next = _state.currentWordIndex + 1;
    if (next <= verse.totalWords) {
      _state = _state.copyWith(currentWordIndex: next);
      _stateController.add(_state);
    }
  }

  void _advanceTo(int wordIndex, WordEvent event) {
    final timing = WordTiming(
      wordIndex: wordIndex,
      timestamp: event.timestamp,
      durationMs: event.wordDurationMs ?? 0,
      pauseBeforeMs: event.pauseDurationMs ?? 0,
    );

    _state = _state.copyWith(
      currentWordIndex: wordIndex,
      wordTimings: [..._state.wordTimings, timing],
    );
    _stateController.add(_state);
  }

  void _updateState(VerseTrackingState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  /// Reset to start.
  void reset() {
    _state = VerseTrackingState(verse: verse);
    _stateController.add(_state);
  }

  void dispose() {
    _eventSub?.cancel();
    _stateController.close();
  }
}
