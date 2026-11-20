# Solarctic-Zen – Datenbankmodell

Status: **v0.2 (2026-11-19)** – lokal umgesetzt (drift, Schema-Version 3): `ice_sessions`, `session_pauses`, `app_settings`. Version 2 ergänzt `warmup_exercise_id` und `warmup_done` an `ice_sessions` (A20). Version 3 ergänzt `overcome_rating`, `during_rating` und die Tabelle `questionnaire_results` (id, kind, answered_at_ms, answers, score). Migrationen getestet. Das Profil liegt vorerst als JSON in `app_settings` (Schlüssel `profile`). Abweichungen zur Planung: Zeitpunkte als UTC-Millisekunden (`*_at_ms`), Zeitzone vorerst als `utc_offset_min` + `tz_name` statt IANA-`tz_id` (ADR-022), Empfinden/Notiz direkt in `ice_sessions`. Übrige Tabellen folgen mit ihren Funktionen.

- **Lokal:** SQLite via drift (Quelle der Wahrheit, offline-fähig).
- **Server (Phase 5):** PostgreSQL (Supabase) mit identischer Struktur für synchronisierte Tabellen + reine Server-Tabellen für Community.
- Alle IDs: UUIDv7 (clientseitig erzeugt). Zeitpunkte: UTC (ISO 8601 / epoch ms in SQLite, `timestamptz` in Postgres).
- Synchronisierbare Tabellen tragen die Sync-Spalten `created_at`, `updated_at`, `deleted_at` (Tombstone), `version`.
- Nicht verfügbare Messwerte sind `NULL` – nie `0`.

## 1. Übersicht

```
profile 1──n ice_session 1──n hr_sample
   │              ├──n session_pause
   │              ├──n water_temp_reading
   │              └──n session_photo
   ├──n goal
   ├──n milestone_state      (Katalog: assets/milestones/*.json)
   ├──n article_state        (Inhalte: assets/knowledge/**.md)
   ├──n reminder
   ├──n consent
   └──n device ──n device_pairing (Phase 4/6)
sync_outbox, sync_cursor, app_setting  (technisch)
```

## 2. Kern-Tabellen

### `profile`
| Spalte | Typ | Null | Beschreibung |
|---|---|---|---|
| id | uuid PK | | |
| display_name | text | ✓ | |
| birth_year | int | ✓ | optional, nur für spätere Auswertungen; nicht im MVP abgefragt |
| locale | text | | `de-CH`, `en` … |
| temp_unit | text | | `celsius` \| `fahrenheit` |
| is_health_owner | bool | | nur dieses Profil schreibt in HealthKit/Health Connect |
| safety_limit_s | int | ✓ | persönliche Sicherheits-Obergrenze (Hinweis) |
| interval_cue_s | int | ✓ | Haptik-/Ton-Intervall |
| week_start | int | | 1 = Montag (ISO) |
| + Sync-Spalten | | | |

### `ice_session`
| Spalte | Typ | Null | Beschreibung |
|---|---|---|---|
| id | uuid PK | | |
| profile_id | uuid FK | | |
| status | text | | `active` \| `completed` \| `discarded` |
| entry_mode | text | | `timer` \| `manual` \| `watch` \| `imported` |
| started_at | timestamp UTC | | Einstieg ins Wasser |
| ended_at | timestamp UTC | ✓ | NULL solange aktiv |
| tz_id | text | | IANA-Zeitzone am Startort, z. B. `Europe/Zurich` |
| local_date | date | | Kalendertag in `tz_id` beim Start – Basis für Kalender & Wochen |
| duration_s | int | ✓ | Netto-Zeit im Wasser (ohne Pausen); bei `completed` Pflicht |
| paused_s | int | | Summe Pausen, Default 0 |
| water_temp_c | real | ✓ | repräsentative Temperatur (manuell oder Ø der Messungen) |
| water_temp_source | text | ✓ | `manual` \| `bath_device` \| `sensor` |
| air_temp_c | real | ✓ | optional (Outdoor-Bäder) |
| hr_avg / hr_min / hr_max | int | ✓ | aus `hr_sample` berechnet und zwischengespeichert |
| hr_provenance | text | ✓ | `live` \| `buffered_live` \| `synced` \| `mixed` |
| hr_device_id | uuid FK | ✓ | |
| feeling_before | int 1–5 | ✓ | |
| feeling_after | int 1–5 | ✓ | |
| feeling_tags | json | ✓ | z. B. `["energisiert","ruhig"]` |
| notes | text | ✓ | |
| breathing_s | int | ✓ | Dauer Atemübung davor |
| rewarm_s | int | ✓ | Dauer Nachwärmphase |
| health_external_id | text | ✓ | UUID des HealthKit-Workouts bzw. Health-Connect-Record-ID |
| + Sync-Spalten | | | |

