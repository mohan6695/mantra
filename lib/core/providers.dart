import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';

/// Single AppDatabase instance for the entire app lifecycle.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Whether the user has completed calibration.
final isCalibrationCompleteProvider = StateProvider<bool>((ref) => false);

/// Whether the user is authenticated (Supabase session present).
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);
