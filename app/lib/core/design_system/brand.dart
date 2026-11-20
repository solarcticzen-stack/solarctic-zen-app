import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';

/// Logo-Dateien (Quelle: brand/, von Solarctic-Zen am 19.11.2026 geliefert).
abstract final class SzBrandAssets {
  static const markWhite = 'assets/brand/logo_weiss_zeichen.png';
  static const markBlack = 'assets/brand/logo_schwarz_zeichen.png';
  static const logoWhite = 'assets/brand/logo_weiss.png';
  static const logoBlack = 'assets/brand/logo_schwarz.png';

  /// Bildzeichen passend zum aktuellen Thema (weiss auf dunkel, schwarz auf hell).
  static String mark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? markWhite : markBlack;
}

/// Kopfzeile mit Bildzeichen und Wortmarke.
class SzBrandHeader extends StatelessWidget {
  const SzBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    return Semantics(
      label: 'Solarctic-Zen',
      excludeSemantics: true,
      child: Row(
        children: [
          Image.asset(
            SzBrandAssets.mark(context),
            key: const Key('brand-mark'),
            height: 36,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'SOLARCTIC-ZEN',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
