import 'package:meta/meta.dart';

import '../common/local_date.dart';
import 'session_clock.dart';

enum SessionStatus { active, completed, discarded }

enum EntryMode { timer, manual, watch, imported }

/// Eine Eisbad-Session (siehe docs/DATABASE_SCHEMA.md, Tabelle `ice_session`).
///
/// Nicht verfügbare Messwerte sind `null`, nie 0.
@immutable
class IceSession {
  const IceSession({
    required this.id,
    required this.status,
    required this.entryMode,
    required this.clock,
    required this.utcOffsetMinutes,
    required this.localDate,
    required this.createdAt,
    required this.updatedAt,
    this.tzName,
    this.waterTempC,
    this.feelingBefore,
    this.feelingAfter,
    this.overcomeRating,
    this.duringRating,
    this.notes,
    this.countdownSeconds,
    this.warmupExerciseId,
    this.warmupDone,
    this.deletedAt,
  });

  /// Neue Session mit laufendem Timer.
  factory IceSession.startNow({
    required String id,
    required DateTime now,
    required int utcOffsetMinutes,
    String? tzName,
    double? waterTempC,
    int? countdownSeconds,
  }) {
    final clock = SessionClock.start(now);
    return IceSession(
      id: id,
      status: SessionStatus.active,
      entryMode: EntryMode.timer,
      clock: clock,
      utcOffsetMinutes: utcOffsetMinutes,
      tzName: tzName,
      localDate: LocalDate.fromInstant(clock.startedAt, utcOffsetMinutes),
      waterTempC: waterTempC,
      countdownSeconds: countdownSeconds,
      createdAt: clock.startedAt,
      updatedAt: clock.startedAt,
    );
  }

