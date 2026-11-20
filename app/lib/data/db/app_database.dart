import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Lokale SQLite-Datenbank (Quelle der Wahrheit, ADR-003).
/// Schema: docs/DATABASE_SCHEMA.md. Zeitpunkte als UTC-Millisekunden.

@DataClassName('IceSessionRow')
class IceSessions extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()();
  TextColumn get entryMode => text()();
  IntColumn get startedAtMs => integer()();
  IntColumn get endedAtMs => integer().nullable()();
  IntColumn get utcOffsetMin => integer()();
  TextColumn get tzName => text().nullable()();

  /// `YYYY-MM-DD` in Lokalzeit beim Start.
  TextColumn get localDate => text()();

  /// Netto-Dauer in Sekunden (Cache für Abfragen; Quelle ist Start/Ende/Pausen).
  IntColumn get durationS => integer().nullable()();
  RealColumn get waterTempC => real().nullable()();
  IntColumn get feelingBefore => integer().nullable()();
  IntColumn get feelingAfter => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get countdownS => integer().nullable()();

  /// Seit Schema-Version 2 (A20 Aufwärm-Impuls).
  TextColumn get warmupExerciseId => text().nullable()();
  BoolColumn get warmupDone => boolean().nullable()();

  /// Seit Schema-Version 3 (N-005): Überwindung vorher, Erleben im Wasser.
  IntColumn get overcomeRating => integer().nullable()();
  IntColumn get duringRating => integer().nullable()();

  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PauseRow')
class SessionPauses extends Table {
  TextColumn get sessionId =>
      text().references(IceSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get pausedAtMs => integer()();
  IntColumn get resumedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, pausedAtMs};
}

/// Seit Schema-Version 3: Fragebogen-Ergebnisse (WHO-5, Schlaf).
@DataClassName('QuestionnaireRow')
class QuestionnaireResults extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  IntColumn get answeredAtMs => integer()();

  /// Antworten als kommagetrennte Zahlen, z. B. «4,3,5,2,4».
  TextColumn get answers => text()();
  RealColumn get score => real()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [IceSessions, SessionPauses, AppSettings, QuestionnaireResults],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Datenbank im App-Verzeichnis des Geräts (iOS/Android).
  factory AppDatabase.onDevice() =>
      AppDatabase(driftDatabase(name: 'solarctic_zen'));

  /// Version 1: Sessions, Pausen, Einstellungen.
  /// Version 2: Aufwärm-Impuls an der Session (A20).
  /// Version 3: drei Bewertungen (N-005), Fragebögen (N-004).
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Höchstens eine laufende Session (DATABASE_SCHEMA.md §2).
      await customStatement(
        'CREATE UNIQUE INDEX idx_one_active_session ON ice_sessions (status) '
        "WHERE status = 'active' AND deleted_at_ms IS NULL",
      );
      await customStatement(
        'CREATE INDEX idx_sessions_local_date ON ice_sessions (local_date)',
      );
      await customStatement(
        'CREATE INDEX idx_sessions_started ON ice_sessions (started_at_ms)',
      );
    },
    onUpgrade: (m, from, to) async {
      // Jede Stufe einzeln, damit auch Sprünge über mehrere Versionen gehen.
      if (from < 2) {
        await m.addColumn(iceSessions, iceSessions.warmupExerciseId);
        await m.addColumn(iceSessions, iceSessions.warmupDone);
      }
      if (from < 3) {
        await m.addColumn(iceSessions, iceSessions.overcomeRating);
        await m.addColumn(iceSessions, iceSessions.duringRating);
        await m.createTable(questionnaireResults);
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
