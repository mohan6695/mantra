import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';

/// Reactive stream of today's stats (all mantras).
final todayStatsProvider = StreamProvider<List<DailyStatsTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final today =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return db.watchTodayStats(today);
});

/// Reactive stream of active mantras.
final mantrasProvider = StreamProvider<List<MantraConfigTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllMantras();
});

/// Reactive stream of recent sessions (last 10).
final recentSessionsProvider = StreamProvider<List<SessionsTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchRecentSessions(limit: 10);
});

/// Heatmap data — last 90 days of stats (not a stream, but auto-refreshes
/// when today's stats change).
final heatmapDataProvider =
    FutureProvider<List<DailyStatsTableData>>((ref) async {
  // Depend on todayStats so we re-fetch whenever today changes.
  ref.watch(todayStatsProvider);
  final db = ref.read(appDatabaseProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 90));
  final fmt = _formatDate;
  return db.getStatsForRange(fmt(start), fmt(now));
});

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Simple derived streak counter.
final streakProvider = FutureProvider<int>((ref) async {
  ref.watch(todayStatsProvider);
  final db = ref.read(appDatabaseProvider);
  final now = DateTime.now();
  int streak = 0;
  for (int i = 0; i < 365; i++) {
    final day = now.subtract(Duration(days: i));
    final date =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final stats = await db.getStatsForRange(date, date);
    if (stats.isEmpty) break;
    final dayTotal = stats.fold<int>(0, (sum, s) => sum + s.totalCount);
    if (dayTotal <= 0) break;
    streak++;
  }
  return streak;
});
