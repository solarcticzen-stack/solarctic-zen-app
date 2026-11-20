import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/profile/user_profile.dart';
import '../../domain/session/ice_session.dart';

/// Energie-Text für eine Session, nur bei Ziel «Abnehmen»; sonst `null`.
/// Solange die Formel ein Platzhalter ist, steht das immer dabei.
String? energyText(AppServices s, IceSession session) {
  final profile = s.profile.profile;
  if (!profile.has(BathGoal.weightLoss)) return null;
  final kcal = s.energy.estimateKcal(session, profile);
  if (kcal == null) return null;
  return 'ca. $kcal kcal${s.energy.isPlaceholder ? ' · Platzhalter' : ''}';
}

/// «Tipp für dich» passend zu den Zielen (FEATURES.md §L, P3).
class TipCard extends StatelessWidget {
  const TipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    return ListenableBuilder(
      listenable: ProfileListenable(s.profile),
      builder: (context, _) {
        final tip = s.tips.forDay(s.profile.profile, s.today());
        if (tip == null) return const SizedBox.shrink();
        final p = context.sz;
        final t = Theme.of(context).textTheme;
        return Card(
          key: const Key('tip-card'),
          child: Padding(
            padding: const EdgeInsets.all(SzSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: p.accentSolar,
                    ),
                    const SizedBox(width: SzSpacing.xs),
                    Flexible(
                      child: Text(
                        'TIPP FÜR DICH',
                        style: t.labelSmall?.copyWith(
                          color: p.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SzSpacing.s),
                Text(tip.text, key: const Key('tip-text'), style: t.bodyLarge),
                const SizedBox(height: SzSpacing.s),
                Wrap(
                  spacing: SzSpacing.s,
                  runSpacing: SzSpacing.xs,
                  children: [
                    _Tag(tip.evidence.label, p.accentIce),
                    if (!s.tips.reviewed)
                      _Tag('Entwurf – Fachprüfung ausstehend', p.stateCaution),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}
