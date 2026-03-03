/// Personalized insights engine.
///
/// Analyzes user's mantra practice data to generate:
/// 1. Practice consistency insights
/// 2. Pronunciation accuracy trends (when ASR is enabled)
/// 3. Optimal chanting time suggestions
/// 4. Progress milestones and projections
/// 5. Per-mantra performance analysis

import 'dart:math';
import '../../data/local/database.dart';

// ──────────────────────────────────────────────────────────
// Insight models
// ──────────────────────────────────────────────────────────

/// A personalized insight card for the dashboard.
class PracticeInsight {
  final InsightType type;
  final String title;
  final String description;
  final String? emoji;
  final double? value;
  final String? valueLabel;
  final InsightTrend trend;
  final DateTime generatedAt;

  const PracticeInsight({
    required this.type,
    required this.title,
    required this.description,
    this.emoji,
    this.value,
    this.valueLabel,
    this.trend = InsightTrend.neutral,
    required this.generatedAt,
  });
}

enum InsightType {
  streak,
  consistency,
  bestTime,
  weeklyTrend,
  accuracy,
  milestone,
  encouragement,
  verseProficiency,
  chantingSpeed,
  devotionScore,
}

enum InsightTrend { up, down, neutral, newRecord }

/// Per-mantra performance summary.
class MantraPerformance {
  final int mantraId;
  final String mantraName;
  final int totalChants;
  final int todayChants;
  final int weeklyChants;
  final int monthlyChants;
  final double averageSessionChants;
  final Duration averageSessionDuration;
  final int longestStreak;
  final int currentStreak;
  final double? avgAccuracy; // ASR accuracy, null if not available
  final double weekOverWeekChange; // % change from last week
  final int sessionsThisWeek;
  final TimeOfDay? bestTimeOfDay; // When user chants most

  const MantraPerformance({
    required this.mantraId,
    required this.mantraName,
    required this.totalChants,
    required this.todayChants,
    required this.weeklyChants,
    required this.monthlyChants,
    required this.averageSessionChants,
    required this.averageSessionDuration,
    required this.longestStreak,
    required this.currentStreak,
    this.avgAccuracy,
    required this.weekOverWeekChange,
    required this.sessionsThisWeek,
    this.bestTimeOfDay,
  });
}

/// Simple time representation (no Flutter dependency).
class TimeOfDay {
  final int hour;
  final int minute;
  const TimeOfDay({required this.hour, required this.minute});

  String get formatted {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:${minute.toString().padLeft(2, '0')} $period';
  }
}

/// Weekly practice summary.
class WeeklySummary {
  final int totalChants;
  final int totalSessions;
  final Duration totalTime;
  final int activeDays;
  final double consistencyScore; // 0.0 to 1.0
  final List<int> dailyCounts; // Mon-Sun counts
  final int comparedToLastWeek; // +/- change in total chants

  const WeeklySummary({
    required this.totalChants,
    required this.totalSessions,
    required this.totalTime,
    required this.activeDays,
    required this.consistencyScore,
    required this.dailyCounts,
    required this.comparedToLastWeek,
  });
}

/// Devotion score — a holistic measure of practice quality.
class DevotionScore {
  final double score; // 0 to 100
  final double consistency; // % of days active in last 30
  final double volume; // normalized count vs target
  final double streakBonus; // streak multiplier
  final double accuracyBonus; // ASR accuracy multiplier (if available)
  final String level; // Sadhaka, Tapasya, Siddhi, etc.
  final String emoji;

  const DevotionScore({
    required this.score,
    required this.consistency,
    required this.volume,
    required this.streakBonus,
    required this.accuracyBonus,
    required this.level,
    required this.emoji,
  });

  /// Compute devotion level from score.
  static String levelFromScore(double score) {
    if (score >= 90) return 'Siddhi';
    if (score >= 75) return 'Tapasya';
    if (score >= 55) return 'Sadhaka';
    if (score >= 35) return 'Abhyasi';
    if (score >= 15) return 'Mumukshu';
    return 'Aarambhi';
  }

  static String emojiFromScore(double score) {
    if (score >= 90) return '🙏✨';
    if (score >= 75) return '🔥';
    if (score >= 55) return '🙏';
    if (score >= 35) return '📿';
    if (score >= 15) return '🌱';
    return '🕉️';
  }
}

// ──────────────────────────────────────────────────────────
// Insights engine
// ──────────────────────────────────────────────────────────

