import 'package:meta/meta.dart';

import '../common/local_date.dart';
import '../session/ice_session.dart';
import '../stats/stats_engine.dart';

enum GoalType { sessionsPerWeek, sessionsPerMonth, minutesPerMonth }

/// Persönliches Ziel (FEATURES.md D5). Ziele werden nicht überschrieben,
/// sondern abgelöst ([activeUntil]), damit die Historie korrekt bleibt.
@immutable
class Goal {
  const Goal({
    required this.id,
    required this.type,
    required this.target,
    required this.activeFrom,
    this.activeUntil,
  });

  final String id;
  final GoalType type;
  final num target;
  final LocalDate activeFrom;
  final LocalDate? activeUntil;

  bool isActiveOn(LocalDate day) =>
      !day.isBefore(activeFrom) &&
      (activeUntil == null || !day.isAfter(activeUntil!));
}

@immutable
class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.current,
    required this.periodStart,
    required this.periodEnd,
  });

  final Goal goal;
  final num current;

  /// Erster und letzter Tag des betrachteten Zeitraums (Woche oder Monat).
  final LocalDate periodStart;
  final LocalDate periodEnd;

  double get fraction =>
      goal.target <= 0 ? 1 : (current / goal.target).clamp(0, 1).toDouble();
  bool get reached => current >= goal.target;
}

abstract final class GoalEngine {
  /// Fortschritt von [goal] im Zeitraum, der [today] enthält.
  static GoalProgress progress(
    Goal goal,
    Iterable<IceSession> sessions, {
    required LocalDate today,
  }) {
    final (start, end) = switch (goal.type) {
      GoalType.sessionsPerWeek => (today.weekStart, today.weekStart.addDays(6)),
      GoalType.sessionsPerMonth ||
      GoalType.minutesPerMonth => (today.monthStart, _monthEnd(today)),
    };
    final inPeriod = completedChronological(
      sessions,
    ).where((s) => !s.localDate.isBefore(start) && !s.localDate.isAfter(end));
    final num current = switch (goal.type) {
      GoalType.sessionsPerWeek || GoalType.sessionsPerMonth => inPeriod.length,
      GoalType.minutesPerMonth =>
        inPeriod.fold<int>(0, (sum, s) => sum + s.duration.inSeconds) / 60,
    };
    return GoalProgress(
      goal: goal,
      current: current,
      periodStart: start,
      periodEnd: end,
    );
  }

  static LocalDate _monthEnd(LocalDate d) {
    final next = d.month == 12
        ? LocalDate(d.year + 1, 1, 1)
        : LocalDate(d.year, d.month + 1, 1);
    return next.addDays(-1);
  }
}
