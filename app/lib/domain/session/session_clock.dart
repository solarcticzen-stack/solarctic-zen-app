// SessionClock – zuverlässige Zeitmessung einer Eisbad-Session.
//
// Grundsatz (ADR-004): Es wird nie «hochgezählt». Die Dauer wird immer aus
// gespeicherten Zeitpunkten berechnet:
//   dauer = jetzt − start − Σ pausen
// Dadurch läuft die Zeit korrekt weiter, auch wenn die App im Hintergrund
// pausiert, der Bildschirm gesperrt ist oder die App neu gestartet wird.
//
// Alle Zeitpunkte sind UTC-Instants (ADR-005). Sommerzeit und Zeitzonen
// beeinflussen die Dauer daher nicht.

import 'package:meta/meta.dart';

/// Liefert die aktuelle Zeit. In Tests durch eine feste Uhr ersetzbar.
typedef Now = DateTime Function();

/// Standard-Uhr der App.
DateTime utcNow() => DateTime.now().toUtc();

/// Eine Pause innerhalb einer Session. [end] ist `null`, solange sie läuft.
@immutable
class PauseInterval {
  const PauseInterval(this.start, [this.end]);

  final DateTime start;
  final DateTime? end;

  bool get isOpen => end == null;

  /// Pausendauer bis [now] (bzw. bis [end], falls abgeschlossen).
  Duration durationUntil(DateTime now) {
    final stop = end ?? now;
    final d = stop.difference(start);
    return d.isNegative ? Duration.zero : d;
  }

  @override
  bool operator ==(Object other) =>
      other is PauseInterval && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

enum SessionClockState { running, paused, ended }

/// Unveränderlicher Zustand der Uhr einer Session.
///
/// Jede Aktion ([pause], [resume], [end]) liefert eine neue Instanz zurück,
/// die direkt gespeichert werden kann (Absturzsicherheit).
@immutable
class SessionClock {
  SessionClock({
    required DateTime startedAt,
    List<PauseInterval> pauses = const [],
    DateTime? endedAt,
  }) : startedAt = startedAt.toUtc(),
       endedAt = endedAt?.toUtc(),
       pauses = List.unmodifiable(pauses) {
    if (this.endedAt != null && this.endedAt!.isBefore(this.startedAt)) {
      throw ArgumentError.value(endedAt, 'endedAt', 'liegt vor dem Start');
    }
  }

  /// Startet eine neue Session zum Zeitpunkt [now].
  factory SessionClock.start(DateTime now) => SessionClock(startedAt: now);

  final DateTime startedAt;
  final List<PauseInterval> pauses;
  final DateTime? endedAt;

  SessionClockState get state {
    if (endedAt != null) return SessionClockState.ended;
    if (pauses.isNotEmpty && pauses.last.isOpen) {
      return SessionClockState.paused;
    }
    return SessionClockState.running;
  }

  bool get isRunning => state == SessionClockState.running;
  bool get isPaused => state == SessionClockState.paused;
  bool get isEnded => state == SessionClockState.ended;

  /// Summe aller Pausen bis [now].
  Duration pausedUntil(DateTime now) {
    final ref = _referenceTime(now);
    return pauses.fold(Duration.zero, (sum, p) => sum + p.durationUntil(ref));
  }

  /// Netto-Zeit im Wasser bis [now] (ohne Pausen). Nie negativ.
  ///
  /// Ist die Session beendet, bleibt der Wert eingefroren. Wird die Systemuhr
  /// zurückgestellt (now < Start), wird 0 statt eines negativen Werts geliefert.
  Duration elapsed(DateTime now) {
    final ref = _referenceTime(now);
    final gross = ref.difference(startedAt);
    final net = gross - pausedUntil(now);
    return net.isNegative ? Duration.zero : net;
  }

  SessionClock pause(DateTime now) {
    _requireState(SessionClockState.running, 'pausieren');
    return _copy(pauses: [...pauses, PauseInterval(_notBeforeStart(now))]);
  }

  SessionClock resume(DateTime now) {
    _requireState(SessionClockState.paused, 'fortsetzen');
    final open = pauses.last;
    final end = now.toUtc().isBefore(open.start) ? open.start : now.toUtc();
    return _copy(
      pauses: [
        ...pauses.sublist(0, pauses.length - 1),
        PauseInterval(open.start, end),
      ],
    );
  }

  /// Beendet die Session. Eine laufende Pause wird zum Endzeitpunkt geschlossen.
  SessionClock end(DateTime now) {
    if (isEnded) {
      throw StateError('Session ist bereits beendet');
    }
    final at = _notBeforeStart(now);
    final closed = [
      for (final p in pauses)
        p.isOpen
            ? PauseInterval(p.start, at.isBefore(p.start) ? p.start : at)
            : p,
    ];
    return SessionClock(startedAt: startedAt, pauses: closed, endedAt: at);
  }

  DateTime _referenceTime(DateTime now) {
    if (endedAt != null) return endedAt!;
    final n = now.toUtc();
    return n.isBefore(startedAt) ? startedAt : n;
  }

  DateTime _notBeforeStart(DateTime now) {
    final n = now.toUtc();
    return n.isBefore(startedAt) ? startedAt : n;
  }

  void _requireState(SessionClockState expected, String action) {
    if (state != expected) {
      throw StateError('Kann nicht $action im Zustand ${state.name}');
    }
  }

  SessionClock _copy({List<PauseInterval>? pauses}) => SessionClock(
    startedAt: startedAt,
    pauses: pauses ?? this.pauses,
    endedAt: endedAt,
  );
}
