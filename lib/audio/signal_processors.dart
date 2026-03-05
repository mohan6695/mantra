/// Six independent signal processors for the ensemble detector.
///
/// Each signal takes a candidate audio segment and returns a confidence
/// score [0.0, 1.0]. The ensemble combines all six via weighted vote.
///
/// Edge cases handled per signal:
///   - Cough/sneeze: short duration, wrong energy contour, all-unvoiced
///   - Silence: below energy threshold, zero DTW match
///   - External speech (TV/people): wrong spectral envelope, wrong rhythm
///   - Background noise (fan/traffic): low ZCR contrast, spectral mismatch
///   - Fast chanting: rhythm adapts via EMA, duration gate widens
///   - Whispered chanting: DTW matches (amplitude-normalized), energy gate lowered
///   - Phone fumble/tap: extremely short, wrong V/UV pattern

import 'dart:math' as math;
import 'dart:typed_data';
import 'calibration_profile.dart';

// ──────────────────────────────────────────────────────────
// Audio segment — the unit of detection
// ──────────────────────────────────────────────────────────

/// Preprocessed audio segment from native VAD. Contains all features
/// needed by the six signal processors.
class AudioSegment {
  /// MFCC frame sequence for this segment (native-extracted).
  final List<Float64List> mfccFrames;

  /// Segment duration in milliseconds.
  final int durationMs;

  /// Normalized energy contour (downsampled to ~20 points).
  final Float64List energyContour;

  /// Voiced/unvoiced binary pattern per frame.
  final List<bool> voicedPattern;

  /// Mean MFCC vector for this segment.
  final Float64List meanMfcc;

  /// Peak energy of this segment (for VAD confirmation).
  final double peakEnergy;

  /// Timestamp when this segment started.
  final DateTime timestamp;

  const AudioSegment({
    required this.mfccFrames,
    required this.durationMs,
    required this.energyContour,
    required this.voicedPattern,
    required this.meanMfcc,
    required this.peakEnergy,
    required this.timestamp,
  });

