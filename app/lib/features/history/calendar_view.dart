import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/formatters.dart';
import '../../domain/common/local_date.dart';
import '../../domain/session/ice_session.dart';
import '../../domain/stats/history.dart';
import 'session_edit_screen.dart';
import 'session_tile.dart';

/// Monatskalender (FEATURES.md C1/C2).
///
/// Badetage werden einheitlich markiert – bewusst nicht nach Dauer abgestuft,
/// damit längere Bäder optisch nicht «belohnt» werden (Sicherheitsregel,
/// FEATURES.md §D). Mehrere Bäder an einem Tag zeigen eine kleine Zahl.
class CalendarView extends StatefulWidget {
  const CalendarView({required this.sessions, super.key});

  final List<IceSession> sessions;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  LocalDate? _month;
  LocalDate? _selected;

  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final today = s.today();
    final month = _month ?? today.monthStart;
    final days = dayAggregates(widget.sessions);
    final selected = _selected ?? (days.containsKey(today) ? today : null);
    final grid = monthGrid(month);
    final inMonth = [
      for (final e in days.entries)
        if (e.key.monthStart == month) e.value,
    ];
    final monthCount = inMonth.fold(0, (n, a) => n + a.count);
    final monthTotal = inMonth.fold(
      Duration.zero,
      (sum, a) => sum + a.totalDuration,
    );
    final canGoForward = month.isBefore(today.monthStart);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('month-prev'),
              tooltip: 'Vormonat',
              onPressed: () => setState(() {
                _month = shiftMonth(month, -1);
                _selected = null;
              }),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                formatMonth(month),
                key: const Key('month-title'),
                textAlign: TextAlign.center,
                style: t.titleMedium,
              ),
            ),
            IconButton(
              key: const Key('month-next'),
              tooltip: 'Nächster Monat',
              onPressed: canGoForward
                  ? () => setState(() {
                      _month = shiftMonth(month, 1);
                      _selected = null;
                    })
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: SzSpacing.s),
        Row(
          children: [
            for (final w in _weekdays)
              Expanded(
                child: Text(
                  w,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: SzSpacing.xs),
        for (var row = 0; row < grid.length ~/ 7; row++)
          Row(
            children: [
              for (final day in grid.sublist(row * 7, row * 7 + 7))
                Expanded(
                  child: _DayCell(
                    day: day,
                    count: days[day]?.count ?? 0,
                    inMonth: day.monthStart == month,
                    isToday: day == today,
                    isSelected: day == selected,
                    onTap: () => setState(() => _selected = day),
                  ),
                ),
            ],
          ),
        const SizedBox(height: SzSpacing.m),
        Text(
          monthCount == 0
              ? 'Keine Eisbäder in diesem Monat'
              : '$monthCount ${monthCount == 1 ? 'Eisbad' : 'Eisbäder'} · ${formatTotal(monthTotal)} gesamt',
          key: const Key('month-summary'),
          textAlign: TextAlign.center,
          style: t.bodyMedium,
        ),
        if (selected != null) ...[
          const SizedBox(height: SzSpacing.l),
          Text(
            formatDay(selected).toUpperCase(),
            key: const Key('selected-day'),
            style: t.labelSmall?.copyWith(
              color: p.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: SzSpacing.s),
          if (days[selected] == null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Kein Eisbad an diesem Tag.',
                    style: t.bodyMedium,
                  ),
                ),
                if (!selected.isAfter(today))
                  TextButton.icon(
                    key: const Key('calendar-add'),
                    onPressed: () =>
                        SessionEditScreen.open(context, initialDay: selected),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Nachtragen'),
                  ),
              ],
            )
          else
            for (final x in days[selected]!.sessions) SessionTile(session: x),
        ],
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.count,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final LocalDate day;
  final int count;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final bathed = count > 0;
    final fg = bathed
        ? p.onAccentPrimary
        : inMonth
        ? p.textPrimary
        : p.textTertiary;
    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${formatDay(day)}, ${bathed ? '$count ${count == 1 ? 'Eisbad' : 'Eisbäder'}' : 'kein Eisbad'}',
      excludeSemantics: true,
      child: InkResponse(
        key: Key('day-$day'),
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          height: 46,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bathed
                        ? p.accentPrimary.withValues(alpha: inMonth ? 1 : 0.4)
                        : null,
                    border: isSelected
                        ? Border.all(color: p.accentIce, width: 2)
                        : isToday
                        ? Border.all(color: p.textSecondary, width: 1.5)
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: fg,
                        fontSize: 14,
                        fontWeight: bathed || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                if (count > 1)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: p.bgElevated,
                        borderRadius: BorderRadius.circular(SzRadius.full),
                        border: Border.all(color: p.borderSubtle),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
