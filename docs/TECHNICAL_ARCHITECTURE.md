# Solarctic-Zen – Technische Architektur

Status: **v0.2 (2026-11-19)** – Framework-Wahl bestätigt (Android startet gleichzeitig mit iOS → Flutter, ADR-001). Weitere offene Fragen siehe `PROJECT_PLAN.md`, Abschnitt «Offene Fragen».
Entscheidungen sind als ADR im `DEVELOPMENT_LOG.md` festgehalten.

---

## 1. Ausgangslage und Architekturtreiber

Diese Anforderungen bestimmen die Architektur am stärksten, in dieser Reihenfolge:

| # | Treiber | Konsequenz |
|---|---------|------------|
| 1 | **Live-Herzfrequenz von der Apple Watch** | Ohne eigene watchOS-App mit `HKWorkoutSession` gibt es *keine* Live-HF auf dem iPhone. HealthKit liefert Watch-Daten ohne laufendes Workout nur verzögert und in grossen Abständen. Eine native Swift-Watch-App ist daher Pflicht – unabhängig vom Framework. |
| 2 | **Zuverlässiger Timer bei gesperrtem Gerät** | Der Timer darf nicht auf «Ticks» beruhen, sondern auf gespeicherten Zeitstempeln. Anzeige im Sperrbildschirm über Live Activity (iOS) bzw. Foreground-Service-Benachrichtigung (Android). |
| 3 | **iOS und Android, eine Marke, ein Premium-Design** | Ein eigenes, markenspezifisches Designsystem (kein Standard-iOS- oder Material-Look) spricht für ein Framework mit eigener Rendering-Engine. |
| 4 | **Offline-first** | Lokale Datenbank ist die «Quelle der Wahrheit». Die Cloud ist optional und kommt erst mit Account/Community dazu. |
| 5 | **Gesundheitsdaten (besonders schützenswerte Personendaten nach revDSG, Art. 9 DSGVO)** | Standardmässig nur lokal; Cloud-Sync nur nach ausdrücklicher Zustimmung; keine Gesundheitsdaten in Community-Funktionen. |
| 6 | **Erweiterbarkeit (weitere Wearables, Eisbad-Steuerung, neue Meilensteine)** | Klare Schnittstellen (Ports & Adapters), datengetriebene Meilensteine und Inhalte. |

---

## 2. Framework-Vergleich

Bewertung 1 (schlecht) – 5 (sehr gut), gewichtet für *dieses* Projekt.

| Kriterium | Gewicht | Native (Swift + Kotlin) | Flutter | React Native (Expo) | Kotlin Multiplatform + native UI |
|---|---|---|---|---|---|
| Apple Watch / Widgets / Live Activities | hoch | 5 | 3 (native Module nötig) | 3 (native Module nötig) | 4 |
| Eigenes Premium-Designsystem auf iOS + Android identisch | hoch | 3 (2× bauen) | 5 | 4 | 3 (2× bauen) |
| Entwicklungs- und Wartungsaufwand für 2 Plattformen | hoch | 2 | 5 | 4 | 3 |
| Animationen / Charts / Timer-Darstellung | mittel | 5 | 5 | 4 | 5 |
| Automatisierte Tests (inkl. UI-Tests ohne Gerät) | mittel | 4 | 5 (Widget- & Golden-Tests laufen headless, auch unter Windows) | 4 | 4 |
| Abhängigkeits-Stabilität | mittel | 5 | 4 | 3 (npm-/Native-Modul-Upgrades) | 4 |
| Verfügbarkeit von Entwicklern | mittel | 4 | 4 | 5 | 2 |
| Zugriff auf neueste Plattform-APIs am Tag 1 | mittel | 5 | 3 | 3 | 4 |

### Empfehlung: **Flutter für die Smartphone-App + native Module für alles Gerätenahe**

Begründung:

