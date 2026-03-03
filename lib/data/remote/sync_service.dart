import '../local/database.dart';

/// Stub sync service — cloud sync disabled for local-only build.
class SyncService {
  final AppDatabase _db;

  SyncService(this._db);

  /// No-op: sync disabled in local-only mode.
  Future<void> queueSync(String sessionId) async {}

  /// No-op: sync disabled in local-only mode.
  Future<void> tryProcessQueue() async {}
}
