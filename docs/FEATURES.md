# Solarctic-Zen – Funktionsumfang und Priorisierung

Status: **Vorschlag v0.1 (2026-11-19)** · Alle Funktionen haben derzeit den Status *geplant*. Umsetzungsstand wird hier und im `DEVELOPMENT_LOG.md` nachgeführt.

## Priorisierung

| Stufe | Bedeutung |
|---|---|
| **P0** | MVP – ohne diese Funktion kein Release |
| **P1** | MVP-Ziel – soll ins erste öffentliche Release, kann notfalls kurz nachgeliefert werden |
| **P2** | Phase 4/5 – geplante Erweiterung |
| **P3** | Später / bei Nachfrage |

Statuswerte: `geplant` · `in Arbeit` · `fertig` · `getestet` · `verschoben`

---

## A. Eisbad-Session (Timer & Tracking)

| ID | Funktion | Prio | Phase | Hinweise |
|---|---|---|---|---|
| A1 | Session starten / pausieren / beenden, grosse Zeitanzeige | P0 | 3 | **fertig (Vorschau)** – inkl. Speicherung, Tests |
| A2 | Zuverlässiger Timer bei gesperrtem Gerät, im Hintergrund, nach App-Absturz | P0 | 3 | **in Arbeit** – Absturz-Wiederherstellung fertig; Sperrbildschirm-Anzeige (A10) fehlt |
| A3 | Wassertemperatur manuell (Vorbelegung: letzter Wert) | P0 | 3 | **fertig** · °F als Anzeigeoption P2 |
| A4 | Automatisches Speichern jeder abgeschlossenen Session | P0 | 3 | **fertig** (SQLite auf Geräten, Arbeitsspeicher in der Browser-Vorschau) |
| A5 | Session nachträglich bearbeiten / löschen | P0 | 3 | **fertig** – Detailansicht → Bearbeiten (Datum, Uhrzeit, Dauer, Temperatur, Empfinden, Notiz) und Löschen mit Rückgängig |
| A6 | Session manuell eintragen | P0 | 3 | **fertig** – «Nachtragen» im Verlauf oder am Kalendertag; Prüfung auf Zukunft, Überschneidung, Plausibilität (5 s – 60 min) |
| A7 | Subjektives Empfinden (5er-Skala) + Notiz | P0 | 3 | **fertig** (nachher); Vorher-Empfinden P1 |
| A8 | Intervall-Haptik/Ton (z. B. jede 30 s / 1 min) | P1 | 3 | Hilft ohne aufs Display zu schauen |
| A9 | Persönliche **Sicherheits-Obergrenze** (Hinweis bei Erreichen) | P0 | 3 | Bewusst kein «Ziel», sondern Schutz; siehe §Sicherheit |
| A10 | Live Activity / Dynamic Island (iOS), laufende Benachrichtigung (Android) | P1 | 3 | |
| A11 | Geführte Atem-/Entspannungsübung **vor** dem Einstieg (an Land) | P1 | 3 | Ruhige Atmung mit langer Ausatmung. **Keine Hyperventilations-Atmung** (Risiko Bewusstseinsverlust im Wasser) |
| A12 | Nachwärm-Phase mit Hinweisen (Afterdrop) | P1 | 3 | Optionaler zweiter Timer · erweitert durch A20 |
| A19 | **Vorlaufzeit vor dem Timerstart** (Notiz N-001) | P0 | 1 | **fertig** – Details siehe §K |
| A20 | **Aufwärm-Impuls nach dem Bad** mit wechselnder Übung, Erklärung und Animation (Notiz N-002) | P1 | 2/3 | **fertig (Vorschau)** – Erklärtext wartet auf Fachreview, Animationen sind Platzhalter bis zu CI-Illustrationen |
| A21 | **Einstiegs-Guide** (Notiz N-006): Schritt-für-Schritt beim Einstieg, prominent auf «Heute» (erste Bäder), in der Vorbereitung, im Wissen; Kurz-Hinweis während des Vorlaufs | P0 | 3 | **fertig (Entwurf)** · Formulierung «schmerzhaft, ich ziehe es durch» bewusst entschärft (Sicherheitsregel «Aussteigen ist immer richtig»); Fachreview ausstehend |
| A13 | Live-HF-Anzeige mit Herkunfts-Kennzeichnung (LIVE / GEPUFFERT / SYNC) | P0* | 4 | *P0 der Wearable-Phase |
| A14 | HF-Verlauf, Ø / min / max pro Session | P0* | 4 | |
| A15 | Fotos zur Session | P2 | 5 | Standardmässig nur lokal |
| A16 | Steuerung per Siri / Kurzbefehle / Action Button | P1 | 3 | Nasse Hände → Sprachsteuerung ist echter Mehrwert |
| A17 | Session-Vorlagen (z. B. «Morgenroutine: 2 min, Atmung an») | P2 | 5 | |
| A18 | Wassertemperatur automatisch vom Solarctic-Zen-Eisbad | P2 | 6 | abhängig von Geräteschnittstelle |

