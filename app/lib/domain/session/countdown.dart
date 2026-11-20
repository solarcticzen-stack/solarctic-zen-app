import 'package:meta/meta.dart';

/// Vorlaufzeit vor dem Timerstart (FEATURES.md A19).
///
/// Wie die SessionClock zeitstempel-basiert: läuft korrekt weiter, auch wenn
/// der Bildschirm gesperrt ist. Die Badezeit beginnt exakt bei [endsAt].
@immutable
class Countdown {
  Countdown({required DateTime startedAt, required this.length})
    : endsAt = startedAt.toUtc().add(length);

  /// Erlaubte Vorlaufzeiten in Sekunden (0 = aus).
  static const options = [0, 5, 10, 15, 30];
  static const defaultSeconds = 10;

  final Duration length;
  final DateTime endsAt;

  Duration remaining(DateTime now) {
    final r = endsAt.difference(now.toUtc());
    return r.isNegative ? Duration.zero : r;
  }

  bool isDone(DateTime now) => remaining(now) == Duration.zero;

  /// Angezeigte Sekunden (aufgerundet: 9,2 s → «10»).
  int secondsLeft(DateTime now) {
    final ms = remaining(now).inMilliseconds;
    return (ms + 999) ~/ 1000;
  }
}