class InsightsEngine {
  final AppDatabase db;

  InsightsEngine({required this.db});

  /// Generate all personalized insights.
  Future<List<PracticeInsight>> generateInsights() async {
    final insights = <PracticeInsight>[];
    final now = DateTime.now();
    final todayStr = _fmt(now);

    // Get last 30 days of stats
    final start30 = now.subtract(const Duration(days: 30));
    final stats30 = await db.getStatsForRange(_fmt(start30), todayStr);

    // Get last 7 days
    final start7 = now.subtract(const Duration(days: 7));
    final stats7 = stats30.where((s) => s.date.compareTo(_fmt(start7)) >= 0).toList();

    // Current streak
    final streak = await _computeStreak();
    insights.add(PracticeInsight(
      type: InsightType.streak,
      title: streak > 0 ? '$streak Day Streak!' : 'Start Your Streak',
      description: streak > 7
          ? 'Amazing! You\'ve been consistent for $streak days. Keep the flame alive!'
          : streak > 0
              ? 'Great start! Chant today to keep your $streak-day streak going.'
              : 'Begin your practice today and start building your streak.',
      emoji: streak > 7 ? '🔥' : streak > 0 ? '📿' : '🌱',
      value: streak.toDouble(),
      valueLabel: '${streak}d',
      trend: streak > 7
          ? InsightTrend.newRecord
          : streak > 0
              ? InsightTrend.up
              : InsightTrend.neutral,
      generatedAt: now,
    ));

    // Weekly trend
    final thisWeekTotal = stats7.fold<int>(0, (sum, s) => sum + s.totalCount);
    final prevStart = now.subtract(const Duration(days: 14));
    final prevStats = stats30
        .where((s) =>
            s.date.compareTo(_fmt(prevStart)) >= 0 &&
            s.date.compareTo(_fmt(start7)) < 0)
        .toList();
    final prevWeekTotal = prevStats.fold<int>(0, (sum, s) => sum + s.totalCount);
    final weekChange = prevWeekTotal > 0
        ? ((thisWeekTotal - prevWeekTotal) / prevWeekTotal * 100).round()
        : (thisWeekTotal > 0 ? 100 : 0);

    insights.add(PracticeInsight(
      type: InsightType.weeklyTrend,
      title: 'This Week: $thisWeekTotal Chants',
      description: weekChange > 0
          ? 'You\'re up $weekChange% from last week! Wonderful devotion.'
          : weekChange < 0
              ? 'Down ${weekChange.abs()}% from last week. Every chant counts!'
              : prevWeekTotal == 0
                  ? 'Start your weekly practice!'
                  : 'Same as last week. Consistency is key!',
      emoji: weekChange > 0 ? '📈' : weekChange < 0 ? '📉' : '➡️',
      value: thisWeekTotal.toDouble(),
      trend: weekChange > 10
          ? InsightTrend.up
          : weekChange < -10
              ? InsightTrend.down
              : InsightTrend.neutral,
      generatedAt: now,
    ));

    // Consistency score
    final activeDays30 = _countActiveDays(stats30);
    final consistencyPct = (activeDays30 / 30 * 100).round();
    insights.add(PracticeInsight(
      type: InsightType.consistency,
      title: '$consistencyPct% Consistency',
      description: consistencyPct >= 80
          ? 'Outstanding! You practiced $activeDays30 of the last 30 days.'
          : consistencyPct >= 50
              ? 'Good effort! $activeDays30/30 active days. Aim for daily practice.'
              : 'You practiced $activeDays30 of 30 days. Small steps lead to big change.',
      emoji: consistencyPct >= 80
          ? '🏆'
          : consistencyPct >= 50
              ? '👍'
              : '💪',
      value: consistencyPct.toDouble(),
      valueLabel: '${consistencyPct}%',
      trend: consistencyPct >= 80
          ? InsightTrend.newRecord
          : InsightTrend.neutral,
      generatedAt: now,
    ));

    // Best time of day
    final sessions = await db.watchRecentSessions(limit: 50).first;
    if (sessions.isNotEmpty) {
      final hourCounts = <int, int>{};
      for (final s in sessions) {
        final h = s.startedAt.hour;
        hourCounts[h] = (hourCounts[h] ?? 0) + (s.achievedCount as int);
      }
      final bestHour = hourCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      final period = bestHour >= 12 ? 'PM' : 'AM';
      final displayHour = bestHour > 12
          ? bestHour - 12
          : (bestHour == 0 ? 12 : bestHour);

      insights.add(PracticeInsight(
        type: InsightType.bestTime,
        title: 'Best Time: $displayHour $period',
        description:
            bestHour < 6
                ? 'Brahma Muhurta sadhak! Early morning practice amplifies devotion.'
                : bestHour < 10
                    ? 'Morning practitioner! A wonderful way to start the day.'
                    : bestHour < 17
                        ? 'Your most productive chanting happens in the afternoon.'
                        : 'Evening devotee! Sandhya vandana time suits you best.',
        emoji: bestHour < 6
            ? '🌅'
            : bestHour < 10
                ? '☀️'
                : bestHour < 17
                    ? '🌤️'
                    : '🌙',
        generatedAt: now,
      ));
    }

    // Total milestone
    final total30 = stats30.fold<int>(0, (sum, s) => sum + s.totalCount);
    final nextMilestone = _nextMilestone(total30);
    if (nextMilestone != null) {
      final remaining = nextMilestone - total30;
      insights.add(PracticeInsight(
        type: InsightType.milestone,
        title: '${_formatCount(total30)} / ${_formatCount(nextMilestone)}',
        description:
            'You need $remaining more chants to reach ${_formatCount(nextMilestone)}. '
            '${_daysToReach(remaining, thisWeekTotal as int)}',
        emoji: '🎯',
        value: total30 / nextMilestone,
        generatedAt: now,
      ));
    }

    // Devotion score
    final devotion = _computeDevotionScore(
      activeDays30: activeDays30,
      total30: total30,
      streak: streak,
    );
    insights.add(PracticeInsight(
      type: InsightType.devotionScore,
      title: '${devotion.level} — ${devotion.score.round()}/100',
      description:
          'Your devotion score reflects consistency, volume, and dedication. '
          '${devotion.score >= 75 ? "You\'re inspiring!" : "Keep practicing to level up!"}',
      emoji: devotion.emoji,
      value: devotion.score,
      valueLabel: devotion.level,
      trend: devotion.score >= 75 ? InsightTrend.up : InsightTrend.neutral,
      generatedAt: now,
    ));

    return insights;
  }

