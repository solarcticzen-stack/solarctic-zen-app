# Solarctic-Zen – Entwicklungslog & Architekturentscheidungen

Neueste Einträge oben. Entscheidungen (ADR) mit Status: `vorgeschlagen` · `angenommen` · `ersetzt`.

---

## 2026-11-20 – Testen auf echten Geräten vorbereitet

**Ausgangslage:** Gründer-Team testet mit 1× iPhone und 1× Android. GitHub und Codemagic sind angelegt.

**Umgesetzt**
- Lokale Android-Werkzeuge auf D: (Java 21 Temurin, Prüfsumme geprüft; Android-SDK Plattform 36, Build-Tools 36.0.0, NDK 28.2; Gradle-Cache auf D:). Android-SDK-Lizenzen mit Zustimmung des Nutzers akzeptiert.
- Release-Signierung in `android/app/build.gradle.kts`: Codemagic-Schlüssel → lokale `key.properties` → sonst Debug-Schlüssel (nur für direkt installierte Test-APKs).
- `INTERNET`-Berechtigung im Haupt-Manifest (fehlte; ohne sie hätte die Karte in Release-Versionen nicht geladen).
- `codemagic.yaml`: neuer Workflow `android-internal` (App Bundle → Google Play «Interner Test»); TestFlight- und Android-Builds laufen nur bei einem Tag `beta-*`, Tests und Analyse vorher.
- Anleitung `docs/DEVICE_TESTING.md` (Konten, Upload-Schlüssel, Installation, Update-Ablauf).

**Entscheidungen**
- ADR-030 (angenommen): Verteilung über TestFlight (interne Tester) und Google Play «Interner Test», gebaut von Codemagic. Updates nur über Tags `beta-*`, damit der Code laufend gesichert werden kann, ohne jedes Mal auszuliefern. Den Android-Upload-Schlüssel erzeugt das Team selbst (Passwort bleibt beim Team).

---

## 2026-11-20 – Premium: Abo oder Eisbad-Kauf

**Entscheid des Nutzers:** Premium gibt es auf beiden Wegen – als In-App-Abo oder inklusive beim Kauf eines Solarctic-Zen-Eisbads.

**Umgesetzt (mit Tests)**
- Domäne `domain/premium/premium.dart`: Quellen (Abo, Eisbad), Berechtigungen mit optionalem Ablaufdatum, zusammengefasster Status, Vorprüfung der Seriennummer (Format noch offen: 6–32 Buchstaben/Ziffern, Leerzeichen/Bindestriche egal), Port `BathRegistration` mit ehrlicher Variante «ohne Server nicht möglich».
- Bildschirm «Premium» (`features/community/premium_screen.dart`): «Mit einem Solarctic-Zen Eisbad» (Seriennummer eingeben → Ergebnis: freigeschaltet / unbekannt / bereits verbunden / zu viele Versuche / erst mit Server) und «Als Abo» (Knopf «Verfügbar mit dem App-Release»). Erreichbar über «Premium freischalten» im Premium-Hinweis und in den Community-Einstellungen.
- Demo-Schalter nur noch in der Browser-Vorschau.
- Einstellungs-Sheet scrollbar (neuer Überlauftest fand 115 px bei grosser Schrift).
- Server-Entwurf: `social.premium_grants` (Quelle, Referenz, Ablauf, Widerruf), `private.bath_serials` (für Clients unsichtbar), `social.claim_bath()` (ein Eisbad = ein Konto, 10 Versuche/Stunde), `is_premium()` liest die Berechtigungen; Spalte `tier` entfällt. Abo-Gutschrift über Edge Function nach Store-Beleg (z. B. RevenueCat).

**Tests: 220 grün**, `flutter analyze` sauber.

**Entscheidungen**
- ADR-029 (angenommen): Zwei Premium-Quellen mit gleichen Rechten; geprüft wird ausschliesslich auf dem Server, die App schaltet nie selbst frei. Übertragung eines Eisbads (Weiterverkauf) über den Kundendienst.

**Offen (Fragen an Solarctic-Zen):** Seriennummern-Format und -Liste, Laufzeit beim Eisbad-Kauf, Haushalts-Nutzung, Abo-Preis. Für das Abo später: Apple- und Google-Entwicklerkonto, Abo-Produkte, ggf. RevenueCat-Konto.

---

## 2026-11-20 – Community Hub (N-008)

**Umgesetzt (lokal, mit klar gekennzeichneten Demo-Daten; mit Tests)**
- Neuer Tab **Community** (Navigation jetzt: Heute · Verlauf · ◉ Start · Community · Erfolge · Wissen). Segment: Karte · Termine · Angebote · Chat.
- **Beitritt:** Anzeigename mit 3 Vorschlägen (z. B. «Polarfuchs 27», Prüfung 3–24 Zeichen + Wortfilter), Avatar aus 8 Symbolen × 8 Farben (kein Foto → keine Bildmoderation), Community-Regeln bestätigen. Gesundheitsdaten werden nie geteilt.
- **Karte:** OpenStreetMap über `flutter_map` 8.3 + `latlong2`, eigene Namensnennung «© OpenStreetMap-Mitwirkende». Orte: privates Eisbad, Badeplatz, Verein; Filter; Marker und Liste; Details mit genauer Adresse.
- **Eintragen nur für Premium:** Orte (Punkt auf der Minikarte setzen; privates Eisbad mit Adresse nur mit ausdrücklicher Bestätigung), Termine (nur in der Zukunft), Angebote/Dienste (Kurs, Coaching, Eisbad-Nutzung, Sonstiges; Hinweis «Atemtechniken nie im oder am Wasser», Markennamen Dritter nur durch Berechtigte). Ohne Premium erklärt ein Dialog, wozu Premium nötig ist. In der Vorschau: Schalter «Premium-Mitglied (Demo)».
- **Chat:** ein gemeinsamer Kanal, max. 500 Zeichen, Wortfilter.
- **Melden und Blockieren** an jedem fremden Inhalt (App-Store-Richtlinie 1.2); blockierte Mitglieder verschwinden aus Chat, Karte, Terminen und Angeboten. «Alle Blockierungen aufheben» und «Community verlassen» (löscht das Community-Profil).
- Ehrlicher Hinweis «Vorschau ohne Server – Inhalte nur auf diesem Gerät».
- **Server-Entwurf** `backend/migrations/0001_community.sql` (Supabase, Schema `social`, RLS auf allen Tabellen, Schreiben nur mit Premium, Adresse nur mit Bestätigung) – noch nie ausgeführt.

