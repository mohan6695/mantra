import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/router.dart';
import 'data/local/database.dart';
import 'notifications/notification_service.dart';

// ──────────────────────────────────────────────
// Entry point
// ──────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notifications init
  await NotificationService.init();

  // Single database instance for the whole app
  final db = AppDatabase();

  // Clean up orphaned sessions from potential crashes
  final orphaned = await db.getOrphanedSessions();
  for (final s in orphaned) {
    final lastDetection = await db.getLastDetectionForSession(s.id);
    await db.markSessionEnded(
      s.id,
      lastDetection?.detectedAt ?? s.startedAt,
      s.achievedCount,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const MantraApp(),
    ),
  );
}

// ──────────────────────────────────────────────
// Root widget
// ──────────────────────────────────────────────

class MantraApp extends ConsumerWidget {
  const MantraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Mantra Counter',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
    );
  }
}
