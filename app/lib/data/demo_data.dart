import 'dart:math';

import '../domain/common/local_date.dart';
import '../domain/session/ice_session.dart';

/// Beispieldaten **nur für die Browser-Vorschau**: etwa drei Bäder pro Woche
/// über [days] Tage, damit Kalender und Diagramme ausprobiert werden können.
/// Werte sind erfunden und deterministisch (fester Zufallsstartwert).
List<IceSession> demoSessions({
  required LocalDate today,
  required int utcOffsetMinutes,
  int days = 90,
  int seed = 42,
}) {
  final rnd = Random(seed);
  const exercises = [
    'squats',
    'jumping_jacks',
    'wall_pushups',
    'arm_circles',
    'march',
  ];
  final result = <IceSession>[];
  for (var i = days; i >= 1; i--) {
    final day = today.addDays(-i);
    // Mo, Mi, Sa mit gelegentlichen Ausnahmen, dazu einzelne Pausenwochen.
    final planned = {1, 3, 6}.contains(day.weekday);
    if (!planned || rnd.nextDouble() < 0.15) continue;
    if (i > 40 && i < 48) continue; // Ferienpause
    final progress = 1 - i / days; // 0 → 1 über den Zeitraum
    final seconds = (60 + progress * 120 + rnd.nextInt(40)).round();
    final temp = (11 - progress * 6 + rnd.nextDouble() * 2).clamp(3.0, 14.0);
    final start = DateTime.utc(
      day.year,
      day.month,
      day.day,
      6,
      30 + rnd.nextInt(60),
    ).subtract(Duration(minutes: utcOffsetMinutes));
    result.add(
      IceSession.manual(
        id: 'demo-$i',
        startedAt: start,
        duration: Duration(seconds: seconds),
        utcOffsetMinutes: utcOffsetMinutes,
        now: start,
        waterTempC: (temp * 2).round() / 2,
        feelingAfter: rnd.nextDouble() < 0.7 ? 3 + rnd.nextInt(3) : null,
      ).copyWith(
        warmupExerciseId: () => exercises[rnd.nextInt(exercises.length)],
        warmupDone: () => rnd.nextDouble() < 0.8,
        updatedAt: start,
      ),
    );
  }
  return result;
}
