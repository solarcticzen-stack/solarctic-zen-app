-- Solarctic-Zen Community Hub – Supabase/PostgreSQL-Schema (FEATURES.md §M, M7)
--
-- STATUS: ENTWURF, NOCH NIE AUSGEFÜHRT. Wird beim Anlegen des Supabase-Projekts
-- (Region EU/Frankfurt) eingespielt und dort getestet (inkl. RLS-Tests).
--
-- Grundsätze:
-- - Schema «social» ist strikt getrennt von privaten Gesundheitsdaten (die bleiben lokal).
-- - Row Level Security auf jeder Tabelle; lesen dürfen nur angemeldete Mitglieder.
-- - Schreiben von Orten/Terminen/Angeboten nur mit gültiger Premium-Berechtigung
--   (Quelle: In-App-Abo ODER registriertes Solarctic-Zen Eisbad, ADR-029).
-- - Melden ist für alle Mitglieder möglich; Moderation über die Rolle 'moderator'.

create schema if not exists social;

create type social.premium_source as enum ('subscription', 'bathPurchase');
create type social.place_type as enum ('privateBath', 'publicSpot', 'club');
create type social.offer_category as enum ('course', 'coaching', 'bathAccess', 'other');
create type social.report_target as enum ('place', 'event', 'offer', 'message', 'member');

