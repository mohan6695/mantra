import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/audio_channel.dart';

/// 4-step calibration flow:
///   1. Microphone check (permission + live level meter)
///   2. Voice sample recording (3 chants per mantra)
///   3. Save calibration profile
///   4. Confirmation
class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  int _step = 0; // 0-based
  bool _micReady = false;
  double _liveLevel = 0;
  StreamSubscription? _levelSub;

  // Calibration results
  double _energyThreshold = 0.01;
  int _refractoryMs = 800;
  final List<double> _energySamples = [];
  final List<int> _gapSamples = [];

  @override
  void dispose() {
    _levelSub?.cancel();
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
    // Start a short audio engine session just for mic testing
    await AudioChannel.startEngine(mantras: [], threshold: 0.5);

    // Listen for detection events as a proxy for mic level
    _levelSub = AudioChannel.detectionStream.listen((event) {
      setState(() {
        _liveLevel = event.confidence;
        if (_liveLevel > 0.05) _micReady = true;
      });
    });

    // Auto-stop after 5 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      await AudioChannel.stopEngine();
      _levelSub?.cancel();
      if (mounted && !_micReady) {
        setState(() => _micReady = true); // allow proceeding anyway
      }
    });
  }

  // ── Step 2: Voice Sampling ───────────────────────────────

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
          'Chant naturally 3 times at your normal pace. '
          'This helps calibrate the detection sensitivity for your voice.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),

        // Sampling button
        Center(
          child: FilledButton.icon(
            onPressed: _runSampling,
            icon: const Icon(Icons.mic),
            label: const Text('Start Recording (10s)'),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (_energySamples.isNotEmpty)
          Text(
            'Captured ${_energySamples.length} energy samples, '
            '${_gapSamples.length} gap measurements.',
            style: theme.textTheme.bodySmall,
          ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _energySamples.isNotEmpty ? _nextStep : null,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Future<void> _runSampling() async {
    _energySamples.clear();
    _gapSamples.clear();

    await AudioChannel.startEngine(mantras: [], threshold: 0.3);

    DateTime? lastDetection;
    _levelSub = AudioChannel.detectionStream.listen((event) {
      _energySamples.add(event.confidence);
      final now = DateTime.now();
      if (lastDetection != null) {
        _gapSamples
            .add(now.difference(lastDetection!).inMilliseconds);
      }
      lastDetection = now;
      if (mounted) setState(() {});
    });

    await Future.delayed(const Duration(seconds: 10));
    await AudioChannel.stopEngine();
    _levelSub?.cancel();

    // Compute calibration
    if (_energySamples.isNotEmpty) {
      final meanEnergy =
          _energySamples.reduce((a, b) => a + b) / _energySamples.length;
      _energyThreshold = 0.6 * meanEnergy;
    }
    if (_gapSamples.isNotEmpty) {
      final meanGap =
          _gapSamples.reduce((a, b) => a + b) / _gapSamples.length;
      _refractoryMs = (0.8 * meanGap).round().clamp(400, 3000);
    }
    if (mounted) setState(() {});
  }

  // ── Step 3: Save Profile ─────────────────────────────────

  Widget _buildSaveProfile(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIndicator(current: 2, total: 4),
        const SizedBox(height: 24),
        Text('Saving Profile',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'Your voice calibration will now be saved.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        _InfoRow(label: 'Energy threshold', value: _energyThreshold.toStringAsFixed(4)),
        _InfoRow(label: 'Refractory gap', value: '${_refractoryMs}ms'),
        const SizedBox(height: 32),
        Center(
          child: FilledButton(
            onPressed: _saveProfile,
            child: const Text('Save & Continue'),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    // Update native engine calibration
    await AudioChannel.updateCalibration(CalibrationProfile(
      energyThreshold: _energyThreshold,
      refractoryMs: _refractoryMs,
    ));
    _nextStep();
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
              Text(
                'Your voice has been calibrated.\n'
                'Energy: ${_energyThreshold.toStringAsFixed(4)}, '
                'Gap: ${_refractoryMs}ms',
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