## B. Wearables

| ID | Funktion | Prio | Phase | Hinweise |
|---|---|---|---|---|
| B1 | Apple Health: Sessions als Workout schreiben, HF nachträglich lesen | P0 | 3 | Grundintegration im MVP |
| B2 | Eigene watchOS-App mit Workout-Session (Live-HF, autark nutzbar) | P0* | 4 | Kernfunktion Phase 4 |
| B3 | Watch ↔ iPhone: Mirroring, Start/Stopp von beiden Seiten, Pufferung | P0* | 4 | |
| B4 | Standard-BLE-HF-Sensoren (inkl. Garmin «HF übertragen», Polar, Wahoo) | P0* | 4 | |
| B5 | Android Health Connect | P0 | 3 | Android startet gleichzeitig mit iOS (F1) |
| B6 | Wear-OS-App (inkl. Galaxy Watch, Pixel Watch) | P1 | 1.1 | ca. 4–6 Wochen nach 1.0 (ADR-014) |
| B7 | Watch-Komplikation (Streak / Woche) | P2 | 4 | |
| B8 | Garmin Connect IQ / Garmin Health API | P3 | – | nur bei Nachfrage |
| B9 | Polar SDK (Zusatzfunktionen, z. B. Gurt-Speicher) | P3 | – | Grundfunktion über B4 |
| B10 | Geräteübersicht «Woher kommen meine Daten?» | P0* | 4 | Transparenz-Anforderung |

## C. Kalender, Historie, Statistik

| ID | Funktion | Prio | Phase | Status |
|---|---|---|---|---|
| C1 | Monatskalender mit Markierung der Badetage | P0 | 3 | **fertig** – einheitliche Markierung statt Abstufung nach Dauer (Sicherheit, ADR-024) |
| C2 | Tag antippen → Sessions des Tages | P0 | 3 | **fertig** |
| C3 | Chronologische Liste aller Sessions | P0 | 3 | **fertig** |
| C4 | Kennzahlen: Anzahl, Gesamtzeit, Ø-Dauer, längste Session, Ø-Temperatur, pro Woche/Monat | P0 | 3 | **fertig** |
| C5 | Diagramme: Sessions pro Woche, Dauer-Verlauf, Temperatur-Verlauf | P0 | 3 | **fertig** – Antippen/Wischen zeigt Werte, Screenreader-Zusammenfassung |
| C6 | Persönliche Bestwerte (inkl. «längste Serie aktiver Wochen») | P1 | 3 |
| C7 | Entwicklung: erste vs. letzte 30 Tage, Empfinden im Verlauf, Temperaturbereiche vergleichen | P1 | 3 | **teilweise** – Vergleich erste/letzte 30 Tage fertig (ab 60 Tagen Verlauf) |
| C8 | HF-Entwicklung (z. B. «Beruhigungszeit»: Zeit vom HF-Spitzenwert in der ersten Minute bis zur Stabilisierung) | P2 | 4 | 
| C9 | Jahresrückblick | P3 | 5 |

> C8 ist ein beschreibender, persönlicher Verlaufswert – **keine** Gesundheits- oder Fitnessbewertung. Formulierung und Berechnung werden vor Umsetzung fachlich geprüft.

## D. Meilensteine & Gamification

| ID | Funktion | Prio | Phase |
|---|---|---|---|
| D1 | Datengetriebener Meilenstein-Katalog (neue Meilensteine ohne Code-Änderung) | P0 | 3 | **fertig** (28 Einträge, 7 Regeltypen) |
| D2 | Freischalt-Animation, Erklärung, motivierende Botschaft | P0 | 3 |
| D3 | Kategorien: Routine, Anzahl, Gesamtzeit, Erfahrung (Temperatur), Achtsamkeit, Wissen | P0 | 3 |
| D4 | Verknüpfung Meilenstein → Wissensbeitrag | P1 | 3 |
| D5 | Persönliche Ziele (pro Woche/Monat, Gesamtzeit/Monat, Temperatur-Routine) | P0 | 3 |
| D6 | «Nächster Meilenstein» mit Fortschritt | P0 | 3 |
| D7 | Remote-Aktualisierung des Katalogs | P2 | 5 |

### Vorgeschlagener Start-Katalog (überarbeitet)

