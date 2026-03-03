import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'insights_engine.dart';
import 'insights_provider.dart';

/// Personalized insights screen — devotion score, weekly summary, tips.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);
    final weeklyAsync = ref.watch(weeklySummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Insights'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(insightsProvider);
          ref.invalidate(weeklySummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Weekly summary bar chart
            weeklyAsync.when(
              loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('$e'),
              data: (w) => _WeeklySummaryCard(summary: w),
            ),
            const SizedBox(height: 16),
            // Insight cards
            insightsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (insights) => Column(
                children: insights
                    .map((i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _InsightCard(insight: i),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Weekly Summary Card with bar chart
// ─────────────────────────────────────────────────────────

class _WeeklySummaryCard extends StatelessWidget {
  final WeeklySummary summary;
  const _WeeklySummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount = summary.dailyCounts.fold<int>(1, (a, b) => a > b ? a : b);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('This Week',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${summary.totalChants} chants',
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${summary.activeDays}/7 days active · '
              '${summary.comparedToLastWeek >= 0 ? '+' : ''}'
              '${summary.comparedToLastWeek} vs last week',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final count = summary.dailyCounts[i];
                  final height = maxCount > 0 ? count / maxCount * 90 : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text('$count',
                                style: theme.textTheme.labelSmall),
                          const SizedBox(height: 4),
                          Container(
                            height: height.clamp(4.0, 90.0),
                            decoration: BoxDecoration(
                              color: count > 0
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(days[i],
                              style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            // Consistency bar
            Row(
              children: [
                Text('Consistency', style: theme.textTheme.bodySmall),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: summary.consistencyScore,
                      minHeight: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(summary.consistencyScore * 100).round()}%',
                    style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Single Insight Card
// ─────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final PracticeInsight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (insight.emoji != null)
              Text(insight.emoji!, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(insight.title,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      if (insight.trend == InsightTrend.up)
                        Icon(Icons.trending_up,
                            color: Colors.green, size: 18),
                      if (insight.trend == InsightTrend.down)
                        Icon(Icons.trending_down,
                            color: Colors.red, size: 18),
                      if (insight.trend == InsightTrend.newRecord)
                        Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(insight.description,
                      style: theme.textTheme.bodySmall),
                  if (insight.value != null &&
                      insight.type == InsightType.milestone) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: insight.value!.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                  if (insight.type == InsightType.devotionScore &&
                      insight.value != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (insight.value! / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: _devotionColor(insight.value!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