1. **Der plattformspezifische Teil ist ohnehin nativ.** watchOS-App, Wear-OS-App, Widgets, Live Activity, Siri/App Intents und HealthKit-Workout-Logik müssen in Swift bzw. Kotlin geschrieben werden – egal welches Framework. Das betrifft ca. 25–30 % des Gesamtumfangs.
2. **Die restlichen 70 % (Dashboard, Timer-UI, Kalender, Statistiken, Meilensteine, Wissen, Profil, Sync)** sind plattformunabhängig und profitieren stark von *einer* Codebasis.
3. **Markendesign statt Systemlook.** Flutter rendert selbst (Impeller). Ein dunkles, eigenständiges Solarctic-Zen-Design sieht auf iPhone und Android identisch aus, Animationen sind präzise steuerbar.
4. **Testbarkeit.** Domain-Logik (Timer, Statistik, Meilensteine, Zeitzonen) und UI-Komponenten lassen sich ohne Gerät automatisiert testen – das ist für die Qualitätsanforderungen (Kap. 11) und für die Arbeit auf diesem Windows-Rechner entscheidend.
5. **Wenige Abhängigkeiten.** Dart/Flutter bringen Lokalisierung, Animationen, Tests und Codegenerierung (Pigeon für typsichere native Brücken) offiziell mit.

**Warum nicht React Native?** Ebenfalls gangbar. Ausschlaggebend für Flutter sind die konsistentere Darstellung eines eigenen Designsystems, die stärkeren UI-Tests und die geringere Abhängigkeits-Fluktuation.
**Warum nicht rein nativ?** Beste Plattformintegration, aber doppelter Aufwand für jede Funktion. Wäre nur sinnvoll gewesen, wenn Android vorerst kein Ziel wäre – mit dem gleichzeitigen Android-Launch (F1) entfällt diese Option.
**Warum nicht Kotlin Multiplatform?** Teilt Logik, aber nicht die UI – das Designsystem müsste zweimal gebaut werden; kleinerer Entwicklerpool.

### Wichtige Rahmenbedingung: macOS → Cloud-Builds (F2, ADR-015)

iOS- und watchOS-Apps können **nur mit Xcode auf macOS** gebaut und signiert werden. Es steht kein Mac zur Verfügung; entwickelt wird unter Windows 11, gebaut wird iOS in der Cloud.

| Was | Wo | Prüfung |
|---|---|---|
| Dart-Domain, UI, Datenbank | Windows lokal | Unit-, Widget-, Golden-Tests headless; Android-Emulator |
| Android-App inkl. Native-Code | Windows lokal | Emulator + echtes Android-Gerät |
| iOS-Native (HealthKit, Live Activity, Widgets, Intents) | Code lokal, Build in Codemagic | XCTest im CI-Simulator, TestFlight auf echtem iPhone |
| watchOS-App | Code lokal, Build in Codemagic | XCTest im CI-watchOS-Simulator, TestFlight auf echter Watch; **Mac-Zugang für Etappe 4 empfohlen** (ADR-016) |

Konsequenzen für den Code-Schnitt:
- Native Brücken bleiben **dünn**: Plattform-Code übersetzt nur Aufrufe; Logik (Plausibilisierung, Pufferung, Duplikat-Erkennung) liegt in Dart oder in reinen, plattformunabhängigen Swift-Modulen, die im Simulator testbar sind.
- Ein lokales, exportierbares **Diagnoseprotokoll** (ADR-017) ersetzt den fehlenden Debugger bei TestFlight-Tests.
- Echte Herzfrequenz-Tests erfordern echte Geräte **im echten Eisbad** – der Simulator liefert nur synthetische Werte.

---

## 3. Systemübersicht

