import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/data/db/app_database.dart';
import 'package:solarctic_zen/data/db/drift_repository.dart';
import 'package:solarctic_zen/data/memory_repository.dart';
import 'package:solarctic_zen/domain/session/ice_session.dart';
import 'package:solarctic_zen/domain/session/session_repository.dart';

import '../domain/helpers.dart';

/// Derselbe Vertrag für jede Implementierung des SessionRepository.
void contract(
  String name,
  Future<(SessionRepository, SettingsStore, Future<void> Function())> Function()
  create,
) {
  group('SessionRepository-Vertrag: $name', () {
    late SessionRepository repo;
    late SettingsStore settings;
    late Future<void> Function() close;

    setUp(() async => (repo, settings, close) = await create());
    tearDown(() => close());

    final t0 = DateTime.utc(2026, 11, 19, 7, 0, 0, 123);
    DateTime at(int s) => t0.add(Duration(seconds: s));

    test('aktive Session mit Pausen speichern und wieder laden (Absturzsicherheit)', () async {
      var s = IceSession.startNow(
        id: 'a',
        now: t0,
        utcOffsetMinutes: 60,
        tzName: 'CET',
        waterTempC: 4.5,
      );
      await repo.save(s);
      s = s.withClock(s.clock.pause(at(30)), at(30));
      await repo.save(s);

      final loaded = await repo.findActive();
      expect(loaded, isNotNull);
      expect(loaded!.id, 'a');
      expect(loaded.startedAt, t0, reason: 'Millisekunden bleiben erhalten');
      expect(loaded.clock.isPaused, isTrue);
      expect(loaded.durationAt(at(100)), const Duration(seconds: 30));
      expect(loaded.waterTempC, 4.5);
      expect(loaded.tzName, 'CET');
      expect(loaded.localDate, d(2026, 11, 19));
    });

    test('Beenden: keine aktive Session mehr, Dauer korrekt', () async {
      var s = IceSession.startNow(id: 'b', now: t0, utcOffsetMinutes: 60);
      await repo.save(s);
      s = s.withClock(s.clock.pause(at(10)).resume(at(20)).end(at(70)), at(70));
      await repo.save(
        s.copyWith(
          feelingAfter: () => 4,
          notes: () => 'ruhig',
          updatedAt: at(70),
        ),
      );

      expect(await repo.findActive(), isNull);
      final all = await repo.all();
      expect(all.single.status, SessionStatus.completed);
      expect(all.single.duration, const Duration(seconds: 60));
      expect(all.single.clock.pauses.single.end, at(20));
      expect(all.single.feelingAfter, 4);
      expect(all.single.notes, 'ruhig');
    });

    test('höchstens eine aktive Session', () async {
      await repo.save(
        IceSession.startNow(id: 'x', now: t0, utcOffsetMinutes: 0),
      );
      await expectLater(
        repo.save(
          IceSession.startNow(id: 'y', now: at(5), utcOffsetMinutes: 0),
        ),
        throwsA(anything),
      );
    });

    test('Liste ist nach Startzeit absteigend sortiert', () async {
      await repo.save(session(d(2026, 11, 1)));
      await repo.save(session(d(2026, 11, 3)));
      await repo.save(session(d(2026, 11, 2)));
      final days = (await repo.all()).map((s) => s.localDate.day).toList();
      expect(days, [3, 2, 1]);
    });

    test('Löschen ist weich (Tombstone) und wird gemeldet', () async {
      final s = session(d(2026, 11, 1));
      await repo.save(s);
      final updates = repo.watchAll().take(2).toList();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repo.delete(s.id, at(1));
      final emitted = await updates;
      expect(emitted.first.single.deletedAt, isNull);
      expect(emitted.last.single.deletedAt, isNotNull);
      expect(emitted.last.single.isCompleted, isFalse);
    });

    test('Einstellungen', () async {
      expect(await settings.get('countdown_s'), isNull);
      await settings.set('countdown_s', '10');
      expect(await settings.get('countdown_s'), '10');
      await settings.set('countdown_s', '15');
      expect(await settings.get('countdown_s'), '15');
    });
  });
}

void main() {
  contract('In-Memory', () async {
    final r = InMemorySessionRepository();
    return (
      r as SessionRepository,
      InMemorySettingsStore() as SettingsStore,
      r.dispose,
    );
  });

  contract('SQLite (drift)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    return (
      DriftSessionRepository(db) as SessionRepository,
      DriftSettingsStore(db) as SettingsStore,
      db.close,
    );
  });
}
