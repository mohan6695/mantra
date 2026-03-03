import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ──────────────────────────────────────────────
// Table definitions
// ──────────────────────────────────────────────

class MantraConfigTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get devanagari => text()();
  TextColumn get romanized => text()();
  IntColumn get targetCount => integer().withDefault(const Constant(108))();
  RealColumn get sensitivity =>
      real().withDefault(const Constant(0.82))();
  IntColumn get refractoryMs =>
      integer().withDefault(const Constant(800))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class SessionsTable extends Table {
  TextColumn get id => text()(); // UUID
  IntColumn get mantraId => integer().references(MantraConfigTable, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get targetCount => integer()();
  IntColumn get achievedCount =>
      integer().withDefault(const Constant(0))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DetectionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().references(SessionsTable, #id)();
  DateTimeColumn get detectedAt => dateTime()();
  RealColumn get confidence => real()();
  TextColumn get engine =>
      text().withDefault(const Constant('tflite'))();
}

class DailyStatsTable extends Table {
  IntColumn get mantraId => integer().references(MantraConfigTable, #id)();
  TextColumn get date => text()(); // ISO date "2026-03-02"
  IntColumn get totalCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get sessionsCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get streakDays =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {mantraId, date};
}

class PendingSyncsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  TextColumn get payload => text()(); // JSON blob
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}

// ──────────────────────────────────────────────
// Database class
// ──────────────────────────────────────────────

@DriftDatabase(tables: [
  MantraConfigTable,
  SessionsTable,
  DetectionsTable,
  DailyStatsTable,
  PendingSyncsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing only.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await insertDefaultMantras();
        },
      );

  // ──────────────────────────────────────────
  // Seed data
  // ──────────────────────────────────────────

  Future<void> insertDefaultMantras() async {
    await batch((batch) {
      batch.insertAll(
        mantraConfigTable,
        [
          MantraConfigTableCompanion.insert(
            name: 'Om Namah Shivaya',
            devanagari: 'ॐ नमः शिवाय',
            romanized: 'Om Na-mah Shi-vaa-ya',
          ),
          MantraConfigTableCompanion.insert(
            name: 'Om Mani Padme Hum',
            devanagari: 'ॐ मणि पद्मे हूँ',
            romanized: 'Om Ma-ni Pad-me Hum',
          ),
          MantraConfigTableCompanion.insert(
            name: 'Hare Krishna',
            devanagari: 'हरे कृष्ण',
            romanized: 'Ha-re Krish-na',
          ),
          MantraConfigTableCompanion.insert(
            name: 'Om Shanti',
            devanagari: 'ॐ शान्ति',
            romanized: 'Om Shan-ti',
          ),
          MantraConfigTableCompanion.insert(
            name: 'Om Gam Ganapataye',
            devanagari: 'ॐ गं गणपतये नमः',
            romanized: 'Om Gam Ga-na-pa-ta-ye',
          ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  // ──────────────────────────────────────────
  // Mantra queries
  // ──────────────────────────────────────────

  Future<List<MantraConfigTableData>> getAllMantras() =>
      (select(mantraConfigTable)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Stream<List<MantraConfigTableData>> watchAllMantras() =>
      (select(mantraConfigTable)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<MantraConfigTableData> getMantraById(int id) =>
      (select(mantraConfigTable)..where((t) => t.id.equals(id))).getSingle();

  // ──────────────────────────────────────────
  // Session queries
  // ──────────────────────────────────────────

  Future<void> insertSession(SessionsTableCompanion entry) =>
      into(sessionsTable).insert(entry);

  Future<SessionsTableData> getSessionById(String id) =>
      (select(sessionsTable)..where((s) => s.id.equals(id))).getSingle();

  Future<void> markSessionEnded(
      String sessionId, DateTime endedAt, int achievedCount) =>
      (update(sessionsTable)..where((s) => s.id.equals(sessionId))).write(
        SessionsTableCompanion(
          endedAt: Value(endedAt),
          achievedCount: Value(achievedCount),
        ),
      );

  Future<void> markSessionSynced(String sessionId) =>
      (update(sessionsTable)..where((s) => s.id.equals(sessionId))).write(
        const SessionsTableCompanion(isSynced: Value(true)),
      );

  Stream<List<SessionsTableData>> watchRecentSessions({int limit = 10}) =>
      (select(sessionsTable)
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
            ..limit(limit))
          .watch();

  /// Find orphaned sessions (started but never ended).
  Future<List<SessionsTableData>> getOrphanedSessions() =>
      (select(sessionsTable)..where((s) => s.endedAt.isNull())).get();

  // ──────────────────────────────────────────
  // Detection queries
  // ──────────────────────────────────────────

  Future<void> insertDetection(DetectionsTableCompanion entry) =>
      into(detectionsTable).insert(entry);

  Stream<List<DetectionsTableData>> watchDetectionsForSession(
          String sessionId) =>
      (select(detectionsTable)
            ..where((d) => d.sessionId.equals(sessionId)))
          .watch();

  Future<DetectionsTableData?> getLastDetectionForSession(
      String sessionId) async {
    final q = select(detectionsTable)
      ..where((d) => d.sessionId.equals(sessionId))
      ..orderBy([(d) => OrderingTerm.desc(d.detectedAt)])
      ..limit(1);
    final results = await q.get();
    return results.isEmpty ? null : results.first;
  }

  // ──────────────────────────────────────────
  // DailyStats queries
  // ──────────────────────────────────────────

  Future<void> upsertDailyStat({
    required int mantraId,
    required String date,
    required int countToAdd,
  }) async {
    // Check if a row already exists for this mantra + date
    final existing = await (select(dailyStatsTable)
          ..where((d) => d.mantraId.equals(mantraId) & d.date.equals(date)))
        .getSingleOrNull();

    if (existing != null) {
      // Update existing row — this notifies Drift stream watchers
      await (update(dailyStatsTable)
            ..where((d) => d.mantraId.equals(mantraId) & d.date.equals(date)))
          .write(DailyStatsTableCompanion(
        totalCount: Value(existing.totalCount + countToAdd),
        sessionsCount: Value(existing.sessionsCount + 1),
      ));
    } else {
      // Insert new row — this also notifies Drift stream watchers
      await into(dailyStatsTable).insert(DailyStatsTableCompanion(
        mantraId: Value(mantraId),
        date: Value(date),
        totalCount: Value(countToAdd),
        sessionsCount: const Value(1),
        streakDays: const Value(0),
      ));
    }
  }

  Stream<List<DailyStatsTableData>> watchTodayStats(String todayDate) =>
      (select(dailyStatsTable)..where((d) => d.date.equals(todayDate)))
          .watch();

  Future<List<DailyStatsTableData>> getStatsForRange(
      String startDate, String endDate) =>
      (select(dailyStatsTable)
            ..where((d) =>
                d.date.isBiggerOrEqualValue(startDate) &
                d.date.isSmallerOrEqualValue(endDate))
            ..orderBy([(d) => OrderingTerm.asc(d.date)]))
          .get();

  // ──────────────────────────────────────────
  // PendingSync queries
  // ──────────────────────────────────────────

  Future<void> insertPendingSync(PendingSyncsTableCompanion entry) =>
      into(pendingSyncsTable).insert(entry);

  Future<List<PendingSyncsTableData>> getPendingSyncs({int maxRetries = 3}) =>
      (select(pendingSyncsTable)
            ..where(
                (p) => p.retryCount.isSmallerThanValue(maxRetries))
            ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
          .get();

  Future<void> markSyncComplete(int syncId) =>
      (delete(pendingSyncsTable)..where((p) => p.id.equals(syncId))).go();

  Future<void> incrementSyncRetry(int syncId) async {
    await customStatement(
      'UPDATE pending_syncs_table SET retry_count = retry_count + 1, '
      'last_attempt_at = ? WHERE id = ?',
      [DateTime.now().millisecondsSinceEpoch ~/ 1000, syncId],
    );
  }
}

// ──────────────────────────────────────────────
// Database connection
// ──────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mantra.db'));
    return NativeDatabase.createInBackground(file);
  });
}