Indizes: `(profile_id, local_date)`, `(profile_id, started_at)`, partieller Index `WHERE status = 'active'` (max. 1 aktive Session je Profil – per Constraint/Trigger erzwungen).

Regeln:
- `ended_at ≥ started_at`, `duration_s = (ended_at − started_at) − paused_s`.
- Eine aktive Session wird **beim Start** geschrieben (Absturzsicherheit).
- Manuelle Einträge: `started_at` + `duration_s` Pflicht, `ended_at` wird berechnet.

### `session_pause`
`id`, `session_id FK`, `paused_at`, `resumed_at NULL` – erlaubt exakte Rekonstruktion, auch nach Absturz während einer Pause.

### `hr_sample` (unveränderlich)
| Spalte | Typ | Beschreibung |
|---|---|---|
| session_id | uuid FK | |
| t_ms | int | Offset ab `started_at` (kompakter als absolute Zeit, unempfindlich gegen Zeitzonen) |
| bpm | smallint | plausibilisiert (30–230) |
| provenance | text | `live` \| `buffered_live` \| `synced` |
| device_id | uuid FK NULL | |
| quality | smallint NULL | falls Quelle eine Konfidenz liefert |

PK `(session_id, t_ms, device_id)`. Volumen: 1 Hz × 5 min ≈ 300 Zeilen/Session → unkritisch. Server-seitig ggf. als komprimiertes Array je Session gespeichert.

### `water_temp_reading`
`session_id`, `t_ms`, `temp_c`, `source` – für Gerätedaten (Phase 6).

### `session_photo`
`id`, `session_id`, `local_path`, `remote_path NULL`, `taken_at`, Sync-Spalten. **Standard: nur lokal**; Upload nur mit Sync-Einwilligung.

## 3. Ziele, Meilensteine, Wissen

### `goal`
| Spalte | Typ | Beschreibung |
|---|---|---|
| id | uuid PK | |
| profile_id | uuid FK | |
| type | text | `sessions_per_week` \| `sessions_per_month` \| `minutes_per_month` \| `sessions_in_temp_range_per_month` |
| target | real | z. B. 3 |
| params | json | z. B. `{"temp_max_c": 10}` |
| active_from | date | |
| active_until | date NULL | Ziele werden nicht überschrieben, sondern abgelöst → Historie bleibt korrekt |
| + Sync-Spalten | | |

Fortschritt wird **berechnet**, nicht gespeichert.

### `milestone_state`
| Spalte | Typ | Beschreibung |
|---|---|---|
| profile_id | uuid | |
| milestone_id | text | ID aus dem Katalog, z. B. `routine.weeks_4` |
| achieved_at | timestamp | Zeitpunkt der auslösenden Session |
| achieved_session_id | uuid NULL | |
| celebrated_at | timestamp NULL | Animation gezeigt |
| catalog_version | int | |

Die Engine leitet erreichte Meilensteine aus den Sessions ab; die Tabelle ist ein Cache + «gesehen»-Status. Wird eine Session gelöscht, wird neu berechnet. Bereits gefeierte, nicht mehr erfüllte Meilensteine werden still zurückgesetzt (kein Hinweis «Meilenstein verloren»).

### `article_state`
`profile_id`, `article_id`, `unlocked_at`, `read_at NULL`, `bookmarked bool`.

## 4. Geräte, Einstellungen, Einwilligungen

### `device`
| Spalte | Typ | Beschreibung |
|---|---|---|
| id | uuid PK | |
| kind | text | `apple_watch` \| `wear_os` \| `ble_hr` \| `health_sync` \| `solarctic_bath` |
| vendor / model | text NULL | |
| platform_identifier | text | z. B. BLE-Peripheral-ID (gerätespezifisch, nicht synchronisieren) |
| capabilities | json | `{"live_hr":true,"buffer":true,"temp":false}` |
| last_seen_at | timestamp NULL | |

