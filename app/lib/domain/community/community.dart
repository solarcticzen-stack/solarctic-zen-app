import 'dart:convert';
import 'dart:math';

import 'package:meta/meta.dart';

import '../session/session_repository.dart';

/// Community Hub (FEATURES.md §M, Notiz N-008).
///
/// Gesundheitsdaten werden hier nie verwendet oder geteilt.

enum MemberTier { member, premium }

/// Avatar = Symbol + Farbe (kein Foto-Upload, keine Bildmoderation nötig).
enum AvatarSymbol {
  snowflake('Schneeflocke'),
  wave('Welle'),
  mountain('Berg'),
  sun('Sonne'),
  moon('Mond'),
  leaf('Blatt'),
  star('Stern'),
  bolt('Blitz');

  const AvatarSymbol(this.label);
  final String label;
}

const avatarColorCount = 8;

@immutable
class CommunityProfile {
  const CommunityProfile({
    required this.id,
    required this.handle,
    required this.symbol,
    required this.colorIndex,
    required this.joinedAt,
    this.tier = MemberTier.member,
    this.blocked = const {},
  });

  factory CommunityProfile.fromJson(Map<String, Object?> j) => CommunityProfile(
    id: j['id']! as String,
    handle: j['handle']! as String,
    symbol:
        AvatarSymbol.values.asNameMap()[j['symbol']] ?? AvatarSymbol.snowflake,
    colorIndex: ((j['color'] as num?)?.toInt() ?? 0) % avatarColorCount,
    joinedAt: DateTime.parse(j['joined']! as String).toUtc(),
    tier: MemberTier.values.asNameMap()[j['tier']] ?? MemberTier.member,
    blocked: {
      for (final b in (j['blocked'] as List<Object?>?) ?? const [])
        b! as String,
    },
  );

  final String id;
  final String handle;
  final AvatarSymbol symbol;
  final int colorIndex;
  final DateTime joinedAt;
  final MemberTier tier;

  /// IDs blockierter Mitglieder (deren Inhalte werden ausgeblendet).
  final Set<String> blocked;

  /// Nur Premium-Mitglieder dürfen Orte, Termine und Angebote eintragen.
  bool get canPublish => tier == MemberTier.premium;

  Map<String, Object?> toJson() => {
    'id': id,
    'handle': handle,
    'symbol': symbol.name,
    'color': colorIndex,
    'joined': joinedAt.toIso8601String(),
    'tier': tier.name,
    'blocked': [...blocked],
  };

  CommunityProfile copyWith({
    String? handle,
    AvatarSymbol? symbol,
    int? colorIndex,
    MemberTier? tier,
    Set<String>? blocked,
  }) => CommunityProfile(
    id: id,
    handle: handle ?? this.handle,
    symbol: symbol ?? this.symbol,
    colorIndex: colorIndex ?? this.colorIndex,
    joinedAt: joinedAt,
    tier: tier ?? this.tier,
    blocked: blocked ?? this.blocked,
  );
}

/// Anzeigenamen: Vorschläge und Prüfung.
abstract final class Handles {
  static const _first = [
    'Polar',
    'Gletscher',
    'Frost',
    'Firn',
    'Nord',
    'Kristall',
    'Eis',
    'Arktis',
  ];
  static const _second = [
    'fuchs',
    'bär',
    'falke',
    'welle',
    'luchs',
    'otter',
    'stern',
    'wolf',
  ];

  static List<String> suggestions(Random random, {int count = 3}) {
    final out = <String>{};
    while (out.length < count) {
      out.add(
        '${_first[random.nextInt(_first.length)]}${_second[random.nextInt(_second.length)]} '
        '${10 + random.nextInt(90)}',
      );
    }
    return out.toList();
  }

  static const minLength = 3, maxLength = 24;

  /// Fehlermeldung oder `null`.
  static String? validate(String raw) {
    final h = raw.trim();
    if (h.length < minLength || h.length > maxLength) {
      return 'Der Name muss $minLength–$maxLength Zeichen lang sein.';
    }
    if (!RegExp(r"^[\p{L}\p{N} ._'-]+$", unicode: true).hasMatch(h)) {
      return 'Erlaubt sind Buchstaben, Zahlen, Leerzeichen und . _ - \'';
    }
    if (ContentFilter.isBlocked(h)) return 'Bitte wähle einen anderen Namen.';
    return null;
  }
}

/// Sehr einfacher Wortfilter. Ersetzt keine Moderation (FEATURES.md M6).
abstract final class ContentFilter {
  static const _blocked = [
    'arschloch',
    'hurensohn',
    'wichser',
    'fotze',
    'missgeburt',
    'schlampe',
    'fuck',
    'bitch',
    'cunt',
    'nigger',
    'kanake',
    'spast',
  ];

