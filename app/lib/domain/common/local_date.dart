import 'package:meta/meta.dart';

/// Ein Kalendertag ohne Uhrzeit und ohne Zeitzone (z. B. «19.11.2026»).
///
/// Wird für Kalender, Wochen- und Monatsstatistiken verwendet. Der Tag einer
/// Session wird beim Start in der damaligen Lokalzeit festgelegt (ADR-005)
/// und ändert sich danach nicht mehr – auch nicht bei Reisen.
@immutable
class LocalDate implements Comparable<LocalDate> {
  LocalDate(this.year, this.month, this.day) {
    final check = DateTime.utc(year, month, day);
    if (check.year != year || check.month != month || check.day != day) {
      throw ArgumentError('Ungültiges Datum: $year-$month-$day');
    }
  }

  /// Kalendertag eines UTC-Zeitpunkts bei gegebener Abweichung von UTC.
  factory LocalDate.fromInstant(DateTime instant, int utcOffsetMinutes) {
    final local = instant.toUtc().add(Duration(minutes: utcOffsetMinutes));
    return LocalDate(local.year, local.month, local.day);
  }

  /// Parst `YYYY-MM-DD`.
  factory LocalDate.parse(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) throw FormatException('Ungültiges Datum', iso);
    return LocalDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// 1 = Montag … 7 = Sonntag (ISO 8601).
  int get weekday => _utc.weekday;

  LocalDate addDays(int days) {
    final d = _utc.add(Duration(days: days));
    return LocalDate(d.year, d.month, d.day);
  }

  /// Montag der ISO-Woche, zu der dieser Tag gehört.
  LocalDate get weekStart => addDays(1 - weekday);

  /// Erster Tag des Monats.
  LocalDate get monthStart => LocalDate(year, month, 1);

  /// Anzahl Tage von [other] bis zu diesem Tag (positiv, wenn dieser später ist).
  int daysSince(LocalDate other) => _utc.difference(other._utc).inDays;

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  @override
  int compareTo(LocalDate other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `YYYY-MM-DD`
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
