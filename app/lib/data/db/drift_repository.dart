import 'package:drift/drift.dart';

import '../../domain/common/local_date.dart';
import '../../domain/questionnaire/questionnaire.dart';
import '../../domain/session/ice_session.dart';
import '../../domain/session/session_clock.dart';
import '../../domain/session/session_repository.dart';
import 'app_database.dart';

DateTime _ms(int v) => DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
DateTime? _msN(int? v) => v == null ? null : _ms(v);

/// SQLite-Implementierung des [SessionRepository].
class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<IceSession>> watchAll() =>
      _sessionsQuery().watch().asyncMap(_withPauses);

  @override
  Future<List<IceSession>> all() async =>
      _withPauses(await _sessionsQuery().get());

  @override
  Future<IceSession?> findActive() async {
    final rows =
        await (_db.select(_db.iceSessions)..where(
              (t) =>
                  t.status.equals(SessionStatus.active.name) &
                  t.deletedAtMs.isNull(),
            ))
            .get();
    if (rows.isEmpty) return null;
    return (await _withPauses(rows)).single;
  }

  @override
  Future<void> save(IceSession s) => _db.transaction(() async {
    await _db.into(_db.iceSessions).insertOnConflictUpdate(_toRow(s));
    await (_db.delete(
      _db.sessionPauses,
    )..where((t) => t.sessionId.equals(s.id))).go();
    for (final p in s.clock.pauses) {
      await _db
          .into(_db.sessionPauses)
          .insert(
            SessionPausesCompanion.insert(
              sessionId: s.id,
              pausedAtMs: p.start.millisecondsSinceEpoch,
              resumedAtMs: Value(p.end?.millisecondsSinceEpoch),
            ),
          );
    }
  });

  @override
  Future<void> delete(String id, DateTime now) async {
    final ms = now.toUtc().millisecondsSinceEpoch;
    await (_db.update(_db.iceSessions)..where((t) => t.id.equals(id))).write(
      IceSessionsCompanion(deletedAtMs: Value(ms), updatedAtMs: Value(ms)),
    );
  }

  SimpleSelectStatement<$IceSessionsTable, IceSessionRow> _sessionsQuery() =>
      _db.select(_db.iceSessions)
        ..orderBy([(t) => OrderingTerm.desc(t.startedAtMs)]);

  Future<List<IceSession>> _withPauses(List<IceSessionRow> rows) async {
    if (rows.isEmpty) return const [];
    final pauses =
        await (_db.select(_db.sessionPauses)
              ..where((t) => t.sessionId.isIn(rows.map((r) => r.id)))
              ..orderBy([(t) => OrderingTerm.asc(t.pausedAtMs)]))
            .get();
    final bySession = <String, List<PauseInterval>>{};
    for (final p in pauses) {
      bySession
          .putIfAbsent(p.sessionId, () => [])
          .add(PauseInterval(_ms(p.pausedAtMs), _msN(p.resumedAtMs)));
    }
    return [for (final r in rows) _fromRow(r, bySession[r.id] ?? const [])];
  }

  static IceSession _fromRow(IceSessionRow r, List<PauseInterval> pauses) =>
      IceSession(
        id: r.id,
        status: SessionStatus.values.byName(r.status),
        entryMode: EntryMode.values.byName(r.entryMode),
        clock: SessionClock(
          startedAt: _ms(r.startedAtMs),
          pauses: pauses,
          endedAt: _msN(r.endedAtMs),
        ),
        utcOffsetMinutes: r.utcOffsetMin,
        tzName: r.tzName,
        localDate: LocalDate.parse(r.localDate),
        waterTempC: r.waterTempC,
        feelingBefore: r.feelingBefore,
        feelingAfter: r.feelingAfter,
        notes: r.notes,
        countdownSeconds: r.countdownS,
        warmupExerciseId: r.warmupExerciseId,
        overcomeRating: r.overcomeRating,
        duringRating: r.duringRating,
        warmupDone: r.warmupDone,
        createdAt: _ms(r.createdAtMs),
        updatedAt: _ms(r.updatedAtMs),
        deletedAt: _msN(r.deletedAtMs),
      );

  static IceSessionsCompanion _toRow(IceSession s) =>
      IceSessionsCompanion.insert(
        id: s.id,
        status: s.status.name,
        entryMode: s.entryMode.name,
        startedAtMs: s.startedAt.millisecondsSinceEpoch,
        endedAtMs: Value(s.endedAt?.millisecondsSinceEpoch),
        utcOffsetMin: s.utcOffsetMinutes,
        tzName: Value(s.tzName),
        localDate: s.localDate.toString(),
        durationS: Value(s.endedAt == null ? null : s.duration.inSeconds),
        waterTempC: Value(s.waterTempC),
        feelingBefore: Value(s.feelingBefore),
        feelingAfter: Value(s.feelingAfter),
        notes: Value(s.notes),
        countdownS: Value(s.countdownSeconds),
        warmupExerciseId: Value(s.warmupExerciseId),
        overcomeRating: Value(s.overcomeRating),
        duringRating: Value(s.duringRating),
        warmupDone: Value(s.warmupDone),
        createdAtMs: s.createdAt.millisecondsSinceEpoch,
        updatedAtMs: s.updatedAt.millisecondsSinceEpoch,
        deletedAtMs: Value(s.deletedAt?.millisecondsSinceEpoch),
      );
}

class DriftSettingsStore implements SettingsStore {
  DriftSettingsStore(this._db);
  final AppDatabase _db;

  @override
  Future<String?> get(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> set(String key, String? value) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: Value(value)),
      );
}

class DriftQuestionnaireRepository implements QuestionnaireRepository {
  DriftQuestionnaireRepository(this._db);
  final AppDatabase _db;

  SimpleSelectStatement<$QuestionnaireResultsTable, QuestionnaireRow>
  _query() =>
      _db.select(_db.questionnaireResults)
        ..orderBy([(t) => OrderingTerm.asc(t.answeredAtMs)]);

  static QuestionnaireResult _fromRow(QuestionnaireRow r) =>
      QuestionnaireResult(
        id: r.id,
        kind: QuestionnaireKind.values.byName(r.kind),
        answeredAt: _ms(r.answeredAtMs),
        answers: [
          for (final a in r.answers.split(','))
            if (a.isNotEmpty) int.parse(a),
        ],
        score: r.score,
      );

  @override
  Stream<List<QuestionnaireResult>> watchAll() =>
      _query().watch().map((rows) => rows.map(_fromRow).toList());

  @override
  Future<List<QuestionnaireResult>> all() async =>
      (await _query().get()).map(_fromRow).toList();

  @override
  Future<void> save(QuestionnaireResult r) => _db
      .into(_db.questionnaireResults)
      .insertOnConflictUpdate(
        QuestionnaireResultsCompanion.insert(
          id: r.id,
          kind: r.kind.name,
          answeredAtMs: r.answeredAt.millisecondsSinceEpoch,
          answers: r.answers.join(','),
          score: r.score,
        ),
      );
}
