import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Baut das App-Theme aus den Design-Tokens.
///
/// Schrift: Roboto (Markenschrift), als variable Schriftdatei eingebunden
/// (assets/fonts/Roboto-Variable.ttf) – identisch auf allen Plattformen.
/// Ziffern sind überall tabellarisch, damit Timer und Zahlen nicht springen.
abstract final class SzTheme {
  static ThemeData dark() => _build(SzPalette.dark, Brightness.dark);

  static ThemeData light() => _build(SzPalette.light, Brightness.light);

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Markenschrift laut Solarctic-Zen.
  static const fontFamily = 'Roboto';

  static ThemeData _build(SzPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.accentPrimary,
      onPrimary: p.onAccentPrimary,
      secondary: p.accentSolar,
      onSecondary: p.bgBase,
      // Ausgewählte Chips (z. B. Vorlauf) in Markenfarbe statt Bernstein.
      secondaryContainer: p.accentPrimary,
      onSecondaryContainer: p.onAccentPrimary,
      error: p.stateDanger,
      onError: p.bgBase,
      surface: p.bgSurface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      outline: p.borderSubtle,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: fontFamily,
    );

    TextStyle? tab(TextStyle? s) => s?.copyWith(fontFeatures: _tabular);
    final text = base.textTheme.apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: p.bgBase,
      canvasColor: p.bgBase,
      dividerColor: p.borderSubtle,
      extensions: [SzThemeExtension(palette: p)],
      textTheme: text.copyWith(
        displayLarge: tab(text.displayLarge)
            ?.copyWith(fontWeight: FontWeight.w300),
        displayMedium: tab(text.displayMedium),
        headlineMedium: tab(text.headlineMedium)
            ?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: tab(text.titleMedium)
            ?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: tab(text.bodyLarge),
        bodyMedium: tab(text.bodyMedium)?.copyWith(color: p.textSecondary),
        labelSmall: tab(text.labelSmall)
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accentPrimary,
          foregroundColor: p.onAccentPrimary,
          minimumSize: const Size(SzTouch.min, SzTouch.min),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SzRadius.m),
          side: BorderSide(color: p.borderSubtle),
        ),
      ),
    );
  }
}

/// Macht die volle Palette (inkl. Solar-Akzente, Zustandsfarben) im Widget-Baum
/// verfügbar: `context.sz.accentSolar`.
@immutable
class SzThemeExtension extends ThemeExtension<SzThemeExtension> {
  const SzThemeExtension({required this.palette});

  final SzPalette palette;

  @override
  SzThemeExtension copyWith({SzPalette? palette}) =>
      SzThemeExtension(palette: palette ?? this.palette);

  @override
  SzThemeExtension lerp(SzThemeExtension? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

extension SzContext on BuildContext {
  SzPalette get sz =>
      Theme.of(this).extension<SzThemeExtension>()?.palette ?? SzPalette.dark;
}