**Gefunden und behoben**
- Überläufe auf iPhone SE mit grosser Schrift: Segment-Beschriftungen, Hinweisbanner, Titel «Community» (brach auf mehrere Zeilen um), Chat-Eingabe (Platzhalter umbrach auf 4 Zeilen).
- Vorschau zeigte keine Demo-Inhalte: Die Datenströme lieferten neuen Zuhörern den Stand nicht zuverlässig (`async*`-Generator im Web-Debug-Build). Jetzt eigener Controller, der jedem Zuhörer sofort den Stand schickt; Regressionstest ergänzt.
- Avatar-Tooltips waren englisch («star») → deutsch.

**Tests: 210 grün**, `flutter analyze` sauber. Vorschau geprüft: Beitritt, Karte mit OSM-Kacheln und Markern, Chat senden, Premium-Demo, Angebotsformular.

**Entscheidungen**
- ADR-025 (angenommen): Karte mit OpenStreetMap/`flutter_map` statt Google Maps – kein Konto und kein Schlüssel für die Entwicklung; für den Release ist ein Kachelanbieter mit eigenem Konto nötig (OSM-Kachelserver sind nicht für App-Last gedacht), z. B. MapTiler oder Stadia.
- ADR-026 (angenommen): Rollen Mitglied/Premium; nur Premium darf Orte, Termine und Angebote veröffentlichen, alle Mitglieder dürfen lesen, chatten, melden. Serverseitig durch RLS durchgesetzt, nicht nur in der App.
- ADR-027 (angenommen): Private Eisbäder mit genauer Adresse, aber nur mit ausdrücklicher Bestätigung und nur für angemeldete Mitglieder sichtbar.
- ADR-028 (angenommen): Navigation mit 5 Bereichen + Start (Community als eigener Tab).

**Offen:** Quelle des Premium-Status (In-App-Abo, Verifizierung beim Kauf eines Eisbads oder beides); Supabase-Konto für M7; Moderationsablauf (wer prüft Meldungen, in welcher Frist).

---

## 2026-11-20 – Einstiegs-Guide (N-006) und Wissensbereich (N-007)

**Einstiegs-Guide «So steigst du ein»** (`features/guide/entry_guide.dart`)
- 6 Schritte: Einstellen → Ruhig atmen (Nase ein, Mund aus) → Stehend tief einatmen → Beim Hinsetzen langsam ausatmen (Lunge leer, wenn der Körper bis zu den Schultern im Wasser ist, Kopf über Wasser) → Auf die Atmung konzentrieren (ruhig = geschafft) → Geniessen.
- **Bewusst entschärft:** «schmerzhaft, aber ich ziehe es durch» → «unangenehm, das ist normal und geht vorbei; du bleibst ruhig» plus fester Hinweis «Aussteigen ist immer richtig». Begründung: Sicherheitsregel, Warnsignale dürfen nicht übergangen werden.
- Gut sichtbar: oben auf «Heute» während der ersten 5 Bäder, in der Vorbereitung (kompakt), im Wissen; während des Vorlaufs Kurzhinweis «Stehend tief einatmen – beim Hinsetzen langsam ausatmen».
- Vorlauf-Bildschirm dabei scroll-/schrumpffähig gemacht (Test fand 170 px Überlauf auf iPhone SE mit grosser Schrift).

**Wissensbereich** (`domain/knowledge/article.dart`, `features/knowledge/`)
- Artikel als Markdown mit Kopfdaten (id, Titel, Zusammenfassung, Evidenz, Lesezeit, Freischalt-Meilenstein, Prüfstatus, Quellen) in `assets/knowledge/de/` + `index.json`. Neue Artikel ohne Code-Änderung.
- 3 Artikel (Entwurf, Quellen angegeben): «Sicher ins Eisbad» (immer), «Die ersten 60 Sekunden: Kälteschock verstehen» (nach dem ersten Bad), «Was passiert im Körper bei Kälte?» (nach 5 Bädern). Jeder Abschnitt mit Einordnung (gut belegt / erste Hinweise / unzureichend untersucht / Hypothese).
- 8 geplante Themen als Platzhalter («In Vorbereitung»).
- Gesperrte Artikel zeigen den freischaltenden Meilenstein; nach dem Bad erscheint «Neu im Wissen: …» in der Meilenstein-Karte.

**Tests: 188 grün.** Vorschau geprüft: Guide oben auf «Heute», Schritt 4 mit Sicherheitshinweis, Wissens-Tab mit gesperrten Beiträgen und Platzhaltern, Artikelansicht.

**Für die Fachperson:** Guide-Text, Sicherheitsartikel, die beiden Fachartikel und die Quellenangaben prüfen (u. a. Zahl «rund 530 Prozent» Noradrenalin bei Šrámek 2000 und deren Bedingungen).

---

## 2026-11-20 – Notizen N-004/N-005: Profil, Onboarding, Tipps, Fragebögen, drei Bewertungen

