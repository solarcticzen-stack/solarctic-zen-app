import 'package:material_ui/material_ui.dart';

import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/formatters.dart';
import '../../domain/session/ice_session.dart';
import '../../domain/stats/stats_engine.dart';
import 'calendar_view.dart';
import 'session_edit_screen.dart';
import 'session_tile.dart';
import 'stats_view.dart';

enum HistoryView { calendar, list, stats }

/// Verlauf mit drei Ansichten: Kalender · Liste · Statistik
/// (FEATURES.md C1–C7, DESIGN_SYSTEM.md §7).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.sessions, super.key});

  final List<IceSession> sessions;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryView _view = HistoryView.calendar;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final completed = completedChronological(widget.sessions).reversed.toList();
    const pad = EdgeInsets.symmetric(horizontal: SzSpacing.pageMargin);

    return CustomScrollView(
      key: const Key('history-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            SzSpacing.pageMargin,
            SzSpacing.pageMargin,
            SzSpacing.pageMargin,
            SzSpacing.l,
          ),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Verlauf', style: t.headlineMedium)),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TextButton.icon(
                        key: const Key('add-manual'),
                        onPressed: () => SessionEditScreen.open(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Nachtragen'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SzSpacing.l),
              SegmentedButton<HistoryView>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: HistoryView.calendar,
                    label: Text('Kalender', key: Key('view-calendar')),
                  ),
                  ButtonSegment(
                    value: HistoryView.list,
                    label: Text('Liste', key: Key('view-list')),
                  ),
                  ButtonSegment(
                    value: HistoryView.stats,
                    label: Text('Statistik', key: Key('view-stats')),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (v) => setState(() => _view = v.first),
              ),
            ],
          ),
        ),
        switch (_view) {
          HistoryView.calendar => SliverPadding(
            padding: pad,
            sliver: SliverToBoxAdapter(
              child: CalendarView(sessions: widget.sessions),
            ),
          ),
          HistoryView.stats => SliverPadding(
            padding: pad,
            sliver: SliverToBoxAdapter(
              child: StatsView(sessions: widget.sessions),
            ),
          ),
          HistoryView.list when completed.isEmpty => SliverPadding(
            padding: pad,
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: SzSpacing.xxl),
                child: Text(
                  'Noch keine Eisbäder. Starte dein erstes über den Button in der Mitte.',
                  style: t.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          HistoryView.list => SliverPadding(
            padding: pad,
            sliver: SliverList.builder(
              itemCount: completed.length,
              itemBuilder: (context, i) {
                final cur = completed[i];
                final showMonth =
                    i == 0 ||
                    completed[i - 1].localDate.monthStart !=
                        cur.localDate.monthStart;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showMonth)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: SzSpacing.s,
                          bottom: SzSpacing.s,
                        ),
                        child: Text(
                          formatMonth(cur.localDate).toUpperCase(),
                          style: t.labelSmall?.copyWith(
                            color: context.sz.textSecondary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    SessionTile(session: cur),
                  ],
                );
              },
            ),
          ),
        },
        const SliverToBoxAdapter(child: SizedBox(height: SzSpacing.xxl)),
      ],
    );
  }
}
