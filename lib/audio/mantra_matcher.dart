/// Fuzzy text matching engine for comparing ASR transcripts to expected mantra text.
///
/// Handles:
/// - Devanagari ↔ Roman script comparison
/// - Phonetic variants (shivaya vs shivāya vs shivay)
/// - Partial matches for long mantras
/// - Word-level alignment for verse tracking

import 'dart:math';

// ──────────────────────────────────────────────────────────
// Match result models
// ──────────────────────────────────────────────────────────

/// Result of matching a transcript against expected mantra text.
class MantraMatchResult {
  /// Overall match confidence (0.0 to 1.0).
  final double confidence;

  /// Whether the match is considered valid (confidence ≥ threshold).
  final bool isMatch;

  /// Number of words matched.
  final int matchedWords;

  /// Total words in expected text.
  final int totalExpectedWords;

  /// Per-word alignment results.
  final List<WordAlignment> alignments;

  /// Raw transcript from ASR.
  final String transcript;

  /// Expected text that was matched against.
  final String expectedText;

  const MantraMatchResult({
    required this.confidence,
    required this.isMatch,
    required this.matchedWords,
    required this.totalExpectedWords,
    required this.alignments,
    required this.transcript,
    required this.expectedText,
  });

  @override
  String toString() =>
      'MantraMatch(${(confidence * 100).toStringAsFixed(1)}%, '
      '$matchedWords/$totalExpectedWords words, isMatch=$isMatch)';
}

/// Alignment of a single word between transcript and expected text.
class WordAlignment {
  final int expectedIndex;
  final String expectedWord;
  final String? matchedWord;
  final double similarity;
  final bool isMatched;

  const WordAlignment({
    required this.expectedIndex,
    required this.expectedWord,
    this.matchedWord,
    required this.similarity,
    required this.isMatched,
  });
}

// ──────────────────────────────────────────────────────────
// Phonetic normalization
// ──────────────────────────────────────────────────────────

/// Common phonetic variant mappings for Indian language mantras.
final Map<String, String> _phoneticNormalizations = {
  // Long vowels → short
  'aa': 'a', 'ee': 'i', 'oo': 'u', 'ā': 'a', 'ī': 'i', 'ū': 'u',
  // Aspirated consonants
  'kh': 'k', 'gh': 'g', 'ch': 'c', 'jh': 'j',
  'th': 't', 'dh': 'd', 'ph': 'p', 'bh': 'b',
  // Retroflex
  'ṭ': 't', 'ḍ': 'd', 'ṇ': 'n', 'ṣ': 'sh',
  // Sibilants
  'sh': 's', 'ś': 's', 'ṣ': 's',
  // Visarga and anusvara
  'ḥ': 'h', 'ṃ': 'm', 'ṁ': 'm',
  // Common variants
  'v': 'w', 'ya': 'ia',
};

/// Normalize a romanized word for phonetic comparison.
String _normalizePhonetic(String word) {
  var result = word.toLowerCase().trim();

  // Remove punctuation
  result = result.replaceAll(RegExp('[,.\\-;:!?।॥\'"]+'), '');

  // Apply phonetic normalizations
  for (final entry in _phoneticNormalizations.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }

  // Remove doubled consonants
  result = result.replaceAll(RegExp(r'(.)\1'), r'$1');

  return result;
}

/// Normalize Devanagari text (remove virama, nukta, normalize matras).
String _normalizeDevanagari(String text) {
  var result = text.trim();
  // Remove common punctuation
  result = result.replaceAll(RegExp(r'[।॥,.\s]+'), ' ').trim();
  // Normalize visarga & anusvara
  result = result.replaceAll('ँ', 'ं');
  return result;
}

// ──────────────────────────────────────────────────────────
// Similarity functions
// ──────────────────────────────────────────────────────────

