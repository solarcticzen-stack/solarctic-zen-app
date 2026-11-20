import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/knowledge/article.dart';
import 'package:solarctic_zen/domain/milestones/milestone.dart';

const sample = '''---
id: test
title: Testartikel
summary: Kurz zusammengefasst.
evidence: early
minutes: 2
unlock: count.5
reviewed: false
sources:
  - Muster A et al. Ein Titel. Zeitschrift, 2020.
  - Beispiel B. Noch ein Titel. Journal, 2021.
---
## Erste Überschrift
Ein Absatz, der über
zwei Zeilen geht.

- Punkt eins
- Punkt zwei
> Ein Hinweis zur Evidenz.
''';

void main() {
  test('Artikel mit Kopfdaten und Blöcken parsen', () {
    final a = parseArticle(sample);
    expect(a.id, 'test');
    expect(a.evidence, ArticleEvidence.early);
    expect(a.minutes, 2);
    expect(a.unlockMilestone, 'count.5');
    expect(a.reviewed, isFalse);
    expect(a.sources, hasLength(2));
    expect(
      a.blocks[0],
      isA<HeadingBlock>().having((b) => b.text, 'text', 'Erste Überschrift'),
    );
    expect(
      a.blocks[1],
      isA<ParagraphBlock>().having(
        (b) => b.text,
        'text',
        'Ein Absatz, der über zwei Zeilen geht.',
      ),
    );
    expect(a.blocks[2], isA<BulletBlock>());
    expect(a.blocks[4], isA<NoteBlock>());
  });

  test('Freischaltung über Meilensteine', () {
    final a = parseArticle(sample);
    expect(a.isUnlocked({}), isFalse);
    expect(a.isUnlocked({'count.5'}), isTrue);
    final always = parseArticle(
      sample.replaceFirst('unlock: count.5', 'unlock: always'),
    );
    expect(always.isUnlocked({}), isTrue);
  });

  test('fehlende Pflichtfelder und Kopfdaten werden erkannt', () {
    expect(() => parseArticle('nur Text'), throwsFormatException);
    expect(
      () => parseArticle(sample.replaceFirst('title: Testartikel\n', '')),
      throwsFormatException,
    );
    expect(
      () => parseArticle(
        sample.replaceFirst('evidence: early', 'evidence: toll'),
      ),
      throwsFormatException,
    );
  });

  group('Mitgelieferte Artikel', () {
    final index = jsonDecode(
      File('assets/knowledge/de/index.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final files = [
      for (final f in index['articles']! as List<Object?>) f! as String,
    ];
    final articles = [
      for (final f in files)
        parseArticle(File('assets/knowledge/de/$f').readAsStringSync()),
    ];
    final milestones = MilestoneCatalog.fromJson(
      jsonDecode(File('assets/milestones/catalog.v1.json').readAsStringSync())
          as Map<String, Object?>,
    );

    test(
      'mindestens drei Artikel, alle mit Quellen und als Entwurf markiert',
      () {
        expect(articles.length, greaterThanOrEqualTo(3));
        for (final a in articles) {
          expect(a.sources, isNotEmpty, reason: a.id);
          expect(a.reviewed, isFalse, reason: '${a.id}: Fachreview steht aus');
          expect(a.blocks.whereType<HeadingBlock>(), isNotEmpty, reason: a.id);
        }
      },
    );

    test(
      'Freischalt-Meilensteine existieren und verweisen auf diese Artikel',
      () {
        final ids = {for (final m in milestones.milestones) m.id};
        for (final a in articles) {
          if (a.unlockMilestone != null) {
            expect(ids, contains(a.unlockMilestone), reason: a.id);
          }
        }
        expect(
          articles.first.unlockMilestone,
          isNull,
          reason: 'Sicherheit ist immer lesbar',
        );
      },
    );

    test('keine Heilsversprechen', () {
      final banned = RegExp(
        r'\bheilt\b|garantiert|nachweislich gesünder|entgiftet|verbrennt fett',
        caseSensitive: false,
      );
      for (final a in articles) {
        for (final b in a.blocks) {
          expect(
            banned.hasMatch(b.text),
            isFalse,
            reason: '${a.id}: ${b.text}',
          );
        }
      }
    });

    test('geplante Themen als Platzhalter vorhanden', () {
      expect(
        (index['planned']! as List<Object?>).length,
        greaterThanOrEqualTo(5),
      );
    });
  });
}
