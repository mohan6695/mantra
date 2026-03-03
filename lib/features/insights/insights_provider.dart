import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'insights_engine.dart';

/// Provider for the insights engine.
final insightsEngineProvider = Provider<InsightsEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return InsightsEngine(db: db);
});

/// Personalized insights — refreshes when today's stats change.
final insightsProvider = FutureProvider<List<PracticeInsight>>((ref) async {
  final engine = ref.watch(insightsEngineProvider);
  return engine.generateInsights();
});

/// Weekly summary.
final weeklySummaryProvider = FutureProvider<WeeklySummary>((ref) async {
  final engine = ref.watch(insightsEngineProvider);
  return engine.getWeeklySummary();
});