  static bool isBlocked(String text) {
    final t = text.toLowerCase();
    return _blocked.any(t.contains);
  }
}

enum PlaceType {
  privateBath('Privates Eisbad'),
  publicSpot('Badeplatz'),
  club('Verein');

  const PlaceType(this.label);
  final String label;
}

@immutable
class Place {
  const Place({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.ownerId,
    required this.ownerHandle,
    required this.createdAt,
    this.address,
    this.isDemo = false,
  });

  final String id;
  final PlaceType type;
  final String name;
  final String description;
  final double lat;
  final double lng;

  /// Genaue Adresse (bei privaten Eisbädern nur nach Bestätigung, nur für Mitglieder).
  final String? address;
  final String ownerId;
  final String ownerHandle;
  final DateTime createdAt;
  final bool isDemo;
}

@immutable
class CommunityEvent {
  const CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.location,
    required this.organizerId,
    required this.organizerHandle,
    this.isDemo = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime startsAt;
  final String location;
  final String organizerId;
  final String organizerHandle;
  final bool isDemo;
}

enum OfferCategory {
  course('Kurs / Workshop'),
  coaching('Coaching'),
  bathAccess('Eisbad-Nutzung'),
  other('Sonstiges');

  const OfferCategory(this.label);
  final String label;
}

@immutable
class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.providerId,
    required this.providerHandle,
    required this.createdAt,
    this.location,
    this.contact,
    this.isDemo = false,
  });

  final String id;
  final String title;
  final OfferCategory category;
  final String description;
  final String? location;
  final String? contact;
  final String providerId;
  final String providerHandle;
  final DateTime createdAt;
  final bool isDemo;
}

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.authorId,
    required this.authorHandle,
    required this.authorSymbol,
    required this.authorColor,
    required this.text,
    required this.sentAt,
    this.isDemo = false,
  });

  final String id;
  final String authorId;
  final String authorHandle;
  final AvatarSymbol authorSymbol;
  final int authorColor;
  final String text;
  final DateTime sentAt;
  final bool isDemo;
}

enum ReportTarget { place, event, offer, message, member }

@immutable
class ContentReport {
  const ContentReport({
    required this.id,
    required this.target,
    required this.targetId,
    required this.reason,
    required this.reporterId,
    required this.createdAt,
  });

  final String id;
  final ReportTarget target;
  final String targetId;
  final String reason;
  final String reporterId;
  final DateTime createdAt;
}

/// Grenzen für Chat-Nachrichten.
abstract final class ChatLimits {
  static const maxLength = 500;

  static String? validate(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 'Nachricht ist leer.';
    if (t.length > maxLength) return 'Höchstens $maxLength Zeichen.';
    if (ContentFilter.isBlocked(t)) {
      return 'Diese Nachricht verstösst gegen die Community-Regeln.';
    }
    return null;
  }
}

/// Port für geteilte Community-Inhalte. Derzeit nur lokal (Demo);
/// Supabase-Adapter folgt mit dem Server (FEATURES.md M7).
abstract interface class CommunityRepository {
  /// `true`, solange Inhalte nicht mit anderen geteilt werden (kein Server).
  bool get isLocalOnly;

  Stream<List<Place>> watchPlaces();
  Future<void> addPlace(Place place);
  Stream<List<CommunityEvent>> watchEvents();
  Future<void> addEvent(CommunityEvent event);
  Stream<List<Offer>> watchOffers();
  Future<void> addOffer(Offer offer);
  Stream<List<ChatMessage>> watchChat();
  Future<void> sendMessage(ChatMessage message);
  Future<void> report(ContentReport report);
}

/// Eigenes Community-Profil, lokal gespeichert (getrennt vom Gesundheitsprofil).
class CommunityProfileController {
  CommunityProfileController(this._store);

  static const _key = 'community_profile';
  final SettingsStore _store;
  CommunityProfile? _profile;
  final List<void Function()> _listeners = [];

  CommunityProfile? get profile => _profile;

  Future<void> load() async {
    final raw = await _store.get(_key);
    _profile = raw == null
        ? null
        : CommunityProfile.fromJson(jsonDecode(raw) as Map<String, Object?>);
    _notify();
  }

  Future<void> save(CommunityProfile? p) async {
    _profile = p;
    await _store.set(_key, p == null ? null : jsonEncode(p.toJson()));
    _notify();
  }

  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() {
    for (final l in [..._listeners]) {
      l();
    }
  }
}
