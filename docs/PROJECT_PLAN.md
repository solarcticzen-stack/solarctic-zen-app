# Solarctic-Zen – Projektplan

Status: **v0.1 (2026-11-19)** – Konzeptphase. Implementierung startet nach Klärung der offenen Fragen.

Verwandte Dokumente: `TECHNICAL_ARCHITECTURE.md` · `FEATURES.md` · `DATABASE_SCHEMA.md` · `DESIGN_SYSTEM.md` · `DEVELOPMENT_LOG.md`

## 1. Produktziel in einem Satz

Die ruhigste und vertrauenswürdigste App, um Eisbäder sicher zu begleiten, ehrlich zu messen und eine langfristige Routine aufzubauen – im Markenkern von Solarctic-Zen.

**Erfolgskriterien (Vorschlag):** Timer verliert in Tests nie eine Session · ≥ 40 % der aktiven Nutzer haben nach 8 Wochen noch mind. 1 Session/Woche · App-Store-Bewertung ≥ 4.7 · null Gesundheitsversprechen ohne Beleg.

## 2. Etappen

**Angepasst 2026-11-19 (ADR-020):** Die App wird von Claude Code programmiert. Die reine Programmierzeit ist deshalb kurz (Tage statt Wochen pro Etappe). Den Takt bestimmen andere Faktoren: eure Test- und Feedbackrunden, Feldtests im Eisbad, iOS-Builds über die Cloud (15–30 min pro Durchlauf), Kontoeröffnungen (D-U-N-S, Apple-Prüfung), die fachliche Prüfung der Inhalte und die Store-Prüfungen. Die frühere Schätzung in Personenwochen galt für ein klassisches Entwicklerteam und ist ersetzt.

| Etappe | Inhalt | Ergebnis / Abnahmekriterium | Programmierung | Wartet auf |
|---|---|---|---|---|
| **0 · Setup** | Flutter-Projekt, Struktur, Lints, CI-Dateien, Timer-Grundfunktion, Browser-Vorschau | Tests grün, Vorschau läuft | **erledigt** (2026-11-19) | – |
| **1 · Domain-Kern** | Entities, Stats-, Milestone-, Goal-Engine, drift-Datenbank, Speichern der Sessions, Vorlauf (A19) | Zeitzonen-/DST-/Absturz-Tests grün | **weitgehend erledigt** (2026-11-19; offen: Bearbeiten/manuell eintragen in der UI) | – |
| **2 · Design** | Designsystem-Komponenten, alle Hauptscreens klickbar in der Vorschau | Review der Screens durch Solarctic-Zen | 1–3 Sitzungen | CI-Unterlagen (`brand/`), euer Feedback |
| **3 · MVP (iOS + Android)** | Onboarding & Sicherheit, Dashboard, Session-Ablauf, Kalender, Liste, Statistik, Meilensteine, Ziele, Profil, Export/PDF, Apple Health und Health Connect, Live Activity / Android-Benachrichtigung, Erinnerungen, DE/EN, Basis-Wissensartikel | TestFlight- und Android-Beta mit 10–20 Personen; Timer-Zuverlässigkeit auf echten Geräten bestätigt | mehrere Sitzungen | Apple-Konto (TestFlight), Android-SDK lokal, Testrunden, Fachreview der Artikel |
| **4 · Wearables** | watchOS-App, BLE-HF-Sensoren auf iOS und Android, Herkunftskennzeichnung | Live-HF im echten Eisbad mit Watch und Brustgurt verifiziert | mehrere Sitzungen | Feldtests im Eisbad; ohne Mac deutlich mehr Testrunden (ADR-016) |
| **Release 1.0** | Store-Unterlagen, Datenschutzerklärung, Datenschutz-Labels | gleichzeitig live in App Store und Play Store | 1–2 Sitzungen | rechtliche Prüfung, Store-Reviews, Google-Play-Konto |
| **1.1 · Wear OS** | Wear-OS-App | wie Etappe 4 für Wear OS | mehrere Sitzungen | Testgerät mit Wear OS |
| **5 · Erweiterungen** | Account, Sync, Community, Widgets, Siri, Fotos, Mehrfachprofile | schrittweise Releases | je Funktion | Supabase-Konto |
| **6 · Eisbad-Integration** | `BathDevice`-Adapter | abhängig von Hardware-Schnittstelle | offen | Unterlagen des Herstellers (`hardware/`) |

**Realistischer Zeitrahmen:** Eine Vorschau mit allen Hauptscreens und echter Speicherung ist in wenigen Arbeitssitzungen möglich. Wie schnell danach die Beta auf echten Geräten steht, hängt vor allem davon ab, wann das Apple-Konto aktiv ist (D-U-N-S-Vorlauf bis ca. 2 Wochen) und wie zügig die Testrunden laufen. Ein Release-Datum lässt sich seriös erst nach der ersten Beta-Runde nennen.

**Build-Setup (F2: kein Mac):** Entwicklung unter Windows, iOS/watchOS-Builds über Codemagic, iOS-Tests auf echten Geräten via TestFlight. Für Etappe 4 wird ein Mac-Zugang (Miet-Mac oder Mac mini) empfohlen – Entscheidung spätestens zu Beginn von Etappe 4.

**Launch-Umfang Android (F1: gleichzeitig):** gleicher Funktionsumfang wie iOS. Live-HF über Bluetooth-Sensoren, synchronisierte HF über Health Connect. Einzige Ausnahme: Die eigene Wear-OS-App kommt mit 1.1 (ADR-014).

## 3. Teststrategie

