import '../session/ice_session.dart';
import 'user_profile.dart';

/// Schätzung des zusätzlichen Energieverbrauchs durch die Kälte (Ziel Abnehmen).
///
/// Austauschbar: Die geprüfte Formel wird später nur hier eingesetzt.
abstract interface class EnergyEstimator {
  /// `null`, wenn keine Schätzung möglich ist.
  int? estimateKcal(IceSession session, UserProfile profile);

  /// `true`, solange nur ein Platzhalterwert geliefert wird.
  bool get isPlaceholder;
}

/// PLATZHALTER (Entscheid 19.11.2026): pauschal ca. 70 kcal pro Eisbad,
/// unabhängig von Dauer, Temperatur und Person.
///
/// **Release-Blocker:** vor Veröffentlichung durch eine von der Fachperson
/// freigegebene Formel ersetzen (FEATURES.md §L, P4). In der App immer als
/// «Platzhalter» gekennzeichnet.
class PlaceholderEnergyEstimator implements EnergyEstimator {
  const PlaceholderEnergyEstimator();

  static const kcalPerBath = 70;

  @override
  bool get isPlaceholder => true;

  @override
  int? estimateKcal(IceSession session, UserProfile profile) => kcalPerBath;
}
