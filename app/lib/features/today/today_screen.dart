import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/brand.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/duration_format.dart';
import '../../core/format/formatters.dart';
import '../../data/demo_data.dart';
import '../../domain/milestones/milestone.dart';
import '../../domain/session/ice_session.dart';
import '../../domain/stats/stats_engine.dart';
import '../guide/entry_guide.dart';
import '../profile/goal_widgets.dart';
import '../profile/profile_screen.dart';
import '../questionnaire/questionnaire_screen.dart';

/// Dashboard «Heute» (FEATURES.md F1–F3).
class TodayScreen extends StatelessWidget {
  const TodayScreen({required this.sessions, required this.onStart, super.key});

  final List<IceSession> sessions;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final today = s.today();
    final stats = StatsEngine.compute(sessions, today: today);
    final next = MilestoneEngine.next(
      MilestoneEngine.evaluate(
        s.catalog,
        sessions,
        today: today,
        externalAchievements: s.externalAchievements,
      ),
    );
    final daysThisWeek = {
      for (final x in completedChronological(sessions))
        if (x.localDate.weekStart == today.weekStart) x.localDate.weekday,
    };

    return ListView(
      padding: const EdgeInsets.all(SzSpacing.pageMargin),
      children: [
        Row(
          children: [
            const Expanded(child: SzBrandHeader()),
            IconButton(
              key: const Key('open-profile'),
              tooltip: 'Profil und Einstellungen',
              onPressed: () => ProfileScreen.open(context),
              icon: const Icon(Icons.person_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: SzSpacing.l),
        Text('Heute', style: t.headlineMedium),
        // Einstiegs-Guide gut sichtbar, solange man noch neu ist (N-006).
        if (stats.count < 5) ...[
          const SizedBox(height: SzSpacing.l),
          const EntryGuideCard(),
        ],
        if (s.isPreview) ...[
          const SizedBox(height: SzSpacing.l),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(SzSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'VORSCHAU',
                        style: t.labelSmall?.copyWith(color: p.stateCaution),
                      ),
                      const SizedBox(width: SzSpacing.m),
                      Expanded(
                        child: Text(
                          'Im Browser werden Daten nur bis zum Neuladen gespeichert.',
                          style: t.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  // Nur Vorschau: erfundene Beispieldaten, um Kalender und
                  // Diagramme auszuprobieren. Auf Geräten nie sichtbar.
                  if (sessions.where((x) => x.id.startsWith('demo-')).isEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        key: const Key('load-demo'),
                        onPressed: () async {
                          for (final x in demoSessions(
                            today: today,
                            utcOffsetMinutes: s.utcOffsetMinutes(),
                          )) {
                            await s.sessions.save(x);
                          }
                        },
                        icon: const Icon(Icons.science_outlined, size: 18),
                        label: const Text('Beispieldaten laden (90 Tage)'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: SzSpacing.l),
        _Section(
          label: 'DIESE WOCHE',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stats.thisWeekCount} ${stats.thisWeekCount == 1 ? 'Eisbad' : 'Eisbäder'}',
                key: const Key('week-count'),
                style: t.titleMedium?.copyWith(fontSize: 24),
              ),
              if (stats.currentWeekStreak > 1)
                Text(
                  '${stats.currentWeekStreak} Wochen in Folge dabei',
                  style: t.bodyMedium,
                ),
              const SizedBox(height: SzSpacing.m),
              _WeekStrip(activeDays: daysThisWeek, todayWeekday: today.weekday),
            ],
          ),
        ),
        const SizedBox(height: SzSpacing.m),
        _Section(
          label: 'LETZTES EISBAD',
          child: stats.last == null
              ? Text('Noch keins – bereit für das erste?', style: t.bodyLarge)
              : Text(
                  [
                    formatDay(stats.last!.localDate),
                    formatTimer(stats.last!.duration),
                    if (stats.last!.waterTempC != null)
                      formatTemp(stats.last!.waterTempC!),
                  ].join(' · '),
                  key: const Key('last-session'),
                  style: t.bodyLarge,
                ),
        ),
        if (next != null) ...[
          const SizedBox(height: SzSpacing.m),
          _Section(
            label: 'NÄCHSTER MEILENSTEIN',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  next.definition.text('de').title,
                  key: const Key('next-milestone'),
                  style: t.titleMedium,
                ),
                Text(
                  next.definition.text('de').description,
                  style: t.bodyMedium,
                ),
                const SizedBox(height: SzSpacing.s),
                ClipRRect(
                  borderRadius: BorderRadius.circular(SzRadius.full),
                  child: LinearProgressIndicator(
                    value: next.progress,
                    minHeight: 6,
                    color: p.accentSolar,
                    backgroundColor: p.bgElevated,
                  ),
                ),
              ],
            ),
          ),
        ],
        const DueQuestionnairesCard(),
        const SizedBox(height: SzSpacing.m),
        const TipCard(),
        const SizedBox(height: SzSpacing.xl),
        SizedBox(
          height: SzTouch.session,
          child: FilledButton.icon(
            key: const Key('today-start'),
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Eisbad starten'),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(SzSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: context.sz.textSecondary, letterSpacing: 1.5),
          ),
          const SizedBox(height: SzSpacing.s),
          child,
        ],
      ),
    ),
  );
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.activeDays, required this.todayWeekday});
  final Set<int> activeDays;
  final int todayWeekday;

  static const _names = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    return Row(
      children: [
        for (var d = 1; d <= 7; d++)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeDays.contains(d)
                        ? p.accentPrimary
                        : Colors.transparent,
                    border: Border.all(
                      color: d == todayWeekday
                          ? p.accentPrimary
                          : p.borderSubtle,
                      width: d == todayWeekday ? 2 : 1,
                    ),
                  ),
                  child: activeDays.contains(d)
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: p.onAccentPrimary,
                        )
                      : null,
                ),
                const SizedBox(height: SzSpacing.xs),
                Text(
                  _names[d - 1],
                  style: TextStyle(fontSize: 11, color: p.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
