import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/local/database.dart';
import '../../data/sample_verses.dart';
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
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: const [
            _TodayCard(),
            SizedBox(height: 12),
            _StreakCard(),
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
                  ...stats.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('Mantra #${s.mantraId}',
                                style: theme.textTheme.bodySmall),
                            const Spacer(),
                            Text('${s.totalCount}',
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      )),
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
            Text('Mantras', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            mantrasAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (mantras) {
                final todayStats = todayAsync.valueOrNull ?? [];
                return Column(
                  children: mantras.map((m) {
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
                          m.devanagari.characters.first,
                          style: TextStyle(
                              color:
                                  theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
                      title: Text(m.name),
                      subtitle: Text(m.romanized),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Verse Mantras',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => GoRouter.of(context).push('/verses'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Long mantras with word-by-word tracking',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
            ),
            const SizedBox(height: 12),
            ...verses.take(3).map((v) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      v.language.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(v.name),
                  subtitle: Text('${v.totalLines} lines · ${v.totalWords} words'),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () => GoRouter.of(context).push('/verse/${v.id}'),
                )),
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
// Mantra Picker Bottom Sheet
// ─────────────────────────────────────────────────────────

class _MantraPickerSheet extends StatelessWidget {
  final List<MantraConfigTableData> mantras;
  const _MantraPickerSheet({required this.mantras});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Choose Mantra',
                style: theme.textTheme.titleMedium),
          ),
          ...mantras.map((m) => ListTile(
                leading: CircleAvatar(
                  child: Text(m.devanagari.characters.first),
                ),
                title: Text(m.name),
                subtitle: Text(m.devanagari),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/session/${m.id}');
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