| Ebene | Inhalt |
|---|---|
| Unit (Dart) | SessionClock (Pause, Absturz, Uhrzeitänderung), Statistik, Meilenstein-Regeln, Ziele, ISO-Wochen, DST (z. B. 30.3./26.10. in `Europe/Zurich`), Zeitzonenwechsel während Reise |
| Datenbank | Migrationstests jeder Schema-Version, Constraint «max. 1 aktive Session» |
| Widget / Golden | Alle Designsystem-Komponenten und Hauptscreens: hell/dunkel, iPhone SE bis Pro Max, Schrift 100–200 % |
| Integration | Session-Ablauf Ende-zu-Ende, Bearbeiten/Löschen → Meilensteine neu berechnet |
| Unterbrechungen | App beenden während Session, Gerät sperren, Anruf, Neustart, Speicher voll, Berechtigung entzogen |
| Datenübertragung | Watch ↔ iPhone (Reichweite verlassen, Watch-App-Absturz, Mirroring-Abbruch), BLE-Verlust/-Wiederverbindung, Duplikat-Erkennung bei nachgelieferten HF-Werten |
| Feldtests | Echte Eisbäder mit Apple Watch, Brustgurt, Garmin-Broadcast; dokumentierte Testprotokolle |
| Native | XCTest für Watch-/HealthKit-Code, JUnit für Android-Native |

## 4. Risiken

| # | Risiko | Wahrscheinlichkeit | Auswirkung | Massnahme |
|---|---|---|---|---|
| R1 | Kein Mac → langsame iOS-Feedback-Schleife, Watch-Entwicklung ohne Debugger | **eingetreten** | mittel (App) / hoch (Watch) | Codemagic + TestFlight, dünne native Brücken, Diagnoseprotokoll; Mac-Zugang für Etappe 4 (ADR-015–017) |
| R2 | HF in kaltem Wasser ungenau/lückenhaft | hoch | mittel | Plausibilisierung, ehrliche Lücken, Brustgurt-Option, Erwartungsmanagement in der UI |
| R3 | Bluetooth-Abriss unter Wasser | hoch | mittel | Pufferung auf Watch/Sensor, Herkunft «GEPUFFERT» |
| R4 | App-Store-Ablehnung (Health-Richtlinien, Medizin-Aussagen) | mittel | mittel | Richtlinien-Check vor Einreichung, keine Diagnose-Funktionen, vorsichtige Texte |
| R5 | Rechtliche Einordnung als Medizinprodukt | gering | hoch | keine Diagnose-/Therapiefunktionen; juristische Prüfung vor Launch |
| R6 | Haftung für Gesundheits-/Sicherheitsinhalte | mittel | hoch | Fachreview, Quellen, Disclaimer, Sicherheits-Onboarding |
| R7 | Google-Play-Freigabe der Health-Connect-Berechtigungen dauert | mittel | gering | frühzeitig beantragen |
| R8 | Geräteschnittstelle des Eisbads unklar | hoch | mittel | Port + Simulator jetzt, Adapter später (F5) |
| R9 | Gamification erzeugt Druck oder riskantes Verhalten | mittel | hoch | Regeln in `FEATURES.md` §D, Nutzertests mit Anfängern |
| R10 | Umfang wächst (Community, Geräte) vor stabilem Kern | hoch | mittel | strikte Etappen, MVP ohne Backend |

## 5. Offene Fragen

Nur die Fragen, die Architektur oder Umfang wesentlich beeinflussen:

- ~~**F1 – Android:**~~ **Beantwortet 2026-11-19:** gleichzeitig mit iOS. → Flutter bestätigt (ADR-001).
- **F2 – Mac & Geräte:** **Beantwortet 2026-11-19:** kein Mac, Cloud-Builds (ADR-015). Testgeräte vorhanden: iPhone, Apple Watch, Android-Smartphone, Brustgurt/BLE-Sensor. Konten existieren noch nicht → Checkliste `SETUP_ACCOUNTS.md`.
- **F3 – Team & Betrieb:** **Beantwortet 2026-11-19:** Entwicklung und Wartung durch Claude Code zusammen mit dem Solarctic-Zen-Team (ADR-018). Eine Fachperson für die Prüfung der Gesundheitsinhalte ist vorhanden.
- **F4 – Marke:** **Beantwortet 2026-11-19:** Logos (schwarz/weiss) geliefert und eingebaut, Markenfarben Schwarz/Weiss, Schrift Roboto. **Noch offen:** Logo als Vektordatei (SVG/PDF/AI) für App-Icon und Startbildschirm; endgültiger App-Name.
- **F5 – Eisbad-Hardware:** **Beantwortet 2026-11-19:** Steuerelektronik mit WLAN/Bluetooth vorhanden. **Noch zu liefern:** Hersteller/Modell des Kühlaggregats bzw. Controllers, Name der Hersteller-App, vorhandene technische Dokumentation → `SolarcticZen/hardware/`. Fragenkatalog: `TECHNICAL_ARCHITECTURE.md` §9. Blockiert erst Etappe 6.
- **F6 – Geschäftsmodell:** *Teilweise geklärt (20.11.2026, ADR-029):* Premium entweder als In-App-Abo oder inklusive beim Kauf eines Solarctic-Zen-Eisbads (Registrierung über die Seriennummer). Offen: Abo-Preis, Laufzeit beim Eisbad-Kauf, Haushalts-Nutzung, Format/Liste der Seriennummern.

Getroffene Annahmen, bis die Antworten vorliegen: MVP ohne Account · Supabase EU erst ab Phase 5 · manuelle Temperatureingabe.
