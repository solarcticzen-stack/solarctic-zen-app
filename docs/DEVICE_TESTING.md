# Solarctic-Zen – Testen auf euren Geräten & Updates

Stand: 2026-11-20 · Geräte: 1× iPhone, 1× Android · Entscheid ADR-030

**Zugangsdaten, Passwörter, Schlüssel nie in den Chat oder ins Repository.** Ihr tragt sie direkt im jeweiligen Dienst ein. Ich brauche jeweils nur Namen bzw. Adressen (z. B. Repo-URL, Projektname).

---

## Überblick

```
Änderung (Claude, lokal auf D:) → Tests grün → Commit + Push auf GitHub (nur mit eurem OK)
        → Tag «beta-JJJJ-MM-TT» → Codemagic baut beide Apps
        → iPhone: TestFlight  ·  Android: Google Play «Interner Test»
        → Update erscheint auf euren Geräten, Daten bleiben erhalten
```

- Ein normaler Push sichert nur den Code. **Erst ein Tag `beta-…` liefert ein Update aus** – so sammeln wir Änderungen (z. B. 1–2 Updates pro Woche).
- Die App-Kennung ist auf beiden Plattformen `ch.solarcticzen.app`. Sie darf sich nie ändern, sonst gilt jede Version als neue App (Daten weg).

---

## Konten anlegen – Reihenfolge

### 1. D-U-N-S-Nummer (kostenlos, bis ca. 2 Wochen)
Voraussetzung für die Firmenkonten bei Apple und Google. Über die D-U-N-S-Suche auf der Apple-Developer-Seite beantragen («D-U-N-S Number lookup»).

### 2. GitHub (kostenlos) – sofort möglich
1. Konto anlegen (Firmen-E-Mail empfohlen), Zwei-Faktor-Anmeldung einschalten.
2. Optional eine **Organisation** «solarctic-zen» anlegen (kostenloser Plan) und den Co-Founder einladen.
3. Ein **privates, leeres** Repository `solarctic-zen-app` anlegen – **ohne** README, .gitignore oder Lizenz (sonst gibt es beim ersten Hochladen einen Konflikt).
4. Mir nur die Adresse melden (z. B. `github.com/solarctic-zen/solarctic-zen-app`). Beim ersten Hochladen öffnet sich ein Browserfenster, in dem **du** dich anmeldest.

### 3. Supabase – Server für die Testphase (kostenlos) – sofort möglich
1. Konto anlegen (z. B. «Continue with GitHub»), **Organisation** «Solarctic-Zen», Plan **Free**.
2. Projekt anlegen: Name `solarctic-zen-test`, Region **Central EU (Frankfurt)**.
3. Das Datenbank-Passwort, das Supabase vorschlägt, **in euren Passwort-Manager** – nicht weitergeben.
4. Mir nur die **Projekt-URL** melden (`https://<kennung>.supabase.co`). Wie der App-Schlüssel in die App kommt, ohne im Chat zu landen, richte ich dann ein (lokale Datei, die nicht eingecheckt wird).
5. Hinweis: Gratis-Projekte werden nach einer Woche ohne Nutzung pausiert (in der Konsole mit einem Klick wieder aktiv). Für den Betrieb später ein zweites Projekt `solarctic-zen` im Pro-Plan (ab 25 USD/Monat).

### 4. Apple Developer Program – Organisation (ca. 99 USD/Jahr) – nach D-U-N-S
1. Mit einer **Firmen-Apple-ID** (z. B. `apps@…`) anmelden, als Organisation registrieren. Apples Prüfung kann einige Tage dauern.
2. Im Developer-Portal unter «Identifiers» die App-ID **`ch.solarcticzen.app`** registrieren.
3. In **App Store Connect** → «Apps» → neue App: Name «Solarctic-Zen», Primärsprache Deutsch, Bundle-ID `ch.solarcticzen.app`, SKU z. B. `solarctic-zen-ios`.
4. «Benutzer und Zugriff»: Co-Founder als Benutzer einladen. Beide werden dann **interne Tester** in TestFlight (keine Prüfung durch Apple nötig).
5. «Integrationen» → «App Store Connect API» → Schlüssel erstellen, Rolle **App-Manager**. Die `.p8`-Datei **direkt in Codemagic** hochladen (lässt sich nur einmal herunterladen).

### 5. Google Play Console – Organisation (einmalig ca. 25 USD) – nach D-U-N-S
1. Organisationskonto anlegen (Identitätsprüfung dauert einige Tage).
2. App erstellen: Name «Solarctic-Zen», Standardsprache Deutsch, App (nicht Spiel), kostenlos. «Play App-Signatur» eingeschaltet lassen (Standard).
3. «Testen → Interner Test» → Testerliste mit den **Google-Konten** von euch beiden. Der Co-Founder öffnet danach den Teilnahme-Link auf dem Android-Gerät.
4. Für automatische Uploads: in Google Cloud ein **Dienstkonto** mit JSON-Schlüssel anlegen und es in der Play Console unter «Nutzer und Berechtigungen» mit Release-Rechten für diese App einladen. Den JSON-Inhalt **direkt in Codemagic** als geheime Variable `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` in der Gruppe `google_play` speichern. (Ich führe euch bei diesem Schritt gerne Klick für Klick durch.)
5. **Die allererste Version** muss Google einmal von Hand bekommen: die `.aab`-Datei aus dem ersten Codemagic-Build herunterladen und unter «Interner Test → Neuen Release erstellen» hochladen. Ab dann lädt Codemagic selbst hoch.

