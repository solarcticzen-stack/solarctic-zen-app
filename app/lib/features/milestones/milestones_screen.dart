import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/formatters.dart';
import '../../domain/common/local_date.dart';
import '../../domain/milestones/milestone.dart';
import '../../domain/session/ice_session.dart';

const _categoryTitles = {
  MilestoneCategory.routine: 'Routine',
  MilestoneCategory.count: 'Anzahl',
  MilestoneCategory.duration: 'Gesamtzeit',
  MilestoneCategory.experience: 'Erfahrung',
  MilestoneCategory.mindfulness: 'Achtsamkeit',
  MilestoneCategory.knowledge: 'Wissen',
};

/// Erfolge: Meilensteine nach Kategorie (FEATURES.md D1–D6).
/// Persönliche Ziele folgen in Etappe 2/3.
class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({required this.sessions, super.key});

  final List<IceSession> sessions;

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final t = Theme.of(context).textTheme;
    final all = MilestoneEngine.evaluate(
      s.catalog,
      sessions,
      today: s.today(),
      externalAchievements: s.externalAchievements,
    );
    final achieved = all.where((m) => m.achieved).length;

    return ListView(
      padding: const EdgeInsets.all(SzSpacing.pageMargin),
      children: [
        Text('Erfolge', style: t.headlineMedium),
        const SizedBox(height: SzSpacing.s),
        Text(
          '$achieved von ${all.length} Meilensteinen erreicht',
          key: const Key('milestones-summary'),
          style: t.bodyMedium,
        ),
        for (final cat in MilestoneCategory.values)
          if (all.any((m) => m.definition.category == cat)) ...[
            const SizedBox(height: SzSpacing.xl),
            Text(
              _categoryTitles[cat]!.toUpperCase(),
              style: t.labelSmall?.copyWith(
                color: context.sz.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: SzSpacing.s),
            for (final m in all.where((m) => m.definition.category == cat))
              _MilestoneTile(status: m),
          ],
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.status});
  final MilestoneStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final text = status.definition.text('de');
    final color = status.achieved
        ? p.accentSolar
        : (status.locked ? p.textTertiary : p.textSecondary);
    final String sub;
    if (status.achieved) {
      sub =
          'Erreicht am ${formatDay(LocalDate.fromInstant(status.achievedAt!, AppServices.of(context).utcOffsetMinutes()))}';
    } else if (status.locked) {
      sub = 'Wird nach den Sicherheits-Grundlagen freigeschaltet (Wissensbereich folgt).';
    } else {
      sub = text.description;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: SzSpacing.s),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(SzSpacing.m),
          child: Row(
            children: [
              Icon(
                status.locked
                    ? Icons.lock_outline_rounded
                    : Icons.military_tech_rounded,
                color: color,
                size: 32,
              ),
              const SizedBox(width: SzSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text.title,
                      style: t.titleMedium?.copyWith(
                        color: status.achieved
                            ? p.textPrimary
                            : p.textSecondary,
                      ),
                    ),
                    Text(sub, style: t.bodyMedium),
                    if (!status.achieved && !status.locked) ...[
                      const SizedBox(height: SzSpacing.s),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(SzRadius.full),
                        child: LinearProgressIndicator(
                          value: status.progress,
                          minHeight: 6,
                          color: p.accentPrimary,
                          backgroundColor: p.bgElevated,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
