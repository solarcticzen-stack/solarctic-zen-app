import '../../domain/common/local_date.dart';

// Deutsche Formatierung (de-CH). Englisch folgt mit der Lokalisierung (H4).

const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const _months = [
  'Januar',
  'Februar',
  'März',
  'April',
  'Mai',
  'Juni',
  'Juli',
  'August',
  'September',
  'Oktober',
  'November',
  'Dezember',
];

/// «Do, 19.11.2026»
String formatDay(LocalDate d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.${d.year}';

/// «November 2026»
String formatMonth(LocalDate d) => '${_months[d.month - 1]} ${d.year}';

/// Gesamtzeiten: «45 s», «12 min», «1 h 05 min».
String formatTotal(Duration d) {
  if (d.inMinutes < 1) return '${d.inSeconds} s';
  if (d.inHours < 1) return '${d.inMinutes} min';
  return '${d.inHours} h ${(d.inMinutes % 60).toString().padLeft(2, '0')} min';
}

/// Temperatur mit einer Nachkommastelle, ohne «.0»: «4 °C», «4.5 °C».
String formatTemp(double c) {
  final rounded = (c * 10).round() / 10;
  final text = rounded == rounded.roundToDouble()
      ? rounded.toStringAsFixed(0)
      : rounded.toStringAsFixed(1);
  return '$text °C';
}

/// Uhrzeit in Lokalzeit: «07:05».
String formatTime(DateTime utc, int offsetMinutes) {
  final l = utc.toUtc().add(Duration(minutes: offsetMinutes));
  return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

/// Kurzes Datum: «19.11.»
String formatShortDate(LocalDate d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';

/// Dauer für Texte: «2:30 min», «45 s».
String formatDurationText(Duration d) {
  if (d.inSeconds < 60) return '${d.inSeconds} s';
  final m = d.inMinutes;
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s min';
}