### 6. Codemagic (kostenloses Kontingent) – nach GitHub
1. Mit GitHub anmelden. **Persönliches Konto** verwenden: nur dort gibt es 500 Gratis-Minuten pro Monat auf dem Mac (Team-Konten haben keine). Darüber hinaus ca. 0.095 USD pro Mac-Minute (iPhone-Build ca. 15–20 Min.).
2. App hinzufügen → GitHub-Repository `solarctic-zen-app` wählen. Die Datei `codemagic.yaml` wird automatisch erkannt.
3. Nach Schritt 4: «Integrationen → Developer Portal» → `.p8`-Schlüssel hochladen, Name **`Solarctic-Zen ASC`**.
4. Android-Upload-Schlüssel (siehe unten) unter «Code signing identities → Android keystores» hochladen, Referenzname **`solarctic-zen-upload`**.

---

## Android-Upload-Schlüssel (macht ihr selbst, einmalig)

Mit diesem Schlüssel wird jede Android-Version unterschrieben. Ich erzeuge ihn bewusst nicht, damit das Passwort nie bei mir vorbeikommt. In PowerShell:

```powershell
New-Item -ItemType Directory -Force D:\SolarcticApp\keys
```

```powershell
& D:\SolarcticApp\sdk\jdk-21\bin\keytool.exe -genkeypair -v -keystore D:\SolarcticApp\keys\solarctic-zen-upload.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- keytool fragt nach einem Passwort und nach Name/Firma (Name: Solarctic-Zen genügt).
- Die Datei `solarctic-zen-upload.jks` und das Passwort **sicher aufbewahren** (Passwort-Manager + Kopie der Datei an einem zweiten Ort). Dank «Play App-Signatur» kann Google einen verlorenen Upload-Schlüssel zurücksetzen – das dauert aber Tage.
- Der Ordner `D:\SolarcticApp\keys` liegt bewusst **ausserhalb** des Repositorys.
- In Codemagic hochladen: Datei, Passwort, Alias `upload`, Schlüssel-Passwort (bei JKS meist dasselbe).

---

## Sofort testen – Android ohne Konto

Bis Google Play steht, kann der Co-Founder eine Installationsdatei (APK) direkt installieren:

1. Ich baue `app-release.apk` (liegt dann unter `app\build\app\outputs\flutter-apk\`).
2. Datei aufs Android-Gerät bringen (USB-Kabel, Cloud-Ordner oder Mail an sich selbst).
3. Antippen → Android fragt einmalig, ob die App (z. B. «Dateien» oder Browser) Apps installieren darf → erlauben → installieren.

**Wichtig:** Diese Testdatei ist mit dem Entwicklungsschlüssel unterschrieben. Bevor die Version aus Google Play installiert wird, muss sie **deinstalliert** werden (die Testdaten gehen dabei verloren). Danach laufen alle Updates über Google Play.

## iPhone

Ohne Mac gibt es keinen Weg vorbei an TestFlight, also erst nach Schritt 4. Dann: App **TestFlight** aus dem App Store installieren → Einladung per Mail annehmen → «Installieren». Neue Versionen erscheinen dort (automatische Updates in TestFlight einschalten). Eine TestFlight-Version läuft nach 90 Tagen ab.

---

## Was in der Testphase geht – und was noch nicht

| Bereich | Stand |
|---|---|
| Session-Timer, Verlauf, Statistik, Erfolge, Wissen | auf beiden Geräten testbar |
| Karte (OpenStreetMap) | testbar (Internet nötig) |
| Community, Chat gemeinsam | erst mit Supabase-Anbindung (nächster Schritt) – bis dahin nur Demo-Daten pro Gerät |
| Premium (Eisbad/Abo) | erst mit Server bzw. Store-Abo-Produkten |
| Apple Health / Health Connect, Benachrichtigungen | folgen in Etappe 3 |

Feedback: in TestFlight per Screenshot → «Feedback senden», sonst einfach Screenshot + kurze Beschreibung an mich.

---

## Für Claude: lokale Werkzeuge (alles auf D:)

| Was | Pfad |
|---|---|
| Flutter | `D:\SolarcticApp\sdk\flutter` |
| Java 21 (Temurin) | `D:\SolarcticApp\sdk\jdk-21` |
| Android-SDK (Plattform 36, Build-Tools 36.0.0, NDK 28.2) | `D:\SolarcticApp\sdk\android` |
| Gradle-Cache | `D:\SolarcticApp\sdk\gradle-home` |

Bash: `export PATH="/d/SolarcticApp/sdk/flutter/bin:/d/SolarcticApp/sdk/jdk-21/bin:$PATH" PUB_CACHE='D:\SolarcticApp\sdk\pub-cache' JAVA_HOME='D:\SolarcticApp\sdk\jdk-21' ANDROID_HOME='D:\SolarcticApp\sdk\android' ANDROID_USER_HOME='D:\SolarcticApp\sdk\android-user' GRADLE_USER_HOME='D:\SolarcticApp\sdk\gradle-home'` – ohne `GRADLE_USER_HOME` landet der Gradle-Cache (mehrere GB) auf C:.