**Routine (höchste Gewichtung)**
- Erste Woche mit 2 Bädern · 3 aktive Wochen in Folge · 4 Wochen in Folge · 8 Wochen · 15 Wochen (≈ 100 Tage) · 26 Wochen · 52 Wochen
- 10 Sessions in einem Kalendermonat
- «Zurückgekehrt»: Routine nach mind. 3 Wochen Pause wieder aufgenommen *(belohnt Wiedereinstieg statt nur Durchhalten)*

**Anzahl:** 1, 5, 10, 25, 50, 100, 250, 500

**Gesamtzeit (kumuliert):** 10 min, 30 min, 60 min, 5 h, 10 h, 25 h

**Erfahrung (Temperatur):** erstes Bad unter 15 °C · unter 10 °C · unter 5 °C · Bad bei ≤ 2 °C *(siehe kritische Anmerkung)*

**Achtsamkeit:** 5 / 25 Sessions mit Atemübung · 10 Sessions mit Reflexion (Empfinden + Notiz)

**Wissen:** 3 / 10 Wissensbeiträge gelesen · Sicherheits-Grundlagen abgeschlossen

### Kritische Anmerkungen zum Anforderungskatalog

1. **«30 Tage / 100 Tage mit mindestens einem Eisbad pro Woche»** ist mehrdeutig. Vorschlag: in **aktiven Wochen in Folge** zählen (4 bzw. 15 Wochen). Das ist eindeutig, verständlich und kalendertauglich.
2. **Serien dürfen nicht bestrafen.** Vorgeschlagen werden Wochen- statt Tagesserien, plus **Pausen-Modus** (Krankheit, Ferien) ohne Serienverlust. Täglicher Druck widerspricht der Produktvision.
3. **Temperatur-Meilensteine** können zu riskantem Verhalten verleiten. Vorschlag: als «Erfahrung» rahmen, Freischaltung des ≤ 5 °C- und ≤ 2 °C-Meilensteins erst nach abgeschlossenen Sicherheits-Grundlagen, Botschaft betont Vorbereitung statt Mut. Optional ganz ausblendbar.
4. **Keine Meilensteine für Einzel-Dauer** (z. B. «10 Minuten am Stück»). Gesamtzeit wird kumuliert belohnt – das fördert Regelmässigkeit statt Grenzüberschreitung.
5. **Ranglisten** (Community) nur nach Regelmässigkeit (aktive Wochen, Anzahl Badetage), **nie nach Dauer oder Temperatur**.

## E. Wissensbereich

| ID | Funktion | Prio | Phase |
|---|---|---|---|
| E1 | Sicherheits-Grundlagen (Pflichtlektüre im Onboarding, kurz) | P0 | 3 | **fertig (Entwurf)** – im Onboarding und als Artikel |
| E2 | Artikel mit Evidenzstufe und Quellenangaben | P1 | 3 (Grundstock), 5 (Ausbau) | **Grundstock fertig** – 3 Artikel (Entwurf), Markdown-Format, weitere ohne Code-Änderung |
| E3 | Freischaltung von Beiträgen nach Meilensteinen | P1 | 3 | **fertig** – inkl. Hinweis «Neu im Wissen» nach dem Bad |
| E4 | Lesezeichen, «gelesen»-Status | P2 | 5 |

### Evidenzstufen (in der App sichtbar)

| Stufe | Bedeutung | Beispiele (vorläufig, fachlich zu prüfen) |
|---|---|---|
| **Gut belegt** | wiederholt und konsistent in Studien beim Menschen gezeigt | Kälteschock-Reaktion (Schnappatmung, HF- und Blutdruckanstieg in den ersten Minuten); deutlicher Anstieg von Noradrenalin bei Kaltwasser-Immersion; Risiken (Kälteschock, Herzrhythmusstörungen, Unterkühlung, Afterdrop) |
| **Erste Hinweise** | einzelne Studien, kleine Stichproben, teils widersprüchlich | Verbessertes subjektives Wohlbefinden/Stimmung kurz nach dem Bad; leichte Reduktion von Muskelkater nach Sport; Aktivierung von braunem Fettgewebe bei regelmässigen Winterschwimmern; weniger krankheitsbedingte Abwesenheit (Kaltdusch-Studie) |
| **Unzureichend untersucht** | Hypothesen, Tierstudien, Anekdoten | «Stärkt das Immunsystem», Gewichtsreduktion, Behandlung von Depressionen, Langlebigkeit, «Entgiftung» |

Zusätzlich gehört in den Wissensbereich, was Kälte *abschwächen* kann: Regelmässige Kaltwasser-Immersion direkt nach Krafttraining kann langfristige Muskel- und Kraftzuwächse dämpfen (Roberts et al., 2015).

