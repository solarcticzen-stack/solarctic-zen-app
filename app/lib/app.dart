import 'package:material_ui/material_ui.dart';

import 'app_services.dart';
import 'core/design_system/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/app_shell.dart';

class SolarcticZenApp extends StatelessWidget {
  const SolarcticZenApp({required this.services, super.key});

  /// Repositories, Katalog, Uhr – in Tests durch kontrollierbare Varianten ersetzt.
  final AppServices Function(Widget child) services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solarctic-Zen',
      debugShowCheckedModeBanner: false,
      theme: SzTheme.light(),
      darkTheme: SzTheme.dark(),
      // Dunkel ist Standard (docs/DESIGN_SYSTEM.md); heller Modus folgt als Einstellung.
      themeMode: ThemeMode.dark,
      // Deutsch (Schweiz) für Datums-/Zeitauswahl und Systemtexte.
      // Englisch folgt mit der Lokalisierung der App-Texte (FEATURES.md H4).
      locale: const Locale('de', 'CH'),
      supportedLocales: const [Locale('de', 'CH'), Locale('de'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => services(child!),
      home: const _OnboardingGate(),
    );
  }
}

/// Zeigt beim ersten Start das Onboarding, danach die App.
class _OnboardingGate extends StatelessWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context) {
    final profile = AppServices.of(context).profile;
    return ListenableBuilder(
      listenable: ProfileListenable(profile),
      builder: (context, _) => profile.profile.onboarded
          ? const AppShell()
          : const OnboardingScreen(),
    );
  }
}
