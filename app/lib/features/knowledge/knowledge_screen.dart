import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/knowledge/article.dart';
import '../../domain/milestones/milestone.dart';
import '../../domain/session/ice_session.dart';
import '../guide/entry_guide.dart';

/// IDs der erreichten Meilensteine (für Freischaltungen).
Set<String> achievedMilestoneIds(AppServices s, List<IceSession> sessions) => {
  for (final m in MilestoneEngine.evaluate(
    s.catalog,
    sessions,
    today: s.today(),
    externalAchievements: s.externalAchievements,
  ))
    if (m.achieved) m.definition.id,
};

/// Wissen (FEATURES.md §E): Einstiegs-Guide, Artikel, geplante Themen.
class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({required this.sessions, super.key});

  final List<IceSession> sessions;

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final achieved = achievedMilestoneIds(s, sessions);
    final milestoneTitles = {
      for (final m in s.catalog.milestones) m.id: m.text('de').title,
    };

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: SzSpacing.xl, bottom: SzSpacing.s),
      child: Text(
        text,
        style: t.labelSmall?.copyWith(
          color: p.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );

    return ListView(
      key: const Key('knowledge-list'),
      padding: const EdgeInsets.all(SzSpacing.pageMargin),
      children: [
        Text('Wissen', style: t.headlineMedium),
        const SizedBox(height: SzSpacing.s),
        Text(
          'Sicher und gut informiert eisbaden. Jeder Beitrag zeigt, wie gut die Aussagen belegt sind.',
          style: t.bodyMedium,
        ),
        const SizedBox(height: SzSpacing.l),
        const EntryGuideCard(),
        label('BEITRÄGE'),
        for (final a in s.knowledge.articles)
          _ArticleTile(
            article: a,
            unlocked: a.isUnlocked(achieved),
            lockHint: a.unlockMilestone == null
                ? null
                : 'Wird mit dem Meilenstein «${milestoneTitles[a.unlockMilestone] ?? a.unlockMilestone}» freigeschaltet',
          ),
        if (s.knowledge.planned.isNotEmpty) ...[
          label('IN VORBEREITUNG'),
          for (final topic in s.knowledge.planned)
            Padding(
              padding: const EdgeInsets.only(bottom: SzSpacing.m),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.schedule_rounded,
                      size: 18,
                      color: p.textTertiary,
                    ),
                  ),
                  const SizedBox(width: SzSpacing.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          style: t.bodyLarge?.copyWith(color: p.textSecondary),
                        ),
                        Text(
                          topic.unlockHint,
                          style: TextStyle(color: p.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({
    required this.article,
    required this.unlocked,
    required this.lockHint,
  });

  final KnowledgeArticle article;
  final bool unlocked;
  final String? lockHint;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: SzSpacing.s),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('article-${article.id}'),
          onTap: unlocked
              ? () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ArticleScreen(article: article),
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(SzSpacing.l),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  unlocked
                      ? Icons.menu_book_rounded
                      : Icons.lock_outline_rounded,
                  color: unlocked ? p.accentIce : p.textTertiary,
                ),
                const SizedBox(width: SzSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: t.titleMedium?.copyWith(
                          color: unlocked ? p.textPrimary : p.textSecondary,
                        ),
                      ),
                      const SizedBox(height: SzSpacing.xs),
                      Text(
                        unlocked ? article.summary : lockHint ?? '',
                        style: t.bodyMedium,
                      ),
                      if (unlocked) ...[
                        const SizedBox(height: SzSpacing.s),
                        Text(
                          '${article.minutes} min · ${article.evidence.label}',
                          style: TextStyle(color: p.textTertiary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Artikelansicht mit Evidenz-Kennzeichnung und Quellen.
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({required this.article, super.key});

  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    Widget tag(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: SzSpacing.s, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SzRadius.full),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(backgroundColor: p.bgBase),
      body: ListView(
        key: const Key('article-body'),
        padding: const EdgeInsets.fromLTRB(
          SzSpacing.pageMargin,
          0,
          SzSpacing.pageMargin,
          SzSpacing.xxl,
        ),
        children: [
          Text(
            article.title,
            key: const Key('article-title'),
            style: t.headlineMedium,
          ),
          const SizedBox(height: SzSpacing.m),
          Wrap(
            spacing: SzSpacing.s,
            runSpacing: SzSpacing.xs,
            children: [
              tag(article.evidence.label, p.accentIce),
              tag('${article.minutes} min Lesezeit', p.textSecondary),
              if (!article.reviewed)
                tag('Entwurf – Fachprüfung ausstehend', p.stateCaution),
            ],
          ),
          const SizedBox(height: SzSpacing.l),
          for (final b in article.blocks)
            switch (b) {
              HeadingBlock() => Padding(
                padding: const EdgeInsets.only(
                  top: SzSpacing.xl,
                  bottom: SzSpacing.s,
                ),
                child: Text(
                  b.text,
                  style: t.titleMedium?.copyWith(fontSize: 19),
                ),
              ),
              ParagraphBlock() => Padding(
                padding: const EdgeInsets.only(bottom: SzSpacing.m),
                child: Text(b.text, style: t.bodyLarge?.copyWith(height: 1.5)),
              ),
              BulletBlock() => Padding(
                padding: const EdgeInsets.only(
                  bottom: SzSpacing.s,
                  left: SzSpacing.xs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 9,
                        right: SzSpacing.s,
                      ),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.accentIce,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        b.text,
                        style: t.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              NoteBlock() => Container(
                margin: const EdgeInsets.only(
                  top: SzSpacing.xs,
                  bottom: SzSpacing.m,
                ),
                padding: const EdgeInsets.all(SzSpacing.m),
                decoration: BoxDecoration(
                  color: p.bgSurface,
                  borderRadius: BorderRadius.circular(SzRadius.s),
                  border: Border(
                    left: BorderSide(color: p.accentIce, width: 3),
                  ),
                ),
                child: Text(
                  b.text,
                  style: t.bodyMedium?.copyWith(color: p.textPrimary),
                ),
              ),
            },
          const SizedBox(height: SzSpacing.xl),
          Text(
            'QUELLEN',
            style: t.labelSmall?.copyWith(
              color: p.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: SzSpacing.s),
          for (final src in article.sources)
            Padding(
              padding: const EdgeInsets.only(bottom: SzSpacing.s),
              child: Text(src, style: t.bodyMedium),
            ),
          if (!article.reviewed)
            Text(
              'Quellen und Inhalt werden vor der Veröffentlichung fachlich geprüft.',
              style: TextStyle(color: p.stateCaution, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
