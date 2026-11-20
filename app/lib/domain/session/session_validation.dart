import 'ice_session.dart';

/// Grenzen für manuell eingetragene/bearbeitete Sessions.
abstract final class SessionLimits {
  static const minDuration = Duration(seconds: 5);

  /// Plausibilitätsgrenze, keine Empfehlung.
  static const maxDuration = Duration(minutes: 60);
}

sealed class SessionProblem {
  const SessionProblem();
}

class DurationTooShort extends SessionProblem {
  const DurationTooShort();
}

class DurationTooLong extends SessionProblem {
  const DurationTooLong();
}

class EndsInFuture extends SessionProblem {
  const EndsInFuture();
}

class OverlapsOther extends SessionProblem {
  const OverlapsOther(this.other);
  final IceSession other;
}

/// Prüft einen Eintrag vor dem Speichern. Leere Liste = alles in Ordnung.
///
/// [others]: alle gespeicherten Sessions (die Session selbst wird ignoriert).
List<SessionProblem> validateSession(
  IceSession candidate,
  Iterable<IceSession> others, {
  required DateTime now,
}) {
  final problems = <SessionProblem>[];
  final d = candidate.duration;
  if (d < SessionLimits.minDuration) problems.add(const DurationTooShort());
  if (d > SessionLimits.maxDuration) problems.add(const DurationTooLong());
  if (candidate.endedAt!.isAfter(now.toUtc())) {
    problems.add(const EndsInFuture());
  }
  for (final o in others) {
    if (o.id == candidate.id || !o.isCompleted) continue;
    if (candidate.overlaps(o)) {
      problems.add(OverlapsOther(o));
      break;
    }
  }
  return problems;
}