### `consent`
`id`, `profile_id`, `kind` (`health_data_processing`, `apple_health`, `health_connect`, `cloud_sync`, `community`, `crash_reports`, `safety_ack`), `granted bool`, `text_version`, `decided_at`. **Nur Einfügen, nie Überschreiben** → nachvollziehbares Protokoll.

### `reminder`
`id`, `profile_id`, `weekdays` (Bitmaske), `local_time` (HH:MM, wird in lokaler Zeit geplant), `label`, `enabled`.

### Technisch
- `app_setting(key, value)` – gerätelokale Einstellungen.
- `sync_outbox(id, table_name, row_id, op, enqueued_at, attempts)`.
- `sync_cursor(table_name, last_pulled_at)`.

## 5. Meilenstein-Katalog (JSON, versioniert)

```json
{
  "version": 1,
  "milestones": [
    {
      "id": "count.10",
      "category": "count",
      "rule": { "type": "session_count", "min": 10 },
      "icon": "badge_count_10",
      "article_unlock": "adaptation-basics",
      "i18n": {
        "de": { "title": "10 Eisbäder", "description": "Du hast zehn Eisbäder dokumentiert.", "message": "Zehn Mal bewusst entschieden – das ist Routine im Entstehen." },
        "en": { "title": "10 ice baths", "description": "You've logged ten ice baths.", "message": "Ten conscious decisions – a routine is taking shape." }
      }
    },
    {
      "id": "routine.weeks_4",
      "category": "routine",
      "rule": { "type": "consecutive_active_weeks", "min_weeks": 4, "sessions_per_week": 1, "allow_paused_weeks": true },
      "i18n": { "de": { "title": "4 Wochen dabei", "...": "..." } }
    },
    {
      "id": "experience.below_5c",
      "category": "experience",
      "rule": { "type": "first_session_with_temp", "max_c": 5.0 },
      "requires": ["knowledge.safety_basics"],
      "i18n": { "de": { "title": "Unter 5 °C", "message": "Gut vorbereitet ist halb gewonnen. Hör weiterhin auf deinen Körper." } }
    }
  ]
}
```

**Regeltypen (Engine v1):** `session_count`, `total_duration`, `consecutive_active_weeks`, `sessions_in_calendar_month`, `first_session_with_temp`, `return_after_break`, `sessions_with_flag` (z. B. Atemübung, Reflexion), `articles_read`, `milestone_achieved` (für `requires`). Neue Meilensteine = neuer Katalogeintrag. Neuer Regeltyp = eine Klasse + Tests; unbekannte Regeltypen in einem Remote-Katalog werden ignoriert (Vorwärtskompatibilität).

## 6. Server-only (Phase 5, Community)

| Tabelle | Inhalt | Zugriff (RLS) |
|---|---|---|
| `public_profile` | `user_id`, `handle`, `display_name`, `avatar_path`, `visibility` | Freunde / öffentlich je nach Einstellung |
| `friendship` | `requester_id`, `addressee_id`, `status` (`pending`/`accepted`/`blocked`), Zeitstempel | beide Beteiligten |
| `shared_activity` | `user_id`, `local_date`, `duration_s`, `temp_c NULL`, `milestone_id NULL` – **nur explizit geteilte, aggregierte Werte, nie HF** | Freunde |
| `challenge` | `id`, `title_i18n`, `rule` (gleiche Regelsprache), `starts_at`, `ends_at`, `visibility`, `created_by` | Teilnehmer / öffentlich |
| `challenge_participant` | `challenge_id`, `user_id`, `joined_at`, `progress` (serverseitig berechnet) | Teilnehmer |

Private, synchronisierte Tabellen liegen im Schema `private` mit RLS `user_id = auth.uid()`; Community-Tabellen im Schema `social`. Es gibt keine Datenbank-Sicht, die beide verbindet.

## 7. Migrationen und Tests

- drift-Schema-Versionen mit automatisierten Migrationstests (jede Version → aktuelle Version).
- Server: SQL-Migrationen im Repo (`backend/migrations`), RLS-Policies mit Tests (pgTAP oder Supabase-Testumgebung).
- Testdaten-Generator für realistische Historien (z. B. 2 Jahre, Zeitzonenwechsel, DST, Lücken).
