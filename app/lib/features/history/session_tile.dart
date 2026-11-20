import 'package:material_ui/material_ui.dart';

import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/duration_format.dart';
import '../../core/format/formatters.dart';
import '../../domain/session/ice_session.dart';
import 'session_detail_screen.dart';

/// Eine Session als Listeneintrag. Antippen öffnet die Detailansicht
/// (Empfinden, Notiz, Bearbeiten, Löschen).
///
/// Bewusst ohne seitliche Symbole: Auf kleinen Geräten mit grosser Schrift
/// bleibt so genug Breite für Datum und Details.
class SessionTile extends StatelessWidget {
  const SessionTile({required this.session, super.key});

  final IceSession session;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final details = [
      formatTime(session.startedAt, session.utcOffsetMinutes),
      if (session.waterTempC != null) formatTemp(session.waterTempC!),
      if (session.feelingAfter != null) 'Danach ${session.feelingAfter}/5',
      if (session.entryMode == EntryMode.manual) 'manuell',
    ].join(' · ');
    final notes = session.notes?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: SzSpacing.s),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('session-${session.id}'),
          onTap: () => SessionDetailScreen.open(context, session),
          child: Padding(
            padding: const EdgeInsets.all(SzSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        formatDay(session.localDate),
                        style: t.titleMedium,
                      ),
                    ),
                    const SizedBox(width: SzSpacing.s),
                    Text(
                      formatTimer(session.duration),
                      style: t.titleMedium?.copyWith(color: p.textPrimary),
                    ),
                    Icon(Icons.chevron_right_rounded, color: p.textTertiary),
                  ],
                ),
                const SizedBox(height: SzSpacing.xs),
                Text(details, style: t.bodyMedium),
                // Vorschau der Notiz (Notiz N-003); vollständig in der Detailansicht.
                if (notes != null && notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: SzSpacing.xs),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 14,
                          color: p.textTertiary,
                        ),
                        const SizedBox(width: SzSpacing.xs),
                        Expanded(
                          child: Text(
                            notes,
                            key: Key('note-preview-${session.id}'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
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
