import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/inputs.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/duration_format.dart';
import '../../core/format/formatters.dart';
import '../../domain/session/ice_session.dart';
import '../profile/goal_widgets.dart';
import 'session_edit_screen.dart';

/// «4 / 5 · Leicht» bzw. «keine Angabe».
String _rating(RatingScale scale, int? v) =>
    v == null ? 'keine Angabe' : '$v / 5 · ${scale.labels[v - 1]}';

/// Detailansicht einer Session: alle Angaben inkl. Empfinden und Notiz
/// (Notiz N-003), von hier aus bearbeiten oder löschen.
class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  static Future<void> open(BuildContext context, IceSession s) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SessionDetailScreen(sessionId: s.id),
        ),
      );

  Future<void> _delete(BuildContext context, IceSession s) async {
    final services = AppServices.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eisbad löschen?'),
        content: Text('${formatDay(s.localDate)} · ${formatTimer(s.duration)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await services.sessions.delete(s.id, services.now());
    nav.pop();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Eisbad gelöscht'),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () => services.sessions.save(s),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    return StreamBuilder<List<IceSession>>(
      stream: services.sessions.watchAll(),
      builder: (context, snap) {
        final s = snap.data
            ?.where((x) => x.id == sessionId && x.isCompleted)
            .firstOrNull;
        if (s == null) {
          return const Scaffold(body: SizedBox.shrink());
        }
        return _DetailBody(session: s, onDelete: () => _delete(context, s));
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.session, required this.onDelete});

  final IceSession session;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final s = session;
    final exercise = s.warmupExerciseId == null
        ? null
        : services.warmup.byId(s.warmupExerciseId!);
    final notes = s.notes?.trim();
    final rows = <(String, String)>[
      (
        'Uhrzeit',
        '${formatTime(s.startedAt, s.utcOffsetMinutes)} – ${formatTime(s.endedAt!, s.utcOffsetMinutes)} Uhr',
      ),
      (
        'Wassertemperatur',
        s.waterTempC == null ? 'keine Angabe' : formatTemp(s.waterTempC!),
      ),
      ('Überwindung', _rating(RatingScale.overcome, s.overcomeRating)),
      ('Im Wasser', _rating(RatingScale.during, s.duringRating)),
      ('Danach', _rating(RatingScale.after, s.feelingAfter)),
      if (exercise != null)
        (
          'Aufwärmen',
          '${exercise.text('de').title} · ${s.warmupDone == true ? 'erledigt' : 'übersprungen'}',
        ),
      if (s.countdownSeconds != null) ('Vorlauf', '${s.countdownSeconds} s'),
      if (s.clock.pauses.isNotEmpty)
        (
          'Pausen',
          '${s.clock.pauses.length} · ${formatDurationText(s.clock.pausedUntil(s.endedAt!))}',
        ),
      if (energyText(services, s) case final energy?)
        ('Energie (Schätzung)', energy),
      (
        'Erfasst',
        s.entryMode == EntryMode.manual
            ? 'manuell nachgetragen'
            : 'mit dem Timer',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.bgBase,
        title: Text(formatDay(s.localDate), key: const Key('detail-title')),
        actions: [
          IconButton(
            key: const Key('detail-edit'),
            tooltip: 'Bearbeiten',
            onPressed: () => SessionEditScreen.open(context, existing: s),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(SzSpacing.pageMargin),
        children: [
          Text(
            'BADEZEIT',
            style: t.labelSmall?.copyWith(
              color: p.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            formatTimer(s.duration),
            key: const Key('detail-duration'),
            style: t.displayMedium?.copyWith(color: p.accentIce),
          ),
          const SizedBox(height: SzSpacing.l),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SzSpacing.l,
                vertical: SzSpacing.s,
              ),
              child: Column(
                children: [
                  for (final (label, value) in rows)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SzSpacing.s,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(label, style: t.bodyMedium),
                          ),
                          const SizedBox(width: SzSpacing.m),
                          Expanded(
                            flex: 3,
                            child: Text(value, style: t.bodyLarge),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SzSpacing.l),
          Text(
            'NOTIZ',
            style: t.labelSmall?.copyWith(
              color: p.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: SzSpacing.s),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(SzSpacing.l),
              child: notes == null || notes.isEmpty
                  ? Row(
                      children: [
                        Expanded(
                          child: Text('Keine Notiz', style: t.bodyMedium),
                        ),
                        TextButton(
                          key: const Key('detail-add-note'),
                          onPressed: () =>
                              SessionEditScreen.open(context, existing: s),
                          child: const Text('Hinzufügen'),
                        ),
                      ],
                    )
                  : SelectableText(
                      notes,
                      key: const Key('detail-notes'),
                      style: t.bodyLarge,
                    ),
            ),
          ),
          const SizedBox(height: SzSpacing.xl),
          OutlinedButton.icon(
            key: const Key('detail-delete'),
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: p.stateDanger),
            label: Text(
              'Eisbad löschen',
              style: TextStyle(color: p.stateDanger),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(SzTouch.min),
              side: BorderSide(color: p.borderSubtle),
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
