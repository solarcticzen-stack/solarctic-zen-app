import 'package:material_ui/material_ui.dart';

import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';

/// Einstiegs-Guide «So steigst du ein» (Notiz N-006, FEATURES.md A21).
///
/// STATUS: Entwurf – vor Veröffentlichung durch die Fachperson zu prüfen.
/// Bewusst entschärft gegenüber der Notiz: kein «ich ziehe es trotz Schmerz
/// durch», weil «Aussteigen ist immer richtig» Vorrang hat.
abstract final class EntryGuide {
  static const title = 'So steigst du ein';

  static const steps = <(IconData, String, String)>[
    (
      Icons.self_improvement_rounded,
      'Einstellen',
      'Nimm dir einen Moment und entscheide dich bewusst. Es wird unangenehm – '
          'das ist normal und geht vorbei. Du bleibst ruhig.',
    ),
    (
      Icons.air_rounded,
      'Ruhig atmen',
      'Atme ein paar Mal ruhig durch die Nase ein und langsam durch den Mund aus. '
          'Gleichmässig, ohne zu hecheln.',
    ),
    (
      Icons.accessibility_new_rounded,
      'Stehend einatmen',
      'Stell dich ins Bad und hol einmal tief Luft – füll deine Lunge.',
    ),
    (
      Icons.south_rounded,
      'Beim Hinsetzen ausatmen',
      'Setz dich langsam und lass die Luft dabei ruhig ausströmen. Timing: Wenn '
          'dein Körper bis zu den Schultern im Wasser ist, ist die Lunge leer. '
          'Der Kopf bleibt über Wasser.',
    ),
    (
      Icons.waves_rounded,
      'Auf die Atmung konzentrieren',
      'Jetzt kommt die Kälteschock-Phase. Konzentriere dich nur auf langes, '
          'ruhiges Ausatmen. Sobald deine Atmung ruhig ist, hast du es geschafft.',
    ),
    (
      Icons.spa_outlined,
      'Geniessen',
      'Spür die Ruhe und die Klarheit. Bleib so lange, wie es sich gut anfühlt – '
          'nicht länger.',
    ),
  ];

  static const safety =
      'Aussteigen ist immer richtig – bei Schwindel, Taubheit, starkem Zittern oder '
      'wenn du dich unwohl fühlst.';

  /// Kurzhinweis während des Vorlaufs (Einstieg passiert genau dann).
  static const countdownCue =
      'Stehend tief einatmen – beim Hinsetzen langsam ausatmen.';
}

/// Schritt-für-Schritt-Ansicht des Guides.
class EntryGuideScreen extends StatefulWidget {
  const EntryGuideScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const EntryGuideScreen(),
    ),
  );

  @override
  State<EntryGuideScreen> createState() => _EntryGuideScreenState();
}

class _EntryGuideScreenState extends State<EntryGuideScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final last = _step == EntryGuide.steps.length - 1;
    final (icon, title, text) = EntryGuide.steps[_step];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.bgBase,
        title: const Text(EntryGuide.title),
        leading: IconButton(
          tooltip: 'Schliessen',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(SzSpacing.pageMargin),
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < EntryGuide.steps.length; i++)
                        Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                SzRadius.full,
                              ),
                              color: i <= _step
                                  ? p.accentPrimary
                                  : p.bgElevated,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: SzSpacing.xxl),
                  Icon(icon, size: 64, color: p.accentIce),
                  const SizedBox(height: SzSpacing.xl),
                  Text(
                    'SCHRITT ${_step + 1} VON ${EntryGuide.steps.length}',
                    style: t.labelSmall?.copyWith(
                      color: p.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: SzSpacing.s),
                  Text(
                    title,
                    key: const Key('guide-title'),
                    style: t.headlineMedium,
                  ),
                  const SizedBox(height: SzSpacing.m),
                  Text(
                    text,
                    style: t.bodyLarge?.copyWith(fontSize: 18, height: 1.45),
                  ),
                  const SizedBox(height: SzSpacing.xxl),
                  Container(
                    padding: const EdgeInsets.all(SzSpacing.m),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SzRadius.s),
                      border: Border.all(color: p.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.exit_to_app_rounded,
                          size: 18,
                          color: p.stateCaution,
                        ),
                        const SizedBox(width: SzSpacing.s),
                        Expanded(
                          child: Text(EntryGuide.safety, style: t.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SzSpacing.s),
                  Text(
                    'Entwurf – fachliche Prüfung ausstehend',
                    style: TextStyle(color: p.stateCaution, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SzSpacing.pageMargin,
                0,
                SzSpacing.pageMargin,
                SzSpacing.l,
              ),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: SizedBox(
                        height: SzTouch.session,
                        child: OutlinedButton(
                          key: const Key('guide-back'),
                          onPressed: () => setState(() => _step--),
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Zurück'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SzSpacing.m),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: SzTouch.session,
                      child: FilledButton(
                        key: const Key('guide-next'),
                        onPressed: last
                            ? () => Navigator.of(context).pop()
                            : () => setState(() => _step++),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(last ? 'Verstanden' : 'Weiter'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Auffällige Karte, die den Guide öffnet (Dashboard, Vorbereitung, Wissen).
class EntryGuideCard extends StatelessWidget {
  const EntryGuideCard({this.compact = false, super.key});

  /// Kompakte Variante für die Vorbereitung.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return Card(
      key: const Key('guide-card'),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SzRadius.m),
        side: BorderSide(color: p.accentIce.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: () => EntryGuideScreen.open(context),
        child: Padding(
          padding: EdgeInsets.all(compact ? SzSpacing.m : SzSpacing.l),
          child: Row(
            children: [
              Icon(
                Icons.waves_rounded,
                color: p.accentIce,
                size: compact ? 28 : 36,
              ),
              const SizedBox(width: SzSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(EntryGuide.title, style: t.titleMedium),
                    Text(
                      compact ? 'Atmung und Timing beim Einstieg' : 'In 6 Schritten: einstellen, atmen, einsteigen, ruhig werden, geniessen.',
                      style: t.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
