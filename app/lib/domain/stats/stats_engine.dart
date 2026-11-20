import 'package:meta/meta.dart';

import '../common/local_date.dart';
import '../session/ice_session.dart';

/// Kennzahlen über alle abgeschlossenen Sessions (FEATURES.md C4/C6).
@immutable
class SessionStats {
  const SessionStats({
    required this.count,
    required this.totalDuration,
    required this.averageDuration,
    required this.longest,
    required this.averageTempC,
    required this.coldestTempC,
    required this.thisWeekCount,
    required this.thisMonthCount,
    required this.perWeek,
    required this.perMonth,
    required this.currentWeekStreak,
    required this.longestWeekStreak,
    required this.last,
  });

  final int count;
  final Duration totalDuration;
  final Duration? averageDuration;
  final IceSession? longest;

  /// Nur über Sessions mit erfasster Temperatur.
  final double? averageTempC;
  final double? coldestTempC;

  final int thisWeekCount;
  final int thisMonthCount;

  /// Anzahl Sessions je Woche (Schlüssel: Montag der ISO-Woche).
  final Map<LocalDate, int> perWeek;

  /// Anzahl Sessions je Monat (Schlüssel: Monatserster).
  final Map<LocalDate, int> perMonth;

  /// Aktive Wochen in Folge bis heute. Die laufende Woche zählt mit, sobald
  /// gebadet wurde; ohne Bad in der laufenden Woche bleibt die Serie bis
  /// Sonntag bestehen (kein Druck mitten in der Woche).
  final int currentWeekStreak;
  final int longestWeekStreak;

  final IceSession? last;

  static const empty = SessionStats(
    count: 0,
    totalDuration: Duration.zero,
    averageDuration: null,
    longest: null,
    averageTempC: null,
    coldestTempC: null,
    thisWeekCount: 0,
    thisMonthCount: 0,
    perWeek: {},
    perMonth: {},
    currentWeekStreak: 0,
    longestWeekStreak: 0,
    last: null,
  );
}

/// Liefert abgeschlossene, nicht gelöschte Sessions chronologisch sortiert.
List<IceSession> completedChronological(Iterable<IceSession> sessions) =>
    sessions.where((s) => s.isCompleted).toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

/// Aktive Wochen (Montage) aus einer Menge von Sessions.
Set<LocalDate> activeWeeks(Iterable<IceSession> sessions) => {
  for (final s in sessions) s.localDate.weekStart,
};

/// Längste Folge aufeinanderfolgender Wochen in [weeks].
/// [pausedWeeks] überbrücken eine Lücke, zählen aber selbst nicht mit.
int longestRun(Set<LocalDate> weeks, {Set<LocalDate> pausedWeeks = const {}}) {
  if (weeks.isEmpty) return 0;
  final sorted = weeks.toList()..sort();
  var best = 1, run = 1;
  for (var i = 1; i < sorted.length; i++) {
    if (_connected(sorted[i - 1], sorted[i], pausedWeeks)) {
      run++;
    } else {
      run = 1;
    }
    if (run > best) best = run;
  }
  return best;
}

bool _connected(LocalDate prev, LocalDate next, Set<LocalDate> paused) {
  var w = prev.addDays(7);
  while (w.isBefore(next)) {
    if (!paused.contains(w)) return false;
    w = w.addDays(7);
  }
  return w == next;
}

/// Serie aktiver Wochen, die bis zur Woche von [today] reicht.
int currentRun(
  Set<LocalDate> weeks,
  LocalDate today, {
  Set<LocalDate> pausedWeeks = const {},
}) {
  if (weeks.isEmpty) return 0;
  final earliest = weeks.reduce((a, b) => a.isBefore(b) ? a : b);
  var week = today.weekStart;
  // Laufende Woche ohne Bad: Serie zählt ab der Vorwoche weiter.
  if (!weeks.contains(week)) week = week.addDays(-7);
  var run = 0;
  while (!week.isBefore(earliest)) {
    if (weeks.contains(week)) {
      run++;
    } else if (!pausedWeeks.contains(week)) {
      break; // Lücke ohne Pausen-Modus beendet die Serie.
    }
    week = week.addDays(-7);
  }
  return run;
}

abstract final class StatsEngine {
  static SessionStats compute(
    Iterable<IceSession> sessions, {
    required LocalDate today,
    Set<LocalDate> pausedWeeks = const {},
  }) {
    final list = completedChronological(sessions);
    if (list.isEmpty) return SessionStats.empty;

    var total = Duration.zero;
    IceSession? longest;
    final temps = <double>[];
    final perWeek = <LocalDate, int>{};
    final perMonth = <LocalDate, int>{};

    for (final s in list) {
      final d = s.duration;
      total += d;
      if (longest == null || d > longest.duration) longest = s;
      if (s.waterTempC != null) temps.add(s.waterTempC!);
      perWeek.update(s.localDate.weekStart, (v) => v + 1, ifAbsent: () => 1);
      perMonth.update(s.localDate.monthStart, (v) => v + 1, ifAbsent: () => 1);
    }

    final weeks = perWeek.keys.toSet();
    return SessionStats(
      count: list.length,
      totalDuration: total,
      averageDuration: Duration(
        microseconds: total.inMicroseconds ~/ list.length,
      ),
      longest: longest,
      averageTempC: temps.isEmpty
          ? null
          : temps.reduce((a, b) => a + b) / temps.length,
      coldestTempC: temps.isEmpty
          ? null
          : temps.reduce((a, b) => a < b ? a : b),
      thisWeekCount: perWeek[today.weekStart] ?? 0,
      thisMonthCount: perMonth[today.monthStart] ?? 0,
      perWeek: Map.unmodifiable(perWeek),
      perMonth: Map.unmodifiable(perMonth),
      currentWeekStreak: currentRun(weeks, today, pausedWeeks: pausedWeeks),
      longestWeekStreak: longestRun(weeks, pausedWeeks: pausedWeeks),
      last: list.last,
    );
  }
}
