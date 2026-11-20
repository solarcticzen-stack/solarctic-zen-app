import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solarctic_zen/domain/profile/user_profile.dart';
import 'package:solarctic_zen/domain/questionnaire/questionnaire.dart';

import '../domain/helpers.dart';
import 'session_flow_test.dart' show Harness, holdToEnd, textOf;

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  if (f.evaluate().isEmpty) {
    // Noch nicht aufgebaut (lange Liste auf kleinem Bildschirm): hinscrollen.
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

UserProfile onboarded({Set<BathGoal> goals = const {}}) => UserProfile(
  goals: goals,
  onboardingCompletedAt: DateTime.utc(2026, 11, 1),
  safetyAcknowledgedAt: DateTime.utc(2026, 11, 1),
);

void main() {
  group('Profil-Bildschirm', () {
    testWidgets('Angaben und Ziele ändern und speichern', (tester) async {
      useTallScreen(tester);
      final h = Harness(profile: onboarded(goals: {BathGoal.sleep}));
      await h.start(tester);
      await tapKey(tester, 'open-profile');
      expect(find.text('Profil'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('ob-weight')), '72,5');
      await tapKey(tester, 'goal-recovery');
      await tapKey(tester, 'goal-sleep'); // abwählen
      await tapKey(tester, 'profile-save');
      expect(find.text('Profil gespeichert'), findsOneWidget);
      expect(h.profile.profile.weightKg, 72.5);
      expect(h.profile.profile.goals, {BathGoal.recovery});
    });

    testWidgets('Unplausibles Geburtsjahr wird abgefangen', (tester) async {
      useTallScreen(tester);
      final h = Harness(profile: onboarded());
      await h.start(tester);
      await tapKey(tester, 'open-profile');
      await tester.enterText(find.byKey(const Key('ob-birthyear')), '2025');
      await tapKey(tester, 'profile-save');
      expect(find.byKey(const Key('profile-error')), findsOneWidget);
      expect(h.profile.profile.birthYear, isNull);
    });

    testWidgets(
      'Aufwärm-Impuls ausschalten: nach dem Bad direkt zur Bewertung',
      (tester) async {
        useTallScreen(tester);
        final h = Harness(profile: onboarded());
        await h.start(tester);
        await tapKey(tester, 'open-profile');
        await tapKey(tester, 'setting-warmup');
        expect(await h.settings.get('warmup_enabled'), 'false');
        await tester.tap(find.byTooltip('Zurück'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tab-start')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('prep-start')));
        await tester.pumpAndSettle();
        await h.tick(tester, const Duration(seconds: 60));
        await holdToEnd(tester);
        expect(find.text('JETZT AKTIV AUFWÄRMEN'), findsNothing);
        expect(find.byKey(const Key('reflect-done')), findsOneWidget);
        await tapKey(tester, 'reflect-done');
        expect((await h.repo.all()).single.warmupExerciseId, isNull);
      },
    );

    testWidgets('Sicherheitshinweise jederzeit wieder lesbar', (tester) async {
      useTallScreen(tester);
      await Harness(profile: onboarded()).start(tester);
      await tapKey(tester, 'open-profile');
      await tapKey(tester, 'open-safety');
      expect(find.text('Nie allein'), findsOneWidget);
    });
  });

  group('Tipps und Energie', () {
    testWidgets('Tipp passt zum Ziel und zeigt Evidenz und Entwurf', (
      tester,
    ) async {
      useTallScreen(tester);
      final h = Harness(profile: onboarded(goals: {BathGoal.sleep}));
      await h.start(tester);
      final tip = textOf(tester, 'tip-text');
      final sleepTips = h.profile.profile.goals; // nur zur Lesbarkeit
      expect(sleepTips, contains(BathGoal.sleep));
      expect(tip.toLowerCase(), anyOf(contains('schlaf'), contains('kälte')));
      expect(find.text('Entwurf – Fachprüfung ausstehend'), findsOneWidget);
    });

    testWidgets('Tipp aktualisiert sich nach Profiländerung', (tester) async {
      useTallScreen(tester);
      final h = Harness(profile: onboarded(goals: {BathGoal.sleep}));
      await h.start(tester);
      final before = textOf(tester, 'tip-text');
      await h.profile.save(
        h.profile.profile.copyWith(goals: {BathGoal.longevity}),
      );
      await tester.pumpAndSettle();
      final after = textOf(tester, 'tip-text');
      expect(after, isNot(before));
      expect(after, contains('nicht belegt'));
    });

    testWidgets(
      'Ziel Abnehmen: Energie-Platzhalter in Bewertung, Details und Statistik',
      (tester) async {
        useTallScreen(tester);
        final s = session(d(2026, 11, 17));
        final h = Harness(
          initial: [s],
          profile: onboarded(goals: {BathGoal.weightLoss}),
        );
        await h.start(tester);

        await tester.tap(find.byKey(const Key('tab-start')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('prep-start')));
        await tester.pumpAndSettle();
        await h.tick(tester, const Duration(seconds: 90));
        await holdToEnd(tester);
        await tapKey(tester, 'warmup-skip');
        expect(
          textOf(tester, 'energy-estimate'),
          'Energie (Schätzung): ca. 70 kcal · Platzhalter',
        );
        await tapKey(tester, 'reflect-done');

        await tester.tap(find.text('Verlauf'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('view-stats')));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const Key('energy-total')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('ca. 140 kcal'), findsOneWidget);
        expect(find.textContaining('Platzhalter'), findsWidgets);
      },
    );

    testWidgets('Ohne Ziel Abnehmen keine Energie-Anzeige', (tester) async {
      useTallScreen(tester);
      final h = Harness(profile: onboarded(goals: {BathGoal.sleep}));
      await h.start(tester);
      await tester.tap(find.byKey(const Key('tab-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('prep-start')));
      await tester.pumpAndSettle();
      await h.tick(tester, const Duration(seconds: 60));
      await holdToEnd(tester);
      await tapKey(tester, 'warmup-skip');
      expect(find.byKey(const Key('energy-estimate')), findsNothing);
    });
  });

  group('Fragebögen', () {
    testWidgets(
      'WHO-5: fällig, beantworten, Wert gespeichert, Karte verschwindet, Diagramm erscheint',
      (tester) async {
        useTallScreen(tester);
        final h = Harness(profile: onboarded(goals: {BathGoal.mental}));
        await h.start(tester);
        expect(find.byKey(const Key('q-due-who5')), findsOneWidget);
        expect(
          find.byKey(const Key('q-due-sleep')),
          findsNothing,
          reason: 'Schlaf nicht als Ziel gewählt',
        );

        await tapKey(tester, 'q-due-who5');
        expect(textOf(tester, 'q-item'), 'Ich war froh und guter Laune.');
        for (final v in [3, 3, 4, 2, 3]) {
          await tapKey(tester, 'q-opt-$v');
        }
        expect(textOf(tester, 'q-score'), '60 / 100');
        expect(find.byKey(const Key('q-support')), findsNothing);
        expect(find.byKey(const Key('q-low')), findsNothing);
        final saved = (await h.questionnaires.all()).single;
        expect(saved.kind, QuestionnaireKind.who5);
        expect(saved.answers, [3, 3, 4, 2, 3]);
        await tapKey(tester, 'q-done');
        expect(
          find.byKey(const Key('q-due-who5')),
          findsNothing,
          reason: 'erst in 14 Tagen wieder',
        );

        await tester.tap(find.text('Verlauf'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('view-stats')));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const Key('chart-q-who5')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(const Key('chart-q-who5')), findsOneWidget);
      },
    );

    testWidgets('Zurück korrigiert die letzte Antwort', (tester) async {
      useTallScreen(tester);
      await Harness(profile: onboarded(goals: {BathGoal.mental})).start(tester);
      await tapKey(tester, 'q-due-who5');
      await tapKey(tester, 'q-opt-5');
      expect(
        textOf(tester, 'q-item'),
        'Ich habe mich ruhig und entspannt gefühlt.',
      );
      await tapKey(tester, 'q-back');
      expect(textOf(tester, 'q-item'), 'Ich war froh und guter Laune.');
    });

    testWidgets(
      'Sehr niedriges Wohlbefinden: unterstützender Hinweis mit 143',
      (tester) async {
        useTallScreen(tester);
        await Harness(profile: onboarded(goals: {BathGoal.stress}))
            .start(tester);
        await tapKey(tester, 'q-due-who5');
        for (final v in [1, 1, 1, 1, 1]) {
          await tapKey(tester, 'q-opt-$v');
        }
        expect(textOf(tester, 'q-score'), '20 / 100');
        expect(find.byKey(const Key('q-support')), findsOneWidget);
        expect(find.text('Die Dargebotene Hand: Telefon 143'), findsOneWidget);
      },
    );

    testWidgets('Niedriges Wohlbefinden: sanfter Hinweis', (tester) async {
      useTallScreen(tester);
      await Harness(profile: onboarded(goals: {BathGoal.mental})).start(tester);
      await tapKey(tester, 'q-due-who5');
      for (final v in [2, 2, 2, 2, 2]) {
        await tapKey(tester, 'q-opt-$v');
      }
      expect(textOf(tester, 'q-score'), '40 / 100');
      expect(find.byKey(const Key('q-low')), findsOneWidget);
      expect(find.byKey(const Key('q-support')), findsNothing);
    });

    testWidgets(
      'Schlaf-Kurzfragen: als nicht klinisch geprüft gekennzeichnet',
      (tester) async {
        useTallScreen(tester);
        final h = Harness(profile: onboarded(goals: {BathGoal.sleep}));
        await h.start(tester);
        await tapKey(tester, 'q-due-sleep');
        for (final v in [4, 3, 5, 4]) {
          await tapKey(tester, 'q-opt-$v');
        }
        expect(textOf(tester, 'q-score'), '75 / 100');
        expect(
          find.text('Diese Kurzfragen sind nicht klinisch geprüft.'),
          findsOneWidget,
        );
      },
    );
  });

  for (final (name, size, scale) in [
    ('iPhone SE', const Size(320, 568), 1.0),
    ('iPhone SE, grosse Schrift', const Size(320, 568), 1.6),
  ]) {
    testWidgets('Kein Überlauf in Profil und Fragebogen: $name', (
      tester,
    ) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await Harness(
        profile: onboarded(
          goals: {BathGoal.mental, BathGoal.weightLoss, BathGoal.medical},
        ),
      ).start(tester);
      expect(tester.takeException(), isNull, reason: 'Dashboard');
      await tapKey(tester, 'open-profile');
      expect(tester.takeException(), isNull, reason: 'Profil');
      await tester.tap(find.byTooltip('Zurück'));
      await tester.pumpAndSettle();
      await tapKey(tester, 'q-due-who5');
      for (final v in [1, 1, 1, 1, 1]) {
        await tapKey(tester, 'q-opt-$v');
        expect(tester.takeException(), isNull);
      }
      expect(find.byKey(const Key('q-support')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Ergebnis');
    });
  }
}
