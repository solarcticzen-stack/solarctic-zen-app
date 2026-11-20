# Solarctic-Zen App – Arbeitsgrundlage für Claude Code

Eisbad-Begleit-App der Schweizer Marke Solarctic-Zen. Entwicklung und Wartung durch Claude Code zusammen mit dem Solarctic-Zen-Team.

## Vor jeder Arbeit
1. `docs/DEVELOPMENT_LOG.md` lesen (neueste Einträge oben) – Status der Entscheidungen (ADR) beachten.
2. Für die betroffene Funktion `docs/FEATURES.md` (Priorität, Status) und die passenden Abschnitte in `docs/TECHNICAL_ARCHITECTURE.md` / `docs/DATABASE_SCHEMA.md` / `docs/DESIGN_SYSTEM.md` prüfen.
3. Angenommene ADRs nicht stillschweigend ändern – Abweichungen vorschlagen und als neuen ADR dokumentieren.

## Nach jeder Arbeit
- Tests ausführen und grün haben, bevor das nächste Modul beginnt.
- `DEVELOPMENT_LOG.md` ergänzen (was, warum, offene Punkte), Status in `FEATURES.md` nachführen, betroffene Dokumente aktualisieren.
- Nicht implementierte oder simulierte Funktionen in UI und Doku klar kennzeichnen.

## Technische Leitplanken
- Flutter-App in `app/`, watchOS in `watch/`, Wear OS in `wear/`, Supabase in `backend/` (ab Phase 5).
- Domain-Logik in reinem Dart ohne Plattformabhängigkeit; native Brücken (Pigeon) bleiben dünn.
- Local-first: SQLite (drift) ist die Quelle der Wahrheit. Zeit in UTC + IANA-Zeitzone, `local_date` beim Start fixiert.
- Timer immer aus gespeicherten Zeitstempeln berechnen, nie hochzählen. Aktive Session beim Start speichern.
- Herzfrequenzwerte tragen immer ihre Herkunft (`live`, `buffered_live`, `synced`).
- Meilensteine/Wissen sind Kataloge in `app/assets/` – neue Einträge ohne Code-Änderung.
- Neue Abhängigkeiten nur mit Begründung im Log.
- Entwicklung unter Windows; iOS/watchOS werden über Codemagic gebaut (kein lokaler Mac).
- **Alles liegt auf Laufwerk D: (C: ist voll).** Projekt `D:\SolarcticApp\SolarcticZen`, Flutter-SDK `D:\SolarcticApp\sdk\flutter`, Pub-Cache `D:\SolarcticApp\sdk\pub-cache` (Benutzervariable `PUB_CACHE`). Weitere SDKs/Caches (Android SDK, JDK, Gradle) ebenfalls unter `D:\SolarcticApp\sdk\`.

## Inhaltliche Leitplanken
- Keine Diagnosen, keine Heilversprechen, keine unbelegten Benefits. Gesundheitsinhalte mit Evidenzstufe und Quellen; Veröffentlichung nur nach Review der Fachperson.
- Gamification belohnt Regelmässigkeit, nie längere Einzelsessions oder tiefere Temperaturen. Ranglisten nur nach Regelmässigkeit.
- Atemübungen nur ruhig und an Land, keine Hyperventilation.
- Ruhige, schuldfreie Tonalität. Deutsch in Schweizer Rechtschreibung (ss statt ß), Englisch als zweite Sprache.

## Sicherheit & Datenschutz
- Gesundheitsdaten standardmässig nur lokal; Cloud nur mit ausdrücklicher Zustimmung; Community sieht nie Herzfrequenzdaten.
- Keine Tracking-/Werbe-SDKs. Keine Zugangsdaten oder Schlüssel ins Repository.
