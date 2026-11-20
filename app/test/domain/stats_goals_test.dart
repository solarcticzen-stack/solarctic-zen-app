import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/goals/goal.dart';
import 'package:solarctic_zen/domain/stats/stats_engine.dart';

import 'helpers.dart';

void main() {
  final today = d(2026, 11, 19); // Donnerstag, Woche ab 16.11.

  group('StatsEngine', () {
    test('leere Historie', () {
      final s = StatsEngine.compute([], today: today);
      expect(s.count, 0);
      expect(s.averageDuration, isNull);
      expect(s.averageTempC, isNull);
      expect(s.currentWeekStreak, 0);
    });

    test('Kennzahlen', () {
      final list = [
        session(d(2026, 11, 2), seconds: 60, temp: 10),
        session(d(2026, 11, 10), seconds: 180, temp: 4),
        session(d(2026, 11, 17), seconds: 120),
        session(d(2026, 11, 18), seconds: 240, temp: 6),
      ];
      final s = StatsEngine.compute(list, today: today);
      expect(s.count, 4);
      expect(s.totalDuration, const Duration(minutes: 10));
      expect(s.averageDuration, const Duration(seconds: 150));
      expect(s.longest!.duration, const Duration(seconds: 240));
      expect(s.averageTempC, closeTo(20 / 3, 1e-9));
      expect(s.coldestTempC, 4);
      expect(s.thisWeekCount, 2);
      expect(s.thisMonthCount, 4);
      expect(s.perWeek[d(2026, 11, 16)], 2);
      expect(s.last!.localDate, d(2026, 11, 18));
    });

    test('gelöschte und aktive Sessions werden ignoriert', () {
      final deleted = session(d(2026, 11, 17))
          .copyWith(deletedAt: () => DateTime.utc(2026));
      final s = StatsEngine.compute([
        deleted,
        session(d(2026, 11, 18)),
      ], today: today);
      expect(s.count, 1);
    });

    test('Wochenserie: laufende Woche ohne Bad bricht die Serie nicht', () {
      final list = [
        session(d(2026, 10, 27)),
        session(d(2026, 11, 3)),
        session(d(2026, 11, 10)),
      ];
      // Heute (19.11.) noch kein Bad in dieser Woche → Serie 3 bleibt bestehen.
      expect(StatsEngine.compute(list, today: today).currentWeekStreak, 3);
      // Eine Woche später ohne Bad → Serie ist vorbei.
      expect(
        StatsEngine.compute(list, today: d(2026, 11, 26)).currentWeekStreak,
        0,
      );
      expect(
        StatsEngine.compute(list, today: d(2026, 11, 26)).longestWeekStreak,
        3,
      );
    });

    test('Pausen-Modus überbrückt Wochen, ohne sie mitzuzählen', () {
      final list = [session(d(2026, 10, 27)), session(d(2026, 11, 10))];
      final noPause = StatsEngine.compute(list, today: today);
      expect(noPause.currentWeekStreak, 1);
      final withPause = StatsEngine.compute(
        list,
        today: today,
        pausedWeeks: {d(2026, 11, 2)},
      );
      expect(withPause.currentWeekStreak, 2);
      expect(withPause.longestWeekStreak, 2);
    });
  });

  group('GoalEngine', () {
    final sessions = [
      session(d(2026, 11, 3), seconds: 600),
      session(d(2026, 11, 16), seconds: 120),
      session(d(2026, 11, 19), seconds: 180),
    ];

    test('Sessions pro Woche', () {
      final g = Goal(
        id: 'g',
        type: GoalType.sessionsPerWeek,
        target: 3,
        activeFrom: d(2026, 1, 1),
      );
      final p = GoalEngine.progress(g, sessions, today: today);
      expect(p.current, 2);
      expect(p.fraction, closeTo(2 / 3, 1e-9));
      expect(p.reached, isFalse);
      expect(p.periodStart, d(2026, 11, 16));
      expect(p.periodEnd, d(2026, 11, 22));
    });

    test('Minuten pro Monat', () {
      final g = Goal(
        id: 'g',
        type: GoalType.minutesPerMonth,
        target: 10,
        activeFrom: d(2026, 1, 1),
      );
      final p = GoalEngine.progress(g, sessions, today: today);
      expect(p.current, 15);
      expect(p.reached, isTrue);
      expect(p.fraction, 1);
      expect(p.periodEnd, d(2026, 11, 30));
    });

    test('Dezember-Monatsende', () {
      final g = Goal(
        id: 'g',
        type: GoalType.sessionsPerMonth,
        target: 10,
        activeFrom: d(2026, 1, 1),
      );
      expect(
        GoalEngine.progress(g, [], today: d(2026, 12, 5)).periodEnd,
        d(2026, 12, 31),
      );
    });

    test('Gültigkeitszeitraum', () {
      final g = Goal(
        id: 'g',
        type: GoalType.sessionsPerWeek,
        target: 2,
        activeFrom: d(2026, 1, 1),
        activeUntil: d(2026, 6, 30),
      );
      expect(g.isActiveOn(d(2026, 3, 1)), isTrue);
      expect(g.isActiveOn(d(2026, 7, 1)), isFalse);
    });
  });
}
