import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/community.dart';
import 'leaderboard_provider.dart';

/// Leaderboard, challenges, and achievements screen.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Leaderboard'),
              Tab(text: 'Challenges'),
              Tab(text: 'Achievements'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LeaderboardTab(),
            _ChallengesTab(),
            _AchievementsTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Leaderboard Tab
// ─────────────────────────────────────────────────────────

class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(leaderboardTimeRangeProvider);
    final lbAsync = ref.watch(leaderboardProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Time range selector
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<LeaderboardTimeRange>(
            segments: const [
              ButtonSegment(
                  value: LeaderboardTimeRange.today, label: Text('Today')),
              ButtonSegment(
                  value: LeaderboardTimeRange.thisWeek,
                  label: Text('Week')),
              ButtonSegment(
                  value: LeaderboardTimeRange.thisMonth,
                  label: Text('Month')),
              ButtonSegment(
                  value: LeaderboardTimeRange.allTime,
                  label: Text('All')),
            ],
            selected: {timeRange},
            onSelectionChanged: (s) {
              ref.read(leaderboardTimeRangeProvider.notifier).state =
                  s.first;
            },
          ),
        ),

        // Content
        Expanded(
          child: lbAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (lb) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // My position card
                if (lb.currentUser != null)
                  Card(
                    color: theme.colorScheme.primaryContainer.withAlpha(80),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text('#${lb.currentUser!.rank}',
                            style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                      title: const Text('Your Position',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${lb.currentUser!.totalCount} chants · '
                          '${lb.currentUser!.streakDays} day streak'),
                      trailing: Text(
                        '${lb.currentUser!.totalCount}',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Top entries
                ...lb.entries.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final e = entry.value;
                  return _LeaderboardTile(
                    rank: idx + 1,
                    entry: e,
                  );
                }),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Leaderboards update when cloud sync is enabled',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  const _LeaderboardTile({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medal = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '';
    return Card(
      child: ListTile(
        leading: medal.isNotEmpty
            ? Text(medal, style: const TextStyle(fontSize: 24))
            : CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text('$rank',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
        title: Text(entry.displayName),
        subtitle: Text(
          '${entry.region ?? ''} · '
          '${entry.streakDays}d streak',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${entry.totalCount}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text('chants', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Challenges Tab
// ─────────────────────────────────────────────────────────

class _ChallengesTab extends ConsumerWidget {
  const _ChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);

    return challengesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (challenges) => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: challenges.length,
        itemBuilder: (_, i) => _ChallengeCard(challenge: challenges[i]),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final CommunityChallenge challenge;
  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = challenge.timeRemaining.inDays;
    final progress = challenge.progress;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(challenge.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                if (challenge.festivalName != null)
                  Chip(
                    label: Text(challenge.festivalName!,
                        style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(challenge.description,
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatCount(challenge.globalProgress)} / ${_formatCount(challenge.globalTarget)}',
                  style: theme.textTheme.bodySmall,
                ),
                Text('${(progress * 100).round()}%',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ChallengeInfo(
                  icon: Icons.people,
                  value: '${challenge.participantCount}',
                  label: 'participants',
                ),
                const SizedBox(width: 16),
                _ChallengeInfo(
                  icon: Icons.person,
                  value: '${challenge.myContribution}',
                  label: 'your chants',
                ),
                const SizedBox(width: 16),
                _ChallengeInfo(
                  icon: Icons.timer,
                  value: '$daysLeft',
                  label: 'days left',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Challenges are tracked automatically. Keep chanting!')),
                  );
                },
                child: const Text('Join Challenge'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int c) {
    if (c >= 100000) return '${(c / 1000).round()}K';
    if (c >= 1000) return '${(c / 1000).toStringAsFixed(1)}K';
    return '$c';
  }
}

class _ChallengeInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _ChallengeInfo(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 4),
        Text('$value ',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Achievements Tab
// ─────────────────────────────────────────────────────────

class _AchievementsTab extends ConsumerWidget {
  const _AchievementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achieveAsync = ref.watch(achievementsProvider);

    return achieveAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (achievements) {
        final unlocked =
            achievements.where((a) => a.isUnlocked).toList();
        final locked =
            achievements.where((a) => !a.isUnlocked).toList();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (unlocked.isNotEmpty) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text('Unlocked (${unlocked.length})',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              ...unlocked.map((a) => _AchievementTile(achievement: a)),
            ],
            if (locked.isNotEmpty) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text('In Progress (${locked.length})',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              ...locked.map((a) => _AchievementTile(achievement: a)),
            ],
          ],
        );
      },
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Text(achievement.icon,
            style: TextStyle(
                fontSize: 28,
                color: achievement.isUnlocked ? null : Colors.grey)),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: achievement.isUnlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: achievement.progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
        trailing: achievement.isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Text(
                '${achievement.currentValue}/${achievement.targetValue}',
                style: theme.textTheme.labelSmall),
      ),
    );
  }
}
