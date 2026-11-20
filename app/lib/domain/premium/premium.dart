/// Premium-Status aus zwei Quellen (Entscheid 20.11.2026, ADR-029):
/// In-App-Abo **oder** Kauf eines Solarctic-Zen-Eisbads (Registrierung über
/// die Seriennummer). Beides ergibt dieselben Rechte.
///
/// Geprüft wird immer auf dem Server (Store-Belege bzw. Seriennummern-Liste);
/// die App zeigt nur an, was der Server bestätigt hat.
library;

enum PremiumSource {
  subscription('Abo'),
  bathPurchase('Solarctic-Zen Eisbad');

  const PremiumSource(this.label);
  final String label;
}

/// Eine vom Server bestätigte Berechtigung.
class PremiumGrant {
  const PremiumGrant({
    required this.source,
    required this.grantedAt,
    this.expiresAt,
  });

  final PremiumSource source;
  final DateTime grantedAt;

  /// `null` = unbefristet (Laufzeit beim Eisbad-Kauf noch offen, FEATURES §M).
  final DateTime? expiresAt;

  bool isActiveAt(DateTime now) =>
      !now.isBefore(grantedAt) &&
      (expiresAt == null || now.isBefore(expiresAt!));
}

/// Zusammengefasster Status: Premium, sobald eine Berechtigung gilt.
class PremiumStatus {
  PremiumStatus(Iterable<PremiumGrant> grants, DateTime now)
    : active = [
        for (final g in grants)
          if (g.isActiveAt(now)) g,
      ];

  final List<PremiumGrant> active;

  bool get isPremium => active.isNotEmpty;

  Set<PremiumSource> get sources => {for (final g in active) g.source};
}

/// Seriennummer eines Eisbads: nur Vorprüfung in der App.
///
/// Das echte Format ist noch nicht festgelegt (Frage an Solarctic-Zen);
/// bis dahin: Buchstaben und Ziffern, 6–32 Zeichen, Leerzeichen und
/// Bindestriche werden ignoriert.
abstract final class SerialNumbers {
  static String normalize(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');

  static String? validate(String input) {
    final s = normalize(input);
    if (s.isEmpty) return 'Bitte die Seriennummer eingeben.';
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(s)) {
      return 'Nur Buchstaben und Ziffern.';
    }
    if (s.length < 6 || s.length > 32) {
      return 'Die Seriennummer hat 6 bis 32 Zeichen.';
    }
    return null;
  }
}

enum RegistrationOutcome {
  /// Eisbad registriert, Premium freigeschaltet.
  granted,

  /// Nummer unbekannt.
  unknown,

  /// Nummer bereits mit einem anderen Konto verbunden.
  alreadyClaimed,

  /// Zu viele Versuche in kurzer Zeit (Schutz vor Durchprobieren).
  tooManyAttempts,

  /// Ohne Server-Anbindung nicht prüfbar.
  unavailable,
}

/// Port für die Prüfung auf dem Server (Phase 5: Supabase-Funktion
/// `social.claim_bath`).
abstract interface class BathRegistration {
  Future<RegistrationOutcome> register(String serial);
}

/// Bis zur Server-Anbindung: ehrlich «noch nicht möglich», nichts wird
/// lokal freigeschaltet.
class UnavailableBathRegistration implements BathRegistration {
  const UnavailableBathRegistration();

  @override
  Future<RegistrationOutcome> register(String serial) async =>
      RegistrationOutcome.unavailable;
}