/// Compute Levenshtein edit distance between two strings.
int _editDistance(String a, String b) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final matrix = List.generate(
    a.length + 1,
    (i) => List.generate(b.length + 1, (j) => 0),
  );

  for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
  for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost,
      ].reduce(min);
    }
  }

  return matrix[a.length][b.length];
}

/// Normalized similarity between two strings (0.0 to 1.0).
double _stringSimilarity(String a, String b) {
  if (a.isEmpty && b.isEmpty) return 1.0;
  if (a.isEmpty || b.isEmpty) return 0.0;
  final maxLen = max(a.length, b.length);
  final distance = _editDistance(a, b);
  return 1.0 - (distance / maxLen);
}

/// Phonemic similarity — normalizes both strings first.
double _phoneticSimilarity(String a, String b) {
  final na = _normalizePhonetic(a);
  final nb = _normalizePhonetic(b);
  return _stringSimilarity(na, nb);
}

// ──────────────────────────────────────────────────────────
// MantraMatcher — the main matching engine
// ──────────────────────────────────────────────────────────

class MantraMatcher {
  /// Minimum similarity for a word to be considered matched.
  final double wordMatchThreshold;

  /// Minimum overall confidence for a mantra to be considered detected.
  final double mantraMatchThreshold;

  const MantraMatcher({
    this.wordMatchThreshold = 0.55,
    this.mantraMatchThreshold = 0.50,
  });

  /// Match a transcript against a single expected mantra text.
  ///
  /// [transcript] — text from Sarvam ASR (verbatim mode).
  /// [expectedDevanagari] — expected text in Devanagari.
  /// [expectedRomanized] — expected text romanized.
  MantraMatchResult matchMantra({
    required String transcript,
    required String expectedDevanagari,
    required String expectedRomanized,
  }) {
    final transcriptWords = transcript
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final expectedDevWords = expectedDevanagari
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final expectedRomWords = expectedRomanized
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (transcriptWords.isEmpty || expectedDevWords.isEmpty) {
      return MantraMatchResult(
        confidence: 0.0,
        isMatch: false,
        matchedWords: 0,
        totalExpectedWords: expectedDevWords.length,
        alignments: [],
        transcript: transcript,
        expectedText: expectedDevanagari,
      );
    }

    // Try matching against both Devanagari and romanized versions
    final devAlignments =
        _alignWords(transcriptWords, expectedDevWords, isDevanagari: true);
    final romAlignments =
        _alignWords(transcriptWords, expectedRomWords, isDevanagari: false);

    // Use whichever alignment is better
    final devScore = devAlignments.isEmpty
        ? 0.0
        : devAlignments.where((a) => a.isMatched).length /
            devAlignments.length;
    final romScore = romAlignments.isEmpty
        ? 0.0
        : romAlignments.where((a) => a.isMatched).length /
            romAlignments.length;

    final alignments = devScore >= romScore ? devAlignments : romAlignments;
    final matchedWords = alignments.where((a) => a.isMatched).length;
    final confidence = alignments.isEmpty
        ? 0.0
        : matchedWords / alignments.length;

    return MantraMatchResult(
      confidence: confidence,
      isMatch: confidence >= mantraMatchThreshold,
      matchedWords: matchedWords,
      totalExpectedWords: alignments.length,
      alignments: alignments,
      transcript: transcript,
      expectedText: expectedDevanagari,
    );
  }

  /// Match a transcript against multiple mantras, return the best match.
  ///
  /// Each entry: {'name', 'devanagari', 'romanized'}
  ({MantraMatchResult result, int mantraIndex})? matchBestMantra({
    required String transcript,
    required List<Map<String, String>> mantras,
  }) {
    MantraMatchResult? bestResult;
    int bestIndex = -1;

    for (int i = 0; i < mantras.length; i++) {
      final m = mantras[i];
      final result = matchMantra(
        transcript: transcript,
        expectedDevanagari: m['devanagari'] ?? '',
        expectedRomanized: m['romanized'] ?? '',
      );
      if (bestResult == null || result.confidence > bestResult.confidence) {
        bestResult = result;
        bestIndex = i;
      }
    }

    if (bestResult == null || !bestResult.isMatch) return null;
    return (result: bestResult, mantraIndex: bestIndex);
  }

