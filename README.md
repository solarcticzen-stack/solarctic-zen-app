# Solarctic-Zen App

Begleit-App für Eisbäder: Session-Tracking, Herzfrequenz (Apple Watch & Wearables), Kalender, Statistiken, Meilensteine und ein wissenschaftlich fundierter Wissensbereich.

**Stand (2026-11-20):** Etappe 1 weitgehend fertig – Timer mit Vorlauf, Speicherung, Verlauf, Statistik, Meilensteine, Aufwärm-Impuls, Marken-Design (Schwarz/Weiss, Logo, Roboto), Kalender und Diagramme, Detailansicht, Bearbeiten und Nachtragen, Onboarding mit Profil und Zielen, Tipps, Fragebögen, Einstiegs-Guide, Wissensbereich, Community Hub (Karte, Termine, Angebote, Chat – lokal mit Demo-Daten), Premium (Abo oder Eisbad-Registrierung, Prüfung folgt mit dem Server), 220 automatische Tests, Browser-Vorschau (`tools/preview-web.cmd` doppelklicken → http://localhost:8080).

## Dokumentation

| Dokument | Inhalt |
|---|---|
| [docs/PROJECT_PLAN.md](docs/PROJECT_PLAN.md) | Etappen, Aufwand, Tests, Risiken, offene Fragen |
| [docs/TECHNICAL_ARCHITECTURE.md](docs/TECHNICAL_ARCHITECTURE.md) | Framework-Wahl, Systemaufbau, Schnittstellen, Wearables, Backend, Sicherheit |
| [docs/FEATURES.md](docs/FEATURES.md) | Vollständiger Funktionsumfang mit Priorisierung, Meilensteine, Wissensbereich |
| [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) | Lokales und Server-Datenmodell, Meilenstein-Katalog |
| [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Designrichtung, Tokens, Komponenten, Navigation, Screens |
| [docs/DEVELOPMENT_LOG.md](docs/DEVELOPMENT_LOG.md) | Verlauf und Architekturentscheidungen (ADR) |
| [docs/SETUP_ACCOUNTS.md](docs/SETUP_ACCOUNTS.md) | Checkliste der benötigten Konten (vom Team anzulegen) |
| [CLAUDE.md](CLAUDE.md) | Verbindliche Arbeitsgrundlage für die Entwicklung mit Claude Code |

## Von Solarctic-Zen zu liefern

- `brand/` – Brand-Manual, Logo-Dateien (SVG/PDF), Schriften inkl. Lizenz für App-Nutzung
- `hardware/` – Hersteller/Modell von Kühlaggregat bzw. Controller, Name der Hersteller-App, technische Dokumentation