```
┌────────────────────────────── Smartphone-App (Flutter) ──────────────────────────────┐
│  Presentation    Screens, Designsystem-Komponenten, Navigation (go_router)           │
│  Application     Use Cases: StartSession, EndSession, EditSession, EvaluateMilestones│
│  Domain          Entities, SessionClock, StatsEngine, MilestoneEngine, GoalEngine    │
│                  (reines Dart, keine Plattform-Abhängigkeit, 100 % unit-getestet)    │
│  Ports           HeartRateSource, HealthStore, BathDevice, SyncGateway, Notifier     │
│  Adapters        drift/SQLite · Pigeon-Brücken · BLE · Supabase (später)             │
└───────────┬──────────────────────┬────────────────────────┬───────────────────────────┘
            │ Pigeon (typsicher)    │                        │ HTTPS/TLS (opt-in)
   ┌────────▼────────┐    ┌────────▼────────┐        ┌───────▼────────┐
   │ iOS-Native      │    │ Android-Native  │        │ Backend        │
   │ HealthKit       │    │ Health Connect  │        │ Supabase (EU)  │
   │ WatchConnect./  │    │ Wearable Data   │        │ Auth, Postgres │
   │ Workout-Mirror  │    │ Layer           │        │ RLS, Storage,  │
   │ ActivityKit     │    │ Foreground Svc  │        │ Edge Functions │
   │ WidgetKit       │    │ Glance Widgets  │        └────────────────┘
   │ App Intents     │    │ Shortcuts       │
   └────────┬────────┘    └────────┬────────┘
   ┌────────▼────────┐    ┌────────▼────────┐    ┌──────────────────────┐
   │ watchOS-App     │    │ Wear-OS-App     │    │ BLE-HF-Sensoren      │
   │ SwiftUI         │    │ Compose for Wear│    │ (GATT 0x180D)        │
   │ HKWorkoutSession│    │ Health Services │    │ Polar, Garmin-Broad- │
   └─────────────────┘    └─────────────────┘    │ cast, Wahoo, …       │
                                                 └──────────────────────┘
```

### Architekturprinzipien

- **Ports & Adapters (hexagonal):** Die Domain kennt keine Plattform. Jede externe Quelle (Watch, BLE, HealthKit, Eisbad, Cloud) ist ein austauschbarer Adapter hinter einem Port.
- **Local-first:** Jede Schreiboperation geht zuerst in SQLite. Sync ist ein nachgelagerter, abschaltbarer Prozess.
- **Abgeleitete statt gespeicherte Zustände:** Statistiken, Meilensteine und Zielfortschritte werden aus den Sessions berechnet (deterministisch, testbar). Gespeichert wird nur, was der Nutzer «erlebt» hat (z. B. dass eine Meilenstein-Animation gezeigt wurde).
- **Datengetriebene Inhalte:** Meilensteine und Wissensartikel sind versionierte JSON-/Markdown-Kataloge, nicht Code.
- **Feature-Module:** `session`, `history`, `milestones`, `goals`, `knowledge`, `profile`, `devices`, `sync`, `community`, `bath_device` – jedes mit eigener Domain-/Data-/UI-Schicht.

---

## 4. Projektstruktur (geplant)

```
SolarcticZen/
├── docs/                        Diese Dokumente
├── app/                         Flutter-App
│   ├── lib/
│   │   ├── core/                Designsystem, Theme, i18n, Utilities, Result-Typen
│   │   ├── domain/              Entities, SessionClock, Stats-, Milestone-, Goal-Engine
│   │   ├── data/                drift-Datenbank, Repositories, Migrations
│   │   ├── platform/            Pigeon-generierte Brücken (Health, Watch, LiveActivity)
│   │   └── features/<modul>/    UI + Application-Logik je Funktionsbereich
│   ├── assets/
│   │   ├── milestones/catalog.v1.json
│   │   └── knowledge/{de,en}/*.md
│   ├── ios/                     Runner + Native Targets (Widget, Live Activity, Intents)
│   ├── android/                 Runner + Foreground Service, Health Connect, Glance
│   ├── pigeons/                 Schnittstellendefinitionen für native Brücken
│   └── test/                    Unit-, Widget-, Golden-, Integrationstests
├── watch/                       watchOS-App (SwiftUI) – im Xcode-Workspace der iOS-App eingebunden
├── wear/                        Wear-OS-App (Kotlin/Compose) – Phase 4b
├── backend/                     Supabase: SQL-Migrationen, RLS-Policies, Edge Functions
└── content/                     Quellen und Review-Protokolle für den Wissensbereich
```

---

## 5. Zentrale Komponenten

### 5.1 SessionClock – zuverlässiger Timer

