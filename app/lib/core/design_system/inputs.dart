import 'package:material_ui/material_ui.dart';

import '../format/formatters.dart';
import 'app_theme.dart';
import 'tokens.dart';

/// Wassertemperatur in 0.5-°C-Schritten, «keine Angabe» möglich.
class SzTempPicker extends StatelessWidget {
  const SzTempPicker({required this.value, required this.onChanged, super.key});

  final double? value;
  final ValueChanged<double?> onChanged;

  static const _step = 0.5;
  static const _min = -2.0;
  static const _max = 30.0;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final v = value;
    if (v == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          key: const Key('temp-add'),
          onPressed: () => onChanged(10),
          icon: const Icon(Icons.thermostat_rounded),
          label: const Text('Temperatur erfassen'),
        ),
      );
    }
    return Row(
      children: [
        IconButton.outlined(
          key: const Key('temp-minus'),
          tooltip: 'Kälter',
          onPressed: v > _min ? () => onChanged(v - _step) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        Expanded(
          child: Center(
            child: Text(
              formatTemp(v),
              key: const Key('temp-value'),
              style: t.headlineMedium?.copyWith(color: p.accentIce),
            ),
          ),
        ),
        IconButton.outlined(
          key: const Key('temp-plus'),
          tooltip: 'Wärmer',
          onPressed: v < _max ? () => onChanged(v + _step) : null,
          icon: const Icon(Icons.add_rounded),
        ),
        const SizedBox(width: SzSpacing.s),
        IconButton(
          key: const Key('temp-clear'),
          tooltip: 'Keine Angabe',
          onPressed: () => onChanged(null),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

/// Subjektives Empfinden 1–5; erneutes Antippen entfernt die Auswahl.
class SzFeelingScale extends StatelessWidget {
  const SzFeelingScale({
    required this.value,
    required this.onChanged,
    this.scale = RatingScale.after,
    super.key,
  });

  final int? value;
  final ValueChanged<int?> onChanged;

  /// Welche der drei Bewertungen (N-005); bestimmt Beschriftung und Schlüssel.
  final RatingScale scale;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                key: Key('${scale.keyPrefix}-$i'),
                borderRadius: BorderRadius.circular(SzRadius.s),
                onTap: () => onChanged(value == i ? null : i),
                child: Container(
                  height: SzTouch.min + 8,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SzRadius.s),
                    color: value == i ? p.accentPrimary : p.bgSurface,
                    border: Border.all(color: p.borderSubtle),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$i',
                            style: TextStyle(
                              color: value == i
                                  ? p.onAccentPrimary
                                  : p.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            scale.labels[i - 1],
                            style: TextStyle(
                              color: value == i
                                  ? p.onAccentPrimary
                                  : p.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Die drei Bewertungen nach dem Bad (Notiz N-005). 5 ist jeweils das
/// Angenehmste – höhere Werte bedeuten nie «mehr ausgehalten».
enum RatingScale {
  overcome('ÜBERWINDUNG VORHER', 'Wie leicht fiel dir der Einstieg?', [
    'Sehr schwer',
    'Schwer',
    'Mittel',
    'Leicht',
    'Ganz leicht',
  ], 'overcome'),
  during('IM WASSER', 'Wie ging es dir im Wasser?', [
    'Sehr hart',
    'Hart',
    'Okay',
    'Gut',
    'Sehr gut',
  ], 'during'),
  after('DANACH', 'Wie fühlst du dich jetzt?', [
    'Schlecht',
    'Mässig',
    'Okay',
    'Gut',
    'Sehr gut',
  ], 'feeling');

  const RatingScale(this.title, this.question, this.labels, this.keyPrefix);

  final String title;
  final String question;
  final List<String> labels;
  final String keyPrefix;
}

/// Bewertung mit Überschrift und Frage.
class SzRatingField extends StatelessWidget {
  const SzRatingField({
    required this.scale,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final RatingScale scale;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          scale.title,
          style: t.labelSmall?.copyWith(
            color: context.sz.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: SzSpacing.xs),
        Text(scale.question, style: t.bodyMedium),
        const SizedBox(height: SzSpacing.s),
        SzFeelingScale(scale: scale, value: value, onChanged: onChanged),
      ],
    );
  }
}