**Umgesetzt (mit Tests)**
- **Drei Bewertungen nach dem Bad (N-005):** Überwindung vorher, im Wasser, danach – in Bewertung, Formular, Detailansicht. 5 ist jeweils das Angenehmste (höher heisst nie «mehr ausgehalten»).
- **Datenbank Version 3:** neue Spalten `overcome_rating`, `during_rating`; Tabelle `questionnaire_results`. Migration 1 → 3 getestet.
- **Onboarding** beim ersten Start: Willkommen (Logo) → Über dich (Geschlecht/Grösse mit «Keine Angabe», Gewicht/Geburtsjahr freiwillig, Plausibilitätsprüfung) → Warum Eisbaden? (9 Ziele, Hinweis bei «krankheitsbedingt») → Sicherheits-Grundlagen (Bestätigung nötig) → Einwilligung (nötig). Die Sicherheits-Bestätigung schaltet die Meilensteine ≤ 5 °C frei.
- **Profil-Bildschirm** (Symbol oben rechts auf «Heute»): Angaben und Ziele ändern, Aufwärm-Impuls an/aus (wird im Ablauf beachtet), Sicherheitshinweise erneut lesen.
- **Tipp für dich:** täglich wechselnd passend zu den Zielen, mit Evidenzstufe und «Entwurf»-Kennzeichnung; bei «krankheitsbedingt» regelmässig der Arzt-Hinweis.
- **Energie (Ziel Abnehmen):** Platzhalter 70 kcal in Bewertung, Details und Statistik, überall als «Platzhalter» gekennzeichnet (austauschbar über `EnergyEstimator`).
- **Fragebögen:** WHO-5 (Ziele Wohlbefinden/Stress) und Schlaf-Kurzfragen (Ziel Schlaf), Ausgangswert sofort, dann alle 14 Tage; eine Frage pro Seite mit Zurück; Ergebnis 0–100; Verlaufsdiagramme in der Statistik. WHO-5 ≤ 50: sanfter Hinweis; ≤ 28: unterstützende Karte (keine Diagnose) mit Die Dargebotene Hand 143 und Notruf 144.
- Profil wird lokal als JSON in den Einstellungen gespeichert (`ProfileController`).

**Durch Tests gefunden und behoben:** Überläufe auf iPhone SE mit grosser Schrift im Verlauf-Kopf («Nachtragen»), in der Fragebogen-Kopfzeile und in der Tipp-Karte; Tipp-Karte verdrängte «Letztes Eisbad» → ans Ende des Dashboards verschoben.

**Tests: 171 grün.** Vorschau geprüft: komplettes Onboarding, Dashboard mit fälligen Fragebögen und Tipp, WHO-5-Bildschirm.

**Release-Blocker (neu):** Energie-Platzhalter durch geprüfte Formel ersetzen; Tipps, Sicherheitstexte und WHO-5-Wortlaut/Lizenz fachlich bzw. rechtlich prüfen.

---

## 2026-11-19 – Detailansicht, Bearbeiten und Nachtragen (A5, A6, Notiz N-003)

**Umgesetzt**
- **Detailansicht** einer Session (aus Liste und Kalender per Antippen): Badezeit, Uhrzeit von–bis, Temperatur, Empfinden mit Bezeichnung, Aufwärm-Übung (erledigt/übersprungen), Vorlauf, Pausen, Erfassungsart und die **vollständige Notiz** (N-003). Von hier: Bearbeiten, Notiz hinzufügen, Löschen mit Rückgängig.
- Listeneintrag zeigt eine einzeilige **Notiz-Vorschau**.
- **Formular** für Bearbeiten und Nachtragen: Datum (deutsche Datumsauswahl), Einstieg (24-h-Zeitauswahl), Dauer (± 1 min / ± 5 s, beschriftet), Temperatur, Empfinden, Notiz. Einstiege: «Nachtragen» im Verlauf-Kopf und an einem leeren Kalendertag (Tag vorbelegt).
- **Prüfung vor dem Speichern** (`domain/session/session_validation.dart`): nicht in der Zukunft, keine Überschneidung mit einem anderen Bad (mit Hinweis auf Datum/Uhrzeit des anderen), Dauer 5 s – 60 min (Plausibilitätsgrenze, keine Empfehlung).
- `IceSession.rescheduled`: Bleiben Start und Dauer gleich, bleiben Pausen erhalten; sonst durchgehende Badezeit, Kalendertag wird neu bestimmt. Sommer-/Winterzeit wird beim Nachtragen über den am jeweiligen Datum gültigen Offset berücksichtigt (`AppServices.localToUtc`).
- Gemeinsame Eingabe-Bausteine `SzTempPicker`, `SzFeelingScale` (`core/design_system/inputs.dart`).
- App-Sprache für System-Dialoge: Deutsch (Schweiz) über die im Material-Paket enthaltenen Übersetzungen – das zunächst hinzugefügte Paket `flutter_localizations` wurde wieder entfernt (nicht nötig).

**Durch Tests gefunden und behoben**
- Listeneintrag wurde auf dem iPhone SE mit grosser Schrift ~800 px hoch (Datum brach Zeichen für Zeichen um). Neu: Datum + Dauer in einer Zeile, Löschen nur noch in der Detailansicht. Test sichert die Höhe ab.
- In der Vorschau entdeckt: unklare Dauer-Knöpfe (jetzt «Min» / «± 5 Sek» beschriftet) und zu enger Abstand in der Detailtabelle.

**Tests: 136 grün.** Vorschau geprüft: Kalendertag → Nachtragen mit Empfinden und Notiz → Eintrag mit Notiz-Vorschau → Detailansicht mit vollständiger Notiz.

---

## 2026-11-19 – Kalender und Diagramme

