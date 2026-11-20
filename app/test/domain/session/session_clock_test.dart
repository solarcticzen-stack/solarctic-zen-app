import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/session/session_clock.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 19, 7, 0, 0);
  DateTime at(int seconds) => t0.add(Duration(seconds: seconds));

  group('SessionClock', () {
    test('misst die Zeit seit dem Start', () {
      final c = SessionClock.start(t0);
      expect(c.isRunning, isTrue);
      expect(c.elapsed(at(0)), Duration.zero);
      expect(c.elapsed(at(95)), const Duration(seconds: 95));
    });

    test('Pausen werden nicht mitgezählt', () {
      var c = SessionClock.start(t0);
      c = c.pause(at(60));
      expect(c.isPaused, isTrue);
      // Während der Pause steht die Zeit.
      expect(c.elapsed(at(60)), const Duration(seconds: 60));
      expect(c.elapsed(at(90)), const Duration(seconds: 60));
      c = c.resume(at(90));
      expect(c.elapsed(at(120)), const Duration(seconds: 90));
    });

    test('mehrere Pausen werden summiert', () {
      var c = SessionClock.start(t0);
      c = c.pause(at(10)).resume(at(20)).pause(at(30)).resume(at(45));
      expect(c.pausedUntil(at(100)), const Duration(seconds: 25));
      expect(c.elapsed(at(100)), const Duration(seconds: 75));
    });

    test('nach dem Beenden ist die Dauer eingefroren', () {
      final c = SessionClock.start(t0).end(at(180));
      expect(c.isEnded, isTrue);
      expect(c.elapsed(at(180)), const Duration(seconds: 180));
      expect(c.elapsed(at(5000)), const Duration(seconds: 180));
    });

    test('Beenden während einer Pause schliesst die Pause', () {
      final c = SessionClock.start(t0).pause(at(60)).end(at(100));
      expect(c.pauses.single.isOpen, isFalse);
      expect(c.pauses.single.end, at(100));
      expect(c.elapsed(at(200)), const Duration(seconds: 60));
    });

    test('zurückgestellte Systemuhr ergibt nie eine negative Dauer', () {
      final c = SessionClock.start(t0);
      expect(c.elapsed(t0.subtract(const Duration(minutes: 5))), Duration.zero);
    });

    test('Zeitpunkte in Lokalzeit werden als UTC-Instant behandelt', () {
      final local = DateTime.fromMillisecondsSinceEpoch(
        t0.millisecondsSinceEpoch,
      );
      final c = SessionClock.start(local);
      expect(c.startedAt.isUtc, isTrue);
      expect(c.elapsed(at(30)), const Duration(seconds: 30));
    });

    test('Sommerzeit-Umstellung verändert die Dauer nicht', () {
      // 26.10.2025, 03:00 Sommerzeit -> 02:00 Winterzeit in Europe/Zurich
      // = 01:00 UTC. Eine Session von 00:58 bis 01:02 UTC dauert 4 Minuten.
      final start = DateTime.utc(2025, 10, 26, 0, 58);
      final c = SessionClock.start(start);
      expect(
        c.elapsed(DateTime.utc(2025, 10, 26, 1, 2)),
        const Duration(minutes: 4),
      );
    });

    test('ungültige Übergänge werden abgelehnt', () {
      final running = SessionClock.start(t0);
      expect(() => running.resume(at(1)), throwsStateError);
      final paused = running.pause(at(1));
      expect(() => paused.pause(at(2)), throwsStateError);
      final ended = running.end(at(3));
      expect(() => ended.end(at(4)), throwsStateError);
      expect(() => ended.pause(at(4)), throwsStateError);
    });

    test('Ende vor dem Start ist ungültig', () {
      expect(
        () => SessionClock(
          startedAt: t0,
          endedAt: t0.subtract(const Duration(seconds: 1)),
        ),
        throwsArgumentError,
      );
    });

    test('Zustand ist unveränderlich', () {
      final c = SessionClock.start(t0);
      c.pause(at(5));
      expect(c.isRunning, isTrue, reason: 'pause() liefert eine neue Instanz');
      expect(() => c.pauses.add(PauseInterval(t0)), throwsUnsupportedError);
    });
  });
}
