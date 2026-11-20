import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solarctic_zen/core/design_system/app_theme.dart';

/// Prüft die eingebundene Markenschrift Roboto (variable Schrift).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final bytes = File('assets/fonts/Roboto-Variable.ttf').readAsBytesSync();
    final loader = FontLoader(SzTheme.fontFamily)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  });

  double widthOf(String text, FontWeight weight) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: SzTheme.fontFamily,
          fontSize: 40,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  test('Schriftdatei und Lizenz liegen im Projekt', () {
    expect(
      File('assets/fonts/Roboto-Variable.ttf').lengthSync(),
      greaterThan(100000),
    );
    expect(
      File('assets/fonts/OFL.txt').readAsStringSync(),
      contains('SIL Open Font License'),
    );
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('assets/fonts/Roboto-Variable.ttf'),
    );
  });

  test('Schriftstärken werden unterschiedlich dargestellt (Fett ≠ Normal)', () {
    const sample = 'Solarctic-Zen Eisbad 02:30';
    final regular = widthOf(sample, FontWeight.w400);
    final bold = widthOf(sample, FontWeight.w700);
    final light = widthOf(sample, FontWeight.w300);
    expect(
      bold,
      isNot(closeTo(regular, 0.5)),
      reason: 'w700 muss sich von w400 unterscheiden',
    );
    expect(
      light,
      isNot(closeTo(regular, 0.5)),
      reason: 'w300 (Timer) muss sich von w400 unterscheiden',
    );
  });

  test('Ziffern sind im Theme tabellarisch (Timer springt nicht)', () {
    final theme = SzTheme.dark();
    expect(
      theme.textTheme.displayLarge!.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(theme.textTheme.bodyLarge!.fontFamily, SzTheme.fontFamily);
  });
}