  /// Compute per-mantra performance.
  Future<MantraPerformance> getMantraPerformance(
      MantraConfigTableData mantra) async {
    final now = DateTime.now();
    final todayStr = _fmt(now);
    final weekStart = _fmt(now.subtract(const Duration(days: 7)));
    final monthStart = _fmt(now.subtract(const Duration(days: 30)));

    final todayStats = (await db.getStatsForRange(todayStr, todayStr))
        .where((s) => s.mantraId == mantra.id);
    final weekStats = (await db.getStatsForRange(weekStart, todayStr))
        .where((s) => s.mantraId == mantra.id)
        .toList();
    final monthStats = (await db.getStatsForRange(monthStart, todayStr))
        .where((s) => s.mantraId == mantra.id)
        .toList();

    final todayCount = todayStats.fold<int>(0, (s, d) => s + d.totalCount);
    final weekCount = weekStats.fold<int>(0, (s, d) => s + d.totalCount);
    final monthCount = monthStats.fold<int>(0, (s, d) => s + d.totalCount);
    final totalSessions = monthStats.fold<int>(0, (s, d) => s + d.sessionsCount);

    // Previous week for comparison
    final prevWeekStart = _fmt(now.subtract(const Duration(days: 14)));
    final prevStats = (await db.getStatsForRange(prevWeekStart, weekStart))
        .where((s) => s.mantraId == mantra.id)
        .toList();
    final prevWeekCount = prevStats.fold<int>(0, (s, d) => s + d.totalCount);
    final weekChange = prevWeekCount > 0
        ? (weekCount - prevWeekCount) / prevWeekCount * 100
        : (weekCount > 0 ? 100.0 : 0.0);

    return MantraPerformance(
      mantraId: mantra.id,
      mantraName: mantra.name,
      totalChants: monthCount,
      todayChants: todayCount,
      weeklyChants: weekCount,
      monthlyChants: monthCount,
      averageSessionChants:
          totalSessions > 0 ? monthCount / totalSessions : 0,
      averageSessionDuration: Duration.zero, // Would need session duration data
      longestStreak: 0, // Would need full streak computation
      currentStreak: await _computeStreakForMantra(mantra.id),
      weekOverWeekChange: weekChange,
      sessionsThisWeek:
          weekStats.fold<int>(0, (s, d) => s + d.sessionsCount),
    );
  }