### Ausgangsliteratur (vor Veröffentlichung von Fachperson verifizieren)

- Tipton MJ, Collier N, Massey H, Corbett J, Harper M. *Cold water immersion: kill or cure?* Experimental Physiology, 2017.
- Esperland D, de Weerd L, Mercer JB. *Health effects of voluntary exposure to cold water – a continuing subject of debate.* International Journal of Circumpolar Health, 2022.
- Cain T, Brinsley J, Bennett H, et al. *Effects of cold-water immersion on health and wellbeing: a systematic review and meta-analysis.* PLOS ONE, 2025.
- Šrámek P, Šimečková M, Janský L, et al. *Human physiological responses to immersion into water of different temperatures.* European Journal of Applied Physiology, 2000.
- Shattock MJ, Tipton MJ. *'Autonomic conflict': a different way to die during cold water immersion?* Journal of Physiology, 2012.
- Søberg S, Löfgren J, Philipsen FE, et al. *Altered brown fat thermoregulation and enhanced cold-induced thermogenesis in young, healthy, winter-swimming men.* Cell Reports Medicine, 2021.
- Machado AF, Ferreira PH, Micheletti JK, et al. *Can water temperature and immersion time influence the effect of cold water immersion on muscle soreness? A systematic review and meta-analysis.* Sports Medicine, 2016.
- Bleakley C, McDonough S, Gardner E, et al. *Cold-water immersion (cryotherapy) for preventing and treating muscle soreness after exercise.* Cochrane Database of Systematic Reviews, 2012.
- Roberts LA, Raastad T, Markworth JF, et al. *Post-exercise cold water immersion attenuates acute anabolic signalling and long-term adaptations in muscle to strength training.* Journal of Physiology, 2015.
- Buijze GA, Sierevelt IN, van der Heijden BCJM, et al. *The effect of cold showering on health and work: a randomized controlled trial.* PLOS ONE, 2016.
- Kox M, van Eijk LT, Zwaag J, et al. *Voluntary activation of the sympathetic nervous system and attenuation of the innate immune response in humans.* PNAS, 2014.

**Redaktionsprozess:** Jeder Artikel hat Autor, fachlichen Reviewer (Arzt/Ärztin oder Sportwissenschaftler/in), Review-Datum und Quellen. Keine Veröffentlichung ohne Review. Formulierungen wie «kann», «Studien deuten darauf hin», nie «heilt», «garantiert», «stärkt nachweislich».

### Geplante Artikel (Arbeitstitel) und Freischaltung

| Artikel | Freischaltung |
|---|---|
| Sicher ins Eisbad: Die 10 wichtigsten Regeln | Onboarding |
| Die ersten 60 Sekunden: Kälteschock verstehen | 1. Session |
| Was passiert im Körper bei Kälte? | 5 Sessions |
| Anpassung: Was regelmässige Kälte verändert – und was nicht | 10 Sessions |
| Herz und Kreislauf im kalten Wasser | erste Session mit HF |
| Nervensystem, Stresshormone und Stimmung | 3 aktive Wochen in Folge |
| Nachwärmen und Afterdrop | 5 Sessions |
| Eisbad und Sport: Timing ist entscheidend | 25 Sessions |
| Was die Forschung (noch) nicht weiss | 50 Sessions |
| Die eigene Routine aufbauen | frei |
| Wer sollte nicht oder nur nach ärztlicher Rücksprache eisbaden? | frei, im Onboarding verlinkt |

## F. Dashboard (Home)

| ID | Funktion | Prio | Phase |
|---|---|---|---|
| F1 | Grosser «Eisbad starten»-Button | P0 | 3 |
| F2 | Diese Woche (Ring: Sessions vs. Wochenziel), letztes Eisbad, Gesamtzahl, Gesamtzeit | P0 | 3 |
| F3 | Nächster Meilenstein mit Fortschritt | P0 | 3 |
| F4 | Kontextuelle Karte (neuer Wissensbeitrag, Erinnerung, Rückblick) | P1 | 3 |
| F5 | Eisbad-Status (Temperatur), sobald Gerät verbunden | P2 | 6 |

## G. Ziele, Erinnerungen, Benachrichtigungen

| ID | Funktion | Prio | Phase |
|---|---|---|---|
| G1 | Persönliche Ziele mit Fortschrittsanzeige | P0 | 3 |
| G2 | Individuelle Erinnerungen (Wochentage, Uhrzeit) | P1 | 3 |
| G3 | Benachrichtigung bei Meilenstein | P1 | 3 |
| G4 | Wöchentlicher Rückblick (lokal erzeugt) | P1 | 3 |
| G5 | Ruhige Tonalität: keine Schuld-Botschaften («Du hast deine Serie verloren!») | P0 | 3 |