  /// Nachträglich manuell eingetragene Session.
  factory IceSession.manual({
    required String id,
    required DateTime startedAt,
    required Duration duration,
    required int utcOffsetMinutes,
    required DateTime now,
    String? tzName,
    double? waterTempC,
    int? feelingAfter,
    String? notes,
  }) {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'muss positiv sein');
    }
    final start = startedAt.toUtc();
    return IceSession(
      id: id,
      status: SessionStatus.completed,
      entryMode: EntryMode.manual,
      clock: SessionClock(startedAt: start, endedAt: start.add(duration)),
      utcOffsetMinutes: utcOffsetMinutes,
      tzName: tzName,
      localDate: LocalDate.fromInstant(start, utcOffsetMinutes),
      waterTempC: waterTempC,
      feelingAfter: feelingAfter,
      notes: notes,
      createdAt: now.toUtc(),
      updatedAt: now.toUtc(),
    );
  }

  final String id;
  final SessionStatus status;
  final EntryMode entryMode;

  /// Start, Pausen, Ende – Quelle der Dauer.
  final SessionClock clock;

  /// Abweichung der Lokalzeit von UTC beim Start (z. B. +60 im Winter in Zürich).
  final int utcOffsetMinutes;

  /// Zeitzonen-Bezeichnung des Geräts beim Start (Information, z. B. «CET»).
  final String? tzName;

  /// Kalendertag des Starts in der damaligen Lokalzeit.
  final LocalDate localDate;

  final double? waterTempC;

  /// Subjektives Empfinden 1–5.
  final int? feelingBefore;
  final int? feelingAfter;

  /// Überwindung vor dem Einstieg 1–5 (1 = sehr schwer, 5 = ganz leicht), N-005.
  final int? overcomeRating;

  /// Erleben im Wasser 1–5 (1 = sehr hart, 5 = sehr gut), N-005.
  final int? duringRating;
  final String? notes;

  /// Verwendete Vorlaufzeit (A19); zählt nicht zur Badezeit.
  final int? countdownSeconds;

  /// Vorgeschlagene Aufwärm-Übung (A20); `null` = kein Impuls angezeigt.
  final String? warmupExerciseId;

  /// `true` erledigt, `false` übersprungen, `null` nicht angeboten.
  final bool? warmupDone;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DateTime get startedAt => clock.startedAt;
  DateTime? get endedAt => clock.endedAt;

  /// Netto-Badezeit. Für abgeschlossene Sessions fix, für aktive bis jetzt.
  Duration durationAt(DateTime now) => clock.elapsed(now);

  /// Netto-Badezeit einer abgeschlossenen Session.
  Duration get duration {
    final end = clock.endedAt;
    if (end == null) {
      throw StateError('Session $id ist noch nicht beendet');
    }
    return clock.elapsed(end);
  }

  bool get isCompleted =>
      status == SessionStatus.completed && deletedAt == null;

  bool get hasReflection =>
      feelingAfter != null ||
      overcomeRating != null ||
      duringRating != null ||
      (notes?.trim().isNotEmpty ?? false);

  IceSession withClock(SessionClock clock, DateTime now) => copyWith(
    clock: clock,
    status: clock.isEnded ? SessionStatus.completed : status,
    updatedAt: now,
  );

  /// Nachträglich geänderte Zeiten (FEATURES.md A5).
  ///
  /// Bleiben Start und Dauer gleich, bleiben auch die Pausen erhalten.
  /// Andernfalls wird die Session als durchgehende Badezeit gespeichert
  /// (Start + Dauer), und der Kalendertag wird neu bestimmt.
  IceSession rescheduled({
    required DateTime startedAt,
    required Duration duration,
    required int utcOffsetMinutes,
    required DateTime now,
  }) {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'muss positiv sein');
    }
    if (status != SessionStatus.completed) {
      throw StateError('Nur abgeschlossene Sessions können bearbeitet werden');
    }
    final start = startedAt.toUtc();
    final unchanged = start == this.startedAt && duration == this.duration;
    return IceSession(
      id: id,
      status: status,
      entryMode: entryMode,
      clock: unchanged
          ? clock
          : SessionClock(startedAt: start, endedAt: start.add(duration)),
      utcOffsetMinutes: utcOffsetMinutes,
      tzName: tzName,
      localDate: LocalDate.fromInstant(start, utcOffsetMinutes),
      waterTempC: waterTempC,
      feelingBefore: feelingBefore,
      feelingAfter: feelingAfter,
      overcomeRating: overcomeRating,
      duringRating: duringRating,
      notes: notes,
      countdownSeconds: countdownSeconds,
      warmupExerciseId: warmupExerciseId,
      warmupDone: warmupDone,
      createdAt: createdAt,
      updatedAt: now.toUtc(),
      deletedAt: deletedAt,
    );
  }

  /// Zeitraum im Wasser (Start bis Ende).
  bool overlaps(IceSession other) {
    final aEnd = endedAt ?? startedAt;
    final bEnd = other.endedAt ?? other.startedAt;
    return startedAt.isBefore(bEnd) && other.startedAt.isBefore(aEnd);
  }

  IceSession copyWith({
    SessionStatus? status,
    SessionClock? clock,
    double? Function()? waterTempC,
    int? Function()? feelingBefore,
    int? Function()? feelingAfter,
    int? Function()? overcomeRating,
    int? Function()? duringRating,
    String? Function()? notes,
    String? Function()? warmupExerciseId,
    bool? Function()? warmupDone,
    DateTime? updatedAt,
    DateTime? Function()? deletedAt,
  }) {
    _checkFeeling(feelingBefore?.call());
    _checkFeeling(feelingAfter?.call());
    _checkFeeling(overcomeRating?.call());
    _checkFeeling(duringRating?.call());
    return IceSession(
      id: id,
      status: status ?? this.status,
      entryMode: entryMode,
      clock: clock ?? this.clock,
      utcOffsetMinutes: utcOffsetMinutes,
      tzName: tzName,
      localDate: localDate,
      waterTempC: waterTempC != null ? waterTempC() : this.waterTempC,
      feelingBefore: feelingBefore != null
          ? feelingBefore()
          : this.feelingBefore,
      feelingAfter: feelingAfter != null ? feelingAfter() : this.feelingAfter,
      overcomeRating: overcomeRating != null
          ? overcomeRating()
          : this.overcomeRating,
      duringRating: duringRating != null ? duringRating() : this.duringRating,
      notes: notes != null ? notes() : this.notes,
      countdownSeconds: countdownSeconds,
      warmupExerciseId: warmupExerciseId != null
          ? warmupExerciseId()
          : this.warmupExerciseId,
      warmupDone: warmupDone != null ? warmupDone() : this.warmupDone,
      createdAt: createdAt,
      updatedAt: (updatedAt ?? DateTime.now()).toUtc(),
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }

  static void _checkFeeling(int? v) {
    if (v != null && (v < 1 || v > 5)) {
      throw RangeError.range(v, 1, 5, 'feeling');
    }
  }
}
