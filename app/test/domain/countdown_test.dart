import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/session/countdown.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 19, 7);

  test('Vorlauf zählt herunter und endet exakt nach der Länge', () {
    final c = Countdown(startedAt: t0, length: const Duration(seconds: 10));
    expect(c.secondsLeft(t0), 10);
    expect(c.secondsLeft(t0.add(const Duration(milliseconds: 800))), 10);
    expect(c.secondsLeft(t0.add(const Duration(milliseconds: 1001))), 9);
    expect(
      c.isDone(t0.add(const Duration(seconds: 9, milliseconds: 999))),
      isFalse,
    );
    expect(c.isDone(t0.add(const Duration(seconds: 10))), isTrue);
    expect(c.endsAt, t0.add(const Duration(seconds: 10)));
  });

  test('nach Ablauf nie negativ', () {
    final c = Countdown(startedAt: t0, length: const Duration(seconds: 5));
    expect(c.remaining(t0.add(const Duration(minutes: 1))), Duration.zero);
    expect(c.secondsLeft(t0.add(const Duration(minutes: 1))), 0);
  });

  test('erlaubte Optionen enthalten «aus» und den Standard', () {
    expect(Countdown.options, contains(0));
    expect(Countdown.options, contains(Countdown.defaultSeconds));
  });
}