- Beim Start wird **sofort** eine Session mit `status = active`, `started_at` (UTC) und `tz_id` in SQLite geschrieben.
- Die angezeigte Zeit wird immer berechnet: `elapsed = now − started_at − Σ Pausen`. Es gibt keinen hochzählenden Zähler, der bei Suspendierung «stehen bleibt».
- **App beendet / abgestürzt / Akku leer:** Beim nächsten Start findet die App die aktive Session und bietet «Fortsetzen» oder «Beenden um …» (mit wählbarer Endzeit) an.
- **iOS gesperrt/Hintergrund:** Live Activity mit systemseitig laufendem Timer (`Text(timerInterval:)`), der ohne App-Updates weiterläuft. Intervall- und Sicherheitshinweise werden beim Start als lokale Benachrichtigungen vorgeplant (funktionieren auch, wenn die App suspendiert ist) und beim Beenden storniert.
- **Android:** Foreground Service (Typ `health`) mit laufender Benachrichtigung (Chronometer) und Stopp-Aktion.
- **Zeitzonen:** Speicherung in UTC + IANA-Zeitzone des Startorts; `local_date` (Kalendertag) wird beim Start festgelegt. Wochen nach ISO 8601 (Montag). Eine Session über Mitternacht zählt zum Starttag. Sommerzeit-Wechsel sind dadurch unkritisch. Tests decken DST-Übergänge, Zeitzonenwechsel (Reise) und manuelle Uhrzeitänderungen ab.
- **Dateischutz iOS:** Die Datenbank verwendet `NSFileProtectionCompleteUntilFirstUserAuthentication`, damit während einer Session bei gesperrtem Gerät geschrieben werden kann (bei `Complete` würden Schreibzugriffe im gesperrten Zustand fehlschlagen).

### 5.2 Herzfrequenz-Abstraktion

```dart
abstract interface class HeartRateSource {
  String get id;                       // z. B. "apple_watch", "ble:AA:BB:..", "health_connect"
  HeartRateCapabilities get capabilities;   // live? gepuffert? nur nachträglich?
  Stream<HeartRateSample> live();      // nur wenn capabilities.live
  Future<List<HeartRateSample>> fetch(DateTimeRange range); // nachträgliche Synchronisation
  Stream<SourceStatus> status();       // verbunden, sucht, Signal verloren, Akku …
}

enum HeartRateProvenance { live, bufferedLive, syncedAfterwards, manual }
```

Jeder gespeicherte HF-Wert trägt seine **Herkunft**. Die UI zeigt das transparent an:
- **LIVE** – Wert kommt in Echtzeit (Watch-Workout, BLE-Sensor).
- **GEPUFFERT** – live gemessen, aber verzögert übertragen (z. B. Watch ausser Reichweite, nach der Session nachgeliefert).
- **SYNCHRONISIERT** – nachträglich aus Apple Health / Health Connect übernommen; Auflösung kann grob sein.

Adapter (Reihenfolge der Umsetzung): `AppleWatchWorkoutSource` → `BleHeartRateSource` (Standard-GATT) → `HealthKitSyncSource` / `HealthConnectSyncSource` → `WearOsWorkoutSource` → herstellerspezifische Adapter (Polar SDK, Garmin Connect IQ) bei Bedarf.

### 5.3 MilestoneEngine (datengetrieben)

Meilensteine werden als JSON-Katalog ausgeliefert (gebündelt, optional später per Remote-Update). Die Engine kennt eine kleine Zahl **Regeltypen**; neue Meilensteine entstehen durch neue Katalogeinträge ohne Code-Änderung. Details und Beispiel in `DATABASE_SCHEMA.md` §5. Neue *Regeltypen* erfordern Code, sind aber gekapselt (eine Klasse + Tests).

### 5.4 Wissensinhalte

Markdown-Dateien mit Front-Matter (`id`, `evidence_level`, `sources`, `unlock_rule`, `reviewed_by`, `reviewed_at`), je Sprache. Freischaltung über dieselbe Regelsprache wie Meilensteine (z. B. «nach 5 Sessions»). Inhalte durchlaufen vor Veröffentlichung eine fachliche Prüfung (siehe `FEATURES.md` §E).

### 5.5 Sync (Phase 5, Architektur jetzt vorbereitet)

