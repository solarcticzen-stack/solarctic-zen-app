import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solarctic_zen/domain/community/community.dart';
import 'package:solarctic_zen/domain/premium/premium.dart';

import 'session_flow_test.dart' show Harness, textOf;

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.5;
  addTearDown(tester.view.reset);
}

Future<void> openCommunity(WidgetTester tester) async {
  await tester.tap(find.text('Community'));
  await tester.pumpAndSettle();
}

/// Harness mit bereits beigetretenem Mitglied.
Future<Harness> joined(
  WidgetTester tester, {
  bool premium = false,
  bool preview = false,
  BathRegistration? registration,
}) async {
  final h = Harness(preview: preview);
  if (registration != null) h.bathRegistration = registration;
  await h.communityProfile.save(
    CommunityProfile(
      id: 'me',
      handle: 'Polarfuchs 12',
      symbol: AvatarSymbol.wave,
      colorIndex: 1,
      joinedAt: DateTime.utc(2026, 11, 1),
      tier: premium ? MemberTier.premium : MemberTier.member,
    ),
  );
  await h.start(tester);
  await openCommunity(tester);
  return h;
}

void main() {
  group('Beitritt', () {
    testWidgets(
      'Name vorgeschlagen, Avatar wählen, Regeln bestätigen, beitreten',
      (tester) async {
        useTallScreen(tester);
        final h = Harness();
        await h.start(tester);
        await openCommunity(tester);
        expect(find.byKey(const Key('community-join')), findsOneWidget);
        expect(
          find.textContaining('Gesundheitsangaben werden nie geteilt'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('community-join-button')),
              )
              .onPressed,
          isNull,
        );

        await tapKey(tester, 'handle-suggestion-1');
        final chosen = tester
            .widget<TextField>(find.byKey(const Key('community-handle')))
            .controller!
            .text;
        expect(Handles.validate(chosen), isNull);
        await tapKey(tester, 'avatar-symbol-mountain');
        await tapKey(tester, 'avatar-color-4');
        await tapKey(tester, 'community-rules');
        await tapKey(tester, 'community-join-button');

        final me = h.communityProfile.profile!;
        expect(me.handle, chosen);
        expect(me.symbol, AvatarSymbol.mountain);
        expect(me.colorIndex, 4);
        expect(me.tier, MemberTier.member);
        expect(
          find.byKey(const Key('community-local-banner')),
          findsOneWidget,
          reason: 'ehrlicher Hinweis ohne Server',
        );
      },
    );

    testWidgets('unzulässiger Name wird abgelehnt', (tester) async {
      useTallScreen(tester);
      final h = Harness();
      await h.start(tester);
      await openCommunity(tester);
      await tester.enterText(
        find.byKey(const Key('community-handle')),
        'Du Arschloch',
      );
      await tapKey(tester, 'community-rules');
      await tapKey(tester, 'community-join-button');
      expect(find.byKey(const Key('community-error')), findsOneWidget);
      expect(h.communityProfile.profile, isNull);
    });

    testWidgets('Community verlassen löscht das Profil', (tester) async {
      useTallScreen(tester);
      final h = await joined(tester);
      await tapKey(tester, 'community-me');
      await tapKey(tester, 'leave-community');
      expect(h.communityProfile.profile, isNull);
      expect(find.byKey(const Key('community-join')), findsOneWidget);
    });
  });

  group('Karte', () {
    testWidgets('Orte als Marker und Liste, Filter, Details mit Adresse', (
      tester,
    ) async {
      useTallScreen(tester);
      await joined(tester);
      expect(find.byKey(const Key('marker-demo-place-1')), findsOneWidget);
      expect(find.byKey(const Key('place-demo-place-3')), findsOneWidget);
      expect(find.text('3 Orte'), findsOneWidget);

      await tapKey(tester, 'filter-club');
      expect(find.byKey(const Key('marker-demo-place-1')), findsNothing);
      expect(find.text('2 Orte'), findsOneWidget);

      await tapKey(tester, 'place-demo-place-3');
      expect(
        find.byKey(const Key('place-details-demo-place-3')),
        findsOneWidget,
      );
      expect(textOf(tester, 'place-address'), contains('Luzern'));
    });

    testWidgets('Marker antippen öffnet die Details', (tester) async {
      useTallScreen(tester);
      await joined(tester);
      await tester.tap(find.byKey(const Key('marker-demo-place-2')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('place-details-demo-place-2')),
        findsOneWidget,
      );
    });

    testWidgets('Mitglied ohne Premium kann nicht eintragen', (tester) async {
      useTallScreen(tester);
      await joined(tester);
      await tapKey(tester, 'add-place');
      expect(find.byKey(const Key('premium-required')), findsOneWidget);
    });

    testWidgets('Premium: privates Eisbad mit Adresse nur mit Bestätigung', (
      tester,
    ) async {
      useTallScreen(tester);
      final h = await joined(tester, preview: true);
      await tapKey(tester, 'community-me');
      await tapKey(tester, 'premium-demo');
      await tester.tapAt(const Offset(10, 10)); // Sheet schliessen
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('premium-badge')), findsOneWidget);
      expect(h.communityProfile.profile!.canPublish, isTrue);

      await tapKey(tester, 'add-place');
      await tester.enterText(
        find.byKey(const Key('place-name')),
        'Eisbad im Garten',
      );
      await tester.enterText(
        find.byKey(const Key('place-address')),
        'Seeweg 5, 8000 Zürich',
      );
      await tapKey(tester, 'publish-save');
      expect(textOf(tester, 'publish-error'), contains('Adresse'));

      await tapKey(tester, 'place-consent');
      await tapKey(tester, 'publish-save');
      expect(find.text('Ort eingetragen'), findsOneWidget);
      expect(find.text('Eisbad im Garten'), findsOneWidget);
      expect(find.text('4 Orte'), findsOneWidget);
    });
  });

  group('Termine und Angebote', () {
    testWidgets('Termine: Demo sichtbar, Premium trägt neuen Termin ein', (
      tester,
    ) async {
      useTallScreen(tester);
      await joined(tester, premium: true);
      await tapKey(tester, 'community-events');
      expect(find.byKey(const Key('event-demo-event-1')), findsOneWidget);
      await tapKey(tester, 'add-event');
      await tester.enterText(
        find.byKey(const Key('event-title')),
        'Vollmond-Eisbaden',
      );
      await tester.enterText(
        find.byKey(const Key('event-location')),
        'Steg beim Seebad',
      );
      await tapKey(tester, 'publish-save');
      expect(find.text('Termin eingetragen'), findsOneWidget);
      expect(find.text('Vollmond-Eisbaden'), findsOneWidget);
    });

    testWidgets('Angebote: Hinweis, Premium präsentiert einen Kurs', (
      tester,
    ) async {
      useTallScreen(tester);
      await joined(tester, premium: true);
      await tapKey(tester, 'community-offers');
      expect(find.textContaining('nicht geprüft'), findsOneWidget);
      await tapKey(tester, 'add-offer');
      expect(find.textContaining('nie im oder am Wasser'), findsOneWidget);
      await tapKey(tester, 'offer-category-coaching');
      await tester.enterText(
        find.byKey(const Key('offer-title')),
        'Kälte-Coaching für Einsteiger',
      );
      await tester.enterText(
        find.byKey(const Key('offer-description')),
        'Drei begleitete Eisbäder mit Atemübungen an Land.',
      );
      await tapKey(tester, 'publish-save');
      expect(find.text('Angebot veröffentlicht'), findsOneWidget);
      expect(find.text('Kälte-Coaching für Einsteiger'), findsOneWidget);
    });

    testWidgets('ohne Premium: Termin eintragen gesperrt', (tester) async {
      useTallScreen(tester);
      await joined(tester);
      await tapKey(tester, 'community-events');
      await tapKey(tester, 'add-event');
      expect(find.byKey(const Key('premium-required')), findsOneWidget);
    });
  });

  group('Chat', () {
    testWidgets('Nachricht senden, Wortfilter', (tester) async {
      useTallScreen(tester);
      await joined(tester);
      await tapKey(tester, 'community-chat');
      expect(find.byKey(const Key('msg-demo-msg-1')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('chat-input')),
        'Hallo zusammen!',
      );
      await tapKey(tester, 'chat-send');
      expect(find.text('Hallo zusammen!'), findsOneWidget);
      expect(find.text('Du'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('chat-input')),
        'Du Arschloch',
      );
      await tapKey(tester, 'chat-send');
      expect(find.byKey(const Key('chat-error')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('chat-list')),
          matching: find.text('Du Arschloch'),
        ),
        findsNothing,
        reason: 'nicht gesendet (Text bleibt nur im Eingabefeld)',
      );
    });

    testWidgets('Melden und Blockieren', (tester) async {
      useTallScreen(tester);
      final h = await joined(tester);
      await tapKey(tester, 'community-chat');

      await tapKey(tester, 'actions-demo-msg-2');
      await tester.tap(find.text('Melden'));
      await tester.pumpAndSettle();
      await tapKey(tester, 'report-reason-1');
      expect(h.community.reports.single.targetId, 'demo-msg-2');
      expect(find.textContaining('Danke für die Meldung'), findsOneWidget);

      await tapKey(tester, 'actions-demo-msg-2');
      await tester.tap(find.text('Mitglied blockieren'));
      await tester.pumpAndSettle();
      await tapKey(tester, 'confirm-block');
      expect(find.byKey(const Key('msg-demo-msg-2')), findsNothing);
      expect(h.communityProfile.profile!.blocked, {'demo-user-2'});

      // Auch auf der Karte ausgeblendet.
      await tapKey(tester, 'community-map');
      expect(find.byKey(const Key('place-demo-place-2')), findsNothing);
    });
  });

  for (final (name, size, scale) in [
    ('iPhone SE', const Size(320, 568), 1.0),
    ('iPhone SE, grosse Schrift', const Size(320, 568), 1.6),
  ]) {
    testWidgets('Kein Überlauf in der Community: $name', (tester) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final h = Harness();
      await h.start(tester);
      await openCommunity(tester);
      expect(tester.takeException(), isNull, reason: 'Beitritt');
      await h.communityProfile.save(
        CommunityProfile(
          id: 'me',
          handle: 'Gletscherfalke 77',
          symbol: AvatarSymbol.star,
          colorIndex: 2,
          joinedAt: DateTime.utc(2026),
          tier: MemberTier.premium,
        ),
      );
      await tester.pumpAndSettle();
      for (final view in [
        'community-map',
        'community-events',
        'community-offers',
        'community-chat',
      ]) {
        await tapKey(tester, view);
        expect(tester.takeException(), isNull, reason: view);
      }
    });
  }

  group('Premium freischalten', () {
    testWidgets('aus dem Hinweis: Eisbad registrieren, ohne Server ehrlich', (
      tester,
    ) async {
      useTallScreen(tester);
      final h = await joined(tester);
      await tapKey(tester, 'add-place');
      await tapKey(tester, 'premium-learn');
      expect(find.byKey(const Key('premium-screen')), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('premium-subscribe')))
            .onPressed,
        isNull,
        reason: 'Abo erst mit dem App-Release',
      );

      await tester.enterText(find.byKey(const Key('premium-serial')), 'ab');
      await tapKey(tester, 'premium-register');
      expect(textOf(tester, 'premium-result'), contains('6 bis 32'));

      await tester.enterText(
        find.byKey(const Key('premium-serial')),
        'SZ-2026 0001',
      );
      await tapKey(tester, 'premium-register');
      expect(textOf(tester, 'premium-result'), contains('Server-Anbindung'));
      expect(h.communityProfile.profile!.canPublish, isFalse);
    });

    testWidgets('bestätigte Registrierung schaltet Premium frei', (
      tester,
    ) async {
      useTallScreen(tester);
      final reg = _FakeRegistration(RegistrationOutcome.granted);
      final h = await joined(tester, registration: reg);
      await tapKey(tester, 'community-me');
      expect(
        find.byKey(const Key('premium-demo')),
        findsNothing,
        reason: 'Demo-Schalter nur in der Vorschau',
      );
      await tapKey(tester, 'premium-open');
      await tester.enterText(
        find.byKey(const Key('premium-serial')),
        'sz-2026 0001',
      );
      await tapKey(tester, 'premium-register');
      expect(reg.received, 'SZ20260001', reason: 'normalisiert');
      expect(textOf(tester, 'premium-result'), contains('freigeschaltet'));
      expect(h.communityProfile.profile!.canPublish, isTrue);
    });

    testWidgets('bereits verbundenes Eisbad', (tester) async {
      useTallScreen(tester);
      await joined(
        tester,
        registration: _FakeRegistration(RegistrationOutcome.alreadyClaimed),
      );
      await tapKey(tester, 'community-me');
      await tapKey(tester, 'premium-open');
      await tester.enterText(
        find.byKey(const Key('premium-serial')),
        'SZ20260001',
      );
      await tapKey(tester, 'premium-register');
      expect(textOf(tester, 'premium-result'), contains('anderen Konto'));
    });

    testWidgets('Kein Überlauf: iPhone SE, grosse Schrift', (tester) async {
      tester.view.physicalSize = const Size(320, 568) * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await joined(tester);
      await tapKey(tester, 'community-me');
      await tapKey(tester, 'premium-open');
      expect(tester.takeException(), isNull);
    });
  });
}

class _FakeRegistration implements BathRegistration {
  _FakeRegistration(this.outcome);

  final RegistrationOutcome outcome;
  String? received;

  @override
  Future<RegistrationOutcome> register(String serial) async {
    received = serial;
    return outcome;
  }
}
