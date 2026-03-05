import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../audio/audio_channel.dart';
import '../../audio/calibration_profile.dart';
import '../../core/constants.dart';
import '../../core/providers.dart';

/// 4-step calibration flow:
///   1. Microphone check (permission + live level meter)
///   2. Voice sample recording (3 chants — MFCC extraction)
///   3. Build & save ensemble calibration profile
///   4. Confirmation
class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  int _step = 0;
  bool _micReady = false;
  double _liveLevel = 0;
  StreamSubscription? _levelSub;
  Timer? _levelTimer;

  // ── Calibration data ──────────────────────────────
  static const int _requiredSamples = 3;
  final List<Map<String, dynamic>> _rawSamples = [];
  bool _isRecording = false;
  bool _isSaving = false;
  String? _saveError;
  EnsembleCalibrationProfile? _builtProfile;

  @override
  void dispose() {
    _levelSub?.cancel();
    _levelTimer?.cancel();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 3) setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibration'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_step) {
            0 => _buildMicCheck(theme),
            1 => _buildVoiceSampling(theme),
            2 => _buildSaveProfile(theme),
            3 => _buildConfirmation(theme),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }

  // ── Step 1: Mic Check ────────────────────────────────────

  Widget _buildMicCheck(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIndicator(current: 0, total: 4),
        const SizedBox(height: 24),
        Text('Microphone Check',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'Make sure your microphone is working. Tap "Test" and speak — '
          'you should see the level meter respond.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),

        // Level meter
        LinearProgressIndicator(
          value: _liveLevel.clamp(0, 1),
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 8),
        Text('Level: ${(_liveLevel * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall),
        const SizedBox(height: 24),

        Row(
          children: [
            OutlinedButton(
              onPressed: _micReady ? null : _startMicTest,
              child: const Text('Test Microphone'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _micReady ? _nextStep : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _startMicTest() async {
    await AudioChannel.startEngine(mode: 'mic_test');

    // Poll live level periodically
    _levelTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      try {
        final level = await AudioChannel.getLiveLevel();
        if (mounted) {
          setState(() {
            _liveLevel = level;
            if (_liveLevel > 0.05) _micReady = true;
          });
        }
      } catch (_) {}
    });

    // Auto-stop after 5 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      _levelTimer?.cancel();
      await AudioChannel.stopEngine();
      if (mounted && !_micReady) {
        setState(() => _micReady = true); // allow proceeding anyway
      }
    });
  }

  // ── Step 2: Voice Sampling (MFCC extraction) ─────────────

  Widget _buildVoiceSampling(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIndicator(current: 1, total: 4),
        const SizedBox(height: 24),
        Text('Voice Sampling',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'Chant your mantra $_requiredSamples times at your normal pace. '
          'Tap "Record" before each chant and "Stop" when finished. '
          'This builds an acoustic template of YOUR voice.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),

        // Progress indicators for each sample
        ...List.generate(_requiredSamples, (i) {
          final captured = i < _rawSamples.length;
          final isCurrentRecording = i == _rawSamples.length && _isRecording;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                  captured
                      ? Icons.check_circle
                      : isCurrentRecording
                          ? Icons.mic
                          : Icons.circle_outlined,
                  color: captured
                      ? Colors.green
                      : isCurrentRecording
                          ? Colors.red
                          : theme.colorScheme.outline,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sample ${i + 1}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: captured ? FontWeight.w600 : FontWeight.normal,
                    color: isCurrentRecording ? Colors.red : null,
                  ),
                ),
                if (captured && i < _rawSamples.length) ...[
                  const Spacer(),
                  Text(
                    '${_rawSamples[i]['durationMs']}ms',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (isCurrentRecording) ...[
                  const Spacer(),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 24),

        // Record/Stop button
        Center(
          child: _isRecording
              ? FilledButton.icon(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Recording'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                )
              : FilledButton.icon(
                  onPressed: _rawSamples.length < _requiredSamples
                      ? _startRecording
                      : null,
                  icon: const Icon(Icons.mic),
                  label: Text(
                    _rawSamples.isEmpty
                        ? 'Record Sample 1'
                        : _rawSamples.length < _requiredSamples
                            ? 'Record Sample ${_rawSamples.length + 1}'
                            : 'All samples captured',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed:
                _rawSamples.length >= AppConstants.minCalibrationRecordings
                    ? _nextStep
                    : null,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Future<void> _startRecording() async {
    setState(() => _isRecording = true);
    await AudioChannel.startEngine(mode: 'calibration');
    await AudioChannel.startCalibrationRecording();
  }

  Future<void> _stopRecording() async {
    try {
      final sample = await AudioChannel.stopCalibrationRecording();
      if (sample != null) {
        _rawSamples.add(sample);
      }
    } catch (e) {
      debugPrint('Calibration recording error: $e');
    } finally {
      await AudioChannel.stopEngine();
      if (mounted) setState(() => _isRecording = false);
    }
  }

  // ── Step 3: Build & Save Profile ─────────────────────────

  Widget _buildSaveProfile(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIndicator(current: 2, total: 4),
        const SizedBox(height: 24),
        Text('Building Profile',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'Your ${_rawSamples.length} voice sample(s) will be processed to '
          'build an acoustic fingerprint for detection.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),

        if (_builtProfile != null) ...[
          _InfoRow(
              label: 'Templates',
              value: '${_builtProfile!.templates.length}'),
          _InfoRow(
              label: 'Energy threshold',
              value: _builtProfile!.energyThreshold.toStringAsFixed(4)),
          _InfoRow(
              label: 'Mean duration',
              value: '${_builtProfile!.meanDurationMs.toStringAsFixed(0)}ms'),
          _InfoRow(
              label: 'Refractory gap',
              value: '${_builtProfile!.refractoryMs}ms'),
          _InfoRow(
              label: 'MFCC dimensions',
              value: '${_builtProfile!.mfccDim}'),
          const SizedBox(height: 16),
        ],

        if (_saveError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(_saveError!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error)),
          ),

        Center(
          child: _isSaving
              ? const CircularProgressIndicator()
              : FilledButton(
                  onPressed: _buildAndSaveProfile,
                  child: Text(
                      _builtProfile == null ? 'Build Profile' : 'Save & Continue'),
                ),
        ),
      ],
    );
  }

  Future<void> _buildAndSaveProfile() async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      // Build MfccTemplates from raw calibration samples
      final templates = <MfccTemplate>[];
      final durations = <double>[];
      final gaps = <double>[];

      for (int i = 0; i < _rawSamples.length; i++) {
        final sample = _rawSamples[i];

        // Parse MFCC frames from native
        final rawFrames = sample['mfccFrames'] as List?;
        if (rawFrames == null || rawFrames.isEmpty) {
          setState(() => _saveError = 'Sample ${i + 1} has no MFCC data');
          return;
        }

        final mfccFrames = rawFrames
            .map((f) => Float64List.fromList(
                (f as List).map((v) => (v as num).toDouble()).toList()))
            .toList();

        final durationMs = (sample['durationMs'] as num).toInt();
        durations.add(durationMs.toDouble());

        final rawEnergy = sample['energyContour'] as List?;
        final energyContour = Float64List.fromList(
            rawEnergy?.map((v) => (v as num).toDouble()).toList() ?? []);

        final rawVoiced = sample['voicedPattern'] as List?;
        final voicedPattern =
            rawVoiced?.map((v) => v as bool).toList() ?? [];

        // Compute mean MFCC across all frames
        final dim = mfccFrames.first.length;
        final meanMfccList = List.filled(dim, 0.0);
        for (final frame in mfccFrames) {
          for (int d = 0; d < dim; d++) {
            meanMfccList[d] += frame[d];
          }
        }
        for (int d = 0; d < dim; d++) {
          meanMfccList[d] /= mfccFrames.length;
        }
        final meanMfcc = Float64List.fromList(meanMfccList);

        templates.add(MfccTemplate(
          frames: mfccFrames,
          durationMs: durationMs,
          energyContour: energyContour,
          voicedPattern: voicedPattern,
          meanMfcc: meanMfcc,
        ));

        // Compute inter-sample gaps
        if (i > 0) {
          // approximate gap from durations (actual timestamps not available)
          gaps.add(1000.0); // default 1s gap estimate for calibration
        }
      }

      // Compute statistics
      final meanDuration =
          durations.reduce((a, b) => a + b) / durations.length;
      double stdDuration = 0;
      if (durations.length > 1) {
        final variance = durations
                .map((d) => (d - meanDuration) * (d - meanDuration))
                .reduce((a, b) => a + b) /
            (durations.length - 1);
        stdDuration = variance > 0 ? _sqrt(variance) : meanDuration * 0.2;
      } else {
        stdDuration = meanDuration * 0.2;
      }

      final double meanGap =
          gaps.isNotEmpty ? gaps.reduce((a, b) => a + b) / gaps.length : 1000.0;

      // Compute global mean MFCC
      final dim = templates.first.meanMfcc.length;
      final globalMeanList = List.filled(dim, 0.0);
      for (final t in templates) {
        for (int d = 0; d < dim; d++) {
          globalMeanList[d] += t.meanMfcc[d];
        }
      }
      for (int d = 0; d < dim; d++) {
        globalMeanList[d] /= templates.length;
      }
      final globalMean = Float64List.fromList(globalMeanList);

      // Energy threshold: 60% of minimum peak energy across samples
      final minPeak = _rawSamples
          .map((s) => (s['peakEnergy'] as num?)?.toDouble() ?? 0.01)
          .reduce((a, b) => a < b ? a : b);
      final energyThreshold = 0.6 * minPeak;

      // Refractory: 80% of mean gap, clamped to safe range
      final refractoryMs = (0.8 * meanGap).round().clamp(400, 3000);

      _builtProfile = EnsembleCalibrationProfile(
        templates: templates,
        energyThreshold: energyThreshold,
        meanDurationMs: meanDuration,
        stdDurationMs: stdDuration,
        meanGapMs: meanGap,
        refractoryMs: refractoryMs,
        globalMeanMfcc: globalMean,
        mfccDim: dim,
        createdAt: DateTime.now(),
      );

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_builtProfile!.toJson());
      await prefs.setString(AppConstants.calibrationProfileKey, json);

      // Send to native engine
      await AudioChannel.updateEnsembleCalibration(_builtProfile!);

      // Mark calibration complete
      ref.read(isCalibrationCompleteProvider.notifier).state = true;

      if (mounted) {
        setState(() {});
        _nextStep();
      }
    } catch (e) {
      setState(() => _saveError = 'Error building profile: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Simple sqrt for Dart (dart:math would work too, but avoids import).
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  // ── Step 4: Confirmation ─────────────────────────────────

  Widget _buildConfirmation(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIndicator(current: 3, total: 4),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Icon(Icons.check_circle,
                  size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Calibration Complete!',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_builtProfile != null)
                Text(
                  '${_builtProfile!.templates.length} voice templates built\n'
                  'Duration: ${_builtProfile!.meanDurationMs.toStringAsFixed(0)}ms '
                  '(±${_builtProfile!.stdDurationMs.toStringAsFixed(0)}ms)\n'
                  'Detection ready with 6-signal ensemble',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(total, (i) {
        final isActive = i <= current;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withAlpha(60),
            ),
          ),
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
