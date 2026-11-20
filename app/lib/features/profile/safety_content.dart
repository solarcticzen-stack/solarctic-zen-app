import 'package:material_ui/material_ui.dart';

import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';

/// Sicherheits-Grundlagen (FEATURES.md E1).
/// STATUS: Entwurf – vor Veröffentlichung durch die Fachperson zu prüfen.
abstract final class SafetyContent {
  static const rules = <(IconData, String, String)>[
    (
      Icons.group_rounded,
      'Nie allein',
      'Jemand sollte in der Nähe sein und dich sehen können.',
    ),
    (
      Icons.air_rounded,
      'Ruhig einsteigen',
      'Die ersten Minuten sind die Kälteschock-Phase. Atme langsam und lang aus.',
    ),
    (
      Icons.water_rounded,
      'Kopf über Wasser',
      'Nicht untertauchen. Keine Hyperventilations-Atemübungen im oder direkt vor dem Wasser.',
    ),
    (
      Icons.no_drinks_rounded,
      'Kein Alkohol',
      'Auch keine Drogen oder beruhigenden Medikamente vor dem Bad.',
    ),
    (
      Icons.timer_outlined,
      'Kurz beginnen',
      'Wenige Minuten genügen. Länger oder kälter ist kein Ziel.',
    ),
    (
      Icons.exit_to_app_rounded,
      'Aussteigen ist immer richtig',
      'Bei Unwohlsein, Schwindel, Taubheit oder starkem Zittern sofort raus.',
    ),
    (
      Icons.local_fire_department_outlined,
      'Danach aufwärmen',
      'Abtrocknen, bewegen, warm anziehen. Hinsetzen, wenn dir schwindlig ist.',
    ),
  ];

  static const medical =
      'Lass dich vorher ärztlich beraten bei Herz-Kreislauf-Erkrankungen, Bluthochdruck, '
      'Herzrhythmusstörungen, Raynaud-Syndrom, Epilepsie, in der Schwangerschaft oder bei '
      'anderen Vorerkrankungen.';
}

class SafetyRulesList extends StatelessWidget {
  const SafetyRulesList({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, title, text) in SafetyContent.rules)
          Padding(
            padding: const EdgeInsets.only(bottom: SzSpacing.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: p.accentIce, size: 22),
                const SizedBox(width: SzSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.titleMedium),
                      Text(text, style: t.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(SzSpacing.m),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SzRadius.s),
            border: Border.all(color: p.stateCaution),
          ),
          child: Text(
            SafetyContent.medical,
            style: t.bodyMedium?.copyWith(color: p.textPrimary),
          ),
        ),
        const SizedBox(height: SzSpacing.s),
        Text(
          'Entwurf – fachliche Prüfung ausstehend',
          style: TextStyle(color: p.stateCaution, fontSize: 12),
        ),
      ],
    );
  }
}
