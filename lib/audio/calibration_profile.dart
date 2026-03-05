/// Calibration profile — stores acoustic templates and thresholds
/// generated during the user's calibration session.
///
/// The profile powers the 6-signal ensemble detector:
///   S1: DTW template match (MFCC sequences)
///   S2: Duration gate (mean ± std of chant duration)
///   S3: Rhythm phase lock (inter-chant period)
///   S4: Spectral envelope (session mean MFCC)
///   S5: Energy contour shape (normalized amplitude envelope)
///   S6: Voiced/unvoiced pattern (ZCR binary pattern)

import 'dart:convert';
import 'dart:typed_data';

// ──────────────────────────────────────────────────────────
// MFCC Template — a single reference chant's feature sequence
// ──────────────────────────────────────────────────────────

/// One calibration recording's worth of MFCC frames.
class MfccTemplate {
  /// Sequence of MFCC vectors, each of length [mfccDim].
  /// Typically 40 coefficients × ~90 frames for a 3s chant.
  final List<Float64List> frames;

  /// Duration of this template in milliseconds.
  final int durationMs;

  /// Normalized energy contour (amplitude envelope downsampled to ~20 points).
  final Float64List energyContour;

  /// Voiced/unvoiced binary pattern (true = voiced, false = unvoiced).
  final List<bool> voicedPattern;

  /// Mean MFCC vector for this template (spectral fingerprint).
  final Float64List meanMfcc;

  const MfccTemplate({
    required this.frames,
    required this.durationMs,
    required this.energyContour,
    required this.voicedPattern,
    required this.meanMfcc,
  });

  /// Number of MFCC frames.
  int get frameCount => frames.length;

  /// Serialize to JSON-friendly map.
  Map<String, dynamic> toJson() => {
        'frames': frames.map((f) => f.toList()).toList(),
        'durationMs': durationMs,
        'energyContour': energyContour.toList(),
        'voicedPattern': voicedPattern,
        'meanMfcc': meanMfcc.toList(),
      };

