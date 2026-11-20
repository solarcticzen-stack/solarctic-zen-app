import 'package:meta/meta.dart';

/// Wissensbereich (FEATURES.md §E). Artikel liegen als Markdown mit Kopfdaten
/// in `assets/knowledge/de/` – neue Artikel ohne Code-Änderung.
enum ArticleEvidence {
  good('Gut belegt'),
  early('Erste Hinweise'),
  insufficient('Unzureichend untersucht'),
  mixed('Gemischte Evidenz'),
  practice('Praxis');

  const ArticleEvidence(this.label);
  final String label;
}

/// Ein Block im Artikeltext.
@immutable
sealed class ArticleBlock {
  const ArticleBlock(this.text);
  final String text;
}

class HeadingBlock extends ArticleBlock {
  const HeadingBlock(super.text);
}

class ParagraphBlock extends ArticleBlock {
  const ParagraphBlock(super.text);
}

class BulletBlock extends ArticleBlock {
  const BulletBlock(super.text);
}

/// Hervorgehobener Hinweis («> …»), z. B. Evidenz-Einordnung.
class NoteBlock extends ArticleBlock {
  const NoteBlock(super.text);
}

@immutable
class KnowledgeArticle {
  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.evidence,
    required this.minutes,
    required this.blocks,
    required this.sources,
    required this.reviewed,
    this.unlockMilestone,
  });

  final String id;
  final String title;
  final String summary;
  final ArticleEvidence evidence;
  final int minutes;
  final List<ArticleBlock> blocks;
  final List<String> sources;

  /// `false` = Entwurf, fachliche Prüfung ausstehend.
  final bool reviewed;

  /// Meilenstein-ID, nach der der Artikel freigeschaltet wird; `null` = immer.
  final String? unlockMilestone;

  bool isUnlocked(Set<String> achievedMilestones) =>
      unlockMilestone == null || achievedMilestones.contains(unlockMilestone);
}

/// Liest einen Artikel im Format:
/// ```
/// ---
/// id: first-60-seconds
/// title: …
/// summary: …
/// evidence: good
/// minutes: 3
/// unlock: count.1
/// reviewed: false
/// sources:
///   - Autor et al. Titel. Zeitschrift, Jahr.
/// ---
/// ## Überschrift
/// Absatz …
/// - Aufzählung
/// > Hinweis
/// ```
KnowledgeArticle parseArticle(String raw) {
  final text = raw.replaceAll('\r\n', '\n');
  final parts = text.split(RegExp(r'^---\s*$', multiLine: true));
  if (parts.length < 3) {
    throw const FormatException('Kopfdaten fehlen (--- … ---)');
  }
  final meta = <String, String>{};
  final sources = <String>[];
  String? listKey;
  for (final line in parts[1].split('\n')) {
    if (line.trim().isEmpty) continue;
    final item = RegExp(r'^\s+-\s+(.*)$').firstMatch(line);
    if (item != null && listKey == 'sources') {
      sources.add(item.group(1)!.trim());
      continue;
    }
    final kv = RegExp(r'^(\w+):\s*(.*)$').firstMatch(line);
    if (kv == null) throw FormatException('Ungültige Kopfzeile', line);
    listKey = kv.group(1);
    meta[kv.group(1)!] = kv.group(2)!.trim();
  }
  String req(String k) =>
      meta[k] ?? (throw FormatException('Pflichtfeld fehlt: $k'));

  final blocks = <ArticleBlock>[];
  final para = <String>[];
  void flush() {
    if (para.isNotEmpty) {
      blocks.add(ParagraphBlock(para.join(' ')));
      para.clear();
    }
  }

  for (final line in parts.sublist(2).join('---').split('\n')) {
    final l = line.trim();
    if (l.isEmpty) {
      flush();
    } else if (l.startsWith('## ')) {
      flush();
      blocks.add(HeadingBlock(l.substring(3).trim()));
    } else if (l.startsWith('- ')) {
      flush();
      blocks.add(BulletBlock(l.substring(2).trim()));
    } else if (l.startsWith('> ')) {
      flush();
      blocks.add(NoteBlock(l.substring(2).trim()));
    } else {
      para.add(l);
    }
  }
  flush();

  final unlock = meta['unlock'];
  return KnowledgeArticle(
    id: req('id'),
    title: req('title'),
    summary: req('summary'),
    evidence:
        ArticleEvidence.values.asNameMap()[req('evidence')] ??
        (throw FormatException('Unbekannte Evidenzstufe', meta['evidence'])),
    minutes: int.parse(req('minutes')),
    unlockMilestone: unlock == null || unlock.isEmpty || unlock == 'always'
        ? null
        : unlock,
    reviewed: meta['reviewed'] == 'true',
    sources: List.unmodifiable(sources),
    blocks: List.unmodifiable(blocks),
  );
}

/// Geplante, noch nicht geschriebene Beiträge (Platzhalter im Wissensbereich).
@immutable
class PlannedTopic {
  const PlannedTopic(this.title, this.unlockHint);
  final String title;
  final String unlockHint;
}

@immutable
class KnowledgeCatalog {
  const KnowledgeCatalog({required this.articles, this.planned = const []});

  final List<KnowledgeArticle> articles;
  final List<PlannedTopic> planned;

  KnowledgeArticle? byId(String id) {
    for (final a in articles) {
      if (a.id == id) return a;
    }
    return null;
  }
}

/// Baut den Katalog aus `index.json` und den Artikeltexten.
KnowledgeCatalog buildKnowledgeCatalog(
  Map<String, Object?> index,
  String Function(String file) readArticle,
) => KnowledgeCatalog(
  articles: [
    for (final f in index['articles']! as List<Object?>)
      parseArticle(readArticle(f! as String)),
  ],
  planned: [
    for (final raw in (index['planned'] as List<Object?>?) ?? const [])
      if (raw case final Map<String, Object?> t)
        PlannedTopic(
          t['title']! as String,
          (t['hint'] as String?) ?? 'in Vorbereitung',
        ),
  ],
);