## H. Profil, Daten, Plattform

| ID | Funktion | Prio | Phase |
|---|---|---|---|
| H1 | Profil ohne Account (lokal) | P0 | 3 |
| H2 | Onboarding: Sicherheitsinfo, Einwilligungen, Ziele, Apple Health | P0 | 3 | **fertig** bis auf Apple Health (folgt mit der Health-Integration) |
| H3 | Dunkelmodus (Standard) + heller Modus | P0 | 3 |
| H4 | Deutsch + Englisch | P0 | 3 |
| H5 | Export CSV/JSON | P0 | 3 |
| H6 | PDF-Auswertung | P1 | 3 |
| H7 | Alle Daten löschen | P0 | 3 |
| H8 | Home-Widgets (iOS/Android) | P1 | 3 |
| H9 | Mehrere Profile auf einem Gerät (z. B. Familie mit gemeinsamem Eisbad) | P2 | 5 | Nur das Hauptprofil schreibt in Apple Health/Health Connect (Health-Daten gehören dem Gerätebesitzer) |
| H10 | Barrierefreiheit: Dynamic Type, VoiceOver/TalkBack, Kontraste | P0 | 3 |

## I. Account, Sync, Community (optional)

| ID | Funktion | Prio | Phase |
|---|---|---|---|
| I1 | Account (Sign in with Apple, Google, E-Mail-Link) | P2 | 5 |
| I2 | Cloud-Sync & Backup (opt-in) | P2 | 5 |
| I3 | Freunde, Fortschritte teilen (nur explizit geteilte Kennzahlen, nie HF) | P2 | 5 |
| I4 | Monatliche Challenges (Regelmässigkeit) | P2 | 5 |
| I5 | Ranglisten innerhalb von Freundesgruppen/Challenges | P3 | 5 |
| I6 | Erfolge als Bild teilen (Share Sheet, ohne Account) | P1 | 3 |

## J. Solarctic-Zen Geräteintegration

| ID | Funktion | Prio | Phase |
|---|---|---|---|
| J1 | Architektur-Port `BathDevice` + Simulator | P1 | 3 (nur Schnittstelle) |
| J2 | Ist-/Soll-Temperatur, Status | P2 | 6 |
| J3 | Temperatur während Session protokollieren | P2 | 6 |
| J4 | Eisbad vorbereiten (Solltemperatur, Zeitplan) | P2 | 6 |
| J5 | Filter-/Wartungsinformationen | P2 | 6 |
| J6 | Produktregistrierung / Garantie / Service-Kontakt | P3 | 6 | Ideen-Vorschlag: Mehrwert für Marke & Kundenbindung |

---

## K. Ideen-Eingang (Notizen des Solarctic-Zen-Teams)

Neue Notizen werden hier mit Datum erfasst, fachlich eingeordnet und einer Funktion (ID) und Etappe zugeordnet. Status: `neu` · `eingeplant` · `umgesetzt` · `zurückgestellt`.

| Nr. | Datum | Notiz (sinngemäss) | Funktion | Status |
|---|---|---|---|---|
| N-001 | 2026-11-19 | Wählbarer Modus mit z. B. 10 s Vorlauf, damit man das Handy hinlegen und in Ruhe einsteigen kann, bevor die Zeit läuft | A19 | umgesetzt |
| N-002 | 2026-11-19 | Nach dem Beenden: Aufforderung zum Aufwärmen mit z. B. 10 Kniebeugen, Liegestützen, Hampelmännern – jedes Mal etwas anderes, vor dem Anziehen; mit kurzer Erklärung warum und möglichst bildlicher Darstellung | A20 | umgesetzt (Text in Prüfung) |
| N-003 | 2026-11-19 | Die Notiz aus der Bewertung nach dem Bad ist nirgends mehr lesbar – beim Antippen einer Session in Kalender oder Liste soll sie sichtbar sein | A5 (Detailansicht) | umgesetzt |
| N-004 | 2026-11-19 | Profil beim ersten Start: Geschlecht, Grösse, Gewicht (freiwillig), «Warum Eisbaden?» als Mehrfachauswahl (Regeneration, geistiges Wohlbefinden, Abnehmen, Langlebigkeit, krankheitsbedingt, Schlaf, Krankheiten vorbeugen …). Passende Tipps je Ziel; bei Abnehmen Kalorienschätzung pro Bad; bei Wohlbefinden/Schlaf regelmässiger Fragebogen mit Verlauf als Diagramm | H2, P1–P5 (§L) | umgesetzt (Kalorien: Platzhalter) |
| N-005 | 2026-11-19 | Nach dem Bad drei Bewertungen 1–5 statt einer: Überwindung vorher, Erleben im Wasser (Durchhalten/Schmerz), Gefühl danach | A7 | umgesetzt |
| N-006 | 2026-11-20 | Eisbade-Guide «So steigst du ein», gut sichtbar am Anfang: mental einstellen, ruhig durch die Nase ein-/durch den Mund ausatmen, stehend tief einatmen, beim Hinsetzen langsam ausatmen (Lunge leer, wenn der Körper im Wasser ist), dann auf die Atmung konzentrieren – ist sie ruhig, ist es geschafft, danach geniessen | A21 | umgesetzt (Entwurf) |
| N-007 | 2026-11-20 | Wissensbereich starten, zunächst 2–3 Artikel (notfalls Platzhalter) | E1–E3 | umgesetzt: 3 Artikel + 8 geplante Themen |
| N-008 | 2026-11-20 | Community Hub: Chat, Karte mit Eisbädern (private Eisbäder von Mitgliedern, Vereine mit Terminen z. B. Winterschwimmen), Avatar/Anzeigename; Premium-Mitglieder können Orte, Termine und Angebote (z. B. Atem-/Kältekurse) eintragen und sich selbst präsentieren | §M | umgesetzt (lokal/Demo); Server offen (M7) |

