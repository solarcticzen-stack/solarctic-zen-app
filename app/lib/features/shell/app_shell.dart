import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/duration_format.dart';
import '../../core/format/formatters.dart';
import '../../domain/session/ice_session.dart';
import '../community/community_screen.dart';
import '../history/history_screen.dart';
import '../knowledge/knowledge_screen.dart';
import '../milestones/milestones_screen.dart';
import '../session/session_screen.dart';
import '../today/today_screen.dart';

/// Hauptnavigation: Heute · Verlauf · (Start) · Community · Erfolge · Wissen
/// (ADR-010, docs/DESIGN_SYSTEM.md §7). Der Start-Button öffnet die Session
/// als Vollbild und ist bewusst kein normaler Tab.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  Stream<List<IceSession>>? _stream;
  bool _recoveryChecked = false;

  static const _tabs = <_TabSpec>[
    _TabSpec('Heute', Icons.wb_twilight_rounded),
    _TabSpec('Verlauf', Icons.calendar_month_rounded),
    _TabSpec('Community', Icons.forum_outlined),
    _TabSpec('Erfolge', Icons.military_tech_rounded),
    _TabSpec('Wissen', Icons.menu_book_rounded),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream ??= AppServices.of(context).sessions.watchAll();
    if (!_recoveryChecked) {
      _recoveryChecked = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_checkRecovery()),
      );
    }
  }

  /// Laufende Session nach Absturz / Neustart gefunden? (ADR-004)
  Future<void> _checkRecovery() async {
    final s = AppServices.of(context);
    final active = await s.sessions.findActive();
    if (active == null || !mounted) return;
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Laufende Session gefunden'),
        content: Text(
          'Gestartet um ${formatTime(active.startedAt, active.utcOffsetMinutes)} Uhr, '
          'bisher ${formatTimer(active.durationAt(s.now()))}.',
        ),
        actions: [
          TextButton(
            key: const Key('recover-discard'),
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Verwerfen'),
          ),
          TextButton(
            key: const Key('recover-end'),
            onPressed: () => Navigator.pop(context, 'end'),
            child: const Text('Jetzt beenden'),
          ),
          FilledButton(
            key: const Key('recover-resume'),
            onPressed: () => Navigator.pop(context, 'resume'),
            child: const Text('Fortsetzen'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    final now = s.now();
    switch (choice) {
      case 'resume':
        await _openSession(resume: active);
      case 'end':
        await s.sessions.save(active.withClock(active.clock.end(now), now));
      case 'discard':
        await s.sessions.save(
          active.copyWith(status: SessionStatus.discarded, updatedAt: now),
        );
    }
  }

  Future<void> _openSession({IceSession? resume}) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => SessionScreen(resume: resume),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<IceSession>>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Text(
                  'Daten konnten nicht geladen werden: ${snap.error}',
                ),
              );
            }
            final sessions = snap.data ?? const <IceSession>[];
            return switch (_index) {
              0 => TodayScreen(sessions: sessions, onStart: _openSession),
              1 => HistoryScreen(sessions: sessions),
              2 => const CommunityScreen(),
              3 => MilestonesScreen(sessions: sessions),
              _ => KnowledgeScreen(sessions: sessions),
            };
          },
        ),
      ),
      bottomNavigationBar: _SzTabBar(
        tabs: _tabs,
        index: _index,
        onSelect: (i) => setState(() => _index = i),
        onStart: _openSession,
      ),
    );
  }
}

@immutable
class _TabSpec {
  const _TabSpec(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _SzTabBar extends StatelessWidget {
  const _SzTabBar({
    required this.tabs,
    required this.index,
    required this.onSelect,
    required this.onStart,
  });

  final List<_TabSpec> tabs;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    Widget item(int i) {
      final selected = i == index;
      final color = selected ? p.accentPrimary : p.textSecondary;
      return Expanded(
        child: InkResponse(
          onTap: () => onSelect(i),
          child: Semantics(
            selected: selected,
            button: true,
            label: tabs[i].label,
            excludeSemantics: true,
            child: SizedBox(
              height: 64,
              // Bei grosser Systemschrift schrumpfen statt überlaufen; die
              // volle Bezeichnung liest der Screenreader über `label` vor.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tabs[i].icon, color: color),
                    const SizedBox(height: SzSpacing.xs),
                    Text(
                      tabs[i].label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.bgSurface,
        border: Border(top: BorderSide(color: p.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        // Feste Höhe: sonst dehnt sich die Leiste über den ganzen Bildschirm.
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              item(0),
              item(1),
              Expanded(
                child: Center(
                  child: Semantics(
                    button: true,
                    label: 'Eisbad starten',
                    excludeSemantics: true,
                    child: InkResponse(
                      key: const Key('tab-start'),
                      onTap: onStart,
                      radius: 36,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.accentPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: p.accentPrimary.withValues(alpha: 0.25),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: p.onAccentPrimary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              item(2),
              item(3),
              item(4),
            ],
          ),
        ),
      ),
    );
  }
}
