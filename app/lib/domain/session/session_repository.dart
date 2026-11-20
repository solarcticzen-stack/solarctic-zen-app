import 'ice_session.dart';

/// Port für die Speicherung von Sessions (Ports & Adapters, Architektur §3).
///
/// Implementierungen: SQLite/drift (iOS, Android) und In-Memory (Tests,
/// Browser-Vorschau).
abstract interface class SessionRepository {
  /// Alle Sessions inkl. gelöschter (Tombstones), neueste zuerst.
  /// Liefert sofort den aktuellen Stand und danach jede Änderung.
  Stream<List<IceSession>> watchAll();

  Future<List<IceSession>> all();

  /// Die laufende Session, falls es eine gibt (z. B. nach App-Absturz).
  Future<IceSession?> findActive();

  /// Speichert oder aktualisiert eine Session samt Pausen.
  Future<void> save(IceSession session);

  /// Löscht weich (Tombstone für späteren Sync, ADR-003).
  Future<void> delete(String id, DateTime now);
}

/// Einfache Schlüssel-Wert-Einstellungen (z. B. letzte Vorlaufzeit).
abstract interface class SettingsStore {
  Future<String?> get(String key);
  Future<void> set(String key, String? value);
}