**Umgesetzt**
- Verlauf mit drei Ansichten: **Kalender · Liste · Statistik** (Kalender ist Startansicht).
- Kalender: Monatsraster Mo–So, Monatswechsel (Zukunft gesperrt), Badetage gefüllt, mehrere Bäder als Zahl, Tag antippen → Sessions des Tages (mit Löschen), Monatszusammenfassung.
- Statistik: 8 Kennzahlen, **Eisbäder pro Woche** (12 Wochen, inkl. Null-Wochen), **Dauer je Eisbad** (letzte 30), **Wassertemperatur** (letzte 30 Messungen), **Erste vs. letzte 30 Tage** (ab 60 Tagen Verlauf, sonst Hinweis mit Restdauer).
- Eigene Diagramm-Bausteine `SzBarChart`/`SzLineChart` ohne zusätzliche Abhängigkeit, nach der Diagramm-Richtlinie (dünne Marken, eine Achse, selektive Beschriftung, Tooltip per Antippen/Wischen, Screenreader-Text). Farbkontrast mit dem Paletten-Validator geprüft (bestanden ≥ 3 : 1, hell/dunkel; die Kategorien-Prüfungen entfallen, da jedes Diagramm nur eine Reihe hat).
- Daten-Logik `domain/stats/history.dart` (Tageswerte, Monatsraster, Wochenwerte, Zeitreihen, Zeitraumvergleich) – rein, getestet.
- **Nur Browser-Vorschau:** Knopf «Beispieldaten laden (90 Tage)» mit erfundenen, klar gekennzeichneten Daten (`id` beginnt mit `demo-`), damit Kalender und Diagramme ohne lange Nutzung beurteilt werden können. Auf Geräten nie sichtbar (getestet).

**Entscheidung:** Badetage im Kalender werden nicht nach Dauer abgestuft (Abweichung vom ersten Designentwurf), damit längere Bäder optisch nicht belohnt werden (ADR-024).

**Tests: 118 grün** (neu: Monatsraster inkl. Jahreswechsel, Wochenwerte mit Lücken, Zeitreihen, Vergleich; Diagramm-Interaktion und Screenreader; Kalender-Navigation und Tagesauswahl; Statistik mit/ohne Daten; alle Verlauf-Ansichten ohne Überlauf auf iPhone SE inkl. 160 % Schrift). In der Vorschau mit Beispieldaten geprüft: Kalender, alle drei Diagramme, Tooltip mit Fadenkreuz, Vergleichstabelle.

| ADR | Entscheidung | Status | Kurzbegründung |
|---|---|---|---|
| 024 | Kalender markiert Badetage einheitlich, ohne Abstufung nach Dauer | vorgeschlagen | Sicherheitsregel: keine optische Belohnung längerer Einzelsessions |
| 025 | Eigene Diagramm-Bausteine statt Chart-Bibliothek | angenommen | wenige, einfache Diagrammtypen; volle Kontrolle über Markendesign und Barrierefreiheit; keine Abhängigkeit |

---

## 2026-11-19 – Roboto als Schriftdatei eingebunden

- Nach Freigabe heruntergeladen aus dem offiziellen Google-Fonts-Archiv (`github.com/google/fonts`, `ofl/roboto`): `Roboto[wdth,wght].ttf` (variable Schrift, alle Stärken in einer Datei, 489 KB) + Lizenz `OFL.txt` (SIL Open Font License 1.1 – Einbetten in Apps erlaubt).
- Abgelegt als `app/assets/fonts/Roboto-Variable.ttf` mit Lizenzdatei; in `pubspec.yaml` als Familie «Roboto» registriert. Damit sieht die App auf iPhone, Android und im Browser identisch aus.
- Nebeneffekt Datenschutz: Die Browser-Vorschau lädt die Schrift jetzt aus der App statt von Google-Servern (im Netzwerkprotokoll geprüft).
- Tests: Datei + Lizenz vorhanden, Schriftstärken w300/w400/w700 werden unterschiedlich dargestellt (wichtig bei variablen Schriften), Theme nutzt Roboto mit tabellarischen Ziffern. **100 Tests grün.**

---

## 2026-11-19 – Marke: Logos, Schwarz/Weiss, Roboto

**Eingang:** Logo schwarz und weiss (WebP, 2000 × 1923 px, transparent), Markenfarben Schwarz/Weiss, Schrift Roboto.

**Umgesetzt**
- Originale in `brand/`; daraus erzeugt (Python/Pillow, lokal): App-Logos (800 px) und Bildzeichen ohne Schriftzug (512 px) in `app/assets/brand/`, grosse Bildzeichen-Version in `brand/` für das spätere App-Icon.
- Palette auf Markenbasis umgestellt: Hintergrund echtes Schwarz, Grautöne neutral (vorher blaustichig), neue Rolle **Primär** = Weiss (dunkel) / Schwarz (hell) für Buttons, Auswahl, Start-Button, Tab-Auswahl, Wochenstreifen, Strichfiguren. Eisblau nur noch für kaltes Wasser, Bernstein für Erfolge (ADR-023).
- Ausgewählte Chips (Vorlauf) und Empfindungs-Skala in Primärfarbe statt Bernstein/Eisblau.
- Schrift im Theme auf Roboto gesetzt (Android/Browser sofort; iOS braucht die Schriftdateien in der App).
- Dashboard-Kopf: Bildzeichen + Wortmarke «SOLARCTIC-ZEN».
- Tests: Kontrast der Primärfarbe auf allen Flächen (≥ 4.5 : 1), Text auf Primärfarbe (≥ 7 : 1), Logo-Dateien vorhanden und registriert. **97 Tests grün.** In der Vorschau geprüft (Dashboard, Vorbereitung).

