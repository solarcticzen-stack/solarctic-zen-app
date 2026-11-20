import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solarctic_zen/domain/profile/user_profile.dart';

import 'session_flow_test.dart' show Harness;

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

void main() {
  testWidgets(
    'Erster Start: Onboarding komplett, Profil gespeichert, App öffnet sich',
    (tester) async {
      useTallScreen(tester);
      final h = Harness(profile: const UserProfile());
      await h.start(tester);

      expect(find.byKey(const Key('ob-logo')), findsOneWidget);
      expect(find.text('Willkommen'), findsOneWidget);
      await tapKey(tester, 'ob-next');

      // Über dich
      expect(find.text('Über dich'), findsOneWidget);
      await tapKey(tester, 'sex-female');
      await tester.enterText(find.byKey(const Key('ob-height')), '172');
      await tester.enterText(find.byKey(const Key('ob-birthyear')), '1990');
      await tapKey(tester, 'ob-next');

      // Ziele
      expect(find.text('Warum Eisbaden?'), findsOneWidget);
      await tapKey(tester, 'goal-sleep');
      await tapKey(tester, 'goal-mental');
      await tapKey(tester, 'ob-next');

      // Sicherheit: erst nach Bestätigung weiter
      expect(find.text('Sicher ins Eisbad'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byKey(const Key('ob-next'))).onPressed,
        isNull,
      );
      await tapKey(tester, 'ob-safety');
      await tapKey(tester, 'ob-next');

      // Einwilligung: erst nach Zustimmung fertig
      expect(find.text('Deine Daten'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('ob-finish')))
            .onPressed,
        isNull,
      );
      await tapKey(tester, 'ob-consent');
      await tapKey(tester, 'ob-finish');

      // App ist offen
      expect(find.text('Heute'), findsWidgets);
      final p = h.profile.profile;
      expect(p.onboarded, isTrue);
      expect(p.sex, Sex.female);
      expect(p.heightCm, 172);
      expect(p.weightKg, isNull, reason: 'freiwillig, leer gelassen');
      expect(p.birthYear, 1990);
      expect(p.goals, {BathGoal.sleep, BathGoal.mental});
      expect(p.safetyAcknowledgedAt, isNotNull);
      expect(p.healthConsentAt, isNotNull);
      expect(
        await h.settings.get('profile'),
        contains('"sex":"female"'),
        reason: 'dauerhaft gespeichert',
      );
    },
  );

  testWidgets('Alle Angaben dürfen leer bleiben («keine Angabe»)', (
    tester,
  ) async {
    useTallScreen(tester);
    final h = Harness(profile: const UserProfile());
    await h.start(tester);
    await tapKey(tester, 'ob-next');
    await tapKey(tester, 'ob-next');
    await tapKey(tester, 'ob-next');
    await tapKey(tester, 'ob-safety');
    await tapKey(tester, 'ob-next');
    await tapKey(tester, 'ob-consent');
    await tapKey(tester, 'ob-finish');
    final p = h.profile.profile;
    expect(p.onboarded, isTrue);
    expect(p.sex, Sex.unspecified);
    expect(p.heightCm, isNull);
    expect(p.goals, isEmpty);
  });

  testWidgets('Unplausible Grösse wird abgefangen', (tester) async {
    useTallScreen(tester);
    final h = Harness(profile: const UserProfile());
    await h.start(tester);
    await tapKey(tester, 'ob-next');
    await tester.enterText(find.byKey(const Key('ob-height')), '50');
    await tapKey(tester, 'ob-next');
    expect(find.byKey(const Key('ob-error')), findsOneWidget);
    expect(
      find.text('Über dich'),
      findsOneWidget,
      reason: 'bleibt auf dem Schritt',
    );
    await tester.enterText(find.byKey(const Key('ob-height')), '180');
    await tapKey(tester, 'ob-next');
    expect(find.text('Warum Eisbaden?'), findsOneWidget);
  });

  testWidgets('Ziel «krankheitsbedingt» zeigt den Arzt-Hinweis', (
    tester,
  ) async {
    useTallScreen(tester);
    await Harness(profile: const UserProfile()).start(tester);
    await tapKey(tester, 'ob-next');
    await tapKey(tester, 'ob-next');
    expect(find.byKey(const Key('medical-note')), findsNothing);
    await tapKey(tester, 'goal-medical');
    expect(find.byKey(const Key('medical-note')), findsOneWidget);
  });

  testWidgets('Sicherheits-Bestätigung schaltet die Kälte-Meilensteine frei', (
    tester,
  ) async {
    useTallScreen(tester);
    final h = Harness(
      profile: UserProfile(
        onboardingCompletedAt: DateTime.utc(2026, 11, 1),
        safetyAcknowledgedAt: DateTime.utc(2026, 11, 1),
      ),
    );
    await h.start(tester);
    await tester.tap(find.text('Erfolge'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sicherheits-Grundlagen'), findsNothing);
  });

  for (final (name, size, scale) in [
    ('iPhone SE', const Size(320, 568), 1.0),
    ('iPhone SE, grosse Schrift', const Size(320, 568), 1.6),
  ]) {
    testWidgets('Kein Überlauf im Onboarding: $name', (tester) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await Harness(profile: const UserProfile()).start(tester);
      await tapKey(tester, 'ob-next'); // → Über dich
      expect(tester.takeException(), isNull, reason: 'Über dich');
      await tapKey(tester, 'ob-next'); // → Ziele
      await tapKey(tester, 'goal-medical');
      expect(tester.takeException(), isNull, reason: 'Ziele');
      await tapKey(tester, 'ob-next'); // → Sicherheit
      final safety = find.byKey(const Key('ob-safety'));
      await tester.scrollUntilVisible(
        safety,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapKey(tester, 'ob-safety');
      expect(tester.takeException(), isNull, reason: 'Sicherheit');
      await tapKey(tester, 'ob-next'); // → Einwilligung
      expect(tester.takeException(), isNull);
    });
  }
}
