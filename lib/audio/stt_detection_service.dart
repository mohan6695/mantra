/// Speech-to-Text mantra detection — robust, Perplexity-style streaming.
///
/// Design principles:
///   1. **en_IN locale first** — returns romanized output that matches our
///      expected text. Hindi fallback for Devanagari-aware matching.
///   2. **Greedy sequential word-scan** — scans transcript words against
///      expected mantra words using fuzzy comparison. Handles noise words,
///      garbled STT output, and multiple repetitions in one transcript.
///   3. **Silence is NOT an error** — `error_no_match` / `error_speech_timeout`
///      just mean nobody is speaking. STT auto-restarts immediately without
///      incrementing error counters. This prevents the service from dying
///      during natural pauses between chants.
///   4. **Self-contained matching** — uses inline Levenshtein + light phonetic
///      normalization. No dependency on MantraMatcher for detection.

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'mantra_matcher.dart' show MantraMatchResult;

// ──────────────────────────────────────────────────────────
// Events
// ──────────────────────────────────────────────────────────

sealed class SttEvent {}

class SttRecognizedText extends SttEvent {
  final String text;
  final bool isFinal;
  SttRecognizedText({required this.text, required this.isFinal});
}

class SttMantraDetected extends SttEvent {
  final MantraMatchResult matchResult;
  final int durationMs;
  SttMantraDetected({required this.matchResult, this.durationMs = 0});
}

class SttStatusChanged extends SttEvent {
  final String status;
  SttStatusChanged({required this.status});
}

class SttErrorEvent extends SttEvent {
  final String message;
  SttErrorEvent({required this.message});
}

// ──────────────────────────────────────────────────────────
// Service
// ──────────────────────────────────────────────────────────

class SttDetectionService {
  final SpeechToText _speech = SpeechToText();
  final StreamController<SttEvent> _eventController =
      StreamController<SttEvent>.broadcast();

  // ── Mantra config (set via configure()) ──
  String _rawRomanized = '';
  String _rawDevanagari = '';
  List<String> _expectedRomWords = []; // normalized
  List<String> _expectedDevWords = []; // normalized
  int _expectedWordCount = 1;

  // ── Lifecycle state ──
  bool _isInitialized = false;
  bool _isActive = false;
  bool _isPaused = false;
  bool _isRestarting = false; // Guard against overlapping restarts

  // ── Match tracking (delta counting per segment) ──
  int _matchesCounted = 0;

  // ── Locale selection ──
  String _selectedLocale = 'en_IN';
  List<String> _availableLocales = [];
  int _localeAttempt = 0;

  // ── Error recovery ──
  Timer? _restartTimer;
  int _consecutiveRealErrors = 0;
  static const int _maxRealErrors = 30;

  SttDetectionService();

  Stream<SttEvent> get events => _eventController.stream;
  bool get isAvailable => _isInitialized;
  bool get isListening => _speech.isListening;

