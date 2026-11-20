import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/milestones/milestone.dart';

import 'helpers.dart';

MilestoneCatalog loadCatalog() => MilestoneCatalog.fromJson(
  jsonDecode(File('assets/milestones/catalog.v1.json').readAsStringSync())
      as Map<String, Object?>,
);

MilestoneStatus byId(List<MilestoneStatus> all, String id) =>
    all.singleWhere((s) => s.definition.id == id);

void main() {
  final today = d(2026, 11, 19);
  final catalog = loadCatalog();

  group('Katalog', () {
    test('lädt vollständig mit deutschen und englischen Texten', () {
      expect(catalog.version, 1);
      expect(catalog.milestones.length, greaterThanOrEqualTo(25));
      for (final m in catalog.milestones) {
        expect(m.texts.keys, containsAll(['de', 'en']), reason: m.id);
        expect(m.text('de').title, isNotEmpty);
      }
    });

    test(
      'Regelmässigkeit im Vordergrund (Sicherheitsregel FEATURES.md §D)',
      () {
        // Einzel-Dauer wird bewusst nicht belohnt: Es gibt dafür keinen
        // Regeltyp. Dauer zählt nur kumuliert (TotalDurationRule).
        expect(
          catalog.milestones
              .where((m) => m.category == MilestoneCategory.routine)
              .length,
          greaterThanOrEqualTo(5),
          reason: 'Regelmässigkeit soll im Vordergrund stehen',
        );
      },
    );

    test('Temperatur ≤ 5 °C erst nach Sicherheits-Grundlagen', () {
      final cold = catalog.milestones.where(
        (m) => m.rule is FirstTempRule && (m.rule as FirstTempRule).maxC <= 5,
      );
      expect(cold, isNotEmpty);
      for (final m in cold) {
        expect(m.requires, contains('knowledge.safety_basics'));
      }
    });

    test('unbekannte Regeltypen und Kategorien werden übersprungen', () {
      final c = MilestoneCatalog.fromJson({
        'version': 2,
        'milestones': [
          {
            'id': 'a',
            'category': 'count',
            'rule': {'type': 'session_count', 'min': 1},
            'i18n': _t,
          },
          {
            'id': 'b',
            'category': 'count',
            'rule': {'type': 'future_rule'},
            'i18n': _t,
          },
          {
            'id': 'c',
            'category': 'unknown',
            'rule': {'type': 'session_count', 'min': 1},
            'i18n': _t,
          },
        ],
      });
      expect(c.milestones.map((m) => m.id), ['a']);
    });

    test('doppelte IDs werden abgelehnt', () {
      expect(
        () => MilestoneCatalog.fromJson({
          'version': 1,
          'milestones': [
            {
              'id': 'a',
              'category': 'count',
              'rule': {'type': 'session_count', 'min': 1},
              'i18n': _t,
            },
            {
              'id': 'a',
              'category': 'count',
              'rule': {'type': 'session_count', 'min': 2},
              'i18n': _t,
            },
          ],
        }),
        throwsFormatException,
      );
    });
  });

  group('Nächster Meilenstein', () {
    test('neuer Nutzer: «Erstes Eisbad»', () {
      final all = MilestoneEngine.evaluate(catalog, [], today: today);
      expect(MilestoneEngine.next(all)!.definition.id, 'count.1');
    });

    test('schlägt nie einen Temperatur-Meilenstein vor', () {
      // Nach einem warmen Bad wäre «Unter 10 °C» sonst ein naheliegender Vorschlag.
      final list = [
        for (var i = 1; i <= 3; i++) session(d(2026, 11, i), temp: 12),
      ];
      final all = MilestoneEngine.evaluate(catalog, list, today: today);
      expect(
        MilestoneEngine.next(all)!.definition.category,
        isNot(MilestoneCategory.experience),
      );
    });
  });

  group('MilestoneEngine', () {
    test('ohne Sessions ist nichts erreicht', () {
      final all = MilestoneEngine.evaluate(catalog, [], today: today);
      expect(all.where((s) => s.achieved), isEmpty);
      expect(MilestoneEngine.next(all), isNotNull);
    });

    test('Anzahl: Zeitpunkt ist die auslösende Session', () {
      final list = [for (var i = 1; i <= 6; i++) session(d(2026, 11, i))];
      final all = MilestoneEngine.evaluate(catalog, list, today: today);
      expect(byId(all, 'count.1').achievedSessionId, list[0].id);
      expect(byId(all, 'count.5').achievedSessionId, list[4].id);
      final ten = byId(all, 'count.10');
      expect(ten.achieved, isFalse);
      expect(ten.current, 6);
      expect(ten.progress, closeTo(0.6, 1e-9));
    });

    test('Gesamtzeit wird kumuliert', () {
      final list = [
        session(d(2026, 11, 1), seconds: 300),
        session(d(2026, 11, 2), seconds: 300),
      ];
      final all = MilestoneEngine.evaluate(catalog, list, today: today);
      expect(byId(all, 'duration.10m').achievedSessionId, list[1].id);
      expect(byId(all, 'duration.30m').current, 600);
    });

    test('Wochen in Folge, inkl. Doppelwoche', () {
      final list = [
        session(d(2026, 10, 27)),
        session(d(2026, 11, 3)),
        session(d(2026, 11, 4)),
        session(d(2026, 11, 10)),
      ];
      final all = MilestoneEngine.evaluate(catalog, list, today: today);
      expect(byId(all, 'routine.weeks_3').achievedSessionId, list[3].id);
      expect(
        byId(all, 'routine.first_double_week').achievedSessionId,
        list[2].id,
      );
      expect(byId(all, 'routine.weeks_4').current, 3);
    });

    test('10 Sessions in einem Kalendermonat', () {
      final list = [for (var i = 1; i <= 10; i++) session(d(2026, 10, i * 3))];
      final all = MilestoneEngine.evaluate(catalog, list, today: today);
      expect(byId(all, 'routine.month_10').achieved, isTrue);
    });

    test('Wiedereinstieg nach Pause', () {
      final list = [session(d(2026, 9, 1)), session(d(2026, 10, 15))];
      final all = MilestoneEngine.evaluate(catalog, list, today: today);
      expect(byId(all, 'routine.comeback').achievedSessionId, list[1].id);
    });

    test('kalte Meilensteine bleiben ohne Sicherheits-Grundlagen gesperrt', () {
      final list = [session(d(2026, 11, 1), temp: 3)];
      final locked = MilestoneEngine.evaluate(catalog, list, today: today);
      expect(byId(locked, 'experience.below_10c').achieved, isTrue);
      expect(byId(locked, 'experience.below_5c').locked, isTrue);
      expect(byId(locked, 'experience.below_5c').achieved, isFalse);

      final open = MilestoneEngine.evaluate(
        catalog,
        list,
        today: today,
        externalAchievements: {'knowledge.safety_basics'},
      );
      expect(byId(open, 'experience.below_5c').achieved, isTrue);
      expect(byId(open, 'experience.at_2c').achieved, isFalse);
    });

    test('Löschen einer Session nimmt den Meilenstein wieder weg (abgeleiteter Zustand)', () {
      final s = session(d(2026, 11, 1));
      expect(
        byId(
          MilestoneEngine.evaluate(catalog, [s], today: today),
          'count.1',
        ).achieved,
        isTrue,
      );
      final deleted = s.copyWith(deletedAt: () => DateTime.utc(2026));
      expect(
        byId(
          MilestoneEngine.evaluate(catalog, [deleted], today: today),
          'count.1',
        ).achieved,
        isFalse,
      );
    });

    test('Reflexion zählt Empfinden oder Notiz', () {
      final list = [
        for (var i = 1; i <= 10; i++)
          session(
            d(2026, 11, i),
            feeling: i.isEven ? 4 : null,
            notes: i.isOdd ? 'gut' : null,
          ),
      ];
      final all = MilestoneEngine.evaluate(catalog, list, today: today);
      expect(byId(all, 'mindfulness.reflect_10').achieved, isTrue);
    });
  });
}

const _t = {
  'de': {'title': 'T', 'description': 'D', 'message': 'M'},
  'en': {'title': 'T', 'description': 'D', 'message': 'M'},
};