**Korrektur:** Die im letzten Bericht erwähnten «doppelten Klicks» in der Vorschau lagen an falsch umgerechneten Koordinaten im Browser-Werkzeug, nicht an der App.

**Offen:** Roboto-Schriftdateien für iOS einbinden (Download nach Freigabe); Logo als Vektordatei für App-Icon/Startbildschirm; App-Icon und Startbildschirm; Bundle-ID mit echter Domain.

| ADR | Entscheidung | Status | Kurzbegründung |
|---|---|---|---|
| 023 | Markenbasis Schwarz/Weiss mit Primärfarbe Weiss/Schwarz; Eisblau und Bernstein nur als funktionale Akzente (Wasser bzw. Erfolge) | vorgeschlagen | entspricht den Markenfarben; Farbe bleibt Bedeutungsträger statt Dekoration |

---

## 2026-11-19 – A20 Aufwärm-Impuls (Notiz N-002)

**Umgesetzt**
- Übungskatalog `assets/warmup/catalog.v1.json` (8 Übungen DE/EN: Kniebeugen, Hampelmänner, Liegestütze an der Wand, Liegestütze, Armkreisen, Marschieren, Ausfallschritte, Schulterkreisen) mit Rutsch-Kennzeichnung.
- `WarmupPicker`: «immer etwas anderes» – meidet die letzten 3 gezeigten Übungen; «Andere Übung» liefert nie die aktuelle. Verlauf in den Einstellungen.
- Neuer Schritt im Ablauf: Beenden → **Jetzt aktiv aufwärmen** → Reflexion. Anzeige: Übung, Animation, Anleitung, Rutsch-Hinweis (falls nötig), immer sichtbarer Sicherheitshinweis, aufklappbar «Warum aktiv aufwärmen?» mit Evidenzstufe «Erste Hinweise» und Kennzeichnung «Entwurf – fachliche Prüfung ausstehend». Aktionen: Andere Übung · Erledigt · Überspringen.
- Animierte Strichfiguren für alle 8 Übungen (eigene Zeichnung, keine Abhängigkeit), respektieren «Bewegung reduzieren». **Platzhalter** bis zu Illustrationen im CI.
- Session speichert gezeigte Übung + erledigt/übersprungen → **Datenbank-Schema Version 2** mit Migration; Test prüft, dass Daten aus Version 1 erhalten bleiben.
- Die Session ist bereits vor dem Aufwärmen als abgeschlossen gespeichert (geht bei Abbruch nicht verloren).

**Tests: 95 grün, Analyse ohne Befund.** In der Browser-Vorschau geprüft: Gedrückthalten → Aufwärm-Schritt, Übungswechsel, Animation (Hampelmann öffnet/schliesst), Rutsch-Hinweis, aufklappbare Erklärung.

**Gefunden und behoben:** doppelter Rutsch-Hinweis bei den Hampelmännern (Anleitung + Warnung).

**Offen:** Fachreview des Erklärtexts; Illustrationen nach CI; Einstellung «Aufwärm-Impuls aus» (folgt mit den Profil-Einstellungen); Meilenstein-Idee «10× aufgewärmt» (Daten sind jetzt vorhanden).

---

## 2026-11-19 – Etappe 1: Domain-Kern, Speicherung, Vorlauf

**Umgesetzt (alles mit Tests)**
- Domain: `LocalDate` (ISO-Wochen, Kalendertag aus UTC + Offset), UUIDv7-Generator, `IceSession`, `Countdown` (A19), `StatsEngine` (Anzahl, Gesamt-/Ø-/längste Dauer, Ø-/kälteste Temperatur, pro Woche/Monat, Wochenserien inkl. Pausen-Wochen), `MilestoneEngine` mit 7 Regeltypen, `GoalEngine` (pro Woche/Monat, Minuten pro Monat).
- Meilenstein-Katalog `assets/milestones/catalog.v1.json`: 28 Meilensteine DE/EN (Anzahl, Routine, Gesamtzeit, Erfahrung, Achtsamkeit). Kälte ≤ 5 °C nur nach Sicherheits-Grundlagen (`requires`).
- Speicherung: Port `SessionRepository`/`SettingsStore`; Adapter **SQLite (drift)** für iOS/Android und **In-Memory** für Tests + Browser-Vorschau. Ein gemeinsamer Vertragstest prüft beide. Datenbank-Constraint «höchstens eine aktive Session».
- Oberfläche: Vorbereitung (Wassertemperatur ±0.5 °C, «keine Angabe»; Vorlauf aus/5/10/15/30 s, gemerkt), Vorlauf-Screen (Abbrechen, Jetzt starten, Ton/Haptik in den letzten 3 s), Timer (Pause gespeichert), Reflexion (Empfinden 1–5, Notiz, neue Meilensteine), Dashboard mit echten Daten, Verlauf (8 Kennzahlen, Liste nach Monaten, Löschen mit Rückgängig), Erfolge (alle Meilensteine mit Fortschritt).
- **Absturz-Wiederherstellung**: Beim App-Start wird eine laufende Session erkannt → Fortsetzen / Jetzt beenden / Verwerfen.

**Entscheidungen / Abweichungen**
- Zeitzone: gespeichert werden UTC-Offset beim Start + Geräte-Kürzel (z. B. «CET»). Der IANA-Name (`Europe/Zurich`) braucht ein natives Plugin und folgt mit Etappe 3. Für Kalendertage genügt der Offset.
- Nächster Meilenstein auf dem Dashboard schlägt **nie** Temperatur-Meilensteine vor (Sicherheit). Durch Test entdeckt: Neue Nutzer bekamen zuerst «Doppelwoche» statt «Erstes Eisbad» vorgeschlagen → Reihenfolge jetzt nach Katalog.
- Neue Meilensteine erscheinen in **einer** kompakten Karte; vorher schoben mehrere Karten die Empfindungs-Abfrage aus dem Bild (durch Test entdeckt).
- Kein Riverpod: Streams aus dem Repository + ein `InheritedWidget` genügen derzeit (ADR-021).
- Neue Abhängigkeiten: `drift`, `drift_flutter` (App), `drift_dev`, `build_runner` (nur Entwicklung). Begründung: ADR-003.

