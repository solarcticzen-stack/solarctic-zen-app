import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/premium/premium.dart';

void main() {
  final now = DateTime.utc(2026, 11, 20, 12);

  group('PremiumGrant / PremiumStatus', () {
    test('unbefristet gilt ab dem Freischalt-Zeitpunkt', () {
      final g = PremiumGrant(
        source: PremiumSource.bathPurchase,
        grantedAt: DateTime.utc(2026, 11, 1),
      );
      expect(g.isActiveAt(now), isTrue);
      expect(g.isActiveAt(DateTime.utc(2026, 10, 31)), isFalse);
    });

    test('abgelaufenes Abo zählt nicht', () {
      final g = PremiumGrant(
        source: PremiumSource.subscription,
        grantedAt: DateTime.utc(2026, 10, 1),
        expiresAt: DateTime.utc(2026, 11, 1),
      );
      expect(g.isActiveAt(now), isFalse);
      expect(PremiumStatus([g], now).isPremium, isFalse);
    });

    test('Premium, sobald eine Quelle gilt; beide Quellen möglich', () {
      final status = PremiumStatus([
        PremiumGrant(
          source: PremiumSource.subscription,
          grantedAt: DateTime.utc(2026, 1, 1),
          expiresAt: DateTime.utc(2026, 12, 1),
        ),
        PremiumGrant(
          source: PremiumSource.bathPurchase,
          grantedAt: DateTime.utc(2026, 11, 1),
        ),
      ], now);
      expect(status.isPremium, isTrue);
      expect(status.sources, {
        PremiumSource.subscription,
        PremiumSource.bathPurchase,
      });
      expect(PremiumStatus(const [], now).isPremium, isFalse);
    });
  });

  group('Seriennummer (Vorprüfung)', () {
    test('normalisiert Gross-/Kleinschreibung, Leerzeichen, Bindestriche', () {
      expect(SerialNumbers.normalize(' sz-2026 0001 '), 'SZ20260001');
    });

    test('prüft Zeichen und Länge', () {
      expect(SerialNumbers.validate(''), isNotNull);
      expect(SerialNumbers.validate('SZ#2026'), contains('Buchstaben'));
      expect(SerialNumbers.validate('AB12'), contains('6 bis 32'));
      expect(SerialNumbers.validate('X' * 33), contains('6 bis 32'));
      expect(SerialNumbers.validate('sz-2026-0001'), isNull);
    });
  });

  test('ohne Server wird nichts lokal freigeschaltet', () async {
    expect(
      await const UnavailableBathRegistration().register('SZ20260001'),
      RegistrationOutcome.unavailable,
    );
  });
}
