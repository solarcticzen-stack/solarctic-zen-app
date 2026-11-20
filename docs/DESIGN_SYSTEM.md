# Solarctic-Zen – Designrichtung und Designsystem

Status: **v0.2 (2026-11-19)** – an die Marke angepasst: Markenfarben **Schwarz / Weiss**, Schrift **Roboto**, Logo in `brand/` (schwarz und weiss, inkl. Bildzeichen ohne Schriftzug). Eisblau und Bernstein bleiben als sparsame, funktionale Akzente (ADR-023).

## 1. Leitidee: «Solar + Arctic»

Der Markenname enthält zwei Pole – **Kälte** und **Wärme**. Das Designsystem nutzt genau diese Spannung:

- **Arctic (Eisblau)** steht für das Bad selbst: Timer, Live-Daten, Wasser, Fokus.
- **Solar (warmes Bernstein)** steht für das Danach: Nachwärmen, Erfolge, Meilensteine, persönliche Entwicklung.
- Der Grossteil der Oberfläche ist ruhig, dunkel und reduziert – Akzentfarben werden sparsam und mit Bedeutung eingesetzt.

Gestalterische Prinzipien:
1. **Ruhe vor Reiz.** Wenige Elemente pro Screen, viel Raum, keine Konfetti-Effekte im Alltag.
2. **Ein Blick genügt.** Im Bad ist nur das Nötigste sichtbar: Zeit, HF, Temperatur, Beenden.
3. **Daten ehrlich zeigen.** Lücken bleiben Lücken; Herkunft der Daten ist sichtbar.
4. **Fortschritt statt Leistung.** Visualisierungen betonen Regelmässigkeit (Wochen, Ringe, Kalender) stärker als Rekorde.
5. **Premium durch Präzision.** Exakte Abstände, tabellarische Ziffern, weiche, physikalisch wirkende Animationen.

## 2. Farb-Tokens

**Markenbasis: Schwarz / Weiss.** Die Oberfläche ist monochrom; Farbe trägt Bedeutung:

| Rolle | Einsatz |
|---|---|
| **Primär** (Weiss auf Schwarz bzw. Schwarz auf Weiss) | Buttons, Auswahl, Start-Button, Tab-Auswahl, Wochenstreifen, Fortschritt |
| **Eisblau** (Arctic) | alles rund ums kalte Wasser: «IM WASSER», Temperatur, Vorlauf, Badezeit in der Zusammenfassung |
| **Bernstein** (Solar) | Erfolge, Meilensteine, Aufwärm-Impuls |
| Zustände | LIVE (grün), Hinweis (gelb), Fehler/Löschen (rot) |

### Dunkles Thema (Standard)
| Token | Wert | Verwendung |
|---|---|---|
| `bg.base` | `#000000` | App-Hintergrund (echtes Schwarz, OLED-freundlich, wie das Logo) |
| `bg.surface` | `#111111` | Karten |
| `bg.elevated` | `#1C1C1C` | Sheets, Dialoge |
| `border.subtle` | `#2A2A2A` | Trennlinien, Kartenränder |
| `text.primary` | `#FFFFFF` | |
| `text.secondary` | `#A3A3A3` | |
| `text.tertiary` | `#6E6E6E` | nur nicht-essentielle Labels |
| `accent.primary` / `on.primary` | `#FFFFFF` / `#000000` | Markenfarbe für Aktionen |
| `accent.ice` | `#7FD3F7` | kaltes Wasser |
| `accent.ice.deep` | `#2B9FD0` | Fortschritt «Halten zum Beenden» |
| `accent.glacier` | `#C9EEFA` | Vorlauf-Zahl |
| `accent.solar` | `#FFB066` | Erfolge, Aufwärmen |
| `state.live` / `state.caution` / `state.danger` | `#5BE3A8` / `#FFD166` / `#FF6B6B` | |

### Helles Thema
`bg.base #F5F5F5`, `bg.surface #FFFFFF`, `text.primary #000000`, `text.secondary #555555`, `accent.primary #000000` (Text darauf weiss), `accent.ice #076A94`, `accent.solar #9C5209` (abgedunkelt für Kontrast). Alle Text-, Akzent- und Primärfarben werden pro Thema automatisch auf ≥ 4.5 : 1 geprüft, Text auf Primärfarbe auf ≥ 7 : 1 (`app/test/core/design_system/tokens_test.dart`).

