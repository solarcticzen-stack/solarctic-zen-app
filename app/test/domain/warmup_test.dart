import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/warmup/warmup.dart';

WarmupCatalog loadWarmup() => WarmupCatalog.fromJson(
  jsonDecode(File('assets/warmup/catalog.v1.json').readAsStringSync())
      as Map<String, Object?>,
);

void main() {
  final catalog = loadWarmup();

  test('Katalog: Übungen mit deutschen und englischen Texten', () {
    expect(catalog.exercises.length, greaterThanOrEqualTo(6));
    for (final e in catalog.exercises) {
      expect(e.texts.keys, containsAll(['de', 'en']), reason: e.id);
      expect(e.text('de').how, isNotEmpty);
    }
    // Notiz N-002 nennt diese Übungen ausdrücklich.
    expect(catalog.byId('squats'), isNotNull);
    expect(catalog.byId('pushups'), isNotNull);
    expect(catalog.byId('jumping_jacks'), isNotNull);
  });

  test('Sprünge und Ausfallschritte tragen den Rutsch-Hinweis', () {
    expect(catalog.byId('jumping_jacks')!.slipRisk, isTrue);
    expect(catalog.byId('lunges')!.slipRisk, isTrue);
    expect(catalog.byId('wall_pushups')!.slipRisk, isFalse);
  });

  test('nie dieselbe Übung wie bei den letzten drei Malen', () {
    final picker = WarmupPicker(catalog, random: Random(1));
    var recent = <String>[];
    for (var i = 0; i < 200; i++) {
      final e = picker.pick(recentIds: recent);
      expect(recent.take(3), isNot(contains(e.id)), reason: 'Durchgang $i');
      recent = WarmupPicker.remember(recent, e.id);
    }
  });

  test('über viele Sessions kommen alle Übungen vor', () {
    final picker = WarmupPicker(catalog, random: Random(7));
    var recent = <String>[];
    final seen = <String>{};
    for (var i = 0; i < 100; i++) {
      final e = picker.pick(recentIds: recent);
      seen.add(e.id);
      recent = WarmupPicker.remember(recent, e.id);
    }
    expect(seen, catalog.exercises.map((e) => e.id).toSet());
  });

  test('«Andere Übung» liefert nie die aktuelle', () {
    final picker = WarmupPicker(catalog, random: Random(3));
    for (var i = 0; i < 50; i++) {
      final current = catalog.exercises[i % catalog.exercises.length].id;
      expect(picker.pick(exclude: current).id, isNot(current));
    }
  });

  test('funktioniert auch mit sehr kleinem Katalog', () {
    final small = WarmupCatalog.fromJson({
      'version': 1,
      'exercises': [
        {'id': 'a', 'animation': 'x', 'i18n': _t},
        {'id': 'b', 'animation': 'x', 'i18n': _t},
      ],
    });
    final picker = WarmupPicker(small, random: Random(1));
    expect(picker.pick(recentIds: ['a', 'b'], exclude: 'a').id, 'b');
    expect(picker.pick(recentIds: ['a']).id, 'b');
  });

  test('Verlauf: neueste zuerst, ohne Duplikate, begrenzt', () {
    expect(WarmupPicker.remember(['b', 'a'], 'a'), ['a', 'b']);
    expect(WarmupPicker.remember(['1', '2', '3', '4', '5'], '6'), [
      '6',
      '1',
      '2',
      '3',
      '4',
    ]);
  });

  test('leerer Katalog und doppelte IDs werden abgelehnt', () {
    expect(
      () => WarmupCatalog.fromJson({'version': 1, 'exercises': <Object>[]}),
      throwsFormatException,
    );
    expect(
      () => WarmupCatalog.fromJson({
        'version': 1,
        'exercises': [
          {'id': 'a', 'animation': 'x', 'i18n': _t},
          {'id': 'a', 'animation': 'x', 'i18n': _t},
        ],
      }),
      throwsFormatException,
    );
  });
}

const _t = {
  'de': {'title': 'T', 'how': 'H'},
};
