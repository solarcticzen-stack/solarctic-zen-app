import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/charts.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/formatters.dart';
import '../../domain/profile/user_profile.dart';
import '../../domain/session/ice_session.dart';
import '../../domain/stats/history.dart';
import '../../domain/stats/stats_engine.dart';
import '../questionnaire/questionnaire_screen.dart';
import 'stats_grid.dart';

/// Statistik: Kennzahlen, Diagramme, Entwicklung (FEATURES.md C4, C5, C7).
class StatsView extends StatelessWidget {
  const StatsView({required this.sessions, super.key});

  final List<IceSession> sessions;

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final p = context.sz;
    final today = s.today();
    final stats = StatsEngine.compute(sessions, today: today);
    final weeks = weeklyCounts(sessions, today: today);
    final durations = durationSeries(sessions);
    final temps = temperatureSeries(sessions);
    final comparison = PeriodComparison.compute(sessions, today: today);
    final weekAvg = weeks.fold(0, (n, w) => n + w.$2) / weeks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsGrid(stats: stats),
        const SizedBox(height: SzSpacing.l),
        _ChartCard(
          key: const Key('chart-weekly'),
          title: 'Eisbäder pro Woche',
          subtitle:
              'Letzte 12 Wochen · Ø ${weekAvg.toStringAsFixed(1)} pro Woche',
          child: SzBarChart(
            data: [
              for (final (week, count) in weeks)
                ChartDatum(
                  value: count.toDouble(),
                  axisLabel: formatShortDate(week),
                  tooltip:
                      'Woche ab ${formatShortDate(week)}: $count ${count == 1 ? 'Eisbad' : 'Eisbäder'}',
                ),
            ],
            semanticsLabel:
                'Eisbäder pro Woche, letzte 12 Wochen: '
                '${weeks.map((w) => w.$2).join(', ')}. Durchschnitt ${weekAvg.toStringAsFixed(1)}.',
          ),
        ),
        const SizedBox(height: SzSpacing.m),
        _ChartCard(
          key: const Key('chart-duration'),
          title: 'Dauer je Eisbad',
          subtitle: 'Letzte ${durations.length} Eisbäder · in Minuten',
          child: SzLineChart(
            minY: 0,
            data: [
              for (final pt in durations)
                ChartDatum(
                  value: pt.value,
                  axisLabel: formatShortDate(pt.session.localDate),
                  tooltip:
                      '${formatDay(pt.session.localDate)}\n${formatDurationText(pt.session.duration)}',
                ),
            ],
            semanticsLabel: durations.isEmpty
                ? 'Dauer je Eisbad: noch keine Daten'
                : 'Dauer je Eisbad, letzte ${durations.length}: zuletzt '
                      '${formatDurationText(durations.last.session.duration)}.',
          ),
        ),
        const SizedBox(height: SzSpacing.m),
        _ChartCard(
          key: const Key('chart-temperature'),
          title: 'Wassertemperatur',
          subtitle: temps.isEmpty
              ? 'Erfasse die Temperatur in der Vorbereitung'
              : 'Letzte ${temps.length} Messungen · in °C',
          child: SzLineChart(
            color: p.accentIce,
            data: [
              for (final pt in temps)
                ChartDatum(
                  value: pt.value,
                  axisLabel: formatShortDate(pt.session.localDate),
                  tooltip:
                      '${formatDay(pt.session.localDate)}\n${formatTemp(pt.value)}',
                ),
            ],
            semanticsLabel: temps.isEmpty
                ? 'Wassertemperatur: noch keine Daten'
                : 'Wassertemperatur, letzte ${temps.length} Messungen: zuletzt ${formatTemp(temps.last.value)}.',
          ),
        ),
        const SizedBox(height: SzSpacing.m),
        _ComparisonCard(comparison: comparison, sessions: sessions),
        const QuestionnaireCharts(),
        if (s.profile.profile.has(BathGoal.weightLoss)) ...[
          const SizedBox(height: SzSpacing.m),
          _EnergyCard(sessions: completedChronological(sessions)),
        ],
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SzSpacing.l,
          SzSpacing.l,
          SzSpacing.l,
          SzSpacing.m,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.titleMedium),
            Text(subtitle, style: t.bodyMedium),
            const SizedBox(height: SzSpacing.xl),
            child,
          ],
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.comparison, required this.sessions});

  final PeriodComparison? comparison;
  final List<IceSession> sessions;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final c = comparison;
    Widget body;
    if (c == null) {
      final first = completedChronological(sessions).firstOrNull;
      final left = first == null
          ? PeriodComparison.minHistoryDays
          : PeriodComparison.minHistoryDays -
                (AppServices.of(context).today().daysSince(first.localDate) +
                    1);
      body = Text(
        'Verfügbar ab ${PeriodComparison.minHistoryDays} Tagen Verlauf – noch $left Tage.',
        key: const Key('comparison-pending'),
        style: t.bodyMedium,
      );
    } else {
      String dur(PeriodSummary s) => s.averageDuration == null
          ? '–'
          : formatDurationText(s.averageDuration!);
      String feel(PeriodSummary s) => s.averageFeeling == null
          ? '–'
          : '${s.averageFeeling!.toStringAsFixed(1)} / 5';
      String temp(PeriodSummary s) =>
          s.averageTempC == null ? '–' : formatTemp(s.averageTempC!);
      final rows = <(String, String, String)>[
        ('Eisbäder', '${c.first.count}', '${c.recent.count}'),
        ('Ø Dauer', dur(c.first), dur(c.recent)),
        ('Ø Empfinden', feel(c.first), feel(c.recent)),
        ('Ø Temperatur', temp(c.first), temp(c.recent)),
      ];
      final head = TextStyle(
        color: p.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      );
      body = Table(
        key: const Key('comparison-table'),
        columnWidths: const {
          0: FlexColumnWidth(1.3),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(
            children: [
              const SizedBox(),
              Text('ERSTE 30 TAGE', style: head),
              Text('LETZTE 30 TAGE', style: head),
            ],
          ),
          for (final (label, a, b) in rows)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(label, style: t.bodyMedium),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(a, style: t.bodyLarge),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(b, style: t.bodyLarge),
                ),
              ],
            ),
        ],
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SzSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deine Entwicklung', style: t.titleMedium),
            Text('Erste vs. letzte 30 Tage', style: t.bodyMedium),
            const SizedBox(height: SzSpacing.m),
            body,
          ],
        ),
      ),
    );
  }
}

/// Summe der Energie-Schätzungen (Ziel Abnehmen); derzeit Platzhalter.
class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.sessions});

  final List<IceSession> sessions;

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final total = sessions.fold<int>(
      0,
      (sum, x) => sum + (s.energy.estimateKcal(x, s.profile.profile) ?? 0),
    );
    return Card(
      key: const Key('energy-total'),
      child: Padding(
        padding: const EdgeInsets.all(SzSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Energie (Schätzung)', style: t.titleMedium),
            Text('Zusätzlicher Verbrauch durch die Kälte', style: t.bodyMedium),
            const SizedBox(height: SzSpacing.m),
            Text('ca. $total kcal', style: t.headlineMedium),
            Text('aus ${sessions.length} Eisbädern', style: t.bodyMedium),
            if (s.energy.isPlaceholder) ...[
              const SizedBox(height: SzSpacing.s),
              Text(
                'Platzhalter: pauschal 70 kcal pro Bad. Eine geprüfte Formel folgt.',
                style: TextStyle(color: p.stateCaution, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
