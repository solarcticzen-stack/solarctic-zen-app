import 'package:meta/meta.dart';

import '../common/local_date.dart';
import '../session/ice_session.dart';
import 'stats_engine.dart';

/// Daten für Kalender und Diagramme im Verlauf (FEATURES.md C1, C2, C5, C7).

/// Alle Sessions eines Kalendertags.
@immutable
class DayAggregate {
  const DayAggregate(this.day, this.sessions);

  final LocalDate day;

  /// Chronologisch.
  final List<IceSession> sessions;

  int get count => sessions.length;
  Duration get totalDuration =>
      sessions.fold(Duration.zero, (sum, s) => sum + s.duration);
}

/// Abgeschlossene Sessions je Kalendertag.
Map<LocalDate, DayAggregate> dayAggregates(Iterable<IceSession> sessions) {
  final byDay = <LocalDate, List<IceSession>>{};
  for (final s in completedChronological(sessions)) {
    byDay.putIfAbsent(s.localDate, () => []).add(s);
  }
  return {for (final e in byDay.entries) e.key: DayAggregate(e.key, e.value)};
}

/// Tage eines Monatsrasters (Montag bis Sonntag), inklusive der Tage aus dem
/// Vor- und Folgemonat, die die erste und letzte Woche auffüllen.
List<LocalDate> monthGrid(LocalDate anyDayInMonth) {
  final first = anyDayInMonth.monthStart;
  final next = first.month == 12
      ? LocalDate(first.year + 1, 1, 1)
      : LocalDate(first.year, first.month + 1, 1);
  final last = next.addDays(-1);
  final start = first.weekStart;
  final end = last.weekStart.addDays(6);
  return [for (var d = start; !d.isAfter(end); d = d.addDays(1)) d];
}

/// Monat verschieben (z. B. −1 = Vormonat). Liefert den Monatsersten.
LocalDate shiftMonth(LocalDate month, int delta) {
  final index = month.year * 12 + (month.month - 1) + delta;
  return LocalDate(index ~/ 12, index % 12 + 1, 1);
}

/// Sessions je Woche für die letzten [weeks] Wochen bis einschliesslich der
/// Woche von [today] – auch Wochen ohne Bad (Wert 0), älteste zuerst.
List<(LocalDate weekStart, int count)> weeklyCounts(
  Iterable<IceSession> sessions, {
  required LocalDate today,
  int weeks = 12,
}) {
  final counts = <LocalDate, int>{};
  for (final s in completedChronological(sessions)) {
    counts.update(s.localDate.weekStart, (v) => v + 1, ifAbsent: () => 1);
  }
  final current = today.weekStart;
  return [
    for (var i = weeks - 1; i >= 0; i--)
      (current.addDays(-7 * i), counts[current.addDays(-7 * i)] ?? 0),
  ];
}

/// Ein Punkt einer Zeitreihe pro Session.
@immutable
class SeriesPoint {
  const SeriesPoint(this.session, this.value);

  final IceSession session;
  final double value;
}

/// Dauer (in Minuten) der letzten [limit] Sessions, älteste zuerst.
List<SeriesPoint> durationSeries(
  Iterable<IceSession> sessions, {
  int limit = 30,
}) {
  final list = completedChronological(sessions);
  final recent = list.length > limit ? list.sublist(list.length - limit) : list;
  return [for (final s in recent) SeriesPoint(s, s.duration.inSeconds / 60)];
}

/// Wassertemperatur der letzten [limit] Sessions mit erfasster Temperatur.
List<SeriesPoint> temperatureSeries(
  Iterable<IceSession> sessions, {
  int limit = 30,
}) {
  final list = [
    for (final s in completedChronological(sessions))
      if (s.waterTempC != null) s,
  ];
  final recent = list.length > limit ? list.sublist(list.length - limit) : list;
  return [for (final s in recent) SeriesPoint(s, s.waterTempC!)];
}

/// Kennzahlen eines Zeitraums.
@immutable
class PeriodSummary {
  const PeriodSummary({
    required this.from,
    required this.to,
    required this.count,
    required this.averageDuration,
    required this.averageFeeling,
    required this.averageTempC,
  });

  final LocalDate from;
  final LocalDate to;
  final int count;
  final Duration? averageDuration;
  final double? averageFeeling;
  final double? averageTempC;
}

/// «Erste vs. letzte 30 Tage» (FEATURES.md C7).
@immutable
class PeriodComparison {
  const PeriodComparison(this.first, this.recent);

  final PeriodSummary first;
  final PeriodSummary recent;

  /// Erst sinnvoll, wenn sich die Zeiträume nicht überschneiden.
  static const minHistoryDays = 60;

  /// `null`, solange die Historie kürzer als [minHistoryDays] ist.
  static PeriodComparison? compute(
    Iterable<IceSession> sessions, {
    required LocalDate today,
    int days = 30,
  }) {
    final list = completedChronological(sessions);
    if (list.isEmpty) return null;
    final start = list.first.localDate;
    if (today.daysSince(start) + 1 < minHistoryDays) return null;
    return PeriodComparison(
      _summary(list, start, start.addDays(days - 1)),
      _summary(list, today.addDays(-(days - 1)), today),
    );
  }

  static PeriodSummary _summary(
    List<IceSession> all,
    LocalDate from,
    LocalDate to,
  ) {
    final s = [
      for (final x in all)
        if (!x.localDate.isBefore(from) && !x.localDate.isAfter(to)) x,
    ];
    double? avg(Iterable<num> v) =>
        v.isEmpty ? null : v.reduce((a, b) => a + b) / v.length;
    final secs = avg(s.map((x) => x.duration.inSeconds));
    return PeriodSummary(
      from: from,
      to: to,
      count: s.length,
      averageDuration: secs == null ? null : Duration(seconds: secs.round()),
      averageFeeling: avg([
        for (final x in s)
          if (x.feelingAfter != null) x.feelingAfter!,
      ]),
      averageTempC: avg([
        for (final x in s)
          if (x.waterTempC != null) x.waterTempC!,
      ]),
    );
  }
}
