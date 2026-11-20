import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/profile/user_profile.dart';

/// Bearbeitbarer Entwurf der persönlichen Angaben (Onboarding und Profil).
class ProfileDraft {
  ProfileDraft.from(UserProfile p)
    : sex = p.sex,
      height = TextEditingController(text: p.heightCm?.toString() ?? ''),
      weight = TextEditingController(text: _fmt(p.weightKg)),
      birthYear = TextEditingController(text: p.birthYear?.toString() ?? ''),
      goals = {...p.goals};

  Sex sex;
  final TextEditingController height;
  final TextEditingController weight;
  final TextEditingController birthYear;
  final Set<BathGoal> goals;

  static String _fmt(double? v) => v == null
      ? ''
      : v == v.roundToDouble()
      ? v.toStringAsFixed(0)
      : v.toString();

  void dispose() {
    height.dispose();
    weight.dispose();
    birthYear.dispose();
  }

  /// Fehlermeldung oder `null`, wenn alle Angaben plausibel (oder leer) sind.
  String? validate(int currentYear) {
    final h = height.text.trim();
    if (h.isNotEmpty) {
      final v = int.tryParse(h);
      if (v == null ||
          v < ProfileLimits.minHeight ||
          v > ProfileLimits.maxHeight) {
        return 'Bitte eine Grösse zwischen ${ProfileLimits.minHeight} und ${ProfileLimits.maxHeight} cm eingeben.';
      }
    }
    final w = weight.text.trim().replaceAll(',', '.');
    if (w.isNotEmpty) {
      final v = double.tryParse(w);
      if (v == null ||
          v < ProfileLimits.minWeight ||
          v > ProfileLimits.maxWeight) {
        return 'Bitte ein Gewicht zwischen ${ProfileLimits.minWeight.toInt()} und ${ProfileLimits.maxWeight.toInt()} kg eingeben.';
      }
    }
    final y = birthYear.text.trim();
    if (y.isNotEmpty) {
      final v = int.tryParse(y);
      final max = ProfileLimits.maxBirthYear(currentYear);
      if (v == null || v < ProfileLimits.minBirthYear || v > max) {
        return 'Bitte ein Geburtsjahr zwischen ${ProfileLimits.minBirthYear} und $max eingeben.';
      }
    }
    return null;
  }

  /// Übernimmt die (gültigen) Angaben ins Profil. Leere Felder = keine Angabe.
  UserProfile applyTo(UserProfile p) {
    final w = weight.text.trim().replaceAll(',', '.');
    return p.copyWith(
      sex: sex,
      heightCm: () => int.tryParse(height.text.trim()),
      weightKg: () => w.isEmpty ? null : double.tryParse(w),
      birthYear: () => int.tryParse(birthYear.text.trim()),
      goals: {...goals},
    );
  }
}

/// «Über dich»: Geschlecht, Grösse, Gewicht, Geburtsjahr.
class AboutYouFields extends StatefulWidget {
  const AboutYouFields({required this.draft, this.onChanged, super.key});

  final ProfileDraft draft;
  final VoidCallback? onChanged;

  @override
  State<AboutYouFields> createState() => _AboutYouFieldsState();
}

class _AboutYouFieldsState extends State<AboutYouFields> {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final d = widget.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('GESCHLECHT'),
        Wrap(
          spacing: SzSpacing.s,
          runSpacing: SzSpacing.s,
          children: [
            for (final s in Sex.values)
              ChoiceChip(
                key: Key('sex-${s.name}'),
                label: Text(s.label),
                selected: d.sex == s,
                onSelected: (_) {
                  setState(() => d.sex = s);
                  widget.onChanged?.call();
                },
              ),
          ],
        ),
        const _Label('GRÖSSE'),
        _NumberField(
          fieldKey: 'ob-height',
          controller: d.height,
          suffix: 'cm',
          hint: 'z. B. 175',
        ),
        const _Label('GEWICHT (FREIWILLIG)'),
        _NumberField(
          fieldKey: 'ob-weight',
          controller: d.weight,
          suffix: 'kg',
          hint: 'z. B. 72',
          decimal: true,
        ),
        const _Label('GEBURTSJAHR (FREIWILLIG)'),
        _NumberField(
          fieldKey: 'ob-birthyear',
          controller: d.birthYear,
          hint: 'z. B. 1988',
        ),
        const SizedBox(height: SzSpacing.m),
        Text(
          'Leer lassen bedeutet «keine Angabe». Deine Angaben bleiben auf diesem Gerät und dienen '
          'nur für persönliche Schätzungen und Tipps.',
          style: t.bodyMedium,
        ),
      ],
    );
  }
}

/// «Warum Eisbaden?» – Mehrfachauswahl.
class GoalSelector extends StatefulWidget {
  const GoalSelector({required this.draft, this.onChanged, super.key});

  final ProfileDraft draft;
  final VoidCallback? onChanged;

  @override
  State<GoalSelector> createState() => _GoalSelectorState();
}

class _GoalSelectorState extends State<GoalSelector> {
  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final goals = widget.draft.goals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: SzSpacing.s,
          runSpacing: SzSpacing.s,
          children: [
            for (final g in BathGoal.values)
              FilterChip(
                key: Key('goal-${g.name}'),
                label: Text(g.label),
                selected: goals.contains(g),
                onSelected: (on) {
                  setState(() => on ? goals.add(g) : goals.remove(g));
                  widget.onChanged?.call();
                },
              ),
          ],
        ),
        if (goals.contains(BathGoal.medical)) ...[
          const SizedBox(height: SzSpacing.l),
          Container(
            key: const Key('medical-note'),
            padding: const EdgeInsets.all(SzSpacing.m),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SzRadius.s),
              border: Border.all(color: p.stateCaution),
            ),
            child: Text(
              'Bitte besprich das Eisbaden vorher mit deiner Ärztin oder deinem Arzt. '
              'Die App gibt keine medizinischen Empfehlungen.',
              style: t.bodyMedium?.copyWith(color: p.textPrimary),
            ),
          ),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: SzSpacing.l, bottom: SzSpacing.s),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: context.sz.textSecondary, letterSpacing: 1.5),
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.fieldKey,
    required this.controller,
    required this.hint,
    this.suffix,
    this.decimal = false,
  });

  final String fieldKey;
  final TextEditingController controller;
  final String hint;
  final String? suffix;
  final bool decimal;

  @override
  Widget build(BuildContext context) => TextField(
    key: Key(fieldKey),
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        RegExp(decimal ? r'[0-9.,]' : r'[0-9]'),
      ),
      LengthLimitingTextInputFormatter(decimal ? 5 : 4),
    ],
    decoration: InputDecoration(
      border: const OutlineInputBorder(),
      hintText: hint,
      suffixText: suffix,
      isDense: true,
    ),
  );
}
