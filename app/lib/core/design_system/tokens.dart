// Design-Tokens von Solarctic-Zen (siehe docs/DESIGN_SYSTEM.md).
//
// Markenbasis laut Solarctic-Zen: Schwarz / Weiss, Schrift Roboto
// (Angaben vom 19.11.2026). Farbige Akzente sind sparsam und nur
// funktional eingesetzt (ADR-023):
//   - Primär (Weiss bzw. Schwarz): Aktionen, Auswahl, Start-Button.
//   - Eisblau: alles rund ums kalte Wasser (Timer-Status, Temperatur, Vorlauf).
//   - Bernstein («Solar»): Erfolge, Meilensteine, Aufwärmen.

import 'package:material_ui/material_ui.dart';

/// Farbsatz eines Themas (dunkel oder hell).
@immutable
class SzPalette {
  const SzPalette({
    required this.bgBase,
    required this.bgSurface,
    required this.bgElevated,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentPrimary,
    required this.onAccentPrimary,
    required this.accentIce,
    required this.accentIceDeep,
    required this.accentGlacier,
    required this.accentSolar,
    required this.accentSolarDeep,
    required this.stateLive,
    required this.stateCaution,
    required this.stateDanger,
  });

  final Color bgBase;
  final Color bgSurface;
  final Color bgElevated;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Markenfarbe für Aktionen und Auswahl (Weiss im dunklen Thema).
  final Color accentPrimary;

  /// Text/Symbol auf [accentPrimary].
  final Color onAccentPrimary;

  /// Arctic: kaltes Wasser – Timer-Status, Temperatur, Vorlauf.
  final Color accentIce;
  final Color accentIceDeep;
  final Color accentGlacier;

  /// Solar: Erfolge, Meilensteine, Aufwärmen.
  final Color accentSolar;
  final Color accentSolarDeep;

  final Color stateLive;
  final Color stateCaution;
  final Color stateDanger;

  /// Standard-Thema der App: Schwarz (OLED-freundlich), Weiss als Primärfarbe.
  static const SzPalette dark = SzPalette(
    bgBase: Color(0xFF000000),
    bgSurface: Color(0xFF111111),
    bgElevated: Color(0xFF1C1C1C),
    borderSubtle: Color(0xFF2A2A2A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA3A3A3),
    textTertiary: Color(0xFF6E6E6E),
    accentPrimary: Color(0xFFFFFFFF),
    onAccentPrimary: Color(0xFF000000),
    accentIce: Color(0xFF7FD3F7),
    accentIceDeep: Color(0xFF2B9FD0),
    accentGlacier: Color(0xFFC9EEFA),
    accentSolar: Color(0xFFFFB066),
    accentSolarDeep: Color(0xFFE8873A),
    stateLive: Color(0xFF5BE3A8),
    stateCaution: Color(0xFFFFD166),
    stateDanger: Color(0xFFFF6B6B),
  );

  /// Helles Thema: Weiss, Schwarz als Primärfarbe.
  static const SzPalette light = SzPalette(
    bgBase: Color(0xFFF5F5F5),
    bgSurface: Color(0xFFFFFFFF),
    bgElevated: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFE0E0E0),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF555555),
    textTertiary: Color(0xFF757575),
    accentPrimary: Color(0xFF000000),
    onAccentPrimary: Color(0xFFFFFFFF),
    // Auf hellem Grund abgedunkelt, damit WCAG AA (4.5 : 1) erreicht wird.
    accentIce: Color(0xFF076A94),
    accentIceDeep: Color(0xFF055778),
    accentGlacier: Color(0xFF0E5675),
    accentSolar: Color(0xFF9C5209),
    accentSolarDeep: Color(0xFF7D4207),
    stateLive: Color(0xFF13805A),
    stateCaution: Color(0xFF8A6500),
    stateDanger: Color(0xFFC62828),
  );
}

/// Abstände im 4-pt-Raster.
abstract final class SzSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Seitenrand (kleine Geräte: [pageMarginCompact]).
  static const double pageMargin = 20;
  static const double pageMarginCompact = 16;
}

abstract final class SzRadius {
  static const double s = 10;
  static const double m = 16;
  static const double l = 24;
  static const double full = 999;
}

/// Mindestgrössen für Touch-Ziele.
abstract final class SzTouch {
  static const double min = 48;

  /// Im Timer-Screen: nasse, kalte Finger.
  static const double session = 72;
}

abstract final class SzMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 450);
}