  /// Compute weekly summary.
  Future<WeeklySummary> getWeeklySummary() async {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final stats = await db.getStatsForRange(_fmt(weekStart), _fmt(now));

    final dailyCounts = List.filled(7, 0);
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayStr = _fmt(day);
      final dayStats = stats.where((s) => s.date == dayStr);
      dailyCounts[i] = dayStats.fold<int>(0, (sum, s) => sum + s.totalCount);
    }

    final totalChants = dailyCounts.fold<int>(0, (a, b) => a + b);
    final activeDays = dailyCounts.where((c) => c > 0).length;
    final totalSessions =
        stats.fold<int>(0, (sum, s) => sum + s.sessionsCount);

    // Previous week
    final prevStart = now.subtract(const Duration(days: 13));
    final prevStats = await db.getStatsForRange(_fmt(prevStart), _fmt(weekStart));
    final prevTotal = prevStats.fold<int>(0, (sum, s) => sum + s.totalCount);

    return WeeklySummary(
      totalChants: totalChants,
      totalSessions: totalSessions,
      totalTime: Duration.zero,
      activeDays: activeDays,
      consistencyScore: activeDays / 7.0,
      dailyCounts: dailyCounts,
      comparedToLastWeek: (totalChants - prevTotal).toInt(),
    );
  }

  // ── Helpers ──

  Future<int> _computeStreak() async {
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final stats = await db.getStatsForRange(_fmt(day), _fmt(day));
      final dayTotal = stats.fold<int>(0, (sum, s) => sum + s.totalCount);
      if (dayTotal <= 0) break;
      streak++;
    }
    return streak;
  }

  Future<int> _computeStreakForMantra(int mantraId) async {
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final dayStr = _fmt(day);
      final stats = await db.getStatsForRange(dayStr, dayStr);
      final mantraStats = stats.where((s) => s.mantraId == mantraId);
      final dayTotal = mantraStats.fold<int>(0, (sum, s) => sum + s.totalCount);
      if (dayTotal <= 0) break;
      streak++;
    }
    return streak;
  }

  int _countActiveDays(List<DailyStatsTableData> stats) {
    final dates = <String>{};
    for (final s in stats) {
      if (s.totalCount > 0) dates.add(s.date);
    }
    return dates.length;
  }

  int? _nextMilestone(int current) {
    const milestones = [108, 1008, 5000, 10008, 25000, 50000, 100008, 500000, 1000000];
    for (final m in milestones) {
      if (current < m) return m;
    }
    return null;
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 100000) return '${(count / 1000).toStringAsFixed(0)}K';
    if (count >= 10000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _daysToReach(int remaining, int weeklyRate) {
    if (weeklyRate <= 0) return 'Start chanting to reach this milestone!';
    final dailyRate = weeklyRate / 7;
    final days = (remaining / dailyRate).ceil();
    if (days <= 1) return 'You could reach this today!';
    if (days <= 7) return 'At your current pace, ~$days days to go.';
    if (days <= 30) return 'About ${(days / 7).ceil()} weeks at your current pace.';
    return 'About ${(days / 30).ceil()} months at your current pace.';
  }

  DevotionScore _computeDevotionScore({
    required int activeDays30,
    required int total30,
    required int streak,
  }) {
    // Consistency: 0-40 points
    final consistency = min(activeDays30 / 30.0, 1.0);
    final consistencyPoints = consistency * 40;

    // Volume: 0-30 points (108/day * 30 = 3240 is "full")
    final volumeNorm = min(total30 / 3240.0, 1.0);
    final volumePoints = volumeNorm * 30;

    // Streak bonus: 0-20 points
    final streakNorm = min(streak / 30.0, 1.0);
    final streakPoints = streakNorm * 20;

    // Accuracy bonus: 0-10 points (placeholder until ASR data available)
    const accuracyPoints = 5.0; // Default 50% when no ASR

    final score = consistencyPoints + volumePoints + streakPoints + accuracyPoints;
    final level = DevotionScore.levelFromScore(score);
    final emoji = DevotionScore.emojiFromScore(score);

    return DevotionScore(
      score: score.clamp(0, 100),
      consistency: consistency,
      volume: volumeNorm,
      streakBonus: streakNorm,
      accuracyBonus: 0.5,
      level: level,
      emoji: emoji,
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
