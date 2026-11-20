import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/common/ids.dart';
import 'package:solarctic_zen/domain/common/local_date.dart';
import 'package:solarctic_zen/domain/session/ice_session.dart';

import 'helpers.dart';

void main() {
  group('LocalDate', () {
    test('Wochenbeginn ist Montag (ISO)', () {
      expect(d(2026, 11, 19).weekday, 4); // Donnerstag
      expect(d(2026, 11, 19).weekStart, d(2026, 11, 16));
      expect(d(2026, 11, 16).weekStart, d(2026, 11, 16));
      expect(d(2026, 11, 22).weekStart, d(2026, 11, 16)); // Sonntag
    });

    test('Woche über den Jahreswechsel', () {
      expect(d(2027, 1, 1).weekStart, d(2026, 12, 28));
    });

    test('Kalendertag aus UTC-Zeitpunkt und Offset', () {
      // 23:30 UTC am 19.11. = 00:30 am 20.11. in Zürich (UTC+1).
      final instant = DateTime.utc(2026, 11, 19, 23, 30);
      expect(LocalDate.fromInstant(instant, 60), d(2026, 11, 20));
      expect(LocalDate.fromInstant(instant, 0), d(2026, 11, 19));
      expect(LocalDate.fromInstant(instant, -300), d(2026, 11, 19)); // New York
    });

    test('Parsen, Formatieren, Vergleichen', () {
      expect(LocalDate.parse('2026-03-05'), d(2026, 3, 5));
      expect(d(2026, 3, 5).toString(), '2026-03-05');
      expect(d(2026, 3, 5).isBefore(d(2026, 3, 6)), isTrue);
      expect(d(2026, 3, 1).daysSince(d(2026, 2, 1)), 28);
      expect(() => LocalDate(2026, 2, 30), throwsArgumentError);
    });
  });

  group('IDs', () {
    test('UUIDv7-Format, eindeutig, zeitlich sortierbar', () {
      final a = newId(now: DateTime.utc(2026, 1, 1));
      final b = newId(now: DateTime.utc(2026, 1, 2));
      final re = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(re.hasMatch(a), isTrue, reason: a);
      expect(a.compareTo(b), lessThan(0));
      expect({for (var i = 0; i < 1000; i++) newId()}.length, 1000);
    });
  });

  group('IceSession', () {
    test('Session nach Mitternacht gehört zum Starttag in Lokalzeit', () {
      final s = IceSession.startNow(
        id: 'x',
        now: DateTime.utc(2026, 11, 19, 22, 50), // 23:50 in Zürich
        utcOffsetMinutes: 60,
      );
      expect(s.localDate, d(2026, 11, 19));
    });

    test('manuelle Session: Dauer und Validierung', () {
      final s = session(d(2026, 11, 19), seconds: 150);
      expect(s.duration, const Duration(seconds: 150));
      expect(s.isCompleted, isTrue);
      expect(
        () => IceSession.manual(
          id: 'y',
          startedAt: DateTime.utc(2026),
          duration: Duration.zero,
          utcOffsetMinutes: 0,
          now: DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
    });

    test('Empfinden nur 1–5', () {
      final s = session(d(2026, 11, 19));
      expect(s.copyWith(feelingAfter: () => 5).feelingAfter, 5);
      expect(() => s.copyWith(feelingAfter: () => 6), throwsRangeError);
    });

    test('Werte können wieder entfernt werden', () {
      final s = session(d(2026, 11, 19), temp: 4);
      expect(s.copyWith(waterTempC: () => null).waterTempC, isNull);
    });

    test('gelöschte Sessions zählen nicht als abgeschlossen', () {
      final s = session(d(2026, 11, 19))
          .copyWith(deletedAt: () => DateTime.utc(2026));
      expect(s.isCompleted, isFalse);
    });
  });
}