**Tests: 81 grün, Analyse ohne Befund.** In der Browser-Vorschau geprüft: Dashboard, Vorbereitung, Vorlauf mit automatischem Start, Timer mit Temperatur.

**Noch offen in Etappe 1/2:** Sessions nachträglich bearbeiten (A5), manuell eintragen (A6, Domain fertig, UI fehlt), Ziele einstellen (UI), Kalenderansicht, Diagramme, A20 Aufwärm-Impuls, Englisch.

| ADR | Entscheidung | Status | Kurzbegründung |
|---|---|---|---|
| 021 | Vorerst kein State-Management-Paket; Repository-Streams + `AppServices` (InheritedWidget) | angenommen | weniger Abhängigkeiten; Riverpod bei wachsender Komplexität neu prüfen |
| 022 | Zeitzone in Etappe 1 als UTC-Offset + Kürzel, IANA-Name ab Etappe 3 (natives Plugin) | angenommen | Kalendertag ist bereits korrekt; keine native Abhängigkeit nötig |

---

## 2026-11-19 – Notizen N-001/N-002 aufgenommen

- Neuer Abschnitt «Ideen-Eingang» in `FEATURES.md` §K: Alle Notizen des Teams werden dort nummeriert, eingeordnet und einer Funktion zugewiesen.
- N-001 → **A19 Vorlaufzeit** (aus/5/10/15/30 s, Badezeit startet erst nach Ablauf, akustische/haptische Signale) – Etappe 1.
- N-002 → **A20 Aufwärm-Impuls** nach dem Bad (wechselnde Übung aus einem Katalog, Animation, Erklärtext). Erklärtext entworfen, aber als «Erste Hinweise» eingestuft und zur Prüfung durch die Fachperson markiert; Sicherheitshinweise (nasser Boden, Schwindel) ergänzt.

---

## 2026-11-19 – Etappe 0: Projektgerüst + erste klickbare Vorschau

**Umgebung**
- Projekt nach `D:\SolarcticApp\SolarcticZen` verschoben (C: voll). Alte Kopien auf C: entfernt.
- Flutter 3.50.0 (stable, Dart 3.14.0) in `D:\SolarcticApp\sdk\flutter`; Benutzervariable `PUB_CACHE=D:\SolarcticApp\sdk\pub-cache`; Flutter-`bin` im Benutzer-PATH. Flutter- und Dart-Analytics deaktiviert.
- Git-Repository initialisiert (Branch `main`, noch kein Commit, kein Remote). `.gitattributes` für LF-Zeilenenden.

**App (`app/`)**
- `flutter create` für iOS, Android und Web. Bundle-/Application-ID **`ch.solarcticzen.app`** (Platzhalter – vor Registrierung im Apple-/Google-Konto mit der echten Firmendomain abgleichen; danach kaum änderbar). Anzeigename «Solarctic-Zen».
- Web dient **nur als Vorschau-Plattform** zum Ausprobieren am Computer (ADR-019), nicht als Release-Ziel.
- Strengere statische Analyse (`strict-casts`, `strict-inference`, `strict-raw-types`, zusätzliche Lints).
- Neu: `domain/session/session_clock.dart` (ADR-004 umgesetzt), `core/design_system/` (Tokens, Theme, Halten-Button), `core/format/duration_format.dart`, `features/shell/` (Navigation nach ADR-010), `features/session/` (Timer-Screen).
- Funktioniert: Session starten, Timer, Pause/Weiter, Beenden per Gedrückthalten, Zusammenfassung. **Noch nicht:** Speichern, Temperatur, HF, Hintergrund-/Sperrbildschirm-Anzeige, alle anderen Tabs (als «Noch nicht umgesetzt» gekennzeichnet).
- Abhängigkeiten: nur `meta` (bereits Teil des Flutter-SDK) zusätzlich zur Vorlage.

**Tests: 24 grün, Analyse ohne Befund**
- SessionClock: Pausen, mehrere Pausen, Beenden (auch während Pause), zurückgestellte Systemuhr, Lokalzeit→UTC, Sommerzeit, ungültige Übergänge, Unveränderlichkeit.
- Design: WCAG-Kontrast aller Text-/Akzentfarben auf allen Flächen (hell + dunkel).
- Oberfläche: Navigation, Platzhalter-Kennzeichnung, Timer mit kontrollierbarer Uhr, kurzes Tippen beendet nicht, Halten beendet; kein Layout-Überlauf auf iPhone SE (auch mit 160 % Schrift) und grossem Smartphone.

**Durch Tests gefundene und behobene Fehler**
- Tab-Leiste dehnte sich über den ganzen Bildschirm (Inhalt verdeckt).
- Helles Thema: Eisblau und Bernstein unter WCAG AA (4.2 : 1) → abgedunkelt (`#076A94`, `#9C5209`). `DESIGN_SYSTEM.md` entsprechend angepasst.
- Überläufe auf schmalen Geräten/grosser Schrift: Halten-Button, Statuszeile, Pause-Button, Tab-Beschriftungen.

**CI/Build**
- `.github/workflows/ci.yml` (Format, Analyse, Tests, Android-Debug-Build) und `codemagic.yaml` (iOS) mit Flutter 3.50.0 – **beide noch nie ausgeführt**, da GitHub-/Codemagic-Konto fehlen.
- Android-Build lokal noch nicht möglich: Android-SDK + JDK fehlen (Installation auf D: nötig).

