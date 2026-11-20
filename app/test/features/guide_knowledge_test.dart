import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solarctic_zen/features/guide/entry_guide.dart';

import '../domain/helpers.dart';
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

Future<void> openKnowledge(WidgetTester tester) async {
  await tester.tap(find.text('Wissen'));
  await tester.pumpAndSettle();
}

void main() {
  group('Einstiegs-Guide (N-006)', () {
    testWidgets(
      'gut sichtbar auf «Heute» für Neue, 6 Schritte, Zurück, Verstanden',
      (tester) async {
        useTallScreen(tester);
        await Harness().start(tester);
        expect(find.byKey(const Key('guide-card')), findsOneWidget);
        // Der Guide steht vor «Diese Woche».
        expect(
          tester.getTopLeft(find.byKey(const Key('guide-card'))).dy,
          lessThan(tester.getTopLeft(find.text('DIESE WOCHE')).dy),
        );

        await tapKey(tester, 'guide-card');
        expect(textOf(tester, 'guide-title'), 'Einstellen');
        final titles = <String>[];
        for (var i = 0; i < EntryGuide.steps.length; i++) {
          titles.add(textOf(tester, 'guide-title'));
          if (i < EntryGuide.steps.length - 1) {
            await tapKey(tester, 'guide-next');
          }
        }
        expect(titles, [
          'Einstellen',
          'Ruhig atmen',
          'Stehend einatmen',
          'Beim Hinsetzen ausatmen',
          'Auf die Atmung konzentrieren',
          'Geniessen',
        ]);
        await tapKey(tester, 'guide-back');
        expect(textOf(tester, 'guide-title'), 'Auf die Atmung konzentrieren');
        await tapKey(tester, 'guide-next');
        expect(find.text('Verstanden'), findsOneWidget);
        await tapKey(tester, 'guide-next');
        expect(
          find.byKey(const Key('guide-title')),
          findsNothing,
          reason: 'geschlossen',
        );
      },
    );

    testWidgets(
      'Sicherheit: Kopf über Wasser und «Aussteigen ist immer richtig»',
      (tester) async {
        useTallScreen(tester);
        await Harness().start(tester);
        await tapKey(tester, 'guide-card');
        expect(
          find.textContaining('Aussteigen ist immer richtig'),
          findsOneWidget,
        );
        for (var i = 0; i < 3; i++) {
          await tapKey(tester, 'guide-next');
        }
        expect(
          find.textContaining('Der Kopf bleibt über Wasser'),
          findsOneWidget,
        );
      },
    );

    testWidgets('nach 5 Bädern nicht mehr auf «Heute», aber im Wissen', (
      tester,
    ) async {
      useTallScreen(tester);
      await Harness(
        initial: [for (var i = 1; i <= 5; i++) session(d(2026, 11, i))],
      ).start(tester);
      expect(find.byKey(const Key('guide-card')), findsNothing);
      await openKnowledge(tester);
      expect(find.byKey(const Key('guide-card')), findsOneWidget);
    });

    testWidgets('in der Vorbereitung und als Hinweis während des Vorlaufs', (
      tester,
    ) async {
      useTallScreen(tester);
      await Harness(countdown: null).start(tester);
      await tester.tap(find.byKey(const Key('tab-start')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('guide-card')), findsOneWidget);
      await tester.tap(find.byKey(const Key('prep-start')));
      await tester.pump();
      expect(textOf(tester, 'countdown-cue'), EntryGuide.countdownCue);
    });
  });

  group('Wissen (N-007)', () {
    testWidgets(
      'Sicherheitsartikel ist sofort lesbar, mit Evidenz und Quellen',
      (tester) async {
        useTallScreen(tester);
        await Harness().start(tester);
        await openKnowledge(tester);
        await tapKey(tester, 'article-safety-basics');
        expect(textOf(tester, 'article-title'), 'Sicher ins Eisbad');
        expect(find.text('Gut belegt'), findsOneWidget);
        expect(find.text('Entwurf – Fachprüfung ausstehend'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('QUELLEN'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('Tipton MJ'), findsWidgets);
      },
    );

    testWidgets('Beiträge werden mit Meilensteinen freigeschaltet', (
      tester,
    ) async {
      useTallScreen(tester);
      await Harness().start(tester);
      await openKnowledge(tester);
      expect(
        find.textContaining('«Erstes Eisbad» freigeschaltet'),
        findsOneWidget,
      );
      expect(
        find.textContaining('«5 Eisbäder» freigeschaltet'),
        findsOneWidget,
      );
      // Gesperrt: Antippen öffnet nichts.
      await tester.tap(find.byKey(const Key('article-first-60-seconds')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('article-title')), findsNothing);
    });

    testWidgets(
      'nach dem ersten Bad: Kälteschock-Artikel offen, Körper-Artikel noch gesperrt',
      (tester) async {
        useTallScreen(tester);
        await Harness(initial: [session(d(2026, 11, 18))]).start(tester);
        await openKnowledge(tester);
        expect(
          find.textContaining('«Erstes Eisbad» freigeschaltet'),
          findsNothing,
        );
        expect(
          find.textContaining('«5 Eisbäder» freigeschaltet'),
          findsOneWidget,
        );
        await tapKey(tester, 'article-first-60-seconds');
        expect(
          textOf(tester, 'article-title'),
          'Die ersten 60 Sekunden: Kälteschock verstehen',
        );
        expect(find.textContaining('Einordnung:'), findsWidgets);
      },
    );

    testWidgets('geplante Themen als Platzhalter sichtbar', (tester) async {
      useTallScreen(tester);
      await Harness().start(tester);
      await openKnowledge(tester);
      expect(find.text('IN VORBEREITUNG'), findsOneWidget);
      expect(
        find.text('Eisbad und Sport: Timing ist entscheidend'),
        findsOneWidget,
      );
    });
  });

  for (final (name, size, scale) in [
    ('iPhone SE', const Size(320, 568), 1.0),
    ('iPhone SE, grosse Schrift', const Size(320, 568), 1.6),
  ]) {
    testWidgets('Kein Überlauf in Guide und Wissen: $name', (tester) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await Harness(
        initial: [for (var i = 1; i <= 5; i++) session(d(2026, 11, i))],
      ).start(tester);
      await openKnowledge(tester);
      expect(tester.takeException(), isNull, reason: 'Wissen');
      await tapKey(tester, 'guide-card');
      for (var i = 0; i < EntryGuide.steps.length; i++) {
        expect(
          tester.takeException(),
          isNull,
          reason: 'Guide Schritt ${i + 1}',
        );
        await tapKey(tester, 'guide-next');
      }
      await tapKey(tester, 'article-body-and-cold');
      await tester.scrollUntilVisible(
        find.text('QUELLEN'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull, reason: 'Artikel');
    });
  }
}
