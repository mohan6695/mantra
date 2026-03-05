import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';
import '../../data/models/mantra_metadata.dart';
import 'session_provider.dart';
import 'widgets/ring_progress.dart';

/// Session screen — active chanting session with ring progress, controls,
/// manual +/- adjustment, pause/resume, and session lifecycle management.
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
    // Reset session state if it belongs to a different mantra
    _resetIfDifferentMantra();
  }

  /// If the global session state is from a different mantra, reset to idle.
  /// This prevents showing stale completed/active states from other mantras.
  void _resetIfDifferentMantra() {
    final session = ref.read(sessionProvider);
    bool needsReset = false;
    if (session is SessionActive && session.mantra.id != widget.mantraId) {
      needsReset = true;
    } else if (session is SessionCompleted && session.mantra.id != widget.mantraId) {
      needsReset = true;
    }
    if (needsReset) {
      // Use addPostFrameCallback to avoid modifying state during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sessionProvider.notifier).forceIdle();
      });
    }
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

    // Request mic permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
      }
      return;
    }

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
          if (session is SessionActive) ...[
            // Reset count
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: 'Reset Count',
              onPressed: () => _confirmReset(context),
            ),
            // End session
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              tooltip: 'End Session',
              onPressed: _stopSession,
            ),
          ],
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

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Count?'),
        content: const Text('This will reset your chant count to 0.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(sessionProvider.notifier).resetCount();
            },
            child: const Text('Reset'),
          ),
        ],
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
            // Mantra info — English + Telugu
            if (_mantra != null) ...[
              // Telugu text
              Builder(builder: (context) {
                final meta = mantraMetadataRegistry['${_mantra!.id}'];
                final teluguText = meta?.telugu ?? '';
                if (teluguText.isNotEmpty) {
                  return Column(children: [
                    Text(
                      teluguText,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ]);
                }
                return const SizedBox.shrink();
              }),
              // English romanized
              Text(
                _mantra!.romanized,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
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

    final notifier = ref.read(sessionProvider.notifier);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Karaoke-style word-by-word mantra display (English romanized)
            _ChantingWordsDisplay(
              text: session.mantra.romanized,
              currentCount: session.currentCount,
              estimatedChantMs: session.mantra.refractoryMs * 2,
              accentColor: color,
            ),
            // Telugu subtitle
            Builder(builder: (context) {
              final meta = mantraMetadataRegistry['${session.mantra.id}'];
              final teluguText = meta?.telugu ?? '';
              if (teluguText.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Text(
                    teluguText.replaceAll('\n', ' '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // STT recognized text display
            if (session.isSttMode && session.recognizedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withAlpha(60),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic, size: 16, color: color.withAlpha(180)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          session.recognizedText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(200),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Ring progress
            RingProgressWidget(
              current: session.currentCount,
              target: session.targetCount,
              size: 240,
              color: color,
            ),
            const SizedBox(height: 16),

            // Live feedback pulse (hidden when paused)
            _LivePulse(isActive: !session.isPaused, color: color),
            if (session.isPaused)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'PAUSED',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // ── Manual +/- counter buttons ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement
                _CountButton(
                  icon: Icons.remove_rounded,
                  onPressed: session.currentCount > 0
                      ? () => notifier.decrementCount()
                      : null,
                  color: theme.colorScheme.errorContainer,
                  iconColor: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 24),
                // Count display
                Column(
                  children: [
                    Text(
                      '${session.currentCount}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'of ${session.targetCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Increment
                _CountButton(
                  icon: Icons.add_rounded,
                  onPressed: () => notifier.incrementCount(),
                  color: theme.colorScheme.primaryContainer,
                  iconColor: theme.colorScheme.onPrimaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Control row: Pause/Resume + End ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pause / Resume
                FilledButton.tonalIcon(
                  onPressed: session.isPaused
                      ? () => notifier.resumeSession()
                      : () => notifier.pauseSession(),
                  icon: Icon(
                    session.isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                  ),
                  label: Text(session.isPaused ? 'Resume' : 'Pause'),
                ),
                const SizedBox(width: 16),
                // End session
                OutlinedButton.icon(
                  onPressed: _stopSession,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('End'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Completed ─────────────────────────────────────────────

  Widget _buildCompletedView(SessionCompleted session, ThemeData theme) {
    final metTarget = session.achievedCount >= session.targetCount;
    final notifier = ref.read(sessionProvider.notifier);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
            const SizedBox(height: 4),
            Text(
              session.mantra.name,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 36),

            // ── Session actions ──
            // Continue (keep count, resume listening)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final status = await Permission.microphone.request();
                  if (!status.isGranted) return;
                  notifier.continueSession();
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  metTarget ? 'Keep Going' : 'Continue',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Restart (fresh count, same mantra & target)
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  final status = await Permission.microphone.request();
                  if (!status.isGranted) return;
                  notifier.restartSession();
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Restart (Reset Count)'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Back to dashboard
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.dashboard_rounded),
                label: const Text('Back to Dashboard'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
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
                    'Target Reached!',
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

/// Circular +/- button for manual count adjustment.
class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color iconColor;

  const _CountButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null ? color : color.withAlpha(80),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            icon,
            size: 28,
            color: onPressed != null ? iconColor : iconColor.withAlpha(80),
          ),
        ),
      ),
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

/// Karaoke-style word-by-word mantra display.
///
/// When [currentCount] changes, it animates through each word of the
/// mantra text sequentially, highlighting the "current" word.
class _ChantingWordsDisplay extends StatefulWidget {
  final String text;
  final int currentCount;
  final int estimatedChantMs;
  final Color accentColor;

  const _ChantingWordsDisplay({
    required this.text,
    required this.currentCount,
    required this.estimatedChantMs,
    required this.accentColor,
  });

  @override
  State<_ChantingWordsDisplay> createState() => _ChantingWordsDisplayState();
}

class _ChantingWordsDisplayState extends State<_ChantingWordsDisplay> {
  late List<String> _words;
  int _activeWordIndex = -1; // -1 = no word highlighted
  Timer? _wordTimer;
  int _lastCount = -1;

  @override
  void initState() {
    super.initState();
    _words = _splitWords(widget.text);
    _lastCount = widget.currentCount;
  }

  @override
  void didUpdateWidget(covariant _ChantingWordsDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-split if mantra text changed
    if (oldWidget.text != widget.text) {
      _words = _splitWords(widget.text);
      _activeWordIndex = -1;
      _wordTimer?.cancel();
    }

    // Count increased → start word cycling animation
    if (widget.currentCount > _lastCount && widget.currentCount > 0) {
      _startWordCycle();
    }
    _lastCount = widget.currentCount;
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    super.dispose();
  }

  /// Split text into words (handles newlines and hyphens).
  List<String> _splitWords(String text) {
    return text
        .replaceAll('\n', ' ')
        .replaceAll('-', '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Animate through words one by one, then reset.
  void _startWordCycle() {
    _wordTimer?.cancel();
    if (_words.isEmpty) return;

    // Time per word: spread estimated chant duration across all words
    final msPerWord = (widget.estimatedChantMs / _words.length)
        .round()
        .clamp(120, 800);

    _activeWordIndex = 0;
    setState(() {});

    _wordTimer = Timer.periodic(Duration(milliseconds: msPerWord), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _activeWordIndex++;
        if (_activeWordIndex >= _words.length) {
          _activeWordIndex = -1;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: List.generate(_words.length, (i) {
          final isActive = i == _activeWordIndex;
          final isPast = _activeWordIndex >= 0 && i < _activeWordIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isActive
                  ? widget.accentColor.withAlpha(50)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.titleLarge!.copyWith(
                color: isActive
                    ? widget.accentColor
                    : isPast
                        ? theme.colorScheme.onSurface.withAlpha(100)
                        : theme.colorScheme.onSurface.withAlpha(180),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: isActive ? 22 : 20,
              ),
              child: Text(_words[i]),
            ),
          );
        }),
      ),
    );
  }
}
