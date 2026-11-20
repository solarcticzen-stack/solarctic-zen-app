import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/community/community.dart';

const avatarColors = [
  Color(0xFF5BC0EB),
  Color(0xFF9BC53D),
  Color(0xFFE59A73),
  Color(0xFFF2D94E),
  Color(0xFFC79BFF),
  Color(0xFF4ECDC4),
  Color(0xFFFF9FB8),
  Color(0xFFB0BEC5),
];

IconData avatarIcon(AvatarSymbol s) => switch (s) {
  AvatarSymbol.snowflake => Icons.ac_unit_rounded,
  AvatarSymbol.wave => Icons.waves_rounded,
  AvatarSymbol.mountain => Icons.landscape_rounded,
  AvatarSymbol.sun => Icons.wb_sunny_rounded,
  AvatarSymbol.moon => Icons.nightlight_round,
  AvatarSymbol.leaf => Icons.eco_rounded,
  AvatarSymbol.star => Icons.star_rounded,
  AvatarSymbol.bolt => Icons.bolt_rounded,
};

/// Avatar aus Symbol und Farbe.
class SzAvatar extends StatelessWidget {
  const SzAvatar({
    required this.symbol,
    required this.colorIndex,
    this.size = 40,
    super.key,
  });

  final AvatarSymbol symbol;
  final int colorIndex;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: avatarColors[colorIndex % avatarColors.length],
    ),
    child: Icon(
      avatarIcon(symbol),
      size: size * 0.55,
      color: const Color(0xFF111111),
    ),
  );
}

/// Kleines «Demo»-Abzeichen für Beispieldaten.
class DemoTag extends StatelessWidget {
  const DemoTag({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SzRadius.full),
        border: Border.all(color: p.stateCaution),
      ),
      child: Text(
        'Demo',
        style: TextStyle(
          color: p.stateCaution,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Melden-Dialog (App-Store-Richtlinie 1.2).
Future<void> showReportDialog(
  BuildContext context,
  ReportTarget target,
  String targetId,
) async {
  final s = AppServices.of(context);
  final me = s.communityProfile.profile;
  if (me == null) return;
  final messenger = ScaffoldMessenger.of(context);
  const reasons = [
    'Beleidigend oder hasserfüllt',
    'Spam oder Werbung',
    'Gefährlich oder irreführend',
    'Falsche Angaben',
    'Anderes',
  ];
  final reason = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Inhalt melden'),
      children: [
        for (final r in reasons)
          SimpleDialogOption(
            key: Key('report-reason-${reasons.indexOf(r)}'),
            onPressed: () => Navigator.pop(context, r),
            child: Text(r),
          ),
      ],
    ),
  );
  if (reason == null) return;
  await s.community.report(
    ContentReport(
      id: s.idGenerator(now: s.now()),
      target: target,
      targetId: targetId,
      reason: reason,
      reporterId: me.id,
      createdAt: s.now(),
    ),
  );
  messenger.showSnackBar(
    const SnackBar(
      content: Text('Danke für die Meldung. Wir prüfen den Inhalt.'),
    ),
  );
}

/// Mitglied blockieren: dessen Inhalte werden ausgeblendet.
Future<void> blockMember(
  BuildContext context,
  String memberId,
  String handle,
) async {
  final s = AppServices.of(context);
  final me = s.communityProfile.profile;
  if (me == null || memberId == me.id) return;
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$handle blockieren?'),
      content: const Text(
        'Du siehst dann keine Nachrichten und Einträge mehr von diesem Mitglied.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          key: const Key('confirm-block'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Blockieren'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  await s.communityProfile.save(
    me.copyWith(blocked: {...me.blocked, memberId}),
  );
  messenger.showSnackBar(SnackBar(content: Text('$handle ist blockiert.')));
}

/// Aktionen-Menü für fremde Inhalte (Melden, Blockieren).
class ContentActionsButton extends StatelessWidget {
  const ContentActionsButton({
    required this.target,
    required this.targetId,
    required this.authorId,
    required this.authorHandle,
    super.key,
  });

  final ReportTarget target;
  final String targetId;
  final String authorId;
  final String authorHandle;

  @override
  Widget build(BuildContext context) {
    final me = AppServices.of(context).communityProfile.profile;
    if (me == null || me.id == authorId) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      key: Key('actions-$targetId'),
      tooltip: 'Melden oder blockieren',
      icon: Icon(Icons.more_vert_rounded, color: context.sz.textTertiary),
      onSelected: (v) => v == 'report'
          ? showReportDialog(context, target, targetId)
          : blockMember(context, authorId, authorHandle),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'report', child: Text('Melden')),
        PopupMenuItem(value: 'block', child: Text('Mitglied blockieren')),
      ],
    );
  }
}

/// Hinweis, solange Inhalte nicht geteilt werden – einzeilig, Details per Antippen.
class LocalOnlyBanner extends StatelessWidget {
  const LocalOnlyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    return InkWell(
      key: const Key('community-local-banner'),
      borderRadius: BorderRadius.circular(SzRadius.s),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Vorschau ohne Server'),
          content: const Text(
            'Die Community ist noch nicht mit dem Server verbunden. Einträge und Nachrichten '
            'bleiben auf diesem Gerät und sind für andere nicht sichtbar. Inhalte mit «Demo» sind Beispiele.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SzSpacing.m,
          vertical: SzSpacing.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SzRadius.s),
          border: Border.all(color: p.stateCaution),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 16, color: p.stateCaution),
            const SizedBox(width: SzSpacing.s),
            Expanded(
              child: Text(
                'Vorschau ohne Server – Inhalte nur auf diesem Gerät',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.textPrimary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
