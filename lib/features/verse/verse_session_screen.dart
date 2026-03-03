import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/verse_mantra.dart';
import 'verse_provider.dart';

/// State of a word relative to the tracking cursor.
enum _WordState { past, current, future }

/// Verse session screen — karaoke-style word-by-word tracking of a long mantra.
///
/// The user chants the predefined verse and the app highlights the current
/// word in real time, auto-scrolling as the user progresses through lines.
class VerseSessionScreen extends ConsumerStatefulWidget {
  final String verseId;

  const VerseSessionScreen({super.key, required this.verseId});

  @override
  ConsumerState<VerseSessionScreen> createState() =>
      _VerseSessionScreenState();
}

class _VerseSessionScreenState extends ConsumerState<VerseSessionScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  Timer? _elapsedTimer;
  bool _showRomanized = true;
  bool _manualMode = false;

  @override
  void initState() {
    super.initState();
    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}), // refresh elapsed time display
    );
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(verseSessionProvider);
    final theme = Theme.of(context);

    // Find the verse
    final verses = ref.read(verseListProvider);
    final verse = verses.where((v) => v.id == widget.verseId).firstOrNull;
    if (verse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verse not found')),
        body: const Center(child: Text('Verse not found')),
      );
    }

    // Initialize line keys
    for (int i = 0; i < verse.totalLines; i++) {
      _lineKeys.putIfAbsent(i, () => GlobalKey());
    }

    // Auto-scroll when tracking state changes
    ref.listen(verseSessionProvider, (prev, next) {
      if (next.tracking != null && prev?.tracking != null) {
        if (next.tracking!.currentLineIndex !=
            prev!.tracking!.currentLineIndex) {
          _scrollToLine(next.tracking!.currentLineIndex);
        }
      }
    });

    return Scaffold(
      appBar: _buildAppBar(sessionState, verse, theme),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            if (sessionState.phase == VerseSessionPhase.active)
              _buildProgressBar(sessionState, theme),

            // Verse body
            Expanded(
              child: _buildBody(sessionState, verse, theme),
            ),

            // Bottom controls
            _buildControls(sessionState, verse, theme),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      VerseSessionState session, VerseMantra verse, ThemeData theme) {
    return AppBar(
      title: Text(verse.name),
      centerTitle: true,
      actions: [
        // Toggle romanized/devanagari mode
        IconButton(
          icon: Icon(_showRomanized ? Icons.translate : Icons.abc),
          tooltip: _showRomanized ? 'Show Devanagari only' : 'Show Romanized',
          onPressed: () => setState(() => _showRomanized = !_showRomanized),
        ),
        // Toggle manual/auto mode
        if (session.phase == VerseSessionPhase.active)
          IconButton(
            icon: Icon(_manualMode
                ? Icons.touch_app
                : Icons.mic),
            tooltip: _manualMode ? 'Manual mode' : 'Auto mode',
            onPressed: () => setState(() => _manualMode = !_manualMode),
          ),
      ],
    );
  }

  // ── Progress Bar ──────────────────────────────────────────

  Widget _buildProgressBar(VerseSessionState session, ThemeData theme) {
    final tracking = session.tracking;
    if (tracking == null) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tracking.wordsCompleted} / ${tracking.verse.totalWords} words',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
              Text(
                'Line ${tracking.currentLineIndex + 1} / ${tracking.verse.totalLines}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
              Text(
                _formatDuration(session.elapsed),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: tracking.progress,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(
            Color.lerp(
              theme.colorScheme.primary,
              Colors.amber,
              tracking.progress,
            ),
          ),
        ),
      ],
    );
  }

  // ── Body (phase-dependent) ────────────────────────────────

  Widget _buildBody(
      VerseSessionState session, VerseMantra verse, ThemeData theme) {
    return switch (session.phase) {
      VerseSessionPhase.idle => _buildIdleView(verse, theme),
      VerseSessionPhase.active => _buildActiveView(session, verse, theme),
      VerseSessionPhase.completed => _buildCompletedView(session, verse, theme),
    };
  }

  // ── Idle View ─────────────────────────────────────────────

  Widget _buildIdleView(VerseMantra verse, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(verse.name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(verse.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoChip(
                          icon: Icons.short_text,
                          label: '${verse.totalLines} lines'),
                      const SizedBox(width: 8),
                      _InfoChip(
                          icon: Icons.text_fields,
                          label: '${verse.totalWords} words'),
                      const SizedBox(width: 8),
                      _InfoChip(
                          icon: Icons.language, label: verse.language.toUpperCase()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preview: first few lines
          Text('Preview', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          ...verse.lines.take(6).map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.devanagari,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                    if (_showRomanized)
                      Text(
                        line.romanized,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(128),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              )),
          if (verse.totalLines > 6)
            Text(
              '... and ${verse.totalLines - 6} more lines',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
            ),
        ],
      ),
    );
  }

  // ── Active View (Karaoke) ─────────────────────────────────

  Widget _buildActiveView(
      VerseSessionState session, VerseMantra verse, ThemeData theme) {
    final tracking = session.tracking;
    if (tracking == null) return const Center(child: CircularProgressIndicator());

    final currentWordIdx = tracking.currentWordIndex;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: verse.totalLines,
      itemBuilder: (context, lineIndex) {
        final line = verse.lines[lineIndex];
        final isCurrentLine = lineIndex == tracking.currentLineIndex;
        final isPastLine = line.words.isNotEmpty &&
            line.words.last.globalIndex < currentWordIdx;
        final isFutureLine = line.words.isNotEmpty &&
            line.words.first.globalIndex > currentWordIdx;

        return Padding(
          key: _lineKeys[lineIndex],
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrentLine
                  ? theme.colorScheme.primaryContainer.withAlpha(80)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isCurrentLine
                  ? Border.all(
                      color: theme.colorScheme.primary.withAlpha(60),
                      width: 1.5)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Devanagari - word-by-word highlighted
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: line.words.map((word) {
                    final wordState = _getWordState(word, currentWordIdx);
                    return _buildWord(
                      word: word,
                      wordState: wordState,
                      theme: theme,
                      isDevanagari: true,
                      onTap: () => _onWordTap(word),
                    );
                  }).toList(),
                ),

                // Romanized subtitle
                if (_showRomanized) ...[
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: line.words.map((word) {
                      final wordState = _getWordState(word, currentWordIdx);
                      return _buildWord(
                        word: word,
                        wordState: wordState,
                        theme: theme,
                        isDevanagari: false,
                        onTap: () => _onWordTap(word),
                      );
                    }).toList(),
                  ),
                ],

                // Line number indicator
                if (isCurrentLine || isPastLine)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'L${lineIndex + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isPastLine
                            ? Colors.green.withAlpha(153)
                            : theme.colorScheme.primary.withAlpha(153),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Word widget ───────────────────────────────────────────

  _WordState _getWordState(VerseWord word, int currentWordIdx) {
    if (word.globalIndex < currentWordIdx) return _WordState.past;
    if (word.globalIndex == currentWordIdx) return _WordState.current;
    return _WordState.future;
  }

  Widget _buildWord({
    required VerseWord word,
    required _WordState wordState,
    required ThemeData theme,
    required bool isDevanagari,
    required VoidCallback onTap,
  }) {
    final text = isDevanagari ? word.devanagari : word.romanized;

    final (Color bgColor, Color textColor, double opacity, FontWeight weight) =
        switch (wordState) {
      _WordState.past => (
          Colors.green.withAlpha(30),
          Colors.green.shade700,
          isDevanagari ? 0.7 : 0.5,
          FontWeight.normal,
        ),
      _WordState.current => (
          theme.colorScheme.primary.withAlpha(40),
          theme.colorScheme.primary,
          1.0,
          FontWeight.w700,
        ),
      _WordState.future => (
          Colors.transparent,
          theme.colorScheme.onSurface,
          isDevanagari ? 0.9 : 0.5,
          FontWeight.normal,
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isDevanagari ? 4 : 2,
          vertical: isDevanagari ? 2 : 0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: wordState == _WordState.current
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Opacity(
          opacity: opacity,
          child: Text(
            text,
            style: (isDevanagari
                    ? theme.textTheme.titleMedium
                    : theme.textTheme.bodySmall)
                ?.copyWith(
              color: textColor,
              fontWeight: weight,
              fontStyle: isDevanagari ? null : FontStyle.italic,
              decoration: wordState == _WordState.past
                  ? TextDecoration.none
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  void _onWordTap(VerseWord word) {
    final session = ref.read(verseSessionProvider);
    if (session.phase != VerseSessionPhase.active) return;

    if (_manualMode) {
      // In manual mode, tap = advance one word
      ref.read(verseSessionProvider.notifier).advanceOneWord();
    } else {
      // In auto mode, tap a word to re-sync position
      ref.read(verseSessionProvider.notifier).jumpToWord(word.globalIndex);
    }
    HapticFeedback.selectionClick();
  }

  // ── Completed View ────────────────────────────────────────

  Widget _buildCompletedView(
      VerseSessionState session, VerseMantra verse, ThemeData theme) {
    final tracking = session.tracking;
    final wordsCompleted = tracking?.wordsCompleted ?? 0;
    final isFullyComplete = wordsCompleted >= verse.totalWords;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFullyComplete
                  ? Icons.emoji_events_rounded
                  : Icons.check_circle,
              size: 64,
              color:
                  isFullyComplete ? Colors.amber : theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isFullyComplete ? 'Verse Complete!' : 'Session Ended',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '${verse.name}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Words tracked',
                      value: '$wordsCompleted / ${verse.totalWords}',
                    ),
                    _StatRow(
                      label: 'Lines covered',
                      value:
                          '${tracking?.currentLineIndex ?? 0} / ${verse.totalLines}',
                    ),
                    _StatRow(
                      label: 'Duration',
                      value: _formatDuration(session.elapsed),
                    ),
                    _StatRow(
                      label: 'Accuracy',
                      value:
                          '${(wordsCompleted / verse.totalWords * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    ref.read(verseSessionProvider.notifier).reset();
                  },
                  child: const Text('Try Again'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Controls ───────────────────────────────────────

  Widget _buildControls(
      VerseSessionState session, VerseMantra verse, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: switch (session.phase) {
        VerseSessionPhase.idle => _buildIdleControls(verse, theme),
        VerseSessionPhase.active => _buildActiveControls(session, theme),
        VerseSessionPhase.completed => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildIdleControls(VerseMantra verse, ThemeData theme) {
    final notifier = ref.read(verseSessionProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              final success = await notifier.startSession(verse: verse);
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Microphone permission is required')),
                );
              }
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 24),
            label: const Text('Start Chanting'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: theme.textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveControls(VerseSessionState session, ThemeData theme) {
    final notifier = ref.read(verseSessionProvider.notifier);
    final tracking = session.tracking;

    return Row(
      children: [
        // Voice indicator
        if (tracking?.isVoiceActive == true)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),

        // Sensitivity slider
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.hearing, size: 16),
                  Expanded(
                    child: Slider(
                      value: session.sensitivity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      label: 'Sensitivity: ${(session.sensitivity * 100).toInt()}%',
                      onChanged: (v) => notifier.updateSensitivity(v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Manual advance button (in manual mode)
        if (_manualMode)
          IconButton.filled(
            onPressed: () {
              notifier.advanceOneWord();
              HapticFeedback.lightImpact();
            },
            icon: const Icon(Icons.skip_next_rounded),
            tooltip: 'Next word',
          ),

        const SizedBox(width: 8),

        // End session
        OutlinedButton.icon(
          onPressed: () => notifier.endSession(),
          icon: const Icon(Icons.stop_rounded, size: 20),
          label: const Text('End'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  void _scrollToLine(int lineIndex) {
    final key = _lineKeys[lineIndex];
    if (key?.currentContext == null) return;

    Scrollable.ensureVisible(
      key!.currentContext!,
      alignment: 0.3, // scroll so the line is ~30% from the top
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}

// ── Small helper widgets ────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: theme.textTheme.labelSmall),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

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
