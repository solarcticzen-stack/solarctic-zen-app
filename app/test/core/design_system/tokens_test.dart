import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solarctic_zen/core/design_system/tokens.dart';
import 'package:solarctic_zen/core/format/duration_format.dart';

/// WCAG-2.x-Kontrastverhältnis zweier Farben.
double contrast(Color a, Color b) {
  double lin(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double lum(Color c) =>
      0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
  final la = lum(a), lb = lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('Farbkontraste (WCAG AA, 4.5 : 1 für Text)', () {
    for (final (name, p) in [
      ('dunkel', SzPalette.dark),
      ('hell', SzPalette.light),
    ]) {
      test('Thema $name', () {
        for (final bg in [p.bgBase, p.bgSurface, p.bgElevated]) {
          expect(contrast(p.textPrimary, bg), greaterThanOrEqualTo(4.5));
          expect(contrast(p.textSecondary, bg), greaterThanOrEqualTo(4.5));
          expect(contrast(p.accentIce, bg), greaterThanOrEqualTo(4.5));
          expect(contrast(p.accentSolar, bg), greaterThanOrEqualTo(4.5));
          expect(contrast(p.accentPrimary, bg), greaterThanOrEqualTo(4.5));
        }
      });
    }
  });

  test('Markenbasis Schwarz/Weiss: Primärfarbe und Text darauf', () {
    expect(SzPalette.dark.bgBase, const Color(0xFF000000));
    expect(SzPalette.dark.accentPrimary, const Color(0xFFFFFFFF));
    expect(SzPalette.light.accentPrimary, const Color(0xFF000000));
    for (final p in [SzPalette.dark, SzPalette.light]) {
      expect(
        contrast(p.onAccentPrimary, p.accentPrimary),
        greaterThanOrEqualTo(7),
      );
    }
  });

  test('Logo-Dateien sind vorhanden und als Asset registriert', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- assets/brand/'));
    for (final f in [
      'logo_weiss.png',
      'logo_schwarz.png',
      'logo_weiss_zeichen.png',
      'logo_schwarz_zeichen.png',
    ]) {
      expect(File('assets/brand/$f').existsSync(), isTrue, reason: f);
    }
  });

  group('formatTimer', () {
    test('Minuten und Sekunden', () {
      expect(formatTimer(Duration.zero), '00:00');
      expect(formatTimer(const Duration(seconds: 75)), '01:15');
      expect(formatTimer(const Duration(minutes: 59, seconds: 59)), '59:59');
    });

    test('ab einer Stunde mit Stunden', () {
      expect(formatTimer(const Duration(hours: 1, seconds: 5)), '1:00:05');
    });

    test('schneidet Bruchteile ab statt zu runden', () {
      expect(formatTimer(const Duration(milliseconds: 1999)), '00:01');
    });

    test('negative Werte werden als 0 angezeigt', () {
      expect(formatTimer(const Duration(seconds: -3)), '00:00');
    });
  });
}
