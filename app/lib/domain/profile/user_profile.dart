import 'dart:convert';

import 'package:meta/meta.dart';

import '../session/session_repository.dart';

/// Persönliche Angaben (Notiz N-004). Alles bleibt lokal auf dem Gerät.
/// Geschlecht und Grösse haben «keine Angabe», Gewicht und Geburtsjahr sind
/// freiwillig (App-Store-Richtlinie 5.1.1, Datensparsamkeit).
enum Sex {
  female('Frau'),
  male('Mann'),
  diverse('Divers'),
  unspecified('Keine Angabe');

  const Sex(this.label);
  final String label;
}

/// «Warum Eisbaden?» – Mehrfachauswahl.
enum BathGoal {
  recovery('Regeneration nach dem Sport'),
  mental('Geistiges Wohlbefinden'),
  stress('Stress abbauen'),
  sleep('Besser schlafen'),
  weightLoss('Abnehmen'),
  longevity('Langlebigkeit'),
  prevention('Krankheiten vorbeugen'),
  discipline('Disziplin & mentale Stärke'),
  medical('Krankheitsbedingt / ärztlich begleitet');

  const BathGoal(this.label);
  final String label;
}

@immutable
class UserProfile {
  const UserProfile({
    this.sex = Sex.unspecified,
    this.heightCm,
    this.weightKg,
    this.birthYear,
    this.goals = const {},
    this.safetyAcknowledgedAt,
    this.healthConsentAt,
    this.onboardingCompletedAt,
  });

  factory UserProfile.fromJson(Map<String, Object?> j) => UserProfile(
    sex: Sex.values.asNameMap()[j['sex']] ?? Sex.unspecified,
    heightCm: (j['height_cm'] as num?)?.toInt(),
    weightKg: (j['weight_kg'] as num?)?.toDouble(),
    birthYear: (j['birth_year'] as num?)?.toInt(),
    goals: {
      for (final g in (j['goals'] as List<Object?>?) ?? const [])
        ?BathGoal.values.asNameMap()[g],
    },
    safetyAcknowledgedAt: _date(j['safety_ack']),
    healthConsentAt: _date(j['health_consent']),
    onboardingCompletedAt: _date(j['onboarded']),
  );

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.parse(v).toUtc() : null;

  final Sex sex;
  final int? heightCm;
  final double? weightKg;
  final int? birthYear;
  final Set<BathGoal> goals;
  final DateTime? safetyAcknowledgedAt;
  final DateTime? healthConsentAt;
  final DateTime? onboardingCompletedAt;

  bool get onboarded => onboardingCompletedAt != null;
  bool has(BathGoal g) => goals.contains(g);

  Map<String, Object?> toJson() => {
    'sex': sex.name,
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'birth_year': birthYear,
    'goals': [for (final g in goals) g.name],
    'safety_ack': safetyAcknowledgedAt?.toIso8601String(),
    'health_consent': healthConsentAt?.toIso8601String(),
    'onboarded': onboardingCompletedAt?.toIso8601String(),
  };

  UserProfile copyWith({
    Sex? sex,
    int? Function()? heightCm,
    double? Function()? weightKg,
    int? Function()? birthYear,
    Set<BathGoal>? goals,
    DateTime? safetyAcknowledgedAt,
    DateTime? healthConsentAt,
    DateTime? onboardingCompletedAt,
  }) => UserProfile(
    sex: sex ?? this.sex,
    heightCm: heightCm != null ? heightCm() : this.heightCm,
    weightKg: weightKg != null ? weightKg() : this.weightKg,
    birthYear: birthYear != null ? birthYear() : this.birthYear,
    goals: goals ?? this.goals,
    safetyAcknowledgedAt: safetyAcknowledgedAt ?? this.safetyAcknowledgedAt,
    healthConsentAt: healthConsentAt ?? this.healthConsentAt,
    onboardingCompletedAt: onboardingCompletedAt ?? this.onboardingCompletedAt,
  );
}

/// Plausibilitätsgrenzen der Eingaben.
abstract final class ProfileLimits {
  static const minHeight = 100, maxHeight = 250;
  static const minWeight = 30.0, maxWeight = 300.0;
  static const minBirthYear = 1920;

  /// Jüngstes erlaubtes Geburtsjahr relativ zum aktuellen Jahr.
  static int maxBirthYear(int currentYear) => currentYear - 10;
}

/// Hält das Profil und speichert es als JSON in den lokalen Einstellungen.
class ProfileController {
  ProfileController(this._store, [UserProfile initial = const UserProfile()])
    : _profile = initial;

  static const _key = 'profile';
  final SettingsStore _store;
  UserProfile _profile;
  final List<void Function()> _listeners = [];

  UserProfile get profile => _profile;

  Future<void> load() async {
    final raw = await _store.get(_key);
    if (raw != null) {
      _profile = UserProfile.fromJson(jsonDecode(raw) as Map<String, Object?>);
    }
    _notify();
  }

  Future<void> save(UserProfile p) async {
    _profile = p;
    await _store.set(_key, jsonEncode(p.toJson()));
    _notify();
  }

  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() {
    for (final l in [..._listeners]) {
      l();
    }
  }
}
