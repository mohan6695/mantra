import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/local/database.dart';
import '../../data/models/mantra_metadata.dart';
import '../../data/sample_verses.dart';
import '../insights/insights_provider.dart';
import '../insights/insights_engine.dart'; // InsightType
import '../leaderboard/leaderboard_provider.dart';
import '../congregation/congregation_provider.dart';
import 'dashboard_provider.dart';

/// Main dashboard — home screen of the app.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantra Counter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayStatsProvider);
          ref.invalidate(streakProvider);
          ref.invalidate(heatmapDataProvider);
          ref.invalidate(insightsProvider);
          ref.invalidate(weeklySummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: const [
            _TodayCard(),
            SizedBox(height: 12),
            _StreakCard(),
            SizedBox(height: 12),
            _QuickNavRow(),
            SizedBox(height: 12),
            _DevotionScoreCard(),
            SizedBox(height: 12),
            _ChallengePreviewCard(),
            SizedBox(height: 12),
            _CongregationPreviewCard(),
            SizedBox(height: 12),
            _HeatmapCalendar(),
            SizedBox(height: 12),
            _PerMantraStats(),
            SizedBox(height: 12),
            _VerseMantrasCard(),
            SizedBox(height: 12),
            _RecentSessions(),
            SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMantraPicker(context, ref),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Start Session'),
      ),
    );
  }

  void _showMantraPicker(BuildContext context, WidgetRef ref) {
    final mantras = ref.read(mantrasProvider);
    mantras.whenData((list) {
      if (list.isEmpty) return;
      if (list.length == 1) {
        context.push('/session/${list.first.id}');
        return;
      }
      showModalBottomSheet(
        context: context,
        builder: (_) => _MantraPickerSheet(mantras: list),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────
// Today Card
// ─────────────────────────────────────────────────────────

class _TodayCard extends ConsumerWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayStatsProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: todayAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (stats) {
            final total =
                stats.fold<int>(0, (sum, s) => sum + s.totalCount);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.today, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Today', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      '$total chants',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (stats.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...stats.map((s) {
                    final meta = mantraMetadataRegistry['${s.mantraId}'];
                    final label = meta?.name ?? 'Mantra #${s.mantraId}';
                    final icon = meta?.icon ?? '🙏';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(label, style: theme.textTheme.bodySmall),
                          const Spacer(),
                          Text('${s.totalCount}',
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Streak Card
// ─────────────────────────────────────────────────────────

class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: streakAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (streak) => Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: streak > 7 ? Colors.orange : theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak day${streak != 1 ? 's' : ''}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Current Streak',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Heatmap Calendar (simplified grid)
// ─────────────────────────────────────────────────────────

class _HeatmapCalendar extends ConsumerWidget {
  const _HeatmapCalendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(heatmapDataProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 90 Days', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            heatmapAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (stats) => _buildGrid(context, stats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
      BuildContext context, List<DailyStatsTableData> stats) {
    // Aggregate counts per date
    final Map<String, int> countByDate = {};
    for (final s in stats) {
      countByDate[s.date] = (countByDate[s.date] ?? 0) + s.totalCount;
    }
    final maxCount =
        countByDate.values.fold<int>(1, (a, b) => a > b ? a : b);

    final now = DateTime.now();
    final days = List.generate(
        90, (i) => now.subtract(Duration(days: 89 - i)));

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: days.map((d) {
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final count = countByDate[key] ?? 0;
        final intensity = count / maxCount;
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: count == 0
                ? primaryColor.withAlpha(20)
                : primaryColor.withAlpha((40 + intensity * 215).toInt()),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Per Mantra Stats
// ─────────────────────────────────────────────────────────

class _PerMantraStats extends ConsumerWidget {
  const _PerMantraStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mantrasAsync = ref.watch(mantrasProvider);
    final todayAsync = ref.watch(todayStatsProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🕉️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('Short Mantras',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${shortMantras.length} mantras',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Repetitive chanting with automatic counting',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
            ),
            const SizedBox(height: 8),
            mantrasAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (mantras) {
                final todayStats = todayAsync.valueOrNull ?? [];
                return Column(
                  children: mantras.map((m) {
                    final meta =
                        mantraMetadataRegistry['${m.id}'];
                    final stat = todayStats
                        .where((s) => s.mantraId == m.id)
                        .firstOrNull;
                    final todayCount = stat?.totalCount ?? 0;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                        child: Text(
                          meta?.icon ?? m.devanagari.characters.first,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(meta?.name ?? m.name),
                      subtitle: Text(
                        meta?.meaning ?? m.romanized,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$todayCount',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('today',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                      onTap: () => context.push('/session/${m.id}'),
                      onLongPress: () => context.push('/mantra/${m.id}'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Verse Mantras Card
// ─────────────────────────────────────────────────────────

class _VerseMantrasCard extends StatelessWidget {
  const _VerseMantrasCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verses = allVerses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📿', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('Verse Mantras',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${longMantras.length} stotras',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => GoRouter.of(context).push('/verses'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Long mantras & stotrams with word-by-word tracking',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
            ),
            const SizedBox(height: 12),
            ...verses.map((v) {
              final meta = mantraMetadataRegistry[v.id];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    meta?.icon ?? '📖',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                title: Text(meta?.name ?? v.name),
                subtitle: Text(
                  meta?.meaning ?? '${v.totalLines} lines · ${v.totalWords} words',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.play_circle_outline),
                onTap: () => GoRouter.of(context).push('/verse/${v.id}'),
                onLongPress: () => GoRouter.of(context).push('/mantra/${v.id}'),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Recent Sessions
// ─────────────────────────────────────────────────────────

class _RecentSessions extends ConsumerWidget {
  const _RecentSessions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(recentSessionsProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Sessions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            sessionsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (sessions) {
                if (sessions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No sessions yet. Start your first!'),
                  );
                }
                return Column(
                  children: sessions.map((s) {
                    final duration = s.endedAt
                        ?.difference(s.startedAt);
                    final durationStr = duration != null
                        ? '${duration.inMinutes}m ${duration.inSeconds % 60}s'
                        : 'In progress';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        '${s.achievedCount} / ${s.targetCount}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDate(s.startedAt)} · $durationStr',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: s.achievedCount >= s.targetCount
                          ? Icon(Icons.check_circle,
                              color: Colors.green.shade400, size: 20)
                          : null,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

// ─────────────────────────────────────────────────────────
// Quick Navigation Row
// ─────────────────────────────────────────────────────────

class _QuickNavRow extends StatelessWidget {
  const _QuickNavRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _NavChip(
            icon: Icons.insights,
            label: 'Insights',
            color: Colors.purple,
            onTap: () => context.push('/insights'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NavChip(
            icon: Icons.leaderboard,
            label: 'Leaderboard',
            color: Colors.amber.shade700,
            onTap: () => context.push('/leaderboard'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NavChip(
            icon: Icons.groups,
            label: 'Congregation',
            color: Colors.teal,
            onTap: () => context.push('/congregation'),
          ),
        ),
      ],
    );
  }
}

class _NavChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Devotion Score Card (from insights)
// ─────────────────────────────────────────────────────────

class _DevotionScoreCard extends ConsumerWidget {
  const _DevotionScoreCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);
    final theme = Theme.of(context);

    return insightsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (insights) {
        final devotionInsight = insights.where(
            (i) => i.type == InsightType.devotionScore).firstOrNull;
        if (devotionInsight == null) return const SizedBox.shrink();

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/insights'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(devotionInsight.emoji ?? '🕉️',
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Devotion Score',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(devotionInsight.title,
                            style: theme.textTheme.bodySmall),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ((devotionInsight.value ?? 0) / 100)
                                .clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            color: _devotionColor(devotionInsight.value ?? 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _devotionColor(double score) {
    if (score >= 90) return Colors.amber;
    if (score >= 75) return Colors.orange;
    if (score >= 55) return Colors.green;
    if (score >= 35) return Colors.blue;
    return Colors.grey;
  }
}

// ─────────────────────────────────────────────────────────
// Challenge Preview Card
// ─────────────────────────────────────────────────────────

class _ChallengePreviewCard extends ConsumerWidget {
  const _ChallengePreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);
    final theme = Theme.of(context);

    return challengesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (challenges) {
        if (challenges.isEmpty) return const SizedBox.shrink();
        final challenge = challenges.first;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/leaderboard'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text('Active Challenge',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('${challenge.timeRemaining.inDays}d left',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(challenge.title,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: challenge.progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${challenge.participantCount} participants',
                          style: theme.textTheme.labelSmall),
                      Text('${(challenge.progress * 100).round()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold)),
                    ],
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

// ─────────────────────────────────────────────────────────
// Congregation Preview Card
// ─────────────────────────────────────────────────────────

class _CongregationPreviewCard extends ConsumerWidget {
  const _CongregationPreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final congState = ref.watch(congregationProvider);
    final theme = Theme.of(context);

    if (congState is CongregationActive) {
      return Card(
        color: theme.colorScheme.tertiaryContainer.withAlpha(80),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/congregation/active'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.groups, size: 32, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(congState.session.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                          '${congState.participants.length} chanting · '
                          '${congState.session.totalChants} total',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('${congState.myCount}',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text('You', style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // No active session — show invite
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/congregation'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.groups, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Group Bhajan',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text('Start or join a congregation',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Mantra Picker Bottom Sheet
// ─────────────────────────────────────────────────────────

class _MantraPickerSheet extends StatelessWidget {
  final List<MantraConfigTableData> mantras;
  const _MantraPickerSheet({required this.mantras});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verses = allVerses;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('Choose Mantra',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
            // — Short mantras section —
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('SHORT MANTRAS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  )),
            ),
            ...mantras.map((m) {
              final meta =
                  mantraMetadataRegistry['${m.id}'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(meta?.icon ?? m.devanagari.characters.first,
                      style: const TextStyle(fontSize: 18)),
                ),
                title: Text(meta?.name ?? m.name),
                subtitle: Text(meta?.telugu ?? m.romanized),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/session/${m.id}');
                },
              );
            }),
            const Divider(indent: 16, endIndent: 16),
            // — Verse mantras section —
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('VERSE MANTRAS & STOTRAMS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  )),
            ),
            ...verses.map((v) {
              final meta = mantraMetadataRegistry[v.id];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  child: Text(meta?.icon ?? '📖',
                      style: const TextStyle(fontSize: 18)),
                ),
                title: Text(meta?.name ?? v.name),
                subtitle: Text(
                  '${v.totalLines} lines · ${v.totalWords} words',
                  style: theme.textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/verse/${v.id}');
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