### Logo
- Dateien: `brand/logo_schwarz.webp`, `brand/logo_weiss.webp` (Originale), daraus erzeugt: App-Versionen und **Bildzeichen ohne Schriftzug** (`app/assets/brand/*_zeichen.png`).
- Dunkles Thema → weisses Logo, helles Thema → schwarzes Logo.
- Dashboard-Kopf: Bildzeichen + Wortmarke «SOLARCTIC-ZEN».
- App-Icon und Startbildschirm folgen, idealerweise aus Vektordaten (SVG/PDF).

### Datenvisualisierung
- **Kalender:** Badetage einheitlich in Primärfarbe gefüllt, **keine Abstufung nach Dauer** (würde längere Bäder optisch belohnen, ADR-024). Mehrere Bäder an einem Tag: kleine Zahl am Kreis. Heute: feiner Ring; ausgewählter Tag: Ring in Eisblau.
- **Diagramme** (je eine Reihe, daher keine Legende – der Titel benennt sie): Balken in Primärfarbe mit 4 px gerundetem Ende auf der Grundlinie, ≥ 2 px Abstand, Null-Wochen als kurze Marke auf der Grundlinie; Linien 2 px, Markierung nur am letzten bzw. ausgewählten Punkt (Ring in Flächenfarbe); Temperatur-Linie in Eisblau; zurückhaltendes Raster, eine Achse, Achsenbeschriftung unten nur erste/mittlere/letzte. Antippen oder Wischen zeigt Tooltip (+ Fadenkreuz bei Linien). Jedes Diagramm hat eine Screenreader-Zusammenfassung. Kontrast der Marken geprüft (≥ 3 : 1 auf Kartenfläche, hell und dunkel).
- Temperatur: kalt → weniger kalt als Eisblau-Skala (nicht Rot – Wärme ist hier kein «Gefahr»-Signal).
- Farbe ist nie alleiniger Bedeutungsträger (zusätzlich Form, Beschriftung, Muster).

## 3. Typografie

- **Schrift:** **Roboto** (Markenschrift von Solarctic-Zen), als variable Schriftdatei in der App enthalten (`app/assets/fonts/`, SIL Open Font License) – identisch auf iPhone, Android und im Browser.
- **Ziffern:** immer `tabular-nums` für Timer, Statistiken und Tabellen (springt nicht).

| Token | Grösse / Zeilenhöhe | Gewicht | Verwendung |
|---|---|---|---|
| `display.timer` | 96–120 / 1.0 (skaliert mit Bildschirmbreite) | 300 Light | Laufender Timer |
| `display.l` | 48 / 52 | 600 | Kennzahl-Hero (z. B. Gesamtzahl) |
| `title.l` | 28 / 34 | 600 | Screen-Titel |
| `title.m` | 20 / 26 | 600 | Kartentitel |
| `body` | 16 / 24 | 400 | Fliesstext |
| `body.s` | 14 / 20 | 400 | Sekundärtexte |
| `label` | 12 / 16, +4 % Laufweite, VERSALIEN | 600 | Kategorie-Labels, «LIVE» |

Unterstützt Dynamic Type / Schriftskalierung bis mind. 200 %; der Timer-Screen bleibt bei grossen Schriften lesbar (Layout bricht um, statt abzuschneiden).

## 4. Raster, Formen, Tiefe

- **Abstände:** 4-pt-Raster; Tokens `xs 4`, `s 8`, `m 12`, `l 16`, `xl 24`, `xxl 32`, `xxxl 48`. Seitenrand 20 (kleine Geräte 16).
- **Radien:** `r.s 10`, `r.m 16` (Karten), `r.l 24` (Sheets), `r.full` (Buttons, Chips).
- **Tiefe:** über Flächenhelligkeit statt Schlagschatten (dunkles Thema). Feine 1-px-Kante `border.subtle`.
- **Touch-Ziele:** min. 48 × 48 pt; im Timer-Screen min. 72 pt (nasse, kalte Finger).

