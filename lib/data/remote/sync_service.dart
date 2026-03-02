import 'dart:convert';
import 'package:http/http.dart' as http;
import '../local/database.dart';
import 'supabase_service.dart';
import '../../core/env.dart';

/// Offline-first sync queue.
/// After each session, data is queued in SQLite and synced to the
/// Cloudflare Worker → Supabase pipeline when connectivity is available.
class SyncService {
  final AppDatabase _db;

  SyncService(this._db);

  /// Queue a completed session for sync.
  Future<void> queueSync(String sessionId) async {
    final session = await _db.getSessionById(sessionId);
    final payload = jsonEncode({
      'id': session.id,
      'mantra_id': session.mantraId,
      'started_at': session.startedAt.toIso8601String(),
      'ended_at': session.endedAt?.toIso8601String(),
      'target_count': session.targetCount,
      'achieved_count': session.achievedCount,
    });

    await _db.insertPendingSync(PendingSyncsTableCompanion.insert(
      sessionId: sessionId,
      payload: payload,
      createdAt: DateTime.now(),
    ));

    // Fire and forget
    _tryProcessQueue();
  }

  /// Process all pending items. Called on connectivity restore,
  /// app foreground, and by Workmanager periodic task.
  Future<void> tryProcessQueue() => _tryProcessQueue();

  Future<void> _tryProcessQueue() async {
    if (!SupabaseService.isAuthenticated) return;

    final pending = await _db.getPendingSyncs(maxRetries: 3);
    if (pending.isEmpty) return;

    final token = SupabaseService.accessToken;
    if (token == null) return;

    final cfWorkerUrl = '${Env.cfWorkerBaseUrl}/sync/session';

    for (final item in pending) {
      try {
        final response = await http.post(
          Uri.parse(cfWorkerUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: item.payload,
        );

        if (response.statusCode == 200) {
          await _db.markSyncComplete(item.id);
          await _db.markSessionSynced(item.sessionId);
        } else {
          await _db.incrementSyncRetry(item.id);
        }
      } catch (_) {
        await _db.incrementSyncRetry(item.id);
      }
    }
  }
}
