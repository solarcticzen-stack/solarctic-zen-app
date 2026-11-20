import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/session/ice_session.dart';
import 'package:solarctic_zen/domain/session/session_validation.dart';

import 'helpers.dart';

void main() {
  final now = DateTime.utc(2026, 11, 19, 12);

  group('Bearbeiten (rescheduled)', () {
    test('neue Dauer und Startzeit, Kalendertag wird neu bestimmt', () {
      final s = session(d(2026, 11, 18), seconds: 120, temp: 5, feeling: 4);
      final edited = s.rescheduled(
        startedAt: DateTime.utc(2026, 11, 16, 22, 30), // 23:30 Lokalzeit
        duration: const Duration(minutes: 3),
        utcOffsetMinutes: 60,
        now: now,
      );
      expect(edited.duration, const Duration(minutes: 3));
      expect(edited.localDate, d(2026, 11, 16));
      expect(edited.id, s.id);
      expect(edited.waterTempC, 5, reason: 'übrige Angaben bleiben');
      expect(edited.feelingAfter, 4);
      expect(edited.createdAt, s.createdAt);
      expect(edited.updatedAt, now);
    });

    test('unveränderte Zeiten behalten die Pausen einer Timer-Session', () {
      final t0 = DateTime.utc(2026, 11, 18, 7);
      var s = IceSession.startNow(id: 'x', now: t0, utcOffsetMinutes: 60);
      s = s.withClock(
        s.clock
            .pause(t0.add(const Duration(seconds: 30)))
            .resume(t0.add(const Duration(seconds: 50)))
            .end(t0.add(const Duration(seconds: 150))),
        t0,
      );
      expect(s.duration, const Duration(seconds: 130));
      final same = s.rescheduled(
        startedAt: s.startedAt,
        duration: s.duration,
        utcOffsetMinutes: 60,
        now: now,
      );
      expect(same.clock.pauses, hasLength(1));
      final changed = s.rescheduled(
        startedAt: s.startedAt,
        duration: const Duration(minutes: 2),
        utcOffsetMinutes: 60,
        now: now,
      );
      expect(changed.clock.pauses, isEmpty);
      expect(changed.duration, const Duration(minutes: 2));
    });

    test('ungültige Eingaben', () {
      final s = session(d(2026, 11, 18));
      expect(
        () => s.rescheduled(
          startedAt: s.startedAt,
          duration: Duration.zero,
          utcOffsetMinutes: 60,
          now: now,
        ),
        throwsArgumentError,
      );
      final active = IceSession.startNow(
        id: 'a',
        now: now,
        utcOffsetMinutes: 60,
      );
      expect(
        () => active.rescheduled(
          startedAt: now,
          duration: const Duration(minutes: 1),
          utcOffsetMinutes: 60,
          now: now,
        ),
        throwsStateError,
      );
    });
  });

  group('Prüfung vor dem Speichern', () {
    IceSession at(int hour, int minute, int seconds, {String id = 'new'}) =>
        IceSession.manual(
          id: id,
          startedAt: DateTime.utc(2026, 11, 18, hour, minute),
          duration: Duration(seconds: seconds),
          utcOffsetMinutes: 60,
          now: now,
        );

    test('gültiger Eintrag', () {
      expect(
        validateSession(at(7, 0, 120), [at(8, 0, 120, id: 'o')], now: now),
        isEmpty,
      );
    });

    test('Überschneidung mit anderem Eisbad wird erkannt', () {
      final other = at(7, 1, 120, id: 'o');
      final problems = validateSession(at(7, 0, 120), [other], now: now);
      expect(
        problems.single,
        isA<OverlapsOther>().having((p) => p.other.id, 'other', 'o'),
      );
    });

    test('direkt aneinander anschliessend ist keine Überschneidung', () {
      expect(
        validateSession(at(7, 2, 60), [at(7, 0, 120, id: 'o')], now: now),
        isEmpty,
      );
    });

    test('die Session selbst und gelöschte zählen nicht', () {
      final self = at(7, 0, 120);
      final deleted = at(7, 0, 120, id: 'd').copyWith(deletedAt: () => now);
      expect(validateSession(self, [self, deleted], now: now), isEmpty);
    });

    test('Zukunft, zu kurz, zu lang', () {
      final future = IceSession.manual(
        id: 'f',
        startedAt: now.subtract(const Duration(seconds: 30)),
        duration: const Duration(minutes: 2),
        utcOffsetMinutes: 60,
        now: now,
      );
      expect(validateSession(future, [], now: now).single, isA<EndsInFuture>());
      expect(
        validateSession(at(7, 0, 3), [], now: now).single,
        isA<DurationTooShort>(),
      );
      expect(
        validateSession(at(7, 0, 3601), [], now: now).single,
        isA<DurationTooLong>(),
      );
    });
  });
}
