import 'package:solarctic_zen/domain/common/local_date.dart';
import 'package:solarctic_zen/domain/session/ice_session.dart';

var _seq = 0;

/// Abgeschlossene Session am Tag [day] (09:00 Lokalzeit Zürich im Winter).
IceSession session(
  LocalDate day, {
  int seconds = 120,
  double? temp,
  int? feeling,
  String? notes,
  int offsetMinutes = 60,
}) {
  final start = DateTime.utc(
    day.year,
    day.month,
    day.day,
    9,
  ).subtract(Duration(minutes: offsetMinutes));
  return IceSession.manual(
    id: 's${_seq++}',
    startedAt: start,
    duration: Duration(seconds: seconds),
    utcOffsetMinutes: offsetMinutes,
    now: start,
    waterTempC: temp,
    feelingAfter: feeling,
    notes: notes,
  );
}

LocalDate d(int y, int m, int day) => LocalDate(y, m, day);