### A19 – Vorlaufzeit vor dem Timerstart

- Einstellbar: **aus · 5 · 10 · 15 · 30 s** (Standard: 10 s), merkt sich die letzte Wahl; zusätzlich direkt im Start-Screen umschaltbar.
- Während des Vorlaufs: grosse Countdown-Zahl, Hinweis «Ruhig einsteigen», Abbrechen und «Jetzt starten» (überspringen) möglich.
- Letzte 3 Sekunden: kurzer Ton + Haptik je Sekunde, beim Start ein deutlicher Doppelton – damit man nicht aufs Display schauen muss (Handy liegt daneben).
- **Gemessen wird ab Ende des Vorlaufs**: `started_at` = Zeitpunkt, an dem der Countdown abläuft. Der Vorlauf selbst zählt nicht zur Badezeit.
- Auch der Vorlauf wird zeitstempel-basiert gerechnet (läuft korrekt weiter, wenn der Bildschirm sperrt).
- Später ebenfalls auf der Apple Watch / Wear OS.

### A20 – Aufwärm-Impuls nach dem Bad

**Ablauf:** Nach dem Beenden erscheint vor der Zusammenfassung ein Screen «Jetzt aktiv aufwärmen» mit **einer** Übung, die bei jeder Session wechselt (Rotation, keine direkte Wiederholung), z. B.:
10 Kniebeugen · 10 Hampelmänner · 8 Liegestütze (auch an der Wand) · 20 s Armkreisen · 30 s Marschieren an Ort · 10 Ausfallschritte · 20 s Schulterkreisen.
Optional: «Andere Übung», «Erledigt», «Überspringen». Die Übungen sind ein Katalog (`assets/warmup/catalog.json`) – neue Übungen ohne Code-Änderung.

**Darstellung:** kurze, ruhige Animation pro Übung (Loop, ohne Ton). Vorschlag: einheitliche Strichfiguren-/Silhouetten-Animationen im Markenstil, die eine Illustratorin/ein Illustrator nach CI erstellt. Bis dahin baue ich einfache animierte Piktogramme als klar gekennzeichnete Platzhalter.

**Sicherheit (wichtig):**
- Nach dem Eisbad ist der Boden oft nass und die Koordination kurzzeitig reduziert → Übungen mit geringem Sturzrisiko bevorzugen; Hampelmänner/Sprünge mit Hinweis «nur auf rutschfestem Untergrund».
- Immer sichtbar: «Nur wenn du dich gut fühlst. Bei Schwindel, starkem Zittern oder Unwohlsein: hinsetzen, abtrocknen, warm anziehen.» Sicherheit geht vor jedem Aufwärm-Prinzip.

**Erklärtext – fachliche Einordnung des Vorschlags «die Hautrezeptoren melden Wärme, dann arbeitet der Körper nicht im vollen Modus»:**
Die Idee dahinter ist bekannt (sie wird oft mit der Forscherin Susanna Søberg in Verbindung gebracht): Wer sich nach dem Bad aus eigener Kraft aufwärmt statt sofort mit heisser Dusche oder dicker Kleidung, lässt den Körper selbst Wärme erzeugen – über Muskelarbeit, Zittern und möglicherweise über braunes Fettgewebe. Die Formulierung muss aber vorsichtig sein, denn **das ist eine plausible Empfehlung mit ersten Hinweisen, kein gesicherter Effekt**. Entwurf für die App (zur Prüfung durch die Fachperson):

