import 'package:material_ui/material_ui.dart';

import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/duration_format.dart';
import '../../core/format/formatters.dart';
import '../../domain/stats/stats_engine.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({required this.stats, super.key});
  final SessionStats stats;

  @override
  Widget build(BuildContext context) {
    final tiles = <(String, String)>[
      ('Eisbäder', '${stats.count}'),
      ('Gesamtzeit', formatTotal(stats.totalDuration)),
      (
        'Ø Dauer',
        stats.averageDuration == null
            ? '–'
            : formatTimer(stats.averageDuration!),
      ),
      (
        'Längste',
        stats.longest == null ? '–' : formatTimer(stats.longest!.duration),
      ),
      (
        'Ø Temperatur',
        stats.averageTempC == null ? '–' : formatTemp(stats.averageTempC!),
      ),
      ('Diese Woche', '${stats.thisWeekCount}'),
      ('Dieser Monat', '${stats.thisMonthCount}'),
      ('Wochen in Folge', '${stats.currentWeekStreak}'),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth > 520 ? 4 : 2;
        final w = (c.maxWidth - (columns - 1) * SzSpacing.s) / columns;
        return Wrap(
          spacing: SzSpacing.s,
          runSpacing: SzSpacing.s,
          children: [
            for (final (label, value) in tiles)
              SizedBox(width: w, child: StatTile(label, value)),
          ],
        );
      },
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SzSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: t.labelSmall?.copyWith(color: p.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: SzSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: t.titleMedium?.copyWith(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }
}