  /// Build from a map received via platform channel.
  factory AudioSegment.fromNative(Map<dynamic, dynamic> map) {
    final mfccRaw = map['mfcc'] as List? ?? [];
    final mfccFrames = mfccRaw
        .map((f) =>
            Float64List.fromList((f as List).map((v) => (v as num).toDouble()).toList()))
        .toList();

    final contourRaw = map['energyContour'] as List? ?? [];
    final energyContour =
        Float64List.fromList(contourRaw.map((v) => (v as num).toDouble()).toList());

    final vuvRaw = map['voicedPattern'] as List? ?? [];
    final voicedPattern = vuvRaw.map((v) => v as bool).toList();

    final meanRaw = map['meanMfcc'] as List? ?? [];
    final meanMfcc =
        Float64List.fromList(meanRaw.map((v) => (v as num).toDouble()).toList());

    return AudioSegment(
      mfccFrames: mfccFrames,
      durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
      energyContour: energyContour,
      voicedPattern: voicedPattern,
      meanMfcc: meanMfcc,
      peakEnergy: (map['peakEnergy'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          (map['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Individual signal result
// ──────────────────────────────────────────────────────────

/// Result from a single signal processor.
class SignalScore {
  final String name;
  final double score; // 0.0 to 1.0
  final bool isHardVeto; // if true, blocks detection regardless of ensemble

  const SignalScore({
    required this.name,
    required this.score,
    this.isHardVeto = false,
  });

  @override
  String toString() =>
      '$name=${(score * 100).toStringAsFixed(0)}%${isHardVeto ? " [VETO]" : ""}';
}

// ──────────────────────────────────────────────────────────
// S1: DTW Template Match
// ──────────────────────────────────────────────────────────

/// Compares incoming MFCC sequence against calibration templates
/// using Dynamic Time Warping. Language-agnostic acoustic matching.
///
/// Edge cases:
///   - Cough → very different spectral shape → low DTW score
///   - Whisper → similar shape but lower amplitude → DTW is amplitude-
///     normalized by MFCC, so still matches
///   - TV speech → different MFCC pattern → low score
///   - Silence → no frames → hard veto
class DtwTemplateSignal {
  /// Maximum DTW distance to still be considered a possible match.
  /// Distances above this get score 0.
  final double rejectionDistance;

  const DtwTemplateSignal({this.rejectionDistance = 150.0});

  SignalScore evaluate(AudioSegment segment, EnsembleCalibrationProfile profile) {
    if (segment.mfccFrames.isEmpty || profile.templates.isEmpty) {
      return const SignalScore(name: 'S1_DTW', score: 0.0, isHardVeto: true);
    }

    double bestScore = 0.0;
    for (final template in profile.templates) {
      if (template.frames.isEmpty) continue;
      final dist = _dtwDistance(segment.mfccFrames, template.frames);
      final score = (1.0 - dist / rejectionDistance).clamp(0.0, 1.0);
      if (score > bestScore) bestScore = score;
    }

    // Hard veto: if even the best template match is terrible
    final veto = bestScore < 0.20;
    return SignalScore(name: 'S1_DTW', score: bestScore, isHardVeto: veto);
  }

  /// Dynamic Time Warping distance between two MFCC frame sequences.
  /// Uses Euclidean distance between individual MFCC vectors.
  /// Runs in O(N*M) where N, M are frame counts.
  double _dtwDistance(List<Float64List> a, List<Float64List> b) {
    final n = a.length;
    final m = b.length;

    // Use Sakoe-Chiba band to limit warping (±30% of lengths)
    final band = math.max(10, (math.max(n, m) * 0.3).ceil());

    // Flat array for cost matrix (row-major, dimensions (n+1) × (m+1))
    final inf = double.infinity;
    final cost = List<double>.filled((n + 1) * (m + 1), inf);
    final w = m + 1; // row width
    cost[0] = 0.0;

    for (int i = 1; i <= n; i++) {
      final jMin = math.max(1, i - band);
      final jMax = math.min(m, i + band);
      for (int j = jMin; j <= jMax; j++) {
        final d = _euclideanDist(a[i - 1], b[j - 1]);
        cost[i * w + j] = d +
            _min3(
              cost[(i - 1) * w + j],
              cost[i * w + (j - 1)],
              cost[(i - 1) * w + (j - 1)],
            );
      }
    }

    final total = cost[n * w + m];
    // Normalize by path length
    return total / (n + m);
  }

  double _euclideanDist(Float64List a, Float64List b) {
    final len = math.min(a.length, b.length);
    double sum = 0.0;
    for (int i = 0; i < len; i++) {
      final d = a[i] - b[i];
      sum += d * d;
    }
    return math.sqrt(sum);
  }

  double _min3(double a, double b, double c) {
    if (a <= b && a <= c) return a;
    if (b <= c) return b;
    return c;
  }
}

// ──────────────────────────────────────────────────────────
// S2: Duration Gate
// ──────────────────────────────────────────────────────────

/// Gaussian penalty on duration deviation from calibrated mean.
///
/// Edge cases:
///   - Cough/sneeze: 100-300ms → typically 3σ+ below mean → near-zero score
///   - Phone tap: <100ms → hard veto
///   - Long pause then resume: >3σ above → hard veto
///   - Fast chanting: duration naturally shortens → adapts via profile update
class DurationGateSignal {
  const DurationGateSignal();

  SignalScore evaluate(AudioSegment segment, EnsembleCalibrationProfile profile) {
    final d = segment.durationMs.toDouble();
    final mu = profile.meanDurationMs;
    final sigma = math.max(profile.stdDurationMs, 100.0); // floor at 100ms

    // Hard veto: physically impossible to be a chant
    if (d < 150 || d > 15000) {
      return const SignalScore(
          name: 'S2_Duration', score: 0.0, isHardVeto: true);
    }

    // Hard veto: beyond 3σ
    if (d < profile.minDurationMs || d > profile.maxDurationMs) {
      return const SignalScore(
          name: 'S2_Duration', score: 0.05, isHardVeto: true);
    }

    // Gaussian score
    final zScore = (d - mu) / sigma;
    final score = math.exp(-0.5 * zScore * zScore);
    return SignalScore(name: 'S2_Duration', score: score);
  }
}

// ──────────────────────────────────────────────────────────
// S3: Rhythm Phase Lock
// ──────────────────────────────────────────────────────────

/// Predicts when the next chant should arrive based on inter-chant period.
/// Uses exponential moving average to track tempo changes.
///
/// Edge cases:
///   - Random noise at wrong time → very low score (off-phase)
///   - User pauses 30s+ → rhythm lock temporarily disabled (neutral 0.5)
///   - Fast/slow transitions → EMA adapts within 3 chants
///   - First 3 chants → neutral score (no rhythm data yet)
class RhythmPhaseLockSignal {
  /// EMA smoothing factor. Higher = faster adaptation to tempo changes.
  final double alpha;

  /// Maximum gap (ms) before rhythm lock resets.
  final int maxGapForLockMs;

  const RhythmPhaseLockSignal({
    this.alpha = 0.25,
    this.maxGapForLockMs = 15000,
  });

  SignalScore evaluate(
    AudioSegment segment,
    RhythmState rhythm,
  ) {
    // Cold start: not enough data
    if (!rhythm.isLocked) {
      return const SignalScore(name: 'S3_Rhythm', score: 0.5);
    }

    // Long pause: rhythm lost, go neutral
    final gap = segment.timestamp.difference(rhythm.lastDetectionTime).inMilliseconds;
    if (gap > maxGapForLockMs) {
      return const SignalScore(name: 'S3_Rhythm', score: 0.5);
    }

    // Expected arrival time
    final expectedGap = rhythm.currentPeriodMs;
    final sigma = math.max(expectedGap * 0.20, 150.0); // 20% tolerance
    final zScore = (gap - expectedGap) / sigma;
    final score = math.exp(-0.5 * zScore * zScore);

    return SignalScore(name: 'S3_Rhythm', score: score);
  }
}

/// Tracks inter-chant rhythm (period estimation via EMA).
class RhythmState {
  double currentPeriodMs;
  DateTime lastDetectionTime;
  int chantCount;
  final double alpha;

  RhythmState({
    required this.currentPeriodMs,
    required this.lastDetectionTime,
    this.chantCount = 0,
    this.alpha = 0.25,
  });

  /// Whether we have enough data for rhythm lock.
  bool get isLocked => chantCount >= 3;

  /// Update after a confirmed detection.
  void onDetection(DateTime timestamp) {
    final gap = timestamp.difference(lastDetectionTime).inMilliseconds.toDouble();

    if (chantCount >= 2 && gap > 0 && gap < 15000) {
      // EMA update
      currentPeriodMs = (1 - alpha) * currentPeriodMs + alpha * gap;
    } else if (chantCount < 2 && gap > 0 && gap < 15000) {
      // Bootstrap: simple average
      currentPeriodMs =
          (currentPeriodMs * chantCount + gap) / (chantCount + 1);
    }

    lastDetectionTime = timestamp;
    chantCount++;
  }

  /// Reset after a long pause.
  void resetLock() {
    chantCount = 0;
  }
}

// ──────────────────────────────────────────────────────────
// S4: Spectral Envelope Consistency
// ──────────────────────────────────────────────────────────

/// Compares candidate's mean MFCC vector against the session-level
/// voice profile via cosine similarity.
///
/// Edge cases:
///   - TV/other person: completely different spectral shape → low cosine
///   - Fan/traffic noise: broadband → very different from voice spectrum
///   - Same person coughing: different spectral shape than singing → low
///   - Whisper: attenuated higher harmonics but similar shape → moderate
class SpectralEnvelopeSignal {
  const SpectralEnvelopeSignal();

  SignalScore evaluate(AudioSegment segment, SessionVoiceProfile profile) {
    if (segment.meanMfcc.isEmpty || profile.meanMfcc.isEmpty) {
      return const SignalScore(name: 'S4_Spectral', score: 0.5);
    }

    final sim = _cosineSimilarity(segment.meanMfcc, profile.meanMfcc);
    // cosine similarity: [-1, 1] → remap to [0, 1]
    final score = ((sim + 1.0) / 2.0).clamp(0.0, 1.0);

    return SignalScore(name: 'S4_Spectral', score: score);
  }

  double _cosineSimilarity(Float64List a, Float64List b) {
    final len = math.min(a.length, b.length);
    double dotProd = 0, normA = 0, normB = 0;
    for (int i = 0; i < len; i++) {
      dotProd += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = math.sqrt(normA) * math.sqrt(normB);
    if (denom < 1e-12) return 0.0;
    return dotProd / denom;
  }
}

/// Rolling session voice profile — updated with each accepted chant.
class SessionVoiceProfile {
  Float64List meanMfcc;
  int sampleCount;
  final int mfccDim;

  SessionVoiceProfile({required this.mfccDim})
      : meanMfcc = Float64List(mfccDim),
        sampleCount = 0;

  /// Seed from calibration profile.
  void seedFromCalibration(EnsembleCalibrationProfile profile) {
    meanMfcc = Float64List.fromList(profile.globalMeanMfcc);
    sampleCount = profile.templates.length;
  }

  /// Update with a new accepted chant's mean MFCC.
  void update(Float64List chantMeanMfcc) {
    sampleCount++;
    final n = sampleCount.toDouble();
    for (int i = 0; i < mfccDim && i < chantMeanMfcc.length; i++) {
      // Running mean update
      meanMfcc[i] = meanMfcc[i] * ((n - 1) / n) + chantMeanMfcc[i] / n;
    }
  }
}

// ──────────────────────────────────────────────────────────
// S5: Energy Contour Shape
// ──────────────────────────────────────────────────────────

/// Compares amplitude envelope shape via 1D DTW.
/// Independent from S1 (spectral content) — only looks at loudness pattern.
///
/// Edge cases:
///   - Cough: single energy spike → wrong contour → low score
///   - Sneeze: burst-silence-burst → wrong contour
///   - Clap: single impulse → very different from multi-peak mantra
///   - Whisper: same contour shape at lower amplitude (normalized) → matches
class EnergyContourSignal {
  final double rejectionDistance;

  const EnergyContourSignal({this.rejectionDistance = 5.0});

  SignalScore evaluate(AudioSegment segment, EnsembleCalibrationProfile profile) {
    if (segment.energyContour.isEmpty || profile.templates.isEmpty) {
      return const SignalScore(name: 'S5_Contour', score: 0.5);
    }

    double bestScore = 0.0;
    for (final template in profile.templates) {
      if (template.energyContour.isEmpty) continue;

      final dist = _dtw1d(
        _normalize(segment.energyContour),
        _normalize(template.energyContour),
      );
      final score = (1.0 - dist / rejectionDistance).clamp(0.0, 1.0);
      if (score > bestScore) bestScore = score;
    }

    return SignalScore(name: 'S5_Contour', score: bestScore);
  }

  /// Normalize a contour to [0, 1] range.
  Float64List _normalize(Float64List contour) {
    if (contour.isEmpty) return contour;
    double minVal = double.infinity, maxVal = double.negativeInfinity;
    for (final v in contour) {
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }
    final range = maxVal - minVal;
    if (range < 1e-12) return Float64List(contour.length); // all zeros
    final result = Float64List(contour.length);
    for (int i = 0; i < contour.length; i++) {
      result[i] = (contour[i] - minVal) / range;
    }
    return result;
  }

  /// 1-dimensional DTW distance between two contours.
  double _dtw1d(Float64List a, Float64List b) {
    final n = a.length;
    final m = b.length;
    if (n == 0 || m == 0) return rejectionDistance;

    final band = math.max(5, (math.max(n, m) * 0.3).ceil());
    final inf = double.infinity;
    final cost = List<double>.filled((n + 1) * (m + 1), inf);
    final w = m + 1;
    cost[0] = 0.0;

    for (int i = 1; i <= n; i++) {
      final jMin = math.max(1, i - band);
      final jMax = math.min(m, i + band);
      for (int j = jMin; j <= jMax; j++) {
        final d = (a[i - 1] - b[j - 1]).abs();
        final prev = [
          cost[(i - 1) * w + j],
          cost[i * w + (j - 1)],
          cost[(i - 1) * w + (j - 1)],
        ].reduce(math.min);
        cost[i * w + j] = d + prev;
      }
    }

    return cost[n * w + m] / (n + m);
  }
}

// ──────────────────────────────────────────────────────────
// S6: Voiced/Unvoiced Pattern
// ──────────────────────────────────────────────────────────

/// Compares the voiced/unvoiced (V/UV) binary pattern of a candidate
/// against templates. Uses Hamming distance after DTW alignment.
///
/// Edge cases:
///   - Cough: mostly unvoiced → high Hamming distance from mantra pattern
///   - Sneeze: all unvoiced burst → very different pattern
///   - Fan noise: uniform ZCR → random V/UV → low match
///   - Humming/singing: all voiced → matches if mantra is also voice-dominant
class VoicedUnvoicedSignal {
  const VoicedUnvoicedSignal();

  SignalScore evaluate(AudioSegment segment, EnsembleCalibrationProfile profile) {
    if (segment.voicedPattern.isEmpty || profile.templates.isEmpty) {
      return const SignalScore(name: 'S6_VUV', score: 0.5);
    }

    double bestScore = 0.0;
    for (final template in profile.templates) {
      if (template.voicedPattern.isEmpty) continue;
      final score = _patternSimilarity(
          segment.voicedPattern, template.voicedPattern);
      if (score > bestScore) bestScore = score;
    }

    return SignalScore(name: 'S6_VUV', score: bestScore);
  }

  /// Compare two V/UV patterns using Hamming distance after
  /// downsampling to equal length.
  double _patternSimilarity(List<bool> a, List<bool> b) {
    // Downsample both to min length for comparison
    final targetLen = math.min(a.length, b.length).clamp(4, 50);
    final da = _downsample(a, targetLen);
    final db = _downsample(b, targetLen);

    int matches = 0;
    for (int i = 0; i < targetLen; i++) {
      if (da[i] == db[i]) matches++;
    }
    return matches / targetLen;
  }

  /// Downsample a boolean pattern to a target length via majority vote.
  List<bool> _downsample(List<bool> pattern, int targetLen) {
    if (pattern.length == targetLen) return pattern;
    final result = <bool>[];
    final binSize = pattern.length / targetLen;
    for (int i = 0; i < targetLen; i++) {
      final start = (i * binSize).floor();
      final end = ((i + 1) * binSize).ceil().clamp(0, pattern.length);
      int voicedCount = 0;
      for (int j = start; j < end; j++) {
        if (pattern[j]) voicedCount++;
      }
      result.add(voicedCount > (end - start) / 2);
    }
    return result;
  }
}