**Vorschau starten:** `tools\preview-web.cmd` → http://localhost:8080

| ADR | Entscheidung | Status | Kurzbegründung |
|---|---|---|---|
| 019 | Flutter-Web als reine Vorschau-Plattform zum Testen von Abläufen/Design am Computer | angenommen | Schnelles Feedback ohne Geräte und Konten; kein Release-Ziel |
| 020 | Zeitplan an Entwicklung mit Claude Code angepasst: Engpässe sind Feedback-/Testrunden, Konten und Store-Prüfungen, nicht Programmierzeit | angenommen | Personenwochen-Schätzung galt für ein klassisches Team |

---

## 2026-11-19 – Antworten F2 (Rest) bis F5

- **Testgeräte:** iPhone, Apple Watch, Android-Smartphone, Brustgurt/BLE-Sensor vorhanden → Feldtests im Eisbad für alle Live-HF-Wege möglich.
- **Konten:** noch keine; Team legt sie an → Checkliste `SETUP_ACCOUNTS.md` erstellt (D-U-N-S zuerst wegen Vorlaufzeit).
- **Team (F3):** Claude Code entwickelt und wartet zusammen mit dem Solarctic-Zen-Team. Folge: Projekt-`CLAUDE.md` mit verbindlichen Konventionen, damit jede neue Session denselben Standards folgt; Doku und ADRs sind die gemeinsame Gedächtnisstütze.
- **Fachprüfung:** Fachperson vorhanden → Redaktionsprozess aus `FEATURES.md` §E gilt: Claude Code erstellt Entwürfe mit Quellen, Veröffentlichung nur nach dokumentiertem Review.
- **Marke (F4):** vollständiges CI vorhanden → Design-Tokens in `DESIGN_SYSTEM.md` werden nach Erhalt der Unterlagen angepasst; bis dahin gelten sie als Platzhalter.
- **Eisbad (F5):** Steuerelektronik mit WLAN/Bluetooth vorhanden → Etappe 6 ist realistisch; technische Details des Herstellers werden benötigt (Fragenkatalog `TECHNICAL_ARCHITECTURE.md` §9).

| ADR | Entscheidung | Status | Kurzbegründung |
|---|---|---|---|
| 018 | Entwicklung durch Claude Code mit dem Team; Projekt-`CLAUDE.md` als verbindliche Arbeitsgrundlage | angenommen | Konsistenz über viele Sessions, einfache spätere Übergabe |

**Nächster Schritt:** Etappe 0 lokal starten (Flutter-SDK installieren, Projektgerüst, Tests), parallel Konten anlegen und CI-/Hardware-Unterlagen liefern.

---

## 2026-11-19 – Entscheidung F2: kein Mac, Cloud-Builds

**Antwort:** Es steht kein Mac zur Verfügung; iOS/watchOS werden über Cloud-Builds erstellt.

**Folgen**
- **Entwicklung auf Windows:** Dart-Domain, UI (Android-Emulator + headless Widget-/Golden-Tests) und Android-Native-Code vollständig lokal.
- **iOS-/watchOS-Builds in der Cloud:** Codemagic (unterstützt Flutter + native Xcode-Targets, automatische Signierung über App-Store-Connect-API-Schlüssel, Upload zu TestFlight, XCTest-Läufe im iOS- und watchOS-Simulator). Xcode Cloud scheidet aus, weil die Ersteinrichtung Xcode auf einem Mac voraussetzt.
- **Kein lokaler iOS-Simulator, kein Hot Reload auf iOS, kein Xcode-Debugger.** iOS-spezifischer Code (HealthKit-Brücke, Live Activity, Widgets, App Intents) wird ohne lokale Ausführung geschrieben und über CI-Builds, XCTest und TestFlight auf einem echten iPhone geprüft. Feedback-Schleife: ca. 15–30 min statt Sekunden.
- **Apple-Watch-App (Etappe 4) ist der kritische Punkt.** Workout-Session, Mirroring und Bluetooth-Abrisse lassen sich nur auf echten Geräten mit Live-Debugging effizient entwickeln. Ohne Mac ist das möglich (Builds via TestFlight auf die Watch, Diagnose über ein in die App eingebautes Protokoll), aber deutlich langsamer.
  **Empfehlung:** Für Etappe 4 einen Mac-Zugang einplanen – Miet-Mac in der Cloud (Remote-Desktop mit Xcode) oder ein Mac mini als einmalige Anschaffung. Ohne Mac +2–3 PW Puffer für Etappe 4.
- Plattform-Code wird so geschnitten, dass möglichst viel Logik in getestetem Dart bzw. in reinen Swift-Modulen liegt, die per XCTest im Simulator der CI laufen (ohne Gerät).
- Voraussetzungen, die vom Solarctic-Zen-Team angelegt werden müssen: Code-Repository (z. B. GitHub, privat), Apple Developer Program (Organisation), Google-Play-Konsole, Codemagic-Konto, App-Store-Connect-API-Schlüssel.

| ADR | Entscheidung | Status | Kurzbegründung |
|---|---|---|---|
| 015 | CI/CD: GitHub Actions (Dart-Tests, Android-Build) + Codemagic (iOS/watchOS-Build, Signierung, XCTest, TestFlight) | angenommen | Kein Mac vorhanden (F2) |
| 016 | Für Etappe 4 (Apple Watch) Mac-Zugang empfohlen (Miet-Mac oder Mac mini) | vorgeschlagen | Gerätenahe Watch-Entwicklung ohne Debugger ist langsam und risikoreich |
| 017 | In-App-Diagnoseprotokoll (lokal, exportierbar, ohne Gesundheitsdaten im Klartext) ab MVP | vorgeschlagen | Ersetzt fehlenden Debugger bei TestFlight-Tests; hilft später im Support |