> **Warum aktiv aufwärmen?**
> Nach dem Eisbad sinkt deine Körperkerntemperatur oft noch ein paar Minuten weiter, weil kaltes Blut aus Armen und Beinen zurückfliesst («Afterdrop»). Bewegung erzeugt Wärme direkt in deinen Muskeln und hilft dir, dich sanft und aus eigener Kraft aufzuwärmen.
> Wärmst du dich sofort mit heisser Dusche oder dicker Kleidung auf, signalisieren die Kälterezeptoren der Haut schnell «warm» – der Körper muss dann selbst weniger Wärme produzieren. Erste Studien deuten darauf hin, dass gerade diese eigene Wärmeproduktion zu den Anpassungen an Kälte beiträgt. *Evidenzstufe: Erste Hinweise.*

Quellenbasis (zu verifizieren): Søberg et al., Cell Reports Medicine 2021; Tipton et al., Experimental Physiology 2017 (Afterdrop, Wiedererwärmung).

## L. Profil, Ziele, Tipps, Fragebögen (Notiz N-004)

| ID | Funktion | Prio | Status |
|---|---|---|---|
| P1 | Onboarding beim ersten Start: Willkommen → Über dich (Geschlecht, Grösse, Gewicht und Geburtsjahr freiwillig) → «Warum Eisbaden?» (Mehrfachauswahl) → Sicherheits-Grundlagen (bestätigen) → Einwilligung Gesundheitsdaten | P0 | **fertig** – Sicherheits-Bestätigung schaltet Kälte-Meilensteine frei |
| P2 | Profil später ändern (Kopf von «Heute») | P0 | **fertig** – inkl. Aufwärm-Impuls an/aus, Sicherheitshinweise erneut lesen |
| P3 | Tipps passend zu den gewählten Zielen (Katalog, Evidenzstufe, Fachreview) | P1 | **fertig (Entwurf)** – 14 Tipps, Karte «Tipp für dich»; Fachreview ausstehend |
| P4 | Ziel Abnehmen: Energie-Schätzung pro Bad | P1 | **Platzhalter 70 kcal** angezeigt in Bewertung, Details, Statistik (Entscheid 19.11.2026) – **vor Release durch geprüfte Formel ersetzen** |
| P5 | Ziel geistiges Wohlbefinden: WHO-5 alle 14 Tage; Ziel Schlaf: eigene Kurzfragen alle 14 Tage; Verlauf als Diagramm | P1 | **fertig** – Ausgangswert sofort, dann alle 14 Tage; Hinweis mit Telefon 143 bei WHO-5 ≤ 28 |

**Entscheide (19.11.2026):** Geburtsjahr freiwillig · WHO-5 (validiert, frei nutzbar – Lizenz und deutscher Wortlaut vor Release prüfen) alle 14 Tage · Schlaf mit eigenen Kurzfragen, als «nicht klinisch geprüft» gekennzeichnet · Kalorien vorerst Platzhalter.

**Abweichung vom Wunsch «Pflichtangaben»:** Geschlecht und Grösse haben eine Option «Keine Angabe». App-Store-Richtlinie 5.1.1 verbietet, Angaben zu verlangen, die für die Kernfunktion nicht nötig sind; zudem Datensparsamkeit (revDSG).

**Sicherheit/Verantwortung:**
- Ziel «krankheitsbedingt»: Hinweis auf ärztliche Begleitung; keine krankheitsbezogenen Tipps oder Versprechen.
- Ziel «Krankheiten vorbeugen» / «Abnehmen» / «Langlebigkeit»: Tipps nennen ehrlich die Evidenzlage («unzureichend untersucht»).
- WHO-5 mit sehr niedrigem Wert (≤ 28 von 100): keine Diagnose, aber ein unterstützender Hinweis, mit einer Fachperson zu sprechen, inkl. Die Dargebotene Hand (Telefon 143).

## M. Community Hub (Notiz N-008)

**Entscheide (20.11.2026):** Karte OpenStreetMap (flutter_map; für Release Kartenanbieter-Konto nötig, z. B. MapTiler) · Navigation mit 5 Bereichen + Start · private Eisbäder mit genauer Adresse · Eintragen von Orten, Terminen und Angeboten nur für Premium-Mitglieder.

