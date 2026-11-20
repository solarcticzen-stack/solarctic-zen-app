import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solarctic_zen/app.dart';
import 'package:solarctic_zen/app_services.dart';
import 'package:solarctic_zen/data/community_demo_repository.dart';
import 'package:solarctic_zen/data/memory_repository.dart';
import 'package:solarctic_zen/domain/community/community.dart';
import 'package:solarctic_zen/domain/knowledge/article.dart';
import 'package:solarctic_zen/domain/milestones/milestone.dart';
import 'package:solarctic_zen/domain/premium/premium.dart';
import 'package:solarctic_zen/domain/profile/tips.dart';
import 'package:solarctic_zen/domain/profile/user_profile.dart';
import 'package:solarctic_zen/domain/session/ice_session.dart';
import 'package:solarctic_zen/domain/warmup/warmup.dart';
import 'package:solarctic_zen/features/session/session_screen.dart';
import 'package:solarctic_zen/features/warmup/stick_figure.dart';

import '../domain/helpers.dart';

/// Kontrollierbare Uhr für Tests.
class FakeClock {
  FakeClock(this.current);
  DateTime current;
  DateTime now() => current;
  void advance(Duration d) => current = current.add(d);
}

final catalog = MilestoneCatalog.fromJson(
  jsonDecode(File('assets/milestones/catalog.v1.json').readAsStringSync())
      as Map<String, Object?>,
);

final warmupCatalog = WarmupCatalog.fromJson(
  jsonDecode(File('assets/warmup/catalog.v1.json').readAsStringSync())
      as Map<String, Object?>,
);

final tipCatalog = TipCatalog.fromJson(
  jsonDecode(File('assets/tips/catalog.v1.json').readAsStringSync())
      as Map<String, Object?>,
);

final knowledgeCatalog = buildKnowledgeCatalog(
  jsonDecode(File('assets/knowledge/de/index.json').readAsStringSync())
      as Map<String, Object?>,
  (f) => File('assets/knowledge/de/$f').readAsStringSync(),
);

class Harness {
  Harness({
    List<IceSession> initial = const [],
    int? countdown = 0,
    this.preview = false,
    UserProfile? profile,
  }) : repo = InMemorySessionRepository(initial) {
    // Standard: Onboarding bereits erledigt (ohne Sicherheits-Bestätigung,
    // damit gesperrte Kälte-Meilensteine prüfbar bleiben).
    this.profile = ProfileController(
      settings,
      profile ?? UserProfile(onboardingCompletedAt: DateTime.utc(2026, 11, 1)),
    );
    if (countdown != null) {
      settings.set(SettingKeys.countdownSeconds, '$countdown');
    }
  }

  final clock = FakeClock(DateTime.utc(2026, 11, 19, 7)); // Do, 08:00 in Zürich
  final InMemorySessionRepository repo;
  final settings = InMemorySettingsStore();
  late final ProfileController profile;
  late final community = LocalCommunityRepository(now: clock.current);
  late final communityProfile = CommunityProfileController(settings);
  final questionnaires = InMemoryQuestionnaireRepository();
  final bool preview;
  BathRegistration bathRegistration = const UnavailableBathRegistration();
  var _ids = 0;

  Widget app() => SolarcticZenApp(
    services: (child) => AppServices(
      sessions: repo,
      settings: settings,
      catalog: catalog,
      warmup: warmupCatalog,
      profile: profile,
      questionnaires: questionnaires,
      tips: tipCatalog,
      knowledge: knowledgeCatalog,
      community: community,
      communityProfile: communityProfile,
      mapTiles: false,
      bathRegistration: bathRegistration,
      random: Random(1),
      isPreview: preview,
      now: clock.now,
      utcOffsetMinutes: () => 60,
      idGenerator: ({DateTime? now}) => 'id${_ids++}',
      localToUtc: (day, h, m) => (
        DateTime.utc(
          day.year,
          day.month,
          day.day,
          h,
          m,
        ).subtract(const Duration(minutes: 60)),
        60,
      ),
      child: child,
    ),
  );

