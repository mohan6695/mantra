import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/community.dart';

// ──────────────────────────────────────────────────────────
// Leaderboard state — local simulation + ready for cloud API
// ──────────────────────────────────────────────────────────

/// Selected time range for leaderboards.
final leaderboardTimeRangeProvider =
    StateProvider<LeaderboardTimeRange>((ref) => LeaderboardTimeRange.thisWeek);

/// Selected mantra for leaderboards (null = all mantras).
final leaderboardMantraFilterProvider = StateProvider<int?>((ref) => null);

/// Leaderboard data — simulated offline, ready for cloud.
final leaderboardProvider =
    FutureProvider<MantraLeaderboard>((ref) async {
  final timeRange = ref.watch(leaderboardTimeRangeProvider);
  // Simulate leaderboard data for offline demo
  return _generateSimulatedLeaderboard(timeRange);
});

/// Community challenges — simulated offline.
final challengesProvider =
    FutureProvider<List<CommunityChallenge>>((ref) async {
  return _generateSimulatedChallenges();
});

/// Achievements for local user.
final achievementsProvider =
    FutureProvider<List<Achievement>>((ref) async {
  return _generateAchievements();
});

// ──────────────────────────────────────────────────────────
// Simulated data generators
// ──────────────────────────────────────────────────────────

MantraLeaderboard _generateSimulatedLeaderboard(
    LeaderboardTimeRange timeRange) {
  final multiplier = switch (timeRange) {
    LeaderboardTimeRange.today => 1,
    LeaderboardTimeRange.thisWeek => 7,
    LeaderboardTimeRange.thisMonth => 30,
    LeaderboardTimeRange.allTime => 365,
  };

  final names = [
    ('Aarav S.', 'Delhi', 156),
    ('Priya M.', 'Mumbai', 142),
    ('Karthik R.', 'Chennai', 128),
    ('Ananya D.', 'Kolkata', 118),
    ('Rahul P.', 'Pune', 104),
    ('Meera K.', 'Bangalore', 98),
    ('Vikram J.', 'Jaipur', 88),
    ('Devi L.', 'Hyderabad', 82),
    ('Arjun N.', 'Ahmedabad', 76),
    ('Lakshmi V.', 'Kochi', 68),
  ];

  final entries = names.asMap().entries.map((e) {
    final idx = e.key;
    final (name, region, base) = e.value;
    final count = base * multiplier;
    return LeaderboardEntry(
      rank: '${idx + 1}',
      userId: 'user_$idx',
      displayName: name,
      totalCount: count,
      todayCount: base,
      streakDays: (30 - idx * 2).clamp(1, 30),
      weeklyCount: base * 7,
      lastActive: DateTime.now().subtract(Duration(hours: idx)),
      region: region,
    );
  }).toList();

  return MantraLeaderboard(
    mantraId: 1,
    mantraName: 'Om Namah Shivaya',
    timeRange: timeRange,
    entries: entries,
    currentUser: LeaderboardEntry(
      rank: '42',
      userId: 'local_user',
      displayName: 'You',
      totalCount: 54 * multiplier,
      todayCount: 54,
      streakDays: 5,
      weeklyCount: 54 * 7,
      lastActive: DateTime.now(),
    ),
    fetchedAt: DateTime.now(),
  );
}

List<CommunityChallenge> _generateSimulatedChallenges() {
  final now = DateTime.now();
  return [
    CommunityChallenge(
      id: 'ch_1',
      title: '1 Lakh Om Namah Shivaya',
      description:
          'Join the community in chanting 1,00,000 Om Namah Shivaya this month!',
      mantraName: 'Om Namah Shivaya',
      mantraId: 1,
      globalTarget: 100000,
      globalProgress: 67842,
      myContribution: 1080,
      participantCount: 2847,
      startDate: now.subtract(const Duration(days: 15)),
      endDate: now.add(const Duration(days: 15)),
      festivalName: 'Maha Shivaratri',
    ),
    CommunityChallenge(
      id: 'ch_2',
      title: 'Gayatri Mantra Marathon',
      description:
          'Chant Gayatri Mantra daily for 21 days. Personal target: 108/day.',
      mantraName: 'Gayatri Mantra',
      mantraId: 2,
      globalTarget: 500000,
      globalProgress: 234567,
      myContribution: 540,
      participantCount: 5423,
      startDate: now.subtract(const Duration(days: 5)),
      endDate: now.add(const Duration(days: 16)),
    ),
    CommunityChallenge(
      id: 'ch_3',
      title: 'Hanuman Chalisa 40-Day Challenge',
      description:
          'Read/chant the complete Hanuman Chalisa daily for 40 days.',
      mantraName: 'Hanuman Chalisa',
      globalTarget: 50000,
      globalProgress: 12340,
      myContribution: 15,
      participantCount: 1256,
      startDate: now.subtract(const Duration(days: 10)),
      endDate: now.add(const Duration(days: 30)),
    ),
  ];
}

List<Achievement> _generateAchievements() {
  return [
    const Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '🔥',
      category: AchievementCategory.streak,
      targetValue: 7,
      currentValue: 5,
    ),
    const Achievement(
      id: 'streak_30',
      title: 'Monthly Devotee',
      description: 'Maintain a 30-day streak',
      icon: '📿',
      category: AchievementCategory.streak,
      targetValue: 30,
      currentValue: 5,
    ),
    const Achievement(
      id: 'count_108',
      title: 'First Mala',
      description: 'Complete 108 chants in a single session',
      icon: '🙏',
      category: AchievementCategory.count,
      targetValue: 108,
      currentValue: 108,
      isUnlocked: true,
    ),
    const Achievement(
      id: 'count_1008',
      title: 'Sahasra',
      description: 'Complete 1008 total chants',
      icon: '✨',
      category: AchievementCategory.count,
      targetValue: 1008,
      currentValue: 540,
    ),
    const Achievement(
      id: 'count_10008',
      title: 'Dasha Sahasra',
      description: 'Complete 10,008 total chants',
      icon: '🏆',
      category: AchievementCategory.count,
      targetValue: 10008,
      currentValue: 540,
    ),
    const Achievement(
      id: 'verse_1',
      title: 'Verse Reader',
      description: 'Complete one full verse mantra',
      icon: '📖',
      category: AchievementCategory.verse,
      targetValue: 1,
      currentValue: 0,
    ),
    const Achievement(
      id: 'community_1',
      title: 'Sangha',
      description: 'Join your first congregation session',
      icon: '👥',
      category: AchievementCategory.community,
      targetValue: 1,
      currentValue: 0,
    ),
    const Achievement(
      id: 'accuracy_90',
      title: 'Perfect Pronunciation',
      description: 'Achieve 90%+ ASR accuracy in a session',
      icon: '🎯',
      category: AchievementCategory.accuracy,
      targetValue: 90,
      currentValue: 0,
    ),
    const Achievement(
      id: 'devotion_brahma',
      title: 'Brahma Muhurta',
      description: 'Complete 7 sessions before 5:30 AM',
      icon: '🌅',
      category: AchievementCategory.devotion,
      targetValue: 7,
      currentValue: 1,
    ),
  ];
}
