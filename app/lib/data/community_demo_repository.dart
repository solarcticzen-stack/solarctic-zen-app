import 'dart:async';

import '../domain/community/community.dart';

/// Lokale Community-Inhalte mit klar gekennzeichneten Beispieldaten.
///
/// Nichts davon wird mit anderen geteilt, bis der Server angebunden ist
/// (FEATURES.md M7). Die Beispiele sind erfunden («Demo»).
class LocalCommunityRepository implements CommunityRepository {
  LocalCommunityRepository({DateTime? now, bool seedDemo = true}) {
    if (seedDemo) _seed((now ?? DateTime.now()).toUtc());
  }

  final _places = <Place>[];
  final _events = <CommunityEvent>[];
  final _offers = <Offer>[];
  final _chat = <ChatMessage>[];
  final reports = <ContentReport>[];

  final _placeCtl = StreamController<List<Place>>.broadcast();
  final _eventCtl = StreamController<List<CommunityEvent>>.broadcast();
  final _offerCtl = StreamController<List<Offer>>.broadcast();
  final _chatCtl = StreamController<List<ChatMessage>>.broadcast();

  @override
  bool get isLocalOnly => true;

  /// Liefert jedem neuen Zuhörer sofort den aktuellen Stand, danach Änderungen.
  Stream<List<T>> _watch<T>(List<T> items, StreamController<List<T>> ctl) {
    StreamSubscription<List<T>>? sub;
    late final StreamController<List<T>> out;
    out = StreamController<List<T>>(
      onListen: () {
        out.add(List<T>.unmodifiable(items));
        sub = ctl.stream.listen(out.add);
      },
      onCancel: () => sub?.cancel(),
    );
    return out.stream;
  }

  @override
  Stream<List<Place>> watchPlaces() => _watch(_places, _placeCtl);
  @override
  Stream<List<CommunityEvent>> watchEvents() => _watch(_events, _eventCtl);
  @override
  Stream<List<Offer>> watchOffers() => _watch(_offers, _offerCtl);
  @override
  Stream<List<ChatMessage>> watchChat() => _watch(_chat, _chatCtl);

  @override
  Future<void> addPlace(Place place) async {
    _places.add(place);
    _placeCtl.add(List.unmodifiable(_places));
  }

  @override
  Future<void> addEvent(CommunityEvent event) async {
    _events.add(event);
    _eventCtl.add(List.unmodifiable(_events));
  }

  @override
  Future<void> addOffer(Offer offer) async {
    _offers.add(offer);
    _offerCtl.add(List.unmodifiable(_offers));
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    _chat.add(message);
    _chatCtl.add(List.unmodifiable(_chat));
  }

  @override
  Future<void> report(ContentReport report) async => reports.add(report);

  void _seed(DateTime now) {
    _places.addAll([
      Place(
        id: 'demo-place-1',
        type: PlaceType.club,
        name: 'Demo: Winterschwimm-Verein Seeufer',
        description: 'Beispiel-Eintrag. Gemeinsames Winterschwimmen jeden Sonntagmorgen.',
        lat: 47.3560,
        lng: 8.5530,
        ownerId: 'demo-user-1',
        ownerHandle: 'Demo · Gletscherfalke 21',
        createdAt: now,
        isDemo: true,
      ),
      Place(
        id: 'demo-place-2',
        type: PlaceType.publicSpot,
        name: 'Demo: Badeplatz am See',
        description: 'Beispiel-Eintrag. Flacher Einstieg, Steg vorhanden.',
        lat: 46.6900,
        lng: 7.7000,
        ownerId: 'demo-user-2',
        ownerHandle: 'Demo · Polarfuchs 47',
        createdAt: now,
        isDemo: true,
      ),
      Place(
        id: 'demo-place-3',
        type: PlaceType.privateBath,
        name: 'Demo: Privates Eisbad (Beispiel)',
        description:
            'Beispiel-Eintrag. Solarctic-Zen Eisbad, nach Absprache im Chat.',
        lat: 47.0500,
        lng: 8.3100,
        address: 'Beispielstrasse 1, 6000 Luzern (Demo)',
        ownerId: 'demo-user-3',
        ownerHandle: 'Demo · Firnotter 12',
        createdAt: now,
        isDemo: true,
      ),
    ]);
    _events.add(
      CommunityEvent(
        id: 'demo-event-1',
        title: 'Demo: Gemeinsames Winterschwimmen',
        description:
            'Beispiel-Termin. Treffpunkt beim Steg, danach heisser Tee.',
        startsAt: DateTime.utc(
          now.year,
          now.month,
          now.day,
          8,
        ).add(const Duration(days: 3)),
        location: 'Demo: Badeplatz am See',
        organizerId: 'demo-user-1',
        organizerHandle: 'Demo · Gletscherfalke 21',
        isDemo: true,
      ),
    );
    _offers.add(
      Offer(
        id: 'demo-offer-1',
        title: 'Demo: Einsteiger-Workshop Kälte & Atmung',
        category: OfferCategory.course,
        description: 'Beispiel-Angebot. Theorie, ruhige Atemübungen an Land und ein begleitetes erstes Eisbad.',
        location: 'Region Zürich',
        contact: 'Über den Community-Chat',
        providerId: 'demo-user-2',
        providerHandle: 'Demo · Polarfuchs 47',
        createdAt: now,
        isDemo: true,
      ),
    );
    _chat.addAll([
      ChatMessage(
        id: 'demo-msg-1',
        authorId: 'demo-user-1',
        authorHandle: 'Demo · Gletscherfalke 21',
        authorSymbol: AvatarSymbol.mountain,
        authorColor: 2,
        text: 'Willkommen im Community-Chat! (Beispielnachricht)',
        sentAt: now.subtract(const Duration(hours: 2)),
        isDemo: true,
      ),
      ChatMessage(
        id: 'demo-msg-2',
        authorId: 'demo-user-2',
        authorHandle: 'Demo · Polarfuchs 47',
        authorSymbol: AvatarSymbol.wave,
        authorColor: 5,
        text: 'Wer kommt am Sonntag zum Winterschwimmen? (Beispielnachricht)',
        sentAt: now.subtract(const Duration(minutes: 40)),
        isDemo: true,
      ),
    ]);
  }
}