  // ────────────────────────────────────────────────────────
  // Initialization
  // ────────────────────────────────────────────────────────

  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: true,
      );
      if (!_isInitialized) {
        debugPrint('STT: init returned false — not available');
        return false;
      }

      final locales = await _speech.locales();
      _availableLocales = locales.map((l) => l.localeId).toList();
      debugPrint('STT: available locales: ${_availableLocales.take(15)}');

      // Prefer en_IN — returns romanized text that matches expected words best.
      if (_availableLocales.any((l) => l == 'en_IN')) {
        _selectedLocale = 'en_IN';
      } else if (_availableLocales.any((l) => l.startsWith('en'))) {
        _selectedLocale =
            _availableLocales.firstWhere((l) => l.startsWith('en'));
      } else if (_availableLocales.any((l) => l.startsWith('hi'))) {
        _selectedLocale =
            _availableLocales.firstWhere((l) => l.startsWith('hi'));
      }
      debugPrint('STT: selected locale = $_selectedLocale');
      return true;
    } catch (e) {
      debugPrint('STT: init error: $e');
      _isInitialized = false;
      return false;
    }
  }

  // ────────────────────────────────────────────────────────
  // Configuration
  // ────────────────────────────────────────────────────────

  void configure({
    required String devanagari,
    required String romanized,
    required int refractoryMs,
  }) {
    _rawRomanized = romanized;
    _rawDevanagari = devanagari;
    _matchesCounted = 0;

    // Pre-normalize expected words for fast comparison at match time.
    _expectedRomWords = romanized
        .replaceAll('\n', ' ')
        .split(RegExp(r'\s+'))
        .map(_normalizeRom)
        .where((w) => w.isNotEmpty)
        .toList();

    _expectedDevWords = devanagari
        .replaceAll('\n', ' ')
        .split(RegExp(r'\s+'))
        .map(_normalizeDev)
        .where((w) => w.isNotEmpty)
        .toList();

    _expectedWordCount = _expectedRomWords.length;

    debugPrint('STT configured: ${_expectedWordCount} expected words');
    debugPrint('  rom: $_expectedRomWords');
    debugPrint('  dev: $_expectedDevWords');
  }

  // ────────────────────────────────────────────────────────
  // Listening lifecycle
  // ────────────────────────────────────────────────────────

  Future<void> startListening() async {
    if (!_isInitialized) {
      debugPrint('STT: not initialized');
      _eventController
          .add(SttErrorEvent(message: 'Speech recognition not available'));
      return;
    }
    _isActive = true;
    _isPaused = false;
    _consecutiveRealErrors = 0;
    _matchesCounted = 0;
    _localeAttempt = 0;
    await _beginListening();
  }

  Future<void> pauseListening() async {
    _isPaused = true;
    _restartTimer?.cancel();
    await _speech.stop();
  }

  Future<void> resumeListening() async {
    if (!_isActive) return;
    _isPaused = false;
    _matchesCounted = 0;
    await _beginListening();
  }

  Future<void> stopListening() async {
    _isActive = false;
    _isPaused = false;
    _restartTimer?.cancel();
    await _speech.stop();
    debugPrint('STT: stopped');
  }

  Future<void> _beginListening() async {
    if (!_isActive || _isPaused) return;
    if (_speech.isListening) return;
    if (_isRestarting) return; // Prevent overlapping restarts

    _isRestarting = true;
    _matchesCounted = 0; // fresh segment

    try {
      // Small delay to let SpeechRecognizer fully release resources
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_isActive || _isPaused) {
        _isRestarting = false;
        return;
      }

      await _speech.listen(
        onResult: _onResult,
        localeId: _selectedLocale,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        ),
      );
      debugPrint('STT: listening (locale=$_selectedLocale)');
    } catch (e) {
      debugPrint('STT: listen() threw: $e');
      _consecutiveRealErrors++;
      _scheduleRestart(delayMs: 1000);
    } finally {
      _isRestarting = false;
    }
  }

  // ────────────────────────────────────────────────────────
  // Result handling
  // ────────────────────────────────────────────────────────

  void _onResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords.trim();
    if (text.isEmpty) return;

    // Any successful recognition → reset real-error counter.
    _consecutiveRealErrors = 0;

    // Show in UI.
    _eventController.add(SttRecognizedText(
      text: text,
      isFinal: result.finalResult,
    ));

    debugPrint('STT [${result.finalResult ? "FINAL" : "partial"}]: "$text"');

    // Count non-overlapping mantra occurrences and emit delta.
    final total = _countOccurrences(text);
    final delta = total - _matchesCounted;

    if (delta > 0) {
      debugPrint('STT ✓ $delta new detection(s) (segment total=$total)');
      for (int i = 0; i < delta; i++) {
        _eventController.add(SttMantraDetected(
          matchResult: MantraMatchResult(
            confidence: 1.0,
            isMatch: true,
            matchedWords: _expectedWordCount,
            totalExpectedWords: _expectedWordCount,
            alignments: const [],
            transcript: text,
            expectedText: _rawRomanized,
          ),
        ));
      }
      _matchesCounted = total;
    }

    if (result.finalResult) {
      _matchesCounted = 0; // next segment starts fresh
    }
  }

  // ────────────────────────────────────────────────────────
  // Occurrence counting — greedy sequential word-scan
  // ────────────────────────────────────────────────────────

  int _countOccurrences(String transcript) {
    final rawWords = transcript
        .replaceAll('\n', ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (rawWords.isEmpty || _expectedWordCount <= 0) return 0;

    // Detect script → choose the right expected-word list + normalizer.
    final hasDevanagari = transcript.contains(RegExp(r'[\u0900-\u097F]'));
    final expected = hasDevanagari ? _expectedDevWords : _expectedRomWords;
    final norm = hasDevanagari
        ? rawWords.map(_normalizeDev).toList()
        : rawWords.map(_normalizeRom).toList();

    if (expected.isEmpty) return 0;

    int matches = 0;
    int pos = 0;

    while (pos < norm.length) {
      final r = _tryMatchFrom(norm, pos, expected);
      if (r.matched) {
        matches++;
        pos += r.consumed;
      } else {
        pos++;
      }
    }
    return matches;
  }

  /// Try to match the expected word sequence starting at [start] in
  /// [transcript]. Allows noise/filler words between expected words.
  ({bool matched, int consumed}) _tryMatchFrom(
    List<String> transcript,
    int start,
    List<String> expected,
  ) {
    int eIdx = 0; // pointer into expected words
    int tIdx = start; // pointer into transcript words
    int matched = 0;

    while (eIdx < expected.length && tIdx < transcript.length) {
      if (_wordsMatch(transcript[tIdx], expected[eIdx])) {
        matched++;
        eIdx++;
      }
      tIdx++;
      // Don't scan too far ahead for one mantra instance.
      if (tIdx - start > expected.length * 3 + 2) break;
    }

    // Adaptive threshold based on mantra length.
    final double minRatio;
    if (expected.length <= 1) {
      minRatio = 1.0; // 1-word mantras: the word must match
    } else if (expected.length <= 4) {
      minRatio = 0.5; // short mantras: ≥ half the words
    } else {
      minRatio = 0.35; // long mantras: ≥ 35%
    }

    final minRequired = (expected.length * minRatio).ceil().clamp(1, expected.length);

    if (matched >= minRequired) {
      return (matched: true, consumed: max(tIdx - start, 1));
    }
    return (matched: false, consumed: 1);
  }

  // ────────────────────────────────────────────────────────
  // Fuzzy word comparison
  // ────────────────────────────────────────────────────────

  bool _wordsMatch(String a, String b) {
    if (a == b) return true;
    if (a.isEmpty || b.isEmpty) return false;

    // Substring containment — catches morphological variants like
    // "shivaya" in "shivayam", "narayana" in "narayanaya", etc.
    if (a.length >= 3 && b.length >= 3) {
      final shorter = a.length <= b.length ? a : b;
      final longer = a.length > b.length ? a : b;
      if (shorter.length >= longer.length * 0.6 &&
          longer.contains(shorter)) {
        return true;
      }
    }

    // Levenshtein similarity ≥ 0.45.
    final maxLen = max(a.length, b.length);
    final dist = _levenshtein(a, b);
    return (1.0 - dist / maxLen) >= 0.45;
  }

  // ────────────────────────────────────────────────────────
  // Text normalization
  // ────────────────────────────────────────────────────────

  /// Normalize a romanized word: lowercase, strip non-letters,
  /// remove hyphens, collapse long vowels.
  static String _normalizeRom(String word) {
    var s = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    s = s
        .replaceAll('aa', 'a')
        .replaceAll('ee', 'i')
        .replaceAll('oo', 'u');
    return s;
  }

  /// Normalize a Devanagari word: strip punctuation / diacritics
  /// that vary between STT engines.
  static String _normalizeDev(String word) {
    return word
        .replaceAll(RegExp(r'[।॥,.\-\s]'), '')
        .replaceAll('ः', '') // visarga
        .replaceAll('ँ', '') // chandrabindu
        .replaceAll('ं', ''); // anusvara
  }

  // ────────────────────────────────────────────────────────
  // Levenshtein edit distance (inline, no external dep)
  // ────────────────────────────────────────────────────────

  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    if (a == b) return 0;

    final al = a.length, bl = b.length;
    // Space-optimised single-row DP.
    var prev = List.generate(bl + 1, (j) => j);
    var curr = List.filled(bl + 1, 0);

    for (int i = 1; i <= al; i++) {
      curr[0] = i;
      for (int j = 1; j <= bl; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1, // deletion
          curr[j - 1] + 1, // insertion
          prev[j - 1] + cost, // substitution
        ].reduce(min);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[bl];
  }

  // ────────────────────────────────────────────────────────
  // Status & error handling
  // ────────────────────────────────────────────────────────

  void _onStatus(String status) {
    debugPrint('STT status: $status');
    _eventController.add(SttStatusChanged(status: status));

    // Only restart on 'done' — 'notListening' always precedes 'done',
    // so restarting on both causes a double-fire race condition.
    if (status == 'done' && _isActive && !_isPaused) {
      _scheduleRestart(delayMs: 300);
    }
  }

  void _onError(SpeechRecognitionError error) {
    final msg = error.errorMsg;
    debugPrint('STT error: $msg (permanent=${error.permanent})');
    _eventController.add(SttErrorEvent(message: msg));

    // ── Silence / no-match: NOT a real error ──
    // These fire when nobody is speaking. Just restart after a short delay.
    if (msg == 'error_no_match' || msg == 'error_speech_timeout') {
      if (_isActive && !_isPaused) {
        _scheduleRestart(delayMs: 500); // Slightly longer to avoid rapid cycling
      }
      return;
    }

    // ── Client error: SpeechRecognizer restart race ──
    // This happens when restarting too quickly. Use longer backoff.
    if (msg == 'error_client') {
      if (_isActive && !_isPaused) {
        _scheduleRestart(delayMs: 2000); // 2 second backoff
      }
      return;
    }

    // ── Busy: SpeechRecognizer occupied, short retry ──
    if (msg == 'error_busy') {
      if (_isActive && !_isPaused) {
        _scheduleRestart(delayMs: 1000);
      }
      return;
    }

    // ── Real error: network, permission, etc. ──
    _consecutiveRealErrors++;

    // After 8 real errors, try switching locale.
    if (_consecutiveRealErrors == 8 && _localeAttempt == 0) {
      _localeAttempt++;
      _trySwitchLocale();
    }

    if (_consecutiveRealErrors < _maxRealErrors &&
        _isActive &&
        !_isPaused) {
      final backoff = (200 * (1 + _consecutiveRealErrors.clamp(0, 5)))
          .clamp(200, 2000);
      _scheduleRestart(delayMs: backoff);
    } else if (_consecutiveRealErrors >= _maxRealErrors) {
      debugPrint('STT: too many real errors — stopping');
      _eventController
          .add(SttErrorEvent(message: 'Speech recognition unavailable'));
    }
  }

  void _trySwitchLocale() {
    final alternatives = _availableLocales
        .where((l) => l != _selectedLocale)
        .where((l) => l.startsWith('hi') || l.startsWith('en'))
        .toList();
    if (alternatives.isNotEmpty) {
      _selectedLocale = alternatives.first;
      debugPrint('STT: switching locale → $_selectedLocale');
    }
  }

  void _scheduleRestart({int delayMs = 500}) {
    _restartTimer?.cancel();
    _restartTimer = Timer(Duration(milliseconds: delayMs), () {
      if (_isActive && !_isPaused) _beginListening();
    });
  }

  // ────────────────────────────────────────────────────────
  // Dispose
  // ────────────────────────────────────────────────────────

  void dispose() {
    _isActive = false;
    _restartTimer?.cancel();
    _speech.stop();
    _eventController.close();
  }
}