- Alle IDs sind clientseitig erzeugte **UUIDv7** (zeitlich sortierbar, kollisionsfrei offline).
- Jede synchronisierbare Tabelle hat `updated_at`, `deleted_at` (Tombstone) und `version`.
- **Outbox-Muster:** Änderungen werden lokal in `sync_outbox` vermerkt und bei Verbindung übertragen; Pull über `updated_at`-Cursor.
- **Konflikte:** Last-Writer-Wins pro Datensatz (Daten gehören einem Nutzer; echte Konflikte entstehen nur bei Bearbeitung auf zwei Geräten). HF-Samples sind unveränderlich.
- Option zur späteren Prüfung: PowerSync (kompatibel mit Supabase) statt Eigenbau – Entscheidung in Phase 5 (ADR-009 offen).

---

## 6. Backend: Supabase vs. Firebase

| Kriterium | Supabase | Firebase |
|---|---|---|
| Datenmodell | PostgreSQL – relational, ideal für Statistiken, Ranglisten, Freundschaften, Challenges | Firestore – Dokumente; Aggregationen/Ranglisten umständlich und teuer |
| Datenschutz / Hoheit | EU-Region (Frankfurt) verfügbar; **Open Source, selbst hostbar** (z. B. später Schweizer Rechenzentrum) | EU-Regionen verfügbar, aber nicht selbst hostbar; Google als Auftragsverarbeiter |
| Zugriffsschutz | Row Level Security direkt in der DB | Security Rules (gut, aber eigene Sprache) |
| Offline | Kein eingebautes Offline – wir sind ohnehin local-first mit eigener DB | Sehr gutes Offline-SDK (würde aber eine zweite Datenhaltung neben SQLite bedeuten) |
| Lock-in | Gering (Standard-Postgres) | Hoch |
| Push | Kein eigener Dienst → APNs/FCM direkt oder via Edge Function | FCM integriert |

**Entscheidung: Supabase** (EU-Region zu Beginn, Selbst-Hosting als Exit-Option). Begründung: relationales Modell passt exakt zu den Community-Funktionen, RLS erzwingt Datentrennung auf DB-Ebene, und die Hoheit über Gesundheitsdaten ist für eine Schweizer Premium-Marke ein Argument. Push-Nachrichten über APNs/FCM (FCM nur als Transport, keine Analytics).

**Wichtig:** Für Tracking, Statistik, Meilensteine, Apple-Health-Integration und Export ist **kein Backend nötig**. Das MVP kommt ohne Account aus.

---

## 7. Externe Schnittstellen – Übersicht