| ID | Funktion | Status |
|---|---|---|
| M1 | Community-Profil: Anzeigename (mit Vorschlägen) + Avatar aus Symbol und Farbe; kein Foto-Upload (keine Bildmoderation nötig); eigene Einwilligung, getrennt von Gesundheitsdaten | umgesetzt (lokal, mit Demo-Daten) |
| M2 | Karte mit Orten: privates Eisbad, öffentlicher Badeplatz, Verein; Filter; Detailansicht | umgesetzt (lokal, mit Demo-Daten) |
| M3 | Termine (z. B. Winterschwimmen am See) mit Datum, Ort, Beschreibung | umgesetzt (lokal, mit Demo-Daten) |
| M4 | Angebote: Premium-Mitglieder präsentieren sich und ihre Dienste (Kurse, Coaching, Eisbad-Nutzung) | umgesetzt (lokal, mit Demo-Daten) |
| M5 | Community-Chat (ein gemeinsamer Kanal) | umgesetzt (lokal, mit Demo-Daten) |
| M6 | Melden und Blockieren (Pflicht laut App-Store-Richtlinie 1.2 für nutzergenerierte Inhalte), einfacher Wortfilter; Moderation durch Solarctic-Zen | umgesetzt (lokal, mit Demo-Daten) |
| M7 | Server (Supabase): Konten, Echtzeit-Chat, geteilte Karte, RLS, Moderations-Werkzeuge | **offen** – Supabase-Konto nötig; Schema-Entwurf in `backend/migrations/` |

**Sicherheit und Datenschutz:**
- Community ist freiwillig (eigene Einwilligung); Gesundheitsdaten (HF, Bewertungen, Fragebögen) werden nie geteilt.
- Private Adressen: beim Eintragen ausdrückliche Bestätigung; sichtbar nur für angemeldete Mitglieder, nicht öffentlich im Web.
- Angebote sind Inhalte der Anbieter; Hinweis, dass Solarctic-Zen sie nicht prüft. Kurse mit Hyperventilations-Atemtechniken: Hinweis «nie im oder am Wasser üben».
- Markennamen Dritter (z. B. «Wim Hof Methode») nur durch berechtigte Anbieter verwenden – Hinweis in den Nutzungsbedingungen.

**Premium-Status (Entscheid 20.11.2026, ADR-029): beide Wege, gleiche Rechte.**

| ID | Funktion | Status |
|---|---|---|
| M8 | Bildschirm «Premium»: erreichbar aus dem Premium-Hinweis und den Community-Einstellungen; erklärt beide Wege | umgesetzt |
| M9 | Eisbad registrieren über die Seriennummer (Vorprüfung in der App, Prüfung und Zuordnung auf dem Server: ein Eisbad = ein Konto, max. 10 Versuche pro Stunde) | App umgesetzt; Server-Funktion `social.claim_bath` im Entwurf; ohne Server ehrliche Meldung, nichts wird lokal freigeschaltet |
| M10 | Premium als Abo über App Store / Google Play (z. B. mit RevenueCat), Gutschrift serverseitig nach Prüfung der Store-Belege | **offen** – braucht Entwicklerkonten und Abo-Produkte; Knopf zeigt «Verfügbar mit dem App-Release» |

Der Demo-Schalter «Premium-Mitglied (Demo)» erscheint nur noch in der Browser-Vorschau.

**Offene Fragen an Solarctic-Zen:** Format der Seriennummern und wo sie stehen (Typenschild, Rechnung)? Gibt es eine Liste aller verkauften Eisbäder (für den Import)? Wie lange gilt Premium nach einem Eisbad-Kauf (unbefristet oder z. B. 2 Jahre)? Dürfen mehrere Personen eines Haushalts ein Eisbad nutzen? Abo-Preis?

## Sicherheit im Produkt (gilt für alle Bereiche)

- Onboarding: kurze Sicherheitsgrundlagen, Hinweis auf ärztliche Abklärung bei Herz-Kreislauf-Erkrankungen, Bluthochdruck, Raynaud-Syndrom, Schwangerschaft u. a. – ohne Diagnose oder «Freigabe» durch die App.
- Grundsätze in der App: nie allein, nie nach Alkohol, ruhig einsteigen, Kopf über Wasser, aussteigen bei Unwohlsein, langsam aufwärmen.
- Timer-Screen: dezenter, immer erreichbarer Hinweis «Aussteigen ist immer richtig».
- Sicherheits-Obergrenze (A9) vom Nutzer einstellbar, mit vorsichtigem Startwert für Anfänger; Erreichen wird **nicht** als Erfolg gefeiert.
- Kein Meilenstein, kein Ziel und keine Rangliste belohnt längere Einzelsessions oder tiefere Temperaturen als bisher.
- Bei auffälligen HF-Werten keine Interpretation, nur der allgemeine Hinweis, bei Unwohlsein auszusteigen.