  /// Mit «Bewegung reduzieren», damit die Endlos-Animation der Aufwärm-Figur
  /// `pumpAndSettle` nicht blockiert (prüft zugleich diesen Pfad).
  Future<void> start(WidgetTester tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  Future<void> tick(WidgetTester tester, Duration d) async {
    clock.advance(d);
    await tester.pump(const Duration(milliseconds: 300));
  }
}

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

Future<void> holdToEnd(WidgetTester tester) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(const Key('session-end'))),
  );
  for (var i = 0; i < 16; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> openPrep(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('tab-start')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Start: Navigation, leeres Dashboard, Vorschau-Hinweis nur im Browser',
    (tester) async {
      final h = Harness(preview: true);
      await h.start(tester);
      expect(find.text('Verlauf'), findsOneWidget);
      expect(find.text('Erfolge'), findsOneWidget);
      expect(find.text('Wissen'), findsOneWidget);
      expect(find.text('VORSCHAU'), findsOneWidget);
      expect(
        find.byKey(const Key('guide-card')),
        findsOneWidget,
        reason: 'Guide gut sichtbar',
      );
      await tester.scrollUntilVisible(
        find.text('Noch keins – bereit für das erste?'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Noch keins – bereit für das erste?'), findsOneWidget);
      expect(textOf(tester, 'next-milestone'), 'Erstes Eisbad');
    },
  );

  testWidgets('Vorschau: Beispieldaten laden füllt Verlauf und Diagramme', (
    tester,
  ) async {
    final h = Harness(preview: true);
    await h.start(tester);
    await tester.tap(find.byKey(const Key('load-demo')));
    await tester.pumpAndSettle();
    final all = await h.repo.all();
    expect(all.length, greaterThan(25));
    expect(all.every((x) => x.id.startsWith('demo-')), isTrue);
    expect(
      all.every((x) => x.localDate.isBefore(d(2026, 11, 19))),
      isTrue,
      reason: 'nichts in der Zukunft',
    );
    expect(
      find.byKey(const Key('load-demo')),
      findsNothing,
      reason: 'nur einmal',
    );
  });

  testWidgets('Auf dem Gerät kein Vorschau-Hinweis', (tester) async {
    await Harness().start(tester);
    expect(find.text('VORSCHAU'), findsNothing);
    expect(find.byKey(const Key('load-demo')), findsNothing);
  });

  testWidgets('Wissen-Tab zeigt Guide und Beiträge', (tester) async {
    await Harness().start(tester);
    await tester.tap(find.text('Wissen'));
    await tester.pumpAndSettle();
    expect(find.text('Wissen'), findsWidgets);
    expect(find.byKey(const Key('guide-card')), findsOneWidget);
    expect(find.byKey(const Key('article-safety-basics')), findsOneWidget);
  });

  testWidgets(
    'Kompletter Ablauf: Temperatur, Timer, Pause, Halten, Reflexion, Speichern',
    (tester) async {
      // Reale iPhone-Grösse, damit «erste Bewertung ohne Scrollen» aussagekräftig ist.
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final h = Harness();
      await h.start(tester);
      await openPrep(tester);

      await tester.tap(find.byKey(const Key('temp-add')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('temp-minus')));
      await tester.pump();
      expect(textOf(tester, 'temp-value'), '9.5 °C');

      await tester.tap(find.byKey(const Key('prep-start')));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'session-timer'), '00:00');
      expect(
        (await h.repo.findActive())?.waterTempC,
        9.5,
        reason: 'sofort gespeichert',
      );

      await h.tick(tester, const Duration(seconds: 75));
      expect(textOf(tester, 'session-timer'), '01:15');

      await tester.tap(find.byKey(const Key('session-pause')));
      await tester.pump();
      expect(find.text('PAUSIERT'), findsOneWidget);
      await h.tick(tester, const Duration(seconds: 30));
      expect(textOf(tester, 'session-timer'), '01:15');
      expect(
        (await h.repo.findActive())!.clock.isPaused,
        isTrue,
        reason: 'Pause gespeichert',
      );

      await tester.tap(find.byKey(const Key('session-pause')));
      await h.tick(tester, const Duration(seconds: 45));
      expect(textOf(tester, 'session-timer'), '02:00');

      // Kurz tippen beendet nicht.
      await tester.tap(find.byKey(const Key('session-end')));
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.byKey(const Key('summary-duration')), findsNothing);

      await holdToEnd(tester);

      // Aufwärm-Impuls (A20) vor der Reflexion.
      expect(find.text('JETZT AKTIV AUFWÄRMEN'), findsOneWidget);
      expect(find.byKey(const Key('warmup-safety')), findsOneWidget);
      expect(
        (await h.repo.all()).single.isCompleted,
        isTrue,
        reason: 'Session ist schon vor dem Aufwärmen gespeichert',
      );
      final first = textOf(tester, 'warmup-title');
      await tester.tap(find.byKey(const Key('warmup-other')));
      await tester.pump();
      final second = textOf(tester, 'warmup-title');
      expect(second, isNot(first), reason: '«Andere Übung» wechselt');
      await tester.tap(find.byKey(const Key('warmup-done')));
      await tester.pumpAndSettle();

      expect(textOf(tester, 'summary-duration'), '02:00');
      expect(
        find.text('Schön aufgewärmt. Zieh dich jetzt warm an.'),
        findsOneWidget,
      );
      // Erstes Bad bei 9.5 °C: Anzahl + zwei Erfahrungs-Meilensteine.
      // Eine gemeinsame Karte statt drei grosser.
      expect(find.text('NEUE MEILENSTEINE'), findsOneWidget);
      expect(find.text('Erstes Eisbad'), findsOneWidget);
      expect(find.text('Unter 10 °C'), findsOneWidget);
      expect(
        find.byKey(const Key('new-article-first-60-seconds')),
        findsOneWidget,
        reason: 'Neu im Wissen',
      );

      // Die erste Bewertung muss ohne Scrollen sichtbar sein (N-005).
      expect(find.byKey(const Key('overcome-2')).hitTestable(), findsOneWidget);
      Future<void> tapVisible(String key) async {
        await tester.ensureVisible(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key(key)));
        await tester.pump();
      }

      await tapVisible('overcome-2');
      await tapVisible('during-3');
      await tapVisible('feeling-4');
      await tester.ensureVisible(find.byKey(const Key('notes')));
      await tester.enterText(find.byKey(const Key('notes')), 'Ruhig geblieben');
      await tester.tap(find.byKey(const Key('reflect-done')));
      await tester.pumpAndSettle();

      final saved = (await h.repo.all()).single;
      expect(saved.isCompleted, isTrue);
      expect(saved.duration, const Duration(minutes: 2));
      expect(saved.feelingAfter, 4);
      expect(saved.overcomeRating, 2);
      expect(saved.duringRating, 3);
      expect(saved.notes, 'Ruhig geblieben');
      expect(saved.countdownSeconds, isNull);
      expect(saved.warmupDone, isTrue);
      expect(
        warmupCatalog.byId(saved.warmupExerciseId!)!.text('de').title,
        second,
        reason: 'gespeichert wird die tatsächlich gezeigte Übung',
      );
      expect(
        await h.settings.get(SettingKeys.warmupRecent),
        saved.warmupExerciseId,
      );

      expect(textOf(tester, 'week-count'), '1 Eisbad');
      expect(textOf(tester, 'last-session'), 'Do, 19.11.2026 · 02:00 · 9.5 °C');
      expect(await h.settings.get(SettingKeys.lastTempC), '9.5');
    },
  );

  testWidgets('Vorlauf: Badezeit beginnt exakt nach Ablauf', (tester) async {
    final h = Harness(countdown: null); // Standard: 10 s
    await h.start(tester);
    await openPrep(tester);
    expect(find.text('Vorlauf starten (10 s)'), findsOneWidget);

    final pressedAt = h.clock.current;
    await tester.tap(find.byKey(const Key('prep-start')));
    await tester.pump();
    expect(textOf(tester, 'countdown-value'), '10');
    expect(await h.repo.findActive(), isNull, reason: 'Vorlauf zählt nicht');

    await h.tick(tester, const Duration(milliseconds: 9500));
    expect(textOf(tester, 'countdown-value'), '1');

    await h.tick(tester, const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    final active = await h.repo.findActive();
    expect(active, isNotNull);
    expect(active!.startedAt, pressedAt.add(const Duration(seconds: 10)));
    expect(active.countdownSeconds, 10);
    expect(textOf(tester, 'session-timer'), '00:00');
    expect(await h.settings.get(SettingKeys.countdownSeconds), '10');
  });

  testWidgets('Vorlauf abbrechen und Wahl «Aus» merken', (tester) async {
    final h = Harness(countdown: null);
    await h.start(tester);
    await openPrep(tester);
    await tester.tap(find.byKey(const Key('prep-start')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('countdown-cancel')));
    await tester.pump();
    expect(find.byKey(const Key('prep-start')), findsOneWidget);
    expect(await h.repo.all(), isEmpty);

    await tester.tap(find.byKey(const Key('countdown-0')));
    await tester.pump();
    expect(find.text('Ins Wasser'), findsOneWidget);
    await tester.tap(find.byKey(const Key('prep-start')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('session-timer')), findsOneWidget);
    expect(await h.settings.get(SettingKeys.countdownSeconds), '0');
  });

  group('Wiederherstellung nach Absturz', () {
    IceSession running(FakeClock clock) => IceSession.startNow(
      id: 'crashed',
      now: clock.current.subtract(const Duration(minutes: 2)),
      utcOffsetMinutes: 60,
    );

    testWidgets('Fortsetzen: Timer läuft mit korrekter Zeit weiter', (
      tester,
    ) async {
      final clock = FakeClock(DateTime.utc(2026, 11, 19, 7));
      final h = Harness(initial: [running(clock)]);
      await h.start(tester);
      expect(find.text('Laufende Session gefunden'), findsOneWidget);
      await tester.tap(find.byKey(const Key('recover-resume')));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'session-timer'), '02:00');
    });

    testWidgets('Jetzt beenden: Session wird abgeschlossen gespeichert', (
      tester,
    ) async {
      final clock = FakeClock(DateTime.utc(2026, 11, 19, 7));
      final h = Harness(initial: [running(clock)]);
      await h.start(tester);
      await tester.tap(find.byKey(const Key('recover-end')));
      await tester.pumpAndSettle();
      final s = (await h.repo.all()).single;
      expect(s.isCompleted, isTrue);
      expect(s.duration, const Duration(minutes: 2));
    });

    testWidgets('Verwerfen: zählt nicht', (tester) async {
      final clock = FakeClock(DateTime.utc(2026, 11, 19, 7));
      final h = Harness(initial: [running(clock)]);
      await h.start(tester);
      await tester.tap(find.byKey(const Key('recover-discard')));
      await tester.pumpAndSettle();
      expect((await h.repo.all()).single.status, SessionStatus.discarded);
      expect(textOf(tester, 'week-count'), '0 Eisbäder');
    });
  });

  Future<void> openHistory(WidgetTester tester, String view) async {
    await tester.tap(find.text('Verlauf'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('view-$view')));
    await tester.pumpAndSettle();
  }

  testWidgets('Verlauf-Liste: Löschen (über Details) und Rückgängig', (
    tester,
  ) async {
    final a = session(d(2026, 11, 17), seconds: 120, temp: 6);
    final b = session(d(2026, 11, 18), seconds: 240);
    final h = Harness(initial: [a, b]);
    await h.start(tester);
    await openHistory(tester, 'list');
    expect(find.text('NOVEMBER 2026'), findsOneWidget);
    expect(find.byKey(Key('session-${a.id}')), findsOneWidget);

    // Löschen über die Detailansicht.
    await tester.tap(find.byKey(Key('session-${a.id}')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('detail-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('detail-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('session-${a.id}')), findsNothing);

    await tester.tap(find.text('Rückgängig'));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('session-${a.id}')), findsOneWidget);
  });

  testWidgets('Kalender: Badetage, Tag antippen, Monat wechseln', (
    tester,
  ) async {
    final a = session(d(2026, 11, 17), seconds: 120, temp: 6);
    final b = session(d(2026, 11, 17), seconds: 60);
    final c = session(d(2026, 10, 5), seconds: 90);
    final h = Harness(initial: [a, b, c]);
    await h.start(tester);
    await tester.tap(find.text('Verlauf'));
    await tester.pumpAndSettle();

    // Kalender ist die Startansicht, aktueller Monat.
    expect(textOf(tester, 'month-title'), 'November 2026');
    expect(textOf(tester, 'month-summary'), '2 Eisbäder · 3 min gesamt');
    // Heute (19.11.) ohne Bad → keine Tagesauswahl vorbelegt.
    expect(find.byKey(const Key('selected-day')), findsNothing);
    // Zukunft ist gesperrt.
    expect(
      tester.widget<IconButton>(find.byKey(const Key('month-next'))).onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('day-2026-11-17')));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'selected-day'), 'DI, 17.11.2026');
    expect(find.byKey(Key('session-${a.id}')), findsOneWidget);
    expect(find.byKey(Key('session-${b.id}')), findsOneWidget);
    expect(
      find.text('2'),
      findsWidgets,
      reason: 'Zähler für zwei Bäder am Tag',
    );

    await tester.tap(find.byKey(const Key('day-2026-11-18')));
    await tester.pumpAndSettle();
    expect(find.text('Kein Eisbad an diesem Tag.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('month-prev')));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'month-title'), 'Oktober 2026');
    expect(textOf(tester, 'month-summary'), '1 Eisbad · 1 min gesamt');
    await tester.tap(find.byKey(const Key('month-next')));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'month-title'), 'November 2026');
  });

  testWidgets('Statistik: Kennzahlen, drei Diagramme, Entwicklung', (
    tester,
  ) async {
    final h = Harness(
      initial: [
        session(d(2026, 8, 1), seconds: 60, feeling: 3, temp: 12),
        session(d(2026, 11, 17), seconds: 120, temp: 6),
        session(d(2026, 11, 18), seconds: 240, feeling: 5),
      ],
    );
    await h.start(tester);
    await openHistory(tester, 'stats');
    expect(find.text('7 min'), findsOneWidget); // Gesamtzeit
    expect(find.byKey(const Key('chart-weekly')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('comparison-table')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('chart-duration')), findsOneWidget);
    expect(find.byKey(const Key('chart-temperature')), findsOneWidget);
    expect(find.text('ERSTE 30 TAGE'), findsOneWidget);
  });

  testWidgets('Statistik ohne Daten: Hinweise statt leerer Diagramme', (
    tester,
  ) async {
    await Harness().start(tester);
    await openHistory(tester, 'stats');
    expect(find.text('Noch keine Daten'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('comparison-pending')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(textOf(tester, 'comparison-pending'), contains('noch 60 Tage'));
  });

  testWidgets('Erfolge: Zusammenfassung und gesperrte Kälte-Meilensteine', (
    tester,
  ) async {
    final h = Harness(initial: [session(d(2026, 11, 18), temp: 3)]);
    await h.start(tester);
    await tester.tap(find.text('Erfolge'));
    await tester.pumpAndSettle();
    final summary = textOf(tester, 'milestones-summary');
    expect(
      summary,
      startsWith('3 von ${catalog.milestones.length}'),
      reason: 'Anzahl 1, unter 15 °C, unter 10 °C; unter 5 °C gesperrt',
    );
    await tester.scrollUntilVisible(find.text('Unter 5 °C'), 300);
    expect(find.textContaining('Sicherheits-Grundlagen'), findsWidgets);
  });

  for (final (name, size, scale) in [
    ('iPhone SE', const Size(320, 568), 1.0),
    ('iPhone SE, grosse Schrift', const Size(320, 568), 1.6),
    ('grosses Smartphone', const Size(430, 932), 1.0),
  ]) {
    testWidgets('Kein Layout-Überlauf in allen Phasen: $name', (tester) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final h = Harness(
        initial: [session(d(2026, 11, 18), temp: 4, feeling: 5)],
        countdown: null,
        preview: true,
      );
      await h.start(tester);
      await tester.tap(find.text('Verlauf'));
      await tester.pumpAndSettle();
      for (final view in ['list', 'stats', 'calendar']) {
        await tester.tap(find.byKey(Key('view-$view')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: view);
      }
      await tester.scrollUntilVisible(
        find.byKey(const Key('day-2026-11-18')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('day-2026-11-18')));
      await tester.pumpAndSettle();
      for (final tab in ['Erfolge', 'Heute']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
      }
      await openPrep(tester);
      await tester.scrollUntilVisible(
        find.byKey(const Key('temp-add')),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('temp-add')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('prep-start')));
      await tester.pump();
      expect(find.byKey(const Key('countdown-value')), findsOneWidget);
      await h.tick(tester, const Duration(seconds: 11));
      await tester.pumpAndSettle();
      await h.tick(tester, const Duration(hours: 1, minutes: 2, seconds: 3));
      // 1 s nach Vorlauf-Ende + 1:02:03
      expect(textOf(tester, 'session-timer'), '1:02:04');
      await holdToEnd(tester);
      // Aufwärm-Schritt mit längster Übung und aufgeklapptem «Warum?».
      for (final ex in warmupCatalog.exercises) {
        while (textOf(tester, 'warmup-title') != ex.text('de').title) {
          await tester.tap(find.byKey(const Key('warmup-other')));
          await tester.pump();
        }
        expect(tester.takeException(), isNull, reason: ex.id);
      }
      await tester.scrollUntilVisible(
        find.byKey(const Key('warmup-why')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('warmup-why')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('warmup-skip')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reflect-done')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Aufwärmen überspringen wird als «nicht erledigt» gespeichert', (
    tester,
  ) async {
    final h = Harness();
    await h.start(tester);
    await openPrep(tester);
    await tester.tap(find.byKey(const Key('prep-start')));
    await tester.pumpAndSettle();
    await h.tick(tester, const Duration(seconds: 90));
    await holdToEnd(tester);
    await tester.tap(find.byKey(const Key('warmup-skip')));
    await tester.pumpAndSettle();
    expect(find.text('Wärm dich jetzt in Ruhe wieder auf.'), findsOneWidget);
    final saved = (await h.repo.all()).single;
    expect(saved.warmupDone, isFalse);
    expect(saved.warmupExerciseId, isNotNull);
  });

  testWidgets('«Warum aktiv aufwärmen?» zeigt Evidenzstufe und Prüfstatus', (
    tester,
  ) async {
    final h = Harness();
    await h.start(tester);
    await openPrep(tester);
    await tester.tap(find.byKey(const Key('prep-start')));
    await tester.pumpAndSettle();
    await holdToEnd(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('warmup-why')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('warmup-why')));
    await tester.pumpAndSettle();
    expect(find.text('Erste Hinweise'), findsOneWidget);
    expect(find.text('Entwurf – fachliche Prüfung ausstehend'), findsOneWidget);
    expect(find.textContaining('Afterdrop'), findsOneWidget);
  });

  testWidgets('Strichfigur bewegt sich, ausser bei «Bewegung reduzieren»', (
    tester,
  ) async {
    Future<Pose> poseAfter(Duration d, {required bool reduce}) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: reduce);
      await tester.pumpWidget(
        const MaterialApp(home: StickFigure(animationKey: 'squat')),
      );
      await tester.pump(d);
      final painter = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(StickFigure),
          matching: find.byType(CustomPaint),
        ),
      );
      // ignore: avoid_dynamic_calls
      return (painter.painter as dynamic).pose as Pose;
    }

    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final moving = await poseAfter(
      const Duration(milliseconds: 800),
      reduce: false,
    );
    expect(
      moving[J.hip]!.dy,
      greaterThan(56),
      reason: 'Hüfte sinkt in die Hocke',
    );
    await tester.pumpWidget(const SizedBox());

    final still = await poseAfter(
      const Duration(milliseconds: 800),
      reduce: true,
    );
    expect(still[J.hip], const Offset(50, 56));
  });

  test('Für jede Übung im Katalog gibt es eine Animation', () {
    for (final e in warmupCatalog.exercises) {
      expect(stickAnimations.containsKey(e.animation), isTrue, reason: e.id);
    }
  });

  /// Hohes Testfenster (800 × 1600), damit Formulare ohne Scrollen sichtbar sind.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.5;
    addTearDown(tester.view.reset);
  }

  group('Detail, Bearbeiten, Nachtragen', () {
    IceSession withNote() => session(
      d(2026, 11, 17),
      seconds: 150,
      temp: 5.5,
      feeling: 4,
      notes: 'Ruhig geblieben.\nAtmung war gut.',
    );

    testWidgets(
      'Notiz ist in Liste (Vorschau) und Detailansicht lesbar (N-003)',
      (tester) async {
        useTallScreen(tester);
        final s = withNote();
        final h = Harness(initial: [s]);
        await h.start(tester);
        await openHistory(tester, 'list');
        expect(find.byKey(Key('note-preview-${s.id}')), findsOneWidget);

        await tester.tap(find.byKey(Key('session-${s.id}')));
        await tester.pumpAndSettle();
        expect(textOf(tester, 'detail-title'), 'Di, 17.11.2026');
        expect(textOf(tester, 'detail-duration'), '02:30');
        expect(
          tester
              .widget<SelectableText>(find.byKey(const Key('detail-notes')))
              .data,
          'Ruhig geblieben.\nAtmung war gut.',
        );
        expect(find.text('4 / 5 · Gut'), findsOneWidget);
        expect(find.text('5.5 °C'), findsOneWidget);
        expect(find.text('manuell nachgetragen'), findsOneWidget);
      },
    );

    testWidgets('Auch aus dem Kalender: Session antippen öffnet die Details', (
      tester,
    ) async {
      useTallScreen(tester);
      final s = withNote();
      final h = Harness(initial: [s]);
      await h.start(tester);
      await tester.tap(find.text('Verlauf'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('day-2026-11-17')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(Key('session-${s.id}')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(Key('session-${s.id}')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail-notes')), findsOneWidget);
    });

    testWidgets('Bearbeiten: Dauer, Empfinden, Notiz ändern', (tester) async {
      useTallScreen(tester);
      final s = withNote();
      final h = Harness(initial: [s]);
      await h.start(tester);
      await openHistory(tester, 'list');
      await tester.tap(find.byKey(Key('session-${s.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail-edit')));
      await tester.pumpAndSettle();
      expect(find.text('Eisbad bearbeiten'), findsOneWidget);
      expect(textOf(tester, 'edit-duration'), '02:30');
      expect(textOf(tester, 'edit-time-value'), '09:00');

      await tester.tap(find.byKey(const Key('dur-min-plus')));
      await tester.tap(find.byKey(const Key('dur-sec-minus')));
      await tester.pump();
      expect(textOf(tester, 'edit-duration'), '03:25');
      await tester.tap(find.byKey(const Key('feeling-5')));
      await tester.enterText(
        find.byKey(const Key('edit-notes')),
        'Neu formuliert',
      );
      await tester.tap(find.byKey(const Key('edit-save')));
      await tester.pumpAndSettle();

      expect(textOf(tester, 'detail-duration'), '03:25');
      final saved = (await h.repo.all()).single;
      expect(saved.duration, const Duration(seconds: 205));
      expect(saved.feelingAfter, 5);
      expect(saved.notes, 'Neu formuliert');
      expect(saved.localDate, d(2026, 11, 17));
      expect(saved.createdAt, s.createdAt);
    });

    testWidgets('Nachtragen aus dem Kalender: Tag ist vorbelegt', (
      tester,
    ) async {
      useTallScreen(tester);
      final h = Harness();
      await h.start(tester);
      await tester.tap(find.text('Verlauf'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('day-2026-11-17')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('calendar-add')));
      await tester.pumpAndSettle();
      expect(find.text('Eisbad nachtragen'), findsOneWidget);
      expect(find.text('Di, 17.11.2026'), findsOneWidget);
      expect(textOf(tester, 'edit-time-value'), '07:00');
      await tester.tap(find.byKey(const Key('edit-save')));
      await tester.pumpAndSettle();

      final saved = (await h.repo.all()).single;
      expect(saved.entryMode, EntryMode.manual);
      expect(saved.localDate, d(2026, 11, 17));
      expect(saved.startedAt, DateTime.utc(2026, 11, 17, 6));
      expect(saved.duration, const Duration(minutes: 2));
      expect(textOf(tester, 'month-summary'), '1 Eisbad · 2 min gesamt');
      expect(find.text('Eisbad nachgetragen'), findsOneWidget);
    });

    testWidgets('Überschneidung mit vorhandenem Eisbad wird verhindert', (
      tester,
    ) async {
      useTallScreen(tester);
      // Heute 07:51 Lokalzeit; Vorschlag beim Nachtragen ist 07:50 (jetzt 08:00 − 10 min).
      final existing = IceSession.manual(
        id: 'vorhanden',
        startedAt: DateTime.utc(2026, 11, 19, 6, 51),
        duration: const Duration(minutes: 2),
        utcOffsetMinutes: 60,
        now: DateTime.utc(2026, 11, 19, 6, 53),
      );
      useTallScreen(tester);
      final h = Harness(initial: [existing]);
      await h.start(tester);
      await tester.tap(find.text('Verlauf'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-manual')));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'edit-time-value'), '07:50');
      await tester.tap(find.byKey(const Key('edit-save')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('edit-error')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        textOf(tester, 'edit-error'),
        contains('Überschneidet sich mit dem Eisbad'),
      );
      expect(await h.repo.all(), hasLength(1));
    });

    testWidgets('Eintrag in der Zukunft wird verhindert', (tester) async {
      useTallScreen(tester);
      final h = Harness();
      await h.start(tester);
      await tester.tap(find.text('Verlauf'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-manual')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byKey(const Key('dur-min-plus')));
      }
      await tester.pump();
      await tester.tap(find.byKey(const Key('edit-save')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('edit-error')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        textOf(tester, 'edit-error'),
        'Das Eisbad kann nicht in der Zukunft liegen.',
      );
      expect(await h.repo.all(), isEmpty);
    });

    testWidgets('Datumsauswahl ist auf Deutsch', (tester) async {
      useTallScreen(tester);
      final h = Harness();
      await h.start(tester);
      await tester.tap(find.text('Verlauf'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-manual')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit-date')));
      await tester.pumpAndSettle();
      expect(find.text('Datum des Eisbads'), findsOneWidget);
      // Material zeigt die Aktionen hier in Grossbuchstaben.
      expect(find.text('ABBRECHEN'), findsOneWidget);
      await tester.tap(find.text('ABBRECHEN'));
      await tester.pumpAndSettle();
    });

    testWidgets('Löschen aus der Detailansicht mit Rückgängig', (tester) async {
      useTallScreen(tester);
      final s = withNote();
      final h = Harness(initial: [s]);
      await h.start(tester);
      await openHistory(tester, 'list');
      await tester.tap(find.byKey(Key('session-${s.id}')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('detail-delete')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const Key('detail-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('session-${s.id}')), findsNothing);
      await tester.tap(find.text('Rückgängig'));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('session-${s.id}')), findsOneWidget);
    });

    for (final (name, size, scale) in [
      ('iPhone SE', const Size(320, 568), 1.0),
      ('iPhone SE, grosse Schrift', const Size(320, 568), 1.6),
    ]) {
      testWidgets('Kein Überlauf in Detail und Formular: $name', (
        tester,
      ) async {
        tester.view.physicalSize = size * 3;
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final s = withNote();
        await Harness(initial: [s]).start(tester);
        await openHistory(tester, 'list');
        final tile = find.byKey(Key('session-${s.id}'));
        await tester.scrollUntilVisible(
          tile,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        expect(
          tester.getSize(tile).height,
          lessThan(500),
          reason: 'Listeneintrag bleibt kompakt (vorher 800 px, Testschrift ist breiter als echte)',
        );
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const Key('detail-edit')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