| Schnittstelle | Zweck | Live / nachträglich | Phase | Bemerkung |
|---|---|---|---|---|
| **Apple HealthKit** | Session als Workout schreiben, HF lesen/schreiben, Atemübung als Achtsamkeitsminuten | nachträglich (Lesen), Schreiben sofort | MVP | Kein Workout-Typ «Eisbad» → `HKWorkoutActivityType.other` + Metadaten (vor Umsetzung prüfen, ob neuere iOS-Versionen passendere Typen bieten). |
| **HKWorkoutSession (watchOS)** | Live-HF ~ jede 1–5 s während Session | **live** | 4 | Kernstück der Watch-Integration. |
| **Workout-Mirroring (iOS 17+)** + **WatchConnectivity** | Watch-Session aufs iPhone spiegeln, Werte übertragen, Start/Stopp von beiden Geräten | live / gepuffert | 4 | Fallback `transferUserInfo` für nachträgliche Übertragung. |
| **HKWorkoutSession auf dem iPhone (seit iOS 26)** | iPhone-Workout mit BLE-Sensor ohne Watch | live | 4 | Vor Umsetzung verifizieren; erweitert Optionen ohne Watch. |
| **ActivityKit (Live Activities, Dynamic Island)** | Laufende Session im Sperrbildschirm | – | MVP+ | Timer läuft systemseitig weiter. |
| **WidgetKit** | Home-/Sperrbildschirm-Widgets (Woche, Streak, nächster Meilenstein) | – | P1 | Datenaustausch via App Group. |
| **App Intents** | Siri, Kurzbefehle, Action Button: «Eisbad starten/beenden» | – | P1 | Wichtig bei nassen Händen. |
| **UserNotifications / Android Notifications** | Erinnerungen, Intervall- & Sicherheitshinweise, Wochenrückblick | – | MVP/P1 | Rein lokal, kein Push nötig. |
| **Core Bluetooth / Android BLE** | Standard-HF-Sensoren (GATT Heart Rate Service `0x180D`, Messung `0x2A37`) | **live** | 4 | Polar H9/H10, Wahoo, Garmin «HF übertragen», viele weitere. |
| **Android Health Connect** | Sessions als `ExerciseSessionRecord`, HF als `HeartRateRecord` | nachträglich | MVP | Google-Play-Freigabe der Health-Berechtigungen nötig (Deklarationsformular). |
| **Wear OS Health Services + Data Layer API** | Live-HF auf Wear-OS-Uhren (inkl. Galaxy Watch, Pixel Watch) | **live** | 1.1 | Eigene Wear-OS-App nötig. |
| **Garmin** | a) HF-Broadcast als BLE-Sensor, b) Connect IQ App + Mobile SDK, c) Garmin Connect Developer Program (Health API) | a/b live, c nachträglich | a: 4, b/c: später | c) erfordert Bewerbung/Freigabe bei Garmin. Zusätzlich synchronisiert Garmin Connect Daten in Apple Health / Health Connect. |
| **Polar** | Polar BLE SDK (live), AccessLink API (nachträglich) | live / nachträglich | 4 (BLE-Standard), SDK optional | Standard-GATT reicht für HF; SDK nur für Zusatzfunktionen (z. B. internen Speicher des H10). |
| **Fitbit / Google** | Web API (nachträglich), über Health Connect | nachträglich | später | Kein Live-HF-SDK für Drittanbieter. Google stellt die Fitbit-Schnittstellen derzeit um – Status vor Umsetzung prüfen. |
| **Samsung Galaxy Watch** | via Wear-OS-App (live) oder Samsung Health → Health Connect (nachträglich) | beides | 4b | |
| **Supabase** (Auth, Postgres, Storage, Edge Functions) | Account, Sync, Community | – | 5 | Sign in with Apple ist Pflicht, sobald andere Social-Logins angeboten werden (App-Store-Richtlinie 4.8). |
| **APNs / FCM** | Community-Benachrichtigungen | – | 5 | |
| **Solarctic-Zen Eisbad** | Temperatur, Status, Steuerung | live | 6 | **Schnittstelle noch nicht definiert** – siehe §9. |

---

## 8. Apple Watch und Wearables – Einschätzung der Herausforderungen

### 8.1 Apple Watch

**Empfehlung: Eigenständige watchOS-App mit eigener Workout-Session – ja, eindeutig.**

- Nur eine aktive `HKWorkoutSession` sorgt für kontinuierliche HF-Messung im Sekundenbereich und hält die Watch-App im Vordergrund aktiv.
- Die Watch-App kann **autark** arbeiten (iPhone liegt oft am Beckenrand oder im Haus): Session starten, Timer, HF, haptische Intervalle, lokale Speicherung, spätere Übertragung.
- **Bedienung im Wasser:** Der Touchscreen ist nass und mit kalten Fingern kaum bedienbar. Steuerung über Digital Crown, Seitentaste und (Ultra) Action Button; Wassersperre beachten. Beenden per langem Drücken, nicht per kleinem Tap-Ziel.

