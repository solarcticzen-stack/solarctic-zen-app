import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/data/db/app_database.dart';
import 'package:solarctic_zen/data/db/drift_repository.dart';
import 'package:solarctic_zen/domain/questionnaire/questionnaire.dart';

/// Schema der Version 1, wie es auf Geräten mit der ersten App-Version liegt.
const _v1 = [
  '''CREATE TABLE ice_sessions (
    id TEXT NOT NULL, status TEXT NOT NULL, entry_mode TEXT NOT NULL,
    started_at_ms INTEGER NOT NULL, ended_at_ms INTEGER NULL,
    utc_offset_min INTEGER NOT NULL, tz_name TEXT NULL, local_date TEXT NOT NULL,
    duration_s INTEGER NULL, water_temp_c REAL NULL,
    feeling_before INTEGER NULL, feeling_after INTEGER NULL, notes TEXT NULL,
    countdown_s INTEGER NULL, created_at_ms INTEGER NOT NULL,
    updated_at_ms INTEGER NOT NULL, deleted_at_ms INTEGER NULL,
    version INTEGER NOT NULL DEFAULT 1, PRIMARY KEY (id))''',
  '''CREATE TABLE session_pauses (
    session_id TEXT NOT NULL REFERENCES ice_sessions (id) ON DELETE CASCADE,
    paused_at_ms INTEGER NOT NULL, resumed_at_ms INTEGER NULL,
    PRIMARY KEY (session_id, paused_at_ms))''',
  'CREATE TABLE app_settings (key TEXT NOT NULL, value TEXT NULL, PRIMARY KEY (key))',
  '''CREATE UNIQUE INDEX idx_one_active_session ON ice_sessions (status)
    WHERE status = 'active' AND deleted_at_ms IS NULL''',
  // Eine bestehende Session aus Version 1.
  '''INSERT INTO ice_sessions (id, status, entry_mode, started_at_ms, ended_at_ms,
    utc_offset_min, local_date, duration_s, water_temp_c, created_at_ms, updated_at_ms)
    VALUES ('old', 'completed', 'timer', 1763535600000, 1763535720000, 60,
    '2025-11-19', 120, 6.0, 1763535600000, 1763535720000)''',
  'PRAGMA user_version = 1',
];

void main() {
  test('Migration 1 → 3: bestehende Sessions bleiben erhalten, neue Felder und Tabellen kommen dazu', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          for (final sql in _v1) {
            raw.execute(sql);
          }
        },
      ),
    );
    addTearDown(db.close);
    final repo = DriftSessionRepository(db);

    final old = (await repo.all()).single;
    expect(old.id, 'old');
    expect(old.duration, const Duration(minutes: 2));
    expect(old.waterTempC, 6.0);
    expect(old.warmupExerciseId, isNull);
    expect(
      old.warmupDone,
      isNull,
      reason: 'alte Sessions: Impuls nicht angeboten',
    );

    await repo.save(
      old.copyWith(
        warmupExerciseId: () => 'squats',
        warmupDone: () => true,
        updatedAt: DateTime.utc(2026),
      ),
    );
    final updated = (await repo.all()).single;
    expect(updated.warmupExerciseId, 'squats');
    expect(updated.warmupDone, isTrue);

    // Version 3: drei Bewertungen und Fragebogen-Tabelle.
    await repo.save(
      updated.copyWith(
        overcomeRating: () => 2,
        duringRating: () => 4,
        updatedAt: DateTime.utc(2026),
      ),
    );
    final rated = (await repo.all()).single;
    expect(rated.overcomeRating, 2);
    expect(rated.duringRating, 4);
    final q = DriftQuestionnaireRepository(db);
    await q.save(
      QuestionnaireResult(
        id: 'q1',
        kind: QuestionnaireKind.who5,
        answeredAt: DateTime.utc(2026, 11, 19),
        answers: const [3, 3, 4, 2, 3],
        score: 60,
      ),
    );
    expect((await q.all()).single.answers, [3, 3, 4, 2, 3]);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);
  });

  test('Neue Datenbank startet direkt mit der aktuellen Version', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
  });
}
