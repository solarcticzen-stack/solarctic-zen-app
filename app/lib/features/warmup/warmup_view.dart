import 'package:material_ui/material_ui.dart';

import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/warmup/warmup.dart';
import 'stick_figure.dart';

/// Erklärtext (FEATURES.md §K, A20).
/// STATUS: Entwurf – vor Veröffentlichung durch die Fachperson zu prüfen.
abstract final class WarmupTexts {
  static const whyTitle = 'Warum aktiv aufwärmen?';
  static const why =
      'Nach dem Eisbad sinkt deine Körperkerntemperatur oft noch ein paar Minuten weiter, '
      'weil kaltes Blut aus Armen und Beinen zurückfliesst («Afterdrop»). Bewegung erzeugt '
      'Wärme direkt in deinen Muskeln und hilft dir, dich sanft und aus eigener Kraft aufzuwärmen.\n\n'
      'Wärmst du dich sofort mit heisser Dusche oder dicker Kleidung auf, signalisieren die '
      'Kälterezeptoren der Haut schnell «warm» – der Körper muss dann selbst weniger Wärme '
      'produzieren. Erste Studien deuten darauf hin, dass gerade diese eigene Wärmeproduktion '
      'zu den Anpassungen an Kälte beiträgt.';
  static const evidence = 'Erste Hinweise';
  static const reviewNote = 'Entwurf – fachliche Prüfung ausstehend';
  static const safety =
      'Nur wenn du dich gut fühlst. Bei Schwindel, starkem Zittern oder Unwohlsein: '
      'hinsetzen, abtrocknen, warm anziehen.';
  static const slip = 'Nur auf trockenem, rutschfestem Boden';
}

/// Inhalt des Aufwärm-Schritts im Session-Ablauf.
class WarmupView extends StatelessWidget {
  const WarmupView({
    required this.exercise,
    required this.onOther,
    required this.onDone,
    required this.onSkip,
    super.key,
  });

  final WarmupExercise exercise;
  final VoidCallback onOther;
  final VoidCallback onDone;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final text = exercise.text('de');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(
                'JETZT AKTIV AUFWÄRMEN',
                style: t.labelSmall?.copyWith(
                  color: p.accentSolar,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: SzSpacing.s),
              Text(
                text.title,
                key: const Key('warmup-title'),
                style: t.headlineMedium,
              ),
              const SizedBox(height: SzSpacing.m),
              Center(
                child: StickFigure(
                  key: ValueKey(exercise.id),
                  animationKey: exercise.animation,
                  size: 170,
                ),
              ),
              const SizedBox(height: SzSpacing.m),
              Text(text.how, style: t.bodyLarge),
              if (exercise.slipRisk) ...[
                const SizedBox(height: SzSpacing.s),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: p.stateCaution,
                    ),
                    const SizedBox(width: SzSpacing.xs),
                    Expanded(
                      child: Text(
                        WarmupTexts.slip,
                        key: const Key('warmup-slip'),
                        style: t.bodyMedium?.copyWith(color: p.stateCaution),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: SzSpacing.m),
              _SafetyNote(),
              const SizedBox(height: SzSpacing.s),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: const Key('warmup-why'),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: SzSpacing.m),
                  title: Text(WarmupTexts.whyTitle, style: t.titleMedium),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WarmupTexts.why,
                      style: t.bodyMedium?.copyWith(color: p.textPrimary),
                    ),
                    const SizedBox(height: SzSpacing.s),
                    Wrap(
                      spacing: SzSpacing.s,
                      runSpacing: SzSpacing.xs,
                      children: [
                        _Tag(WarmupTexts.evidence, p.accentIce),
                        _Tag(WarmupTexts.reviewNote, p.stateCaution),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SzSpacing.s),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: SzTouch.session,
                child: OutlinedButton(
                  key: const Key('warmup-other'),
                  onPressed: onOther,
                  style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Andere Übung'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: SzSpacing.m),
            Expanded(
              child: SizedBox(
                height: SzTouch.session,
                child: FilledButton(
                  key: const Key('warmup-done'),
                  onPressed: onDone,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Erledigt'),
                  ),
                ),
              ),
            ),
          ],
        ),
        TextButton(
          key: const Key('warmup-skip'),
          onPressed: onSkip,
          child: const Text('Überspringen'),
        ),
      ],
    );
  }
}

class _SafetyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    return Container(
      padding: const EdgeInsets.all(SzSpacing.m),
      decoration: BoxDecoration(
        color: p.bgSurface,
        borderRadius: BorderRadius.circular(SzRadius.s),
        border: Border.all(color: p.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: p.textSecondary),
          const SizedBox(width: SzSpacing.s),
          Expanded(
            child: Text(
              WarmupTexts.safety,
              key: const Key('warmup-safety'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: SzSpacing.s, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(SzRadius.full),
      border: Border.all(color: color),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}