**Herausforderungen:**
1. **Messqualität in der Kälte.** Optische Sensoren (PPG) messen die Durchblutung der Haut. Kälte verengt die Gefässe (Vasokonstriktion) → schwächeres Signal, Aussetzer, Fehlwerte. Werte müssen plausibilisiert (z. B. 30–220 bpm, Sprungfilter) und Lücken ehrlich als Lücken dargestellt werden – keine Interpolation, die Genauigkeit vortäuscht.
2. **Wasser und Funk.** Bluetooth (2,4 GHz) dringt kaum durch Wasser. Ist die Uhr oder ein Brustgurt untergetaucht, reisst die Verbindung zum iPhone ab. Lösung: Die Watch puffert lokal und überträgt nach dem Auftauchen bzw. nach der Session (Herkunft «GEPUFFERT»).
3. **Kälteschock-Reaktion.** In den ersten 1–3 Minuten sind starke HF-Sprünge physiologisch normal. Die Darstellung darf nicht alarmistisch wirken, aber auch keine Diagnose andeuten.
4. **Plattform-Lebenszyklus:** Mirroring, Wiederaufnahme nach Absturz (`recoverActiveWorkoutSession`), Synchronisation, wenn das iPhone ausser Reichweite ist – alles muss gezielt getestet werden (siehe `PROJECT_PLAN.md`, Teststrategie).
5. **Entwicklung nur mit Mac und echter Watch.** Simulator liefert keine realistischen Daten.

### 8.2 Weitere Wearables – ehrliche Einordnung

| Gerät / Plattform | Live-HF in unserer App möglich? | Wie | Aufwand |
|---|---|---|---|
| BLE-Brustgurt / Armband (Polar, Wahoo, Garmin HRM, Coros, …) | **Ja** | Standard-GATT, ohne Hersteller-SDK | gering |
| Garmin-Uhren | **Ja**, wenn der Nutzer «HF übertragen» aktiviert (bei vielen aktuellen Modellen) | wie BLE-Sensor | gering; Bedienhinweis nötig |
| Garmin (eigene Watch-App) | Ja | Connect IQ (Monkey C) + Mobile SDK | hoch – erst bei Nachfrage |
| Wear OS (Pixel, Galaxy Watch 4+) | **Ja** | eigene Wear-OS-App, Health Services | mittel–hoch |
| Polar-Uhren | teilweise (HF-Übertragung modellabhängig) | BLE / Polar SDK | gering–mittel |
| Fitbit | **Nein** (kein Live-Zugriff für Drittanbieter) | nachträglich via Health Connect / Web API | gering |
| Oura, die meisten Ringe | **Nein** | nachträglich via HealthKit/Health Connect/API | gering |
| WHOOP | teilweise (HF-Broadcast-Funktion) | wie BLE-Sensor | gering |

Fazit: **Mit Apple Watch + Standard-BLE + HealthKit/Health Connect deckt das MVP der Wearable-Phase den Grossteil der Nutzer ab.** Herstellerspezifische SDKs nur bei nachgewiesenem Bedarf.

---

## 9. Solarctic-Zen Eisbad-Integration (Modul `bath_device`)

**Es werden keine Schnittstellen erfunden.** Vorbereitet wird ein Port, der unabhängig vom späteren Transportweg ist:

```dart
abstract interface class BathDevice {
  Future<BathInfo> info();                 // Modell, Seriennr., Firmware
  Stream<BathTelemetry> telemetry();       // Ist-Temperatur, Status, Fehler
  Future<void> setTargetTemperature(double celsius); // nur wenn capability vorhanden
  Future<MaintenanceInfo> maintenance();   // Filter, Wasserwechsel, Betriebsstunden
  Set<BathCapability> get capabilities;
}
```

Mögliche Adapter (abhängig von der Hardware): BLE-GATT-Profil, lokales Netzwerk (mDNS + HTTP/MQTT), Hersteller-Cloud-API, oder ein OEM-Kühlaggregat mit eigener IoT-Plattform.

**Stand 2026-11-19:** Die Eisbäder haben eine Steuerelektronik mit WLAN/Bluetooth. Welches Protokoll sie spricht und ob es für Drittanbieter-Apps nutzbar ist, ist noch unbekannt.

**Vom Solarctic-Zen-Team benötigte Informationen:**
1. Gibt es heute eine Steuerelektronik mit Funkmodul? Hersteller/Typ des Kühlaggregats und des Controllers?
2. Transportweg (BLE, WLAN, beides), Firmware-Update-Fähigkeit, wer besitzt die Firmware?
3. Verfügbare Datenpunkte (Ist-/Soll-Temperatur, Pumpe, Filter, Ozon/UV, Fehlercodes) mit Einheiten und Abtastrate.
4. Authentifizierung/Kopplung (Pairing-Verfahren, Geräteschlüssel), Mehrbenutzer-Zugriff.
5. Gibt es eine Hersteller-Cloud? Dokumentation, Nutzungsbedingungen, Datenstandort.
6. Sicherheitsanforderungen an Fernsteuerung (z. B. darf die App nur bei lokaler Nähe Solltemperatur ändern?).
7. Testgeräte bzw. Entwicklerzugang.