  /// Align transcript words to expected words using dynamic programming.
  ///
  /// For verse tracking: aligns ASR output to the verse text and returns
  /// the position of the last matched word.
  ({int lastMatchedIndex, double confidence, List<WordAlignment> alignments})
      alignToVerse({
    required String transcript,
    required List<String> expectedWords,
    int startFromIndex = 0,
  }) {
    final transcriptWords = transcript
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (transcriptWords.isEmpty) {
      return (lastMatchedIndex: startFromIndex, confidence: 0.0, alignments: []);
    }

    // Search window: from startFromIndex to startFromIndex + 2*transcript length
    final searchEnd = min(
      expectedWords.length,
      startFromIndex + transcriptWords.length * 3,
    );
    final searchStart = max(0, startFromIndex - 2);
    final searchWords = expectedWords.sublist(searchStart, searchEnd);

    final alignments = <WordAlignment>[];
    int bestMatchEnd = startFromIndex;
    int searchIdx = 0;

    for (final tWord in transcriptWords) {
      double bestSim = 0.0;
      int bestJ = -1;

      // Look ahead in search window
      for (int j = searchIdx; j < searchWords.length && j < searchIdx + 4; j++) {
        final sim = _phoneticSimilarity(tWord, searchWords[j]);
        if (sim > bestSim) {
          bestSim = sim;
          bestJ = j;
        }
      }

      if (bestJ >= 0 && bestSim >= wordMatchThreshold) {
        final absIdx = searchStart + bestJ;
        alignments.add(WordAlignment(
          expectedIndex: absIdx,
          expectedWord: searchWords[bestJ],
          matchedWord: tWord,
          similarity: bestSim,
          isMatched: true,
        ));
        bestMatchEnd = absIdx + 1;
        searchIdx = bestJ + 1;
      } else {
        alignments.add(WordAlignment(
          expectedIndex: -1,
          expectedWord: '',
          matchedWord: tWord,
          similarity: bestSim,
          isMatched: false,
        ));
      }
    }

    final matched = alignments.where((a) => a.isMatched).length;
    final confidence =
        alignments.isEmpty ? 0.0 : matched / alignments.length;

    return (
      lastMatchedIndex: bestMatchEnd,
      confidence: confidence,
      alignments: alignments,
    );
  }

  /// Internal word alignment.
  List<WordAlignment> _alignWords(
    List<String> transcriptWords,
    List<String> expectedWords, {
    required bool isDevanagari,
  }) {
    final alignments = <WordAlignment>[];
    int searchStart = 0;

    for (int i = 0; i < expectedWords.length; i++) {
      double bestSim = 0.0;
      String? bestMatch;

      // Search in transcript words around expected position
      final lo = max(0, searchStart - 1);
      final hi = min(transcriptWords.length, searchStart + 3);

      for (int j = lo; j < hi; j++) {
        final sim = isDevanagari
            ? _stringSimilarity(
                _normalizeDevanagari(transcriptWords[j]),
                _normalizeDevanagari(expectedWords[i]))
            : _phoneticSimilarity(transcriptWords[j], expectedWords[i]);

        if (sim > bestSim) {
          bestSim = sim;
          bestMatch = transcriptWords[j];
          searchStart = j + 1;
        }
      }

      alignments.add(WordAlignment(
        expectedIndex: i,
        expectedWord: expectedWords[i],
        matchedWord: bestSim >= wordMatchThreshold ? bestMatch : null,
        similarity: bestSim,
        isMatched: bestSim >= wordMatchThreshold,
      ));
    }

    return alignments;
  }
}