create table social.members (
  id           uuid primary key references auth.users (id) on delete cascade,
  handle       text not null unique check (char_length(handle) between 3 and 24),
  symbol       text not null,
  color_index  smallint not null check (color_index between 0 and 7),
  is_moderator boolean not null default false,
  joined_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------- Premium
-- Berechtigungen schreibt nur der Server (Edge Function / security definer),
-- nie die App direkt.
create table social.premium_grants (
  id         uuid primary key default gen_random_uuid(),
  member_id  uuid not null references social.members (id) on delete cascade,
  source     social.premium_source not null,
  reference  text not null,              -- Store-Transaktions-ID bzw. Seriennummer
  granted_at timestamptz not null default now(),
  expires_at timestamptz,                 -- null = unbefristet (Laufzeit Eisbad-Kauf: offen)
  revoked_at timestamptz,
  unique (source, reference)
);
create index on social.premium_grants (member_id);

-- Seriennummern verkaufter Eisbäder: für die App unsichtbar (eigenes Schema,
-- kein Zugriff über die API). Import durch Solarctic-Zen (Produktion/Verkauf).
create schema if not exists private;
create table private.bath_serials (
  serial     text primary key check (serial ~ '^[A-Z0-9]{6,32}$'),
  sold_at    date,
  claimed_by uuid references social.members (id) on delete set null,
  claimed_at timestamptz
);
-- Missbrauchsschutz: Registrierungsversuche zählen.
create table private.claim_attempts (
  member_id    uuid not null,
  attempted_at timestamptz not null default now()
);
create index on private.claim_attempts (member_id, attempted_at desc);

create table social.blocks (
  member_id  uuid not null references social.members (id) on delete cascade,
  blocked_id uuid not null references social.members (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (member_id, blocked_id)
);

create table social.places (
  id          uuid primary key default gen_random_uuid(),
  type        social.place_type not null,
  name        text not null check (char_length(name) between 3 and 80),
  description text not null default '' check (char_length(description) <= 1000),
  lat         double precision not null check (lat between -90 and 90),
  lng         double precision not null check (lng between -180 and 180),
  -- Genaue Adresse; bei privaten Eisbädern nur mit ausdrücklicher Bestätigung.
  address     text,
  address_consent boolean not null default false,
  owner_id    uuid not null references social.members (id) on delete cascade,
  hidden      boolean not null default false, -- durch Moderation ausgeblendet
  created_at  timestamptz not null default now(),
  check (type <> 'privateBath' or address is null or address_consent)
);

create table social.events (
  id           uuid primary key default gen_random_uuid(),
  title        text not null check (char_length(title) between 3 and 80),
  description  text not null default '' check (char_length(description) <= 2000),
  starts_at    timestamptz not null,
  location     text not null,
  place_id     uuid references social.places (id) on delete set null,
  organizer_id uuid not null references social.members (id) on delete cascade,
  hidden       boolean not null default false,
  created_at   timestamptz not null default now()
);

create table social.offers (
  id          uuid primary key default gen_random_uuid(),
  title       text not null check (char_length(title) between 3 and 80),
  category    social.offer_category not null,
  description text not null check (char_length(description) <= 2000),
  location    text,
  contact     text,
  provider_id uuid not null references social.members (id) on delete cascade,
  hidden      boolean not null default false,
  created_at  timestamptz not null default now()
);

create table social.messages (
  id         uuid primary key default gen_random_uuid(),
  author_id  uuid not null references social.members (id) on delete cascade,
  text       text not null check (char_length(text) between 1 and 500),
  hidden     boolean not null default false,
  sent_at    timestamptz not null default now()
);

create table social.reports (
  id          uuid primary key default gen_random_uuid(),
  target      social.report_target not null,
  target_id   uuid not null,
  reason      text not null check (char_length(reason) <= 500),
  reporter_id uuid not null references social.members (id) on delete cascade,
  resolved    boolean not null default false,
  created_at  timestamptz not null default now()
);

create index on social.events (starts_at);
create index on social.messages (sent_at desc);

-- Hilfsfunktionen
create function social.is_member() returns boolean language sql stable as $$
  select exists (select 1 from social.members where id = auth.uid());
$$;
create function social.is_premium() returns boolean language sql stable as $$
  select exists (
    select 1 from social.premium_grants
    where member_id = auth.uid()
      and revoked_at is null
      and granted_at <= now()
      and (expires_at is null or expires_at > now())
  );
$$;

-- Eisbad registrieren (von der App aufgerufen). Antwort:
-- 'granted' | 'unknown' | 'alreadyClaimed' | 'tooManyAttempts'.
-- Ein Eisbad gehört genau einem Konto; Übertragung (Verkauf, Familie) über den Kundendienst.
create function social.claim_bath(p_serial text) returns text
  language plpgsql security definer set search_path = '' as $$
declare
  v_serial text := upper(regexp_replace(p_serial, '[\s-]', '', 'g'));
  v_row private.bath_serials;
begin
  if not social.is_member() then raise exception 'not a member'; end if;
  if (select count(*) from private.claim_attempts
      where member_id = auth.uid() and attempted_at > now() - interval '1 hour') >= 10 then
    return 'tooManyAttempts';
  end if;
  insert into private.claim_attempts (member_id) values (auth.uid());

  select * into v_row from private.bath_serials where serial = v_serial for update;
  if not found then return 'unknown'; end if;
  if v_row.claimed_by is not null and v_row.claimed_by <> auth.uid() then
    return 'alreadyClaimed';
  end if;
  update private.bath_serials set claimed_by = auth.uid(), claimed_at = now()
    where serial = v_serial;
  insert into social.premium_grants (member_id, source, reference)
    values (auth.uid(), 'bathPurchase', v_serial)
    on conflict (source, reference) do nothing;
  return 'granted';
end;
$$;
revoke all on function social.claim_bath(text) from public;
grant execute on function social.claim_bath(text) to authenticated;

-- Abo: Gutschrift/Verlängerung/Kündigung schreibt eine Edge Function nach
-- Prüfung der Store-Belege (App Store Server Notifications, Google RTDN),
-- z. B. über RevenueCat. Keine direkte Schreib-Policy für Clients.
create function social.is_moderator() returns boolean language sql stable as $$
  select exists (select 1 from social.members where id = auth.uid() and is_moderator);
$$;

-- Row Level Security
alter table social.members  enable row level security;
alter table social.premium_grants enable row level security;
alter table social.blocks   enable row level security;
alter table social.places   enable row level security;
alter table social.events   enable row level security;
alter table social.offers   enable row level security;
alter table social.messages enable row level security;
alter table social.reports  enable row level security;

-- Mitglieder: sehen einander; ändern nur sich selbst (is_moderator nur serverseitig).
create policy members_read   on social.members for select using (social.is_member());
create policy members_insert on social.members for insert with check (id = auth.uid() and not is_moderator);
create policy members_update on social.members for update using (id = auth.uid())
  with check (id = auth.uid());
-- Hinweis: is_moderator per Trigger gegen Änderung durch Nutzer schützen.

-- Premium: eigene Berechtigungen lesen; schreiben nur der Server.
create policy grants_read_own on social.premium_grants for select using (member_id = auth.uid());

create policy blocks_own on social.blocks for all using (member_id = auth.uid()) with check (member_id = auth.uid());

-- Orte, Termine, Angebote: lesen Mitglieder (ohne ausgeblendete), schreiben nur Premium.
create policy places_read   on social.places for select using (social.is_member() and (not hidden or social.is_moderator()));
create policy places_write  on social.places for insert with check (social.is_premium() and owner_id = auth.uid());
create policy places_update on social.places for update using (owner_id = auth.uid() or social.is_moderator());
create policy places_delete on social.places for delete using (owner_id = auth.uid() or social.is_moderator());

create policy events_read   on social.events for select using (social.is_member() and (not hidden or social.is_moderator()));
create policy events_write  on social.events for insert with check (social.is_premium() and organizer_id = auth.uid());
create policy events_update on social.events for update using (organizer_id = auth.uid() or social.is_moderator());
create policy events_delete on social.events for delete using (organizer_id = auth.uid() or social.is_moderator());

create policy offers_read   on social.offers for select using (social.is_member() and (not hidden or social.is_moderator()));
create policy offers_write  on social.offers for insert with check (social.is_premium() and provider_id = auth.uid());
create policy offers_update on social.offers for update using (provider_id = auth.uid() or social.is_moderator());
create policy offers_delete on social.offers for delete using (provider_id = auth.uid() or social.is_moderator());

-- Chat: alle Mitglieder lesen und schreiben (eigene Nachrichten).
create policy messages_read   on social.messages for select using (social.is_member() and (not hidden or social.is_moderator()));
create policy messages_write  on social.messages for insert with check (social.is_member() and author_id = auth.uid());
create policy messages_delete on social.messages for delete using (author_id = auth.uid() or social.is_moderator());

-- Meldungen: jedes Mitglied darf melden; nur Moderation liest.
create policy reports_insert on social.reports for insert with check (social.is_member() and reporter_id = auth.uid());
create policy reports_read   on social.reports for select using (social.is_moderator());
create policy reports_update on social.reports for update using (social.is_moderator());
