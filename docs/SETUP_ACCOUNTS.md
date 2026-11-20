# Solarctic-Zen – Benötigte Konten (Checkliste)

Stand: 2026-11-19 · Wird vom Solarctic-Zen-Team angelegt. **Zugangsdaten, Passwörter und API-Schlüssel nie in den Chat oder ins Repository kopieren** – sie werden direkt im jeweiligen Dienst hinterlegt.

Gebühren und Bedingungen ändern sich gelegentlich – bitte beim Anlegen auf der Seite des Anbieters prüfen.

## Grundsatz: Kosten erst, wenn sie nötig sind

Zum **Programmieren** wird kein kostenpflichtiges Konto gebraucht. Kosten entstehen erst, wenn die App auf echten Geräten über die Stores getestet bzw. veröffentlicht wird.

| # | Konto | Kosten | Wann nötig | Ohne dieses Konto geht … / geht nicht … |
|---|---|---|---|---|
| 1 | **D-U-N-S-Nummer** | kostenlos | **jetzt beantragen** (Vorlaufzeit bis ca. 2 Wochen) | Voraussetzung für die Firmenkonten 2 und 3 |
| 2 | **GitHub** (Organisation, privates Repo) | kostenlos | sobald Code geteilt bzw. automatisch getestet werden soll (wenige Wochen) | Ohne: Code nur lokal auf D:, keine Sicherung ausser lokalem Git, keine automatischen Tests in der Cloud |
| 3 | **Codemagic** | kostenloses Kontingent | zusammen mit GitHub | Ohne: keine Kontrolle, ob die iOS-Version überhaupt kompiliert. Unsignierte iOS-Builds und Simulator-Tests gehen **ohne** Apple-Konto |
| 4 | **Apple Developer Program** (Organisation) | Jahresgebühr (ca. 99/Jahr) | **sobald die App erstmals auf dem iPhone/der Apple Watch getestet werden soll** – geplant gegen Ende der Etappe 1/Beginn MVP, also deutlich vor dem Release | Ohne: keine Installation auf iPhone oder Watch (ohne Mac gibt es keinen kostenlosen Weg dafür), kein TestFlight, keine echten Tests von Apple Health und Watch-Herzfrequenz |
| 5 | **App-Store-Connect-API-Schlüssel** | kostenlos (Teil von 4) | zusammen mit 4 | wird in Codemagic hochgeladen |
| 6 | **Google Play Console** (Organisation) | einmalige Gebühr (ca. 25) | erst für Play-Store-Beta mit externen Testern und für den Release; Health-Connect-Freigabe rechtzeitig vor dem Release beantragen | Ohne: Android-Tests auf eurem eigenen Android-Gerät per USB gehen vollständig, auch Health Connect im Entwicklungs-Build |

**Präzisierung zu Apple:** Die Gebühr ist nicht erst beim Release fällig. Weil kein Mac vorhanden ist, ist TestFlight der einzige Weg, die App auf euer iPhone und eure Apple Watch zu bringen – und TestFlight setzt das bezahlte Programm voraus. Bis dahin entwickle und teste ich auf Windows und Android.

Zusätzlich für die Store-Einträge (bis zur Beta):
- **Support-E-Mail-Adresse** (z. B. `app-support@…`)
- **Website-Seite für die Datenschutzerklärung** (URL ist Pflicht in beiden Stores; Text erstelle ich als Entwurf zur rechtlichen Prüfung)

**Schritt-für-Schritt für das Testen auf euren Geräten:** `docs/DEVICE_TESTING.md` (Stand 2026-11-20: GitHub und Codemagic angelegt). Supabase (Testprojekt, gratis) wird vorgezogen, damit ihr die Community gemeinsam testen könnt. Codemagic als **persönliches** Konto nutzen – nur dort gibt es die 500 Gratis-Minuten.

## Hinweise zum Anlegen

- **Apple:** Mit einer Firmen-Apple-ID anlegen (z. B. `apps@…`), nicht mit einer privaten. Als Organisation erscheint «Solarctic-Zen» als Anbieter im App Store.
- **Google Play:** Organisationskonto wählen. Neue *private* Konten müssen vor dem ersten Release einen längeren geschlossenen Test mit vielen Testern durchlaufen.
- **GitHub:** Vorschlag Repo-Name `solarctic-zen-app`.
- **API-Schlüssel:** In App Store Connect → Benutzer und Zugriff → Integrationen → Schlüssel erstellen (Rolle «App-Manager»). Die `.p8`-Datei **direkt in Codemagic** hochladen; sie kann nur einmal heruntergeladen werden.

## Später nötig

| Wann | Konto | Wozu |
|---|---|---|
| Etappe 4 (empfohlen) | Mac-Zugang (Miet-Mac oder Mac mini) | Effiziente Entwicklung der Apple-Watch-App (ADR-016) |
| Etappe 3 (optional) | Crash-Reporting-Dienst, EU-gehostet | Nur opt-in; Auswahl in Etappe 3 |
| Etappe 5 | **Supabase** (Organisation, Region EU/Frankfurt) | Account, Sync, Community |
| Etappe 5 | Sign in with Apple / Google-OAuth-Client | Anmeldung |
| Etappe 5 | Abo-Produkte in App Store Connect und Google Play (Teil von 4 und 6), optional **RevenueCat** (kostenlos bis zu einem Umsatz-Schwellenwert) | Premium als Abo (ADR-029); Apple/Google behalten 15–30 % |
| Etappe 5 | Liste der Seriennummern verkaufter Eisbäder (von Solarctic-Zen, kein Konto) | Premium über Eisbad-Registrierung (ADR-029) |
| Vor Release | Kartenanbieter mit eigenem Schlüssel (z. B. MapTiler) | Community-Karte (ADR-025) |

## Wenn fertig

Bitte kurz melden, welche Schritte erledigt sind (ohne Zugangsdaten). Für das Repository und Codemagic brauche ich dann nur die Namen, um die Projektkonfiguration darauf auszurichten.