Bis dahin: manuelle Temperatureingabe (mit Vorbelegung der letzten Messung) + ein `SimulatedBathDevice` für Entwicklung und Tests, klar als Simulation gekennzeichnet.

---

## 10. Sicherheit und Datenschutz (technische Umsetzung)

- **Einwilligungen** granular und protokolliert (Tabelle `consent`): Gesundheitsdaten-Erfassung, Apple Health/Health Connect (zusätzlich zum System-Dialog), Cloud-Sync, Community, Diagnosedaten.
- **Lokal:** OS-Verschlüsselung (iOS Data Protection, Android File-Based Encryption); Tokens im Keychain/Keystore. SQLCipher als Option, falls Anforderungen strenger werden (zusätzliche Abhängigkeit, daher nicht im MVP).
- **Übertragung:** ausschliesslich TLS 1.2+; Certificate Pinning wird geprüft.
- **Server:** RLS auf jeder Tabelle (`user_id = auth.uid()`), getrennte Schemata für private und geteilte Daten; HF-Rohdaten werden nur bei aktiviertem Sync übertragen; Community sieht nie HF-Daten.
- **App-Store-Regeln:** HealthKit-Daten nicht für Werbung, nicht in iCloud speichern (Richtlinie 5.1.3); Datenschutz-Labels/Data-Safety-Formulare korrekt ausfüllen.
- **Löschen & Export:** «Alle Daten löschen» (lokal + Server + Storage) und Export (CSV/JSON, PDF-Bericht) ohne Account.
- **Keine Medizinprodukt-Funktionen:** keine Diagnosen, keine Grenzwert-«Warnungen» mit medizinischem Anspruch. Hinweise sind allgemeine Sicherheitsempfehlungen. Damit bleibt die App ausserhalb der Medizinprodukte-Regulierung (MepV/MDR) – vor Launch juristisch bestätigen lassen.
- **Telemetrie:** Keine Tracking-SDKs. Crash-Reporting nur opt-in (Anbieterwahl in Phase 3, bevorzugt EU-gehostet).

---

## 11. Technologie-Stack (minimal gehalten)

| Bereich | Wahl | Begründung |
|---|---|---|
| App | Flutter (stable), Dart 3 | siehe §2 |
| State Management | Riverpod | testbar, kompilierzeitsicher, verbreitet |
| Navigation | go_router (offizielles Flutter-Paket) | Deep Links (Widget/Intents → Screen) |
| Lokale DB | drift (SQLite) | typsichere Queries, Migrationen, reaktive Streams, testbar ohne Gerät |
| Native Brücken | Pigeon (offiziell) | typsicher, keine Fremd-Plugins für HealthKit/Watch |
| BLE | flutter_blue_plus | etabliert; hinter `HeartRateSource` gekapselt |
| Benachrichtigungen | flutter_local_notifications | |
| Charts | eigene CustomPainter-Komponenten (ggf. fl_chart als Basis) | Premium-Look, volle Kontrolle |
| PDF | `pdf`-Paket | lokal generiert, kein Server |
| i18n | flutter_localizations + ARB | DE/EN zum Start |
| Backend | Supabase (supabase_flutter) | ab Phase 5 |
| watchOS | Swift 6, SwiftUI, HealthKit, WatchConnectivity | |
| Wear OS | Kotlin, Compose for Wear OS, Health Services | |
| CI | GitHub Actions (Dart-Tests, Android) + Codemagic (iOS/watchOS-Build, Signierung, XCTest, TestFlight) | kein Mac vorhanden (ADR-015); Xcode Cloud bräuchte für die Einrichtung einen Mac |

Mindestversionen (Vorschlag, vor Release prüfen): iOS 17 / watchOS 10 (Workout-Mirroring), Android 9 (API 28) mit Health Connect.