## 5. Bewegung

| Token | Dauer | Kurve | Verwendung |
|---|---|---|---|
| `motion.fast` | 150 ms | ease-out | Zustandswechsel, Tap-Feedback |
| `motion.base` | 250 ms | ease-in-out (standard) | Screen-Übergänge, Karten |
| `motion.slow` | 450 ms | Feder (gedämpft) | Ringe füllen, Zahlen zählen hoch |
| `motion.celebrate` | 1.2–1.8 s | choreografiert | **nur** Meilenstein-Freischaltung |

- Atemübung: langsames «Atmen» eines Eiskristall-/Ring-Elements (4 s ein, 6 s aus o. ä.).
- Timer: sanft pulsierender Ring im HF-Rhythmus, wenn Live-HF verfügbar – deaktivierbar.
- «Bewegung reduzieren» des Systems wird respektiert (Überblendungen statt Bewegungen).
- Haptik: kurze, gleichförmige Impulse für Intervalle; deutlicher Doppelimpuls für Sicherheits-Obergrenze.

## 6. Komponenten (Bibliothek `core/design_system`)

| Komponente | Beschreibung |
|---|---|
| `SzButton` | Primary (Eisblau gefüllt), Secondary (Kontur), Ghost; Varianten `large` und `hold` (Gedrückt-halten mit Fortschrittsring, für «Beenden» ohne Fehlbedienung) |
| `SzCard` | Standardkarte mit Titel, optionalem Label und Aktion |
| `SzStatTile` | Kennzahl + Einheit + Trend (▲▼ ohne Wertung, neutral gefärbt) |
| `SzRing` | Fortschrittsring (Wochenziel, Meilenstein) |
| `SzBigTimer` | Timer mit tabellarischen Ziffern, auto-skalierend, Barrierefreiheits-Label |
| `SzHeartRateBadge` | aktueller Wert + Herkunfts-Chip `LIVE` / `GEPUFFERT` / `SYNC` / `–` + Verbindungsstatus |
| `SzTempChip` | Wassertemperatur mit Quelle (manuell/Gerät) |
| `CalendarView` | Monatsraster Mo–So, Monat wechseln (Zukunft gesperrt), Tap → Sessions des Tages, Monatszusammenfassung |
| `SzWeekStrip` | 7-Tage-Streifen für Dashboard |
| `SzBarChart` / `SzLineChart` | Balken (pro Woche), Linie (Dauer, Temperatur); später HF-Kurve mit Lücken |
| `SzMilestoneBadge` | gesperrt (Umriss), erreichbar (Fortschritt), erreicht (Solar-Verlauf) |
| `SzEvidenceTag` | «Gut belegt» / «Erste Hinweise» / «Unzureichend untersucht» |
| `SzFeelingScale` | 5-stufige Skala mit Symbolen + Text |
| `SzSafetyNote` | dezente, nicht alarmierende Hinweiskarte |
| `SzEmptyState` | Illustration + eine klare Handlung |

Jede Komponente erhält Golden-Tests (hell/dunkel, kleine/grosse Geräte, grosse Schrift).

## 7. Navigation

### Vorschlag (leicht angepasst gegenüber Briefing)

```
┌──────────────────────────────────────────────────────────────┐
│  Heute   Verlauf   ( ◉ Start )   Community   Erfolge   Wissen │
└──────────────────────────────────────────────────────────────┘
          Profil, Geräte, Einstellungen: Avatar oben rechts auf «Heute»
```

| Tab | Inhalt |
|---|---|
| **Heute** | Dashboard: Wochenring, letztes Eisbad, nächster Meilenstein, Kontextkarte, (später) Eisbad-Status |
| **Verlauf** | Segment: Kalender · Liste · Statistik |
| **◉ Start** (zentral, hervorgehoben) | Öffnet den Session-Ablauf als Vollbild – **kein** normaler Tab |
| **Community** (seit N-008) | Segment: Karte · Termine · Angebote · Chat; Profil/Einstellungen über den Avatar oben rechts |
| **Erfolge** | Segment: Meilensteine · Ziele (später: Challenges) |
| **Wissen** | Artikel nach Themen, freigeschaltete Beiträge, Sicherheit |