---

## 2026-11-19 – Entscheidung F1: Android gleichzeitig mit iOS

**Antwort:** Android muss zum Launch gleichzeitig mit iOS verfügbar sein.

**Folgen**
- ADR-001 (Flutter + native Module) → **angenommen**. Rein native Entwicklung würde jede Funktion doppelt kosten.
- Neu ADR-014: Funktionsgleichheit iOS/Android zum Launch, mit einer bewusst benannten Ausnahme (Wear-OS-App in 1.1, siehe unten).
- Health Connect, Android-Foreground-Service und Android-Widgets wandern ins MVP (P0/P1).
- Die Freigabe der Health-Connect-Berechtigungen bei Google Play wird in Etappe 0 beantragt (Vorlaufzeit).
- Zeitplan: +2–3 PW für Android-spezifische Umsetzung und QA; 1.0 nach ca. 5 Monaten statt 4–5.

**Live-Herzfrequenz auf Android zum Launch:** Über Standard-Bluetooth-Sensoren (Brustgurte, Garmin «HF übertragen», Polar, WHOOP-Broadcast) – das funktioniert auf Android identisch wie auf iOS. Synchronisierte HF über Health Connect (u. a. Samsung Health, Fitbit, Garmin Connect).
Die eigene **Wear-OS-App** (Galaxy Watch, Pixel Watch) folgt in **1.1**, ca. 4–6 Wochen nach 1.0. Begründung: Sie ist das Gegenstück zur Apple-Watch-App, kostet aber zusätzlich 3–4 PW; den Launch daran zu koppeln, würde beide Plattformen verzögern. Kann auf Wunsch vorgezogen werden.

| ADR | Entscheidung | Status | Kurzbegründung |
|---|---|---|---|
| 001 | Flutter für die Smartphone-App, native Module für Gerätenahes | **angenommen** | Android und iOS gleichzeitig zum Launch (F1) |
| 014 | iOS und Android mit gleichem Funktionsumfang in 1.0; Ausnahme: Wear-OS-App in 1.1 | vorgeschlagen | Gleichzeitiger Launch ohne Verzögerung durch die zweite Uhren-Plattform |

---

## 2026-11-19 – Phase 1: Analyse & Konzeption

**Ausgangslage**
- Kein bestehender Code für Solarctic-Zen im Arbeitsverzeichnis gefunden; Projekt neu angelegt unter `SolarcticZen/`.
- Entwicklungsrechner: Windows 11, kein Flutter-SDK, kein Xcode. iOS/watchOS-Builds benötigen macOS (siehe F2).

**Erstellt**
- `TECHNICAL_ARCHITECTURE.md`, `FEATURES.md`, `DATABASE_SCHEMA.md`, `DESIGN_SYSTEM.md`, `PROJECT_PLAN.md`, dieses Log.

**Nächster Schritt**
- Antworten auf F1–F5 einholen, ADRs bestätigen, dann Etappe 0 (Setup).

### Architekturentscheidungen

| ADR | Entscheidung | Status | Kurzbegründung |
|---|---|---|---|
| 001 | Flutter für die Smartphone-App, native Module für Watch, Widgets, Live Activity, Intents, Health | angenommen (siehe Eintrag F1) | ~70 % gemeinsamer Code, eigenes Premium-Design auf beiden Plattformen; gerätenahe Teile sind ohnehin nativ. |
| 002 | Eigenständige watchOS-App (SwiftUI) mit `HKWorkoutSession` + Mirroring | vorgeschlagen | Einzige Möglichkeit für kontinuierliche Live-HF der Apple Watch |
| 003 | Local-first mit SQLite (drift); Cloud optional | vorgeschlagen | Offline-Tracking, Datenschutz, kein Account nötig |
| 004 | Timer basiert auf persistierten Zeitstempeln, aktive Session wird beim Start gespeichert | vorgeschlagen | Zuverlässigkeit bei Sperre, Hintergrund, Absturz |
| 005 | Zeit in UTC + IANA-Zeitzone; `local_date` beim Start fixiert; ISO-Wochen | vorgeschlagen | Korrekte Kalender bei DST und Reisen |
| 006 | HF-Werte tragen Herkunft (`live`, `buffered_live`, `synced`) | vorgeschlagen | Transparenz-Anforderung des Briefings |
| 007 | Meilensteine und Wissensinhalte als versionierte Kataloge; Zustände abgeleitet | vorgeschlagen | Erweiterbarkeit ohne Code-Änderung, Konsistenz bei Bearbeitung |
| 008 | Supabase (EU-Region, selbst hostbar) als Backend ab Phase 5 | vorgeschlagen | Relational, RLS, Datenhoheit, geringer Lock-in |
| 009 | Sync-Verfahren (Eigenbau Outbox vs. PowerSync) | offen | Entscheidung in Phase 5 |
| 010 | Navigation: Heute · Verlauf · (Start) · Erfolge · Wissen; Profil über Avatar | vorgeschlagen | Timer ist ein Modus, kein Tab; Wissen ist Markenkern |
| 011 | Wochen- statt Tagesserien, Pausen-Modus, keine Belohnung für Einzel-Dauer/Kälterekorde, Ranglisten nur nach Regelmässigkeit | vorgeschlagen | Sicherheit, kein Leistungsdruck |
| 012 | Keine Tracking-/Werbe-SDKs; Crash-Reports nur opt-in | vorgeschlagen | Gesundheitsdaten, App-Store-Richtlinien, Markenvertrauen |
| 013 | Atemübungen nur ruhig und an Land, keine Hyperventilations-Techniken vor dem Einstieg | vorgeschlagen | Risiko Bewusstseinsverlust im Wasser |
