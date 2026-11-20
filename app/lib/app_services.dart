import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'domain/common/ids.dart';
import 'domain/common/local_date.dart';
import 'domain/community/community.dart';
import 'domain/knowledge/article.dart';
import 'domain/milestones/milestone.dart';
import 'domain/premium/premium.dart';
import 'domain/profile/energy.dart';
import 'domain/profile/tips.dart';
import 'domain/profile/user_profile.dart';
import 'domain/questionnaire/questionnaire.dart';
import 'domain/session/session_clock.dart';
import 'domain/session/session_repository.dart';
import 'domain/warmup/warmup.dart';

/// Zentrale Abhängigkeiten der App, im Widget-Baum verfügbar.
///
/// Bewusst ohne zusätzliches State-Management-Paket: Für den jetzigen Umfang
/// genügen Streams aus dem Repository (ADR-021).
class AppServices extends InheritedWidget {
  const AppServices({
    required this.sessions,
    required this.settings,
    required this.catalog,
    required this.warmup,
    required this.profile,
    required this.questionnaires,
    required this.tips,
    required this.knowledge,
    required this.community,
    required this.communityProfile,
    required this.isPreview,
    required super.child,
    this.random,
    this.energy = const PlaceholderEnergyEstimator(),
    this.mapTiles = true,
    this.bathRegistration = const UnavailableBathRegistration(),
    this.now = utcNow,
    this.utcOffsetMinutes = _deviceOffset,
    this.idGenerator = newId,
    this.localToUtc = _deviceLocalToUtc,
    super.key,
  });

  final SessionRepository sessions;
  final SettingsStore settings;
  final MilestoneCatalog catalog;
  final WarmupCatalog warmup;

  /// Persönliche Angaben und Ziele (N-004).
  final ProfileController profile;
  final QuestionnaireRepository questionnaires;
  final TipCatalog tips;

  /// Wissensbereich (Artikel + geplante Themen).
  final KnowledgeCatalog knowledge;

  /// Community Hub (derzeit lokal/Demo, Server folgt).
  final CommunityRepository community;
  final CommunityProfileController communityProfile;

  /// Kartenkacheln laden (in Tests aus, dort kein Netzwerk).
  final bool mapTiles;

  /// Eisbad über die Seriennummer registrieren (Premium-Quelle, ADR-029).
  final BathRegistration bathRegistration;

  /// Energie-Schätzung für das Ziel Abnehmen (derzeit Platzhalter).
  final EnergyEstimator energy;

  /// Zufall für die Übungsauswahl; in Tests mit festem Startwert.
  final Random? random;

  /// Browser-Vorschau: Daten nur im Arbeitsspeicher.
  final bool isPreview;
  final Now now;
  final int Function() utcOffsetMinutes;
  final String Function({DateTime? now}) idGenerator;

  /// Wandelt eine Lokalzeit (Tag + Uhrzeit) in UTC und liefert den an diesem
  /// Datum gültigen Offset – berücksichtigt Sommer-/Winterzeit beim Nachtragen.
  final LocalTimeResolver localToUtc;

  /// Heutiger Kalendertag in Lokalzeit.
  LocalDate today() => LocalDate.fromInstant(now(), utcOffsetMinutes());

  /// Erfolge ausserhalb der Sessions: bestätigte Sicherheits-Grundlagen aus dem
  /// Onboarding schalten die Kälte-Meilensteine frei.
  Set<String> get externalAchievements => {
    if (profile.profile.safetyAcknowledgedAt != null) 'knowledge.safety_basics',
  };

  static AppServices of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<AppServices>();
    assert(s != null, 'AppServices fehlt im Widget-Baum');
    return s!;
  }

  @override
  bool updateShouldNotify(AppServices old) =>
      sessions != old.sessions ||
      settings != old.settings ||
      catalog != old.catalog;
}

int _deviceOffset() => DateTime.now().timeZoneOffset.inMinutes;

typedef LocalTimeResolver = (DateTime utc, int offsetMinutes) Function(
  LocalDate day,
  int hour,
  int minute,
);

(DateTime, int) _deviceLocalToUtc(LocalDate day, int hour, int minute) {
  final local = DateTime(day.year, day.month, day.day, hour, minute);
  return (local.toUtc(), local.timeZoneOffset.inMinutes);
}

/// Macht den [ProfileController] für Flutter-Widgets beobachtbar.
class ProfileListenable implements Listenable {
  const ProfileListenable(this.controller);
  final ProfileController controller;

  @override
  void addListener(VoidCallback listener) => controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      controller.removeListener(listener);
}

/// Macht den [CommunityProfileController] für Flutter-Widgets beobachtbar.
class CommunityProfileListenable implements Listenable {
  const CommunityProfileListenable(this.controller);
  final CommunityProfileController controller;

  @override
  void addListener(VoidCallback listener) => controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      controller.removeListener(listener);
}
