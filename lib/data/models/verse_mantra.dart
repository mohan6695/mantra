/// Data models for long verse mantras with word-level segmentation.
///
/// A VerseMantra holds the complete text of a multi-line mantra, broken
/// into lines and individual words. The audio tracker advances through
/// words sequentially as the user chants.

class VerseWord {
  /// Position of this word across the entire verse (0-indexed).
  final int globalIndex;

  /// Which line this word belongs to (0-indexed).
  final int lineIndex;

  /// Position within its line (0-indexed).
  final int wordIndexInLine;

  /// Devanagari text of this word.
  final String devanagari;

  /// Romanized/transliterated text.
  final String romanized;

  /// Estimated syllable count — used for timing validation.
  final int syllableCount;

  const VerseWord({
    required this.globalIndex,
    required this.lineIndex,
    required this.wordIndexInLine,
    required this.devanagari,
    required this.romanized,
    required this.syllableCount,
  });

  /// Estimated chanting duration in ms based on syllable count.
  /// Average chanting rate: ~200ms per syllable.
  int get estimatedDurationMs => syllableCount * 200;
}

class VerseLine {
  /// Line index (0-indexed).
  final int index;

  /// Full line text in Devanagari.
  final String devanagari;

  /// Full line text romanized.
  final String romanized;

  /// Words in this line.
  final List<VerseWord> words;

  const VerseLine({
    required this.index,
    required this.devanagari,
    required this.romanized,
    required this.words,
  });

  int get wordCount => words.length;
}

class VerseMantra {
  /// Unique ID.
  final String id;

  /// Display name.
  final String name;

  /// Short description.
  final String description;

  /// Language tag (e.g. 'sa' for Sanskrit, 'hi' for Hindi).
  final String language;

  /// Lines of the verse.
  final List<VerseLine> lines;

  const VerseMantra({
    required this.id,
    required this.name,
    required this.description,
    required this.language,
    required this.lines,
  });

  /// Total word count across all lines.
  int get totalWords => lines.fold(0, (sum, l) => sum + l.wordCount);

  /// Total line count.
  int get totalLines => lines.length;

  /// Get a word by its global index.
  VerseWord? wordAt(int globalIndex) {
    for (final line in lines) {
      for (final word in line.words) {
        if (word.globalIndex == globalIndex) return word;
      }
    }
    return null;
  }

  /// Get the line that contains a given global word index.
  VerseLine? lineForWord(int globalIndex) {
    final word = wordAt(globalIndex);
    if (word == null) return null;
    return lines[word.lineIndex];
  }
}