  factory MfccTemplate.fromJson(Map<String, dynamic> json) {
    return MfccTemplate(
      frames: (json['frames'] as List)
          .map((f) => Float64List.fromList((f as List).cast<double>()))
          .toList(),
      durationMs: json['durationMs'] as int,
      energyContour: Float64List.fromList(
          (json['energyContour'] as List).cast<double>()),
      voicedPattern: (json['voicedPattern'] as List).cast<bool>(),
      meanMfcc:
          Float64List.fromList((json['meanMfcc'] as List).cast<double>()),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Full calibration profile — all data from calibration session
// ──────────────────────────────────────────────────────────

class EnsembleCalibrationProfile {
  /// Reference templates from calibration recordings (typically 3).
  final List<MfccTemplate> templates;

  /// Energy threshold for VAD (60% of calibrated mean energy).
  final double energyThreshold;

  /// Mean chant duration (ms).
  final double meanDurationMs;

  /// Std dev of chant duration (ms).
  final double stdDurationMs;

  /// Mean inter-chant gap (ms) — used as initial rhythm period estimate.
  final double meanGapMs;

  /// Refractory gate (80% of mean gap, clamped to [400, 3000]).
  final int refractoryMs;

  /// Global mean MFCC vector across all templates (spectral fingerprint).
  final Float64List globalMeanMfcc;

  /// Number of MFCC coefficients (dimension).
  final int mfccDim;

  /// Timestamp when this profile was created.
  final DateTime createdAt;

  const EnsembleCalibrationProfile({
    required this.templates,
    required this.energyThreshold,
    required this.meanDurationMs,
    required this.stdDurationMs,
    required this.meanGapMs,
    required this.refractoryMs,
    required this.globalMeanMfcc,
    this.mfccDim = 40,
    required this.createdAt,
  });

  /// Minimum valid duration (μ - 3σ, floor at 200ms).
  double get minDurationMs => (meanDurationMs - 3 * stdDurationMs).clamp(200, double.infinity);

  /// Maximum valid duration (μ + 3σ, cap at 10s).
  double get maxDurationMs => (meanDurationMs + 3 * stdDurationMs).clamp(0, 10000);

  /// Whether this profile has enough data to be useful.
  bool get isValid => templates.length >= 2;

  /// Serialize to JSON string for SharedPreferences storage.
  String serialize() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'templates': templates.map((t) => t.toJson()).toList(),
        'energyThreshold': energyThreshold,
        'meanDurationMs': meanDurationMs,
        'stdDurationMs': stdDurationMs,
        'meanGapMs': meanGapMs,
        'refractoryMs': refractoryMs,
        'globalMeanMfcc': globalMeanMfcc.toList(),
        'mfccDim': mfccDim,
        'createdAt': createdAt.toIso8601String(),
      };

  factory EnsembleCalibrationProfile.fromJson(Map<String, dynamic> json) {
    return EnsembleCalibrationProfile(
      templates: (json['templates'] as List)
          .map((t) => MfccTemplate.fromJson(t as Map<String, dynamic>))
          .toList(),
      energyThreshold: (json['energyThreshold'] as num).toDouble(),
      meanDurationMs: (json['meanDurationMs'] as num).toDouble(),
      stdDurationMs: (json['stdDurationMs'] as num).toDouble(),
      meanGapMs: (json['meanGapMs'] as num).toDouble(),
      refractoryMs: json['refractoryMs'] as int,
      globalMeanMfcc: Float64List.fromList(
          (json['globalMeanMfcc'] as List).cast<double>()),
      mfccDim: json['mfccDim'] as int? ?? 40,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory EnsembleCalibrationProfile.deserialize(String jsonStr) {
    return EnsembleCalibrationProfile.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  /// Build profile from raw calibration recordings.
  ///
  /// [mfccSequences] — list of MFCC frame sequences (one per recorded chant).
  /// [durations] — duration in ms for each recorded chant.
  /// [energyContours] — normalized amplitude envelopes.
  /// [voicedPatterns] — V/UV binary patterns.
  /// [interChantGaps] — gap in ms between consecutive chants.
  factory EnsembleCalibrationProfile.build({
    required List<List<Float64List>> mfccSequences,
    required List<int> durations,
    required List<Float64List> energyContours,
    required List<List<bool>> voicedPatterns,
    required List<int> interChantGaps,
    required double energyThreshold,
    int mfccDim = 40,
  }) {
    // Build individual templates
    final templates = <MfccTemplate>[];
    for (int i = 0; i < mfccSequences.length; i++) {
      final seq = mfccSequences[i];
      // Compute mean MFCC for this template
      final mean = Float64List(mfccDim);
      for (final frame in seq) {
        for (int j = 0; j < mfccDim && j < frame.length; j++) {
          mean[j] += frame[j];
        }
      }
      if (seq.isNotEmpty) {
        for (int j = 0; j < mfccDim; j++) {
          mean[j] /= seq.length;
        }
      }

      templates.add(MfccTemplate(
        frames: seq,
        durationMs: durations[i],
        energyContour: i < energyContours.length
            ? energyContours[i]
            : Float64List(0),
        voicedPattern: i < voicedPatterns.length ? voicedPatterns[i] : [],
        meanMfcc: mean,
      ));
    }

    // Compute duration stats
    final meanDur = durations.isEmpty
        ? 3000.0
        : durations.reduce((a, b) => a + b) / durations.length;
    final variance = durations.isEmpty
        ? 250000.0
        : durations.map((d) => (d - meanDur) * (d - meanDur)).reduce((a, b) => a + b) /
            durations.length;
    final stdDur = variance > 0 ? _sqrt(variance) : 500.0;

    // Compute gap stats
    final meanGap = interChantGaps.isEmpty
        ? 1000.0
        : interChantGaps.reduce((a, b) => a + b) / interChantGaps.length;
    final refMs = (0.8 * meanGap).round().clamp(400, 3000);

    // Compute global mean MFCC
    final globalMean = Float64List(mfccDim);
    int totalFrames = 0;
    for (final t in templates) {
      for (final frame in t.frames) {
        for (int j = 0; j < mfccDim && j < frame.length; j++) {
          globalMean[j] += frame[j];
        }
        totalFrames++;
      }
    }
    if (totalFrames > 0) {
      for (int j = 0; j < mfccDim; j++) {
        globalMean[j] /= totalFrames;
      }
    }

    return EnsembleCalibrationProfile(
      templates: templates,
      energyThreshold: energyThreshold,
      meanDurationMs: meanDur,
      stdDurationMs: stdDur,
      meanGapMs: meanGap,
      refractoryMs: refMs,
      globalMeanMfcc: globalMean,
      mfccDim: mfccDim,
      createdAt: DateTime.now(),
    );
  }
}

double _sqrt(double x) {
  if (x <= 0) return 0;
  double guess = x / 2;
  for (int i = 0; i < 20; i++) {
    guess = (guess + x / guess) / 2;
  }
  return guess;
}
