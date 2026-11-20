import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/stats/history.dart';

import 'helpers.dart';

void main() {
  final today = d(2026, 11, 19); // Donnerstag

  group('Monatsraster', () {
    test('November 2026: beginnt Montag 26.10., endet Sonntag 6.12.', () {
      final grid = monthGrid(d(2026, 11, 19));
      expect(grid.first, d(2026, 10, 26));
      expect(grid.last, d(2026, 12, 6));
      expect(grid.length % 7, 0);
      expect(grid.first.weekday, 1);
      expect(grid.last.weekday, 7);
    });

    test('Februar 2027 (beginnt Montag, 28 Tage) braucht genau 4 Wochen', () {
      final grid = monthGrid(d(2027, 2, 10));
      expect(grid.length, 28);
      expect(grid.first, d(2027, 2, 1));
    });

    test('Monate verschieben über den Jahreswechsel', () {
      expect(shiftMonth(d(2026, 12, 15), 1), d(2027, 1, 1));
      expect(shiftMonth(d(2026, 1, 31), -1), d(2025, 12, 1));
      expect(shiftMonth(d(2026, 11, 1), -12), d(2025, 11, 1));
    });
  });

  test('Tageswerte: mehrere Sessions an einem Tag, gelöschte ignoriert', () {
    final deleted = session(d(2026, 11, 18))
        .copyWith(deletedAt: () => DateTime.utc(2026));
    final agg = dayAggregates([
      session(d(2026, 11, 17), seconds: 60),
      session(d(2026, 11, 17), seconds: 90),
      session(d(2026, 11, 19), seconds: 120),
      deleted,
    ]);
    expect(agg.keys, containsAll([d(2026, 11, 17), d(2026, 11, 19)]));
    expect(agg.containsKey(d(2026, 11, 18)), isFalse);
    expect(agg[d(2026, 11, 17)]!.count, 2);
    expect(agg[d(2026, 11, 17)]!.totalDuration, const Duration(seconds: 150));
  });

  test('Wochenwerte: lückenlos inkl. Wochen ohne Bad, älteste zuerst', () {
    final w = weeklyCounts(
      [
        session(d(2026, 11, 17)),
        session(d(2026, 11, 18)),
        session(d(2026, 11, 3)),
      ],
      today: today,
      weeks: 4,
    );
    expect(w.map((e) => e.$1).toList(), [
      d(2026, 10, 26),
      d(2026, 11, 2),
      d(2026, 11, 9),
      d(2026, 11, 16),
    ]);
    expect(w.map((e) => e.$2).toList(), [0, 1, 0, 2]);
  });

  test(
    'Zeitreihen: Dauer in Minuten, Temperatur nur mit Messwert, begrenzt',
    () {
      final list = [
        for (var i = 1; i <= 40; i++)
          session(
            d(2026, 10, 1).addDays(i),
            seconds: 60 + i,
            temp: i.isEven ? 8 : null,
          ),
      ];
      final dur = durationSeries(list);
      expect(dur.length, 30);
      expect(dur.last.value, closeTo(100 / 60, 1e-9));
      expect(
        dur.first.session.localDate.isBefore(dur.last.session.localDate),
        isTrue,
      );
      final temp = temperatureSeries(list);
      expect(temp.length, 20);
      expect(temp.every((p) => p.value == 8), isTrue);
    },
  );

  group('Erste vs. letzte 30 Tage', () {
    test('erst ab 60 Tagen Verlauf', () {
      expect(
        PeriodComparison.compute([session(d(2026, 10, 1))], today: today),
        isNull,
      );
      expect(PeriodComparison.compute([], today: today), isNull);
    });

    test('Kennzahlen beider Zeiträume', () {
      final c = PeriodComparison.compute([
        session(d(2026, 8, 1), seconds: 60, feeling: 2, temp: 14),
        session(d(2026, 8, 10), seconds: 120, feeling: 3),
        session(d(2026, 11, 1), seconds: 180, feeling: 4, temp: 6),
        session(d(2026, 11, 15), seconds: 240, feeling: 5, temp: 4),
      ], today: today)!;
      expect(c.first.from, d(2026, 8, 1));
      expect(c.first.count, 2);
      expect(c.first.averageDuration, const Duration(seconds: 90));
      expect(c.first.averageFeeling, 2.5);
      expect(c.first.averageTempC, 14);
      expect(c.recent.to, today);
      expect(c.recent.count, 2);
      expect(c.recent.averageDuration, const Duration(seconds: 210));
      expect(c.recent.averageTempC, 5);
    });
  });
}
