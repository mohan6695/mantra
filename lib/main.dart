import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'core/env.dart';
import 'core/router.dart';
import 'data/local/database.dart';
import 'data/remote/sync_service.dart';
import 'notifications/notification_service.dart';

// ──────────────────────────────────────────────
// Workmanager background callback
// ──────────────────────────────────────────────

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'syncPendingSessions') {
      final db = AppDatabase();
      final sync = SyncService(db);
      await sync.tryProcessQueue();
      await db.close();
    }
    return true;
  });
}

// ──────────────────────────────────────────────
// Entry point
// ──────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase init
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Notifications init
  await NotificationService.init();

  // Workmanager init (background sync)
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    'mantra-sync',
    'syncPendingSessions',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  // Clean up orphaned sessions from potential crashes
  final db = AppDatabase();
  final orphaned = await db.getOrphanedSessions();
  for (final s in orphaned) {
    final lastDetection = await db.getLastDetectionForSession(s.id);
    await db.markSessionEnded(
      s.id,
      lastDetection?.detectedAt ?? s.startedAt,
      s.achievedCount,
    );
  }

  runApp(const ProviderScope(child: MantraApp()));
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