**Begründung der Änderungen:**
1. **Timer als Aktion statt Tab.** Eine Session ist ein Modus mit Anfang und Ende. Ein zentraler Start-Button (von überall erreichbar) ist schneller und verhindert, dass man versehentlich aus einer laufenden Session wegnavigiert. Während einer Session ist die Tab-Leiste ausgeblendet; verlässt man den Screen, bleibt eine «Session läuft»-Leiste sichtbar.
2. **Wissen als eigener Tab** statt versteckt – Wissen und Sicherheit sind Teil des Markenversprechens und differenzieren gegenüber reinen Timer-Apps.
3. **Profil oben rechts** – Einstellungen werden selten gebraucht und brauchen keinen permanenten Tab-Platz (Muster von Apple Fitness, Oura, Strava).

### Session-Ablauf (Vollbild)

```
Vorbereitung ──▶ (Atmung, optional) ──▶ Im Wasser ──▶ (Nachwärmen, optional) ──▶ Reflexion ──▶ Zusammenfassung
 Temperatur        2–3 min an Land       Timer, HF,     Timer + Hinweise          Empfinden,     ggf. Meilenstein-
 HF-Quelle-Status  ruhiges Atmen         Beenden         zum Aufwärmen            Notiz, Foto    Animation
```

- **Ein Tap bis zum Start:** «Start» → Vorbereitung ist vorausgefüllt (letzte Temperatur, Gerät) → «Ins Wasser».
- Jeder optionale Schritt ist mit einem Schalter dauerhaft abschaltbar.

### Timer-Screen (Skizze)

```
┌───────────────────────────────┐
│ ● LIVE  Apple Watch      4 °C │   ← Herkunft der HF, Temperatur
│                               │
│            02:47              │   ← display.timer, tabellarisch
│        ◯◯◯◯◯◯◯◯◯◯◯◯           │   ← Ring: Intervallmarken
│                               │
│          ♥ 118 bpm            │
│                               │
│  Aussteigen ist immer richtig │   ← SzSafetyNote, dezent
│                               │
│  [ Pause ]   [■ Halten zum ]  │   ← min. 72 pt, «Beenden» per Halten
│              [   Beenden   ]  │
└───────────────────────────────┘
```

- Bildschirm bleibt während der Session an (konfigurierbar), Helligkeit wird nicht verändert.
- Querformat und kleine Geräte (iPhone SE) werden explizit gestaltet und getestet.

### Heute (Skizze)

```
┌───────────────────────────────┐
│ Guten Morgen, Lea         (◎) │
│                               │
│  ╭─── Diese Woche ───╮        │
│  │   ◔  2 / 3        │  Mo–So │   ← SzRing + SzWeekStrip
│  ╰───────────────────╯        │
│                               │
│ [ Letztes Eisbad ]            │
│  Gestern · 3:10 · 6 °C · ♥ Ø 104
│                               │
│ [ Nächster Meilenstein ]      │
│  4 Wochen dabei  ▓▓▓▓▓░  3/4  │
│                               │
│ [ Neu im Wissen ]             │
│  Die ersten 60 Sekunden       │
│                               │
│      (  ◉  Eisbad starten  )  │
└───────────────────────────────┘
```

## 8. Apple Watch (Grundsätze)

- Ein Screen im Wasser: Zeit (gross), HF, Herkunftspunkt. Seitlich wischen: Temperatur, Pause.
- Bedienung über Digital Crown / Tasten; Start/Ende mit deutlicher Haptik.
- Farben identisch zu den Tokens, angepasst an OLED (echtes Schwarz `#000000` als Hintergrund auf der Watch).

## 9. Tonalität (Texte)

- Ruhig, respektvoll, «du»-Form (DE), keine Ausrufezeichen-Kaskaden.
- Lob für Konsistenz und Achtsamkeit, nie für Grenzüberschreitung.
- Keine Schuld: statt «Serie verloren» → «Willkommen zurück. Jede Woche ist ein neuer Anfang.»
- Keine Heilsversprechen (siehe Redaktionsprozess in `FEATURES.md`).
- Schweizer Rechtschreibung im Deutschen (ss statt ß).
