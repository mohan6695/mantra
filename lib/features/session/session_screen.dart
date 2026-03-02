import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';
import 'session_provider.dart';
import 'widgets/ring_progress.dart';

/// Session screen — active chanting session with ring progress, controls,
/// live feedback, and target-reached celebration.
class SessionScreen extends ConsumerStatefulWidget {
  final int mantraId;

  const SessionScreen({super.key, required this.mantraId});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen>
    with SingleTickerProviderStateMixin {
  int _targetCount = 108;
  MantraConfigTableData? _mantra;
  bool _showCelebration = false;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _loadMantra();
  }

  Future<void> _loadMantra() async {
    final db = ref.read(appDatabaseProvider);
    final mantras = await db.getAllMantras();
    final found = mantras.where((m) => m.id == widget.mantraId).firstOrNull;
    if (found != null && mounted) {
      setState(() {
        _mantra = found;
        _targetCount = found.targetCount;
      });
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    if (_mantra == null) return;
    await ref.read(sessionProvider.notifier).startSession(
          mantra: _mantra!,
          targetCount: _targetCount,
        );
  }

  Future<void> _stopSession() async {
    await ref.read(sessionProvider.notifier).endSession();
  }

  void _triggerCelebration() {
    setState(() => _showCelebration = true);
    HapticFeedback.heavyImpact();
    _celebrationController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showCelebration = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final theme = Theme.of(context);

    // Watch for target reached
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next is SessionActive &&
          prev is SessionActive &&
          next.currentCount >= next.targetCount &&
          prev.currentCount < prev.targetCount) {
        _triggerCelebration();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_mantra?.name ?? 'Session'),
        centerTitle: true,
        actions: [
          if (session is SessionActive)
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              tooltip: 'End Session',
              onPressed: _stopSession,
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _buildBody(session, theme),
            if (_showCelebration) _buildCelebrationOverlay(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SessionState session, ThemeData theme) {
    return switch (session) {
      SessionIdle() => _buildIdleView(theme),
      SessionActive() => _buildActiveView(session, theme),
      SessionCompleted() => _buildCompletedView(session, theme),
    };
  }

  // ── Idle (pre-start) ──────────────────────────────────────

  Widget _buildIdleView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mantra info
            if (_mantra != null) ...[
              Text(
                _mantra!.devanagari,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _mantra!.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Target picker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Target: ', style: theme.textTheme.bodyLarge),
                DropdownButton<int>(
                  value: _targetCount,
                  items: [27, 54, 108, 216, 324, 540, 1080]
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _targetCount = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Start button
            FilledButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text('Start Session'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Active session ────────────────────────────────────────

  Widget _buildActiveView(SessionActive session, ThemeData theme) {
    final progress = session.targetCount > 0
        ? session.currentCount / session.targetCount
        : 0.0;

    // Color transition: deepPurple → amber when near target
    final color = Color.lerp(
      theme.colorScheme.primary,
      Colors.amber,
      progress.clamp(0.0, 1.0),
    )!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mantra text
          Text(
            session.mantra.devanagari,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(178),
            ),
          ),
          const SizedBox(height: 24),

          // Ring progress
          RingProgressWidget(
            current: session.currentCount,
            target: session.targetCount,
            size: 280,
            color: color,
          ),
          const SizedBox(height: 24),

          // Live feedback pulse
          _LivePulse(isActive: true, color: color),
          const SizedBox(height: 32),

          // Stop button
          OutlinedButton.icon(
            onPressed: _stopSession,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('End Session'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Completed ─────────────────────────────────────────────

  Widget _buildCompletedView(SessionCompleted session, ThemeData theme) {
    final metTarget = session.achievedCount >= session.targetCount;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              metTarget ? Icons.emoji_events_rounded : Icons.check_circle,
              size: 64,
              color: metTarget ? Colors.amber : theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              metTarget ? 'Target Reached!' : 'Session Complete',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${session.achievedCount} / ${session.targetCount} chants',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              session.mantra.name,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Celebration overlay ───────────────────────────────────

  Widget _buildCelebrationOverlay(ThemeData theme) {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        final opacity = 1.0 - _celebrationController.value;
        return IgnorePointer(
          child: Container(
            color: Colors.black.withAlpha((opacity * 100).toInt()),
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: Colors.amber.withAlpha((opacity * 255).toInt()),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '🎉 Target Reached! 🎉',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color:
                          Colors.white.withAlpha((opacity * 255).toInt()),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Small pulsing dot indicating live voice detection.
class _LivePulse extends StatefulWidget {
  final bool isActive;
  final Color color;

  const _LivePulse({required this.isActive, required this.color});

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + _controller.value * 0.3;
        final opacity = 0.4 + _controller.value * 0.6;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withAlpha((opacity * 255).toInt()),
            ),
          ),
        );
      },
    );
  }
}
