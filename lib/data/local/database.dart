import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class MantraConfigTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get devanagari => text()();
  TextColumn get romanized => text()();
  IntColumn get targetCount => integer()();
  RealColumn get sensitivity => real().withDefault(const Constant(0.6))();
  IntColumn get refractoryMs => integer().withDefault(const Constant(800))();
}

class SessionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mantraId => integer().references(MantraConfigTable, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get targetCount => integer()();
  IntColumn get achievedCount => integer()();
}

class DetectionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(SessionsTable, #id)();
  DateTimeColumn get detectedAt => dateTime()();
  RealColumn get confidence => real()();
  TextColumn get engine => text()(); // 'porcupine' | 'vosk'
}

@DriftDatabase(tables: [MantraConfigTable, SessionsTable, DetectionsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await insertDefaultMantras();
        },
      );

  Future<void> insertDefaultMantras() async {
    await batch((batch) {
      batch.insertAll(mantraConfigTable, [
        MantraConfigTableCompanion.insert(
          name: 'Om Namah Shivaya',
          devanagari: 'ॐ नमः शिवाय',
          romanized: 'Om Namah Shivaya',
          targetCount: 108,
        ),
        MantraConfigTableCompanion.insert(
          name: 'Om Mani Padme Hum',
          devanagari: 'ॐ मणि पद्मे हूँ',
          romanized: 'Om Mani Padme Hum',
          targetCount: 108,
        ),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  // --- Query helpers ---

  Future<List<MantraConfigTableData>> getAllMantras() =>
      select(mantraConfigTable).get();

  Stream<List<MantraConfigTableData>> watchAllMantras() =>
      select(mantraConfigTable).watch();

  Future<int> startSession(int mantraId, int target) =>
      into(sessionsTable).insert(SessionsTableCompanion.insert(
        mantraId: mantraId,
        startedAt: DateTime.now(),
        targetCount: target,
        achievedCount: 0,
      ));

  Future<void> endSession(int sessionId, int achievedCount) =>
      (update(sessionsTable)..where((s) => s.id.equals(sessionId))).write(
        SessionsTableCompanion(
          endedAt: Value(DateTime.now()),
          achievedCount: Value(achievedCount),
        ),
      );

  Future<void> recordDetection(int sessionId, double confidence, String engine) =>
      into(detectionsTable).insert(DetectionsTableCompanion.insert(
        sessionId: sessionId,
        detectedAt: DateTime.now(),
        confidence: confidence,
        engine: engine,
      ));

  Stream<List<DetectionsTableData>> watchDetectionsForSession(int sessionId) =>
      (select(detectionsTable)..where((d) => d.sessionId.equals(sessionId)))
          .watch();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mantra.db'));
    return NativeDatabase.createInBackground(file);
  });
}
