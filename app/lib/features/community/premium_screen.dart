import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/community/community.dart';
import '../../domain/premium/premium.dart';

/// Premium freischalten: über ein Solarctic-Zen Eisbad oder als Abo
/// (ADR-029). Beides ergibt dieselben Rechte.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const PremiumScreen()));

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _serial = TextEditingController();
  String? _message;
  bool _ok = false;
  bool _busy = false;

  @override
  void dispose() {
    _serial.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final s = AppServices.of(context);
    final err = SerialNumbers.validate(_serial.text);
    if (err != null) {
      setState(() {
        _message = err;
        _ok = false;
      });
      return;
    }
    setState(() => _busy = true);
    final outcome = await s.bathRegistration.register(
      SerialNumbers.normalize(_serial.text),
    );
    final me = s.communityProfile.profile;
    if (outcome == RegistrationOutcome.granted && me != null) {
      await s.communityProfile.save(me.copyWith(tier: MemberTier.premium));
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _ok = outcome == RegistrationOutcome.granted;
      _message = switch (outcome) {
        RegistrationOutcome.granted =>
          'Eisbad registriert – Premium ist freigeschaltet.',
        RegistrationOutcome.unknown =>
          'Diese Seriennummer ist uns nicht bekannt. Bitte Eingabe prüfen '
              'oder den Solarctic-Zen-Kundendienst kontaktieren.',
        RegistrationOutcome.alreadyClaimed =>
          'Dieses Eisbad ist bereits mit einem anderen Konto verbunden. '
              'Der Kundendienst hilft weiter.',
        RegistrationOutcome.tooManyAttempts =>
          'Zu viele Versuche. Bitte in einer Stunde erneut probieren.',
        RegistrationOutcome.unavailable =>
          'Die Prüfung ist erst mit der Server-Anbindung möglich. '
              'In der Vorschau kannst du Premium über den Demo-Schalter '
              'in den Community-Einstellungen ausprobieren.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final isPremium =
        AppServices.of(context).communityProfile.profile?.canPublish ?? false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.bgBase,
        title: const Text('Premium'),
        leading: IconButton(
          tooltip: 'Schliessen',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('premium-screen'),
          padding: const EdgeInsets.all(SzSpacing.pageMargin),
          children: [
            Text(
              'Als Premium-Mitglied trägst du Eisbäder, Termine und Angebote '
              'ein – zum Beispiel dein privates Eisbad, Treffen deines Vereins '
              'oder deine Kurse. Karte und Chat stehen allen offen.',
              style: t.bodyLarge,
            ),
            if (isPremium) ...[
              const SizedBox(height: SzSpacing.m),
              Text(
                'Du bist bereits Premium-Mitglied.',
                key: const Key('premium-active'),
                style: TextStyle(
                  color: p.accentSolar,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: SzSpacing.xl),
            _Option(
              icon: Icons.hot_tub_rounded,
              title: 'Mit einem Solarctic-Zen Eisbad',
              text:
                  'Du hast ein Solarctic-Zen Eisbad gekauft? Registriere es mit '
                  'der Seriennummer – Premium ist dann inklusive.',
              children: [
                const SizedBox(height: SzSpacing.m),
                TextField(
                  key: const Key('premium-serial'),
                  controller: _serial,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Seriennummer',
                  ),
                  onSubmitted: (_) => _register(),
                ),
                const SizedBox(height: SzSpacing.s),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('premium-register'),
                    onPressed: _busy ? null : _register,
                    child: const Text('Eisbad registrieren'),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: SzSpacing.s),
                  Text(
                    _message!,
                    key: const Key('premium-result'),
                    style: TextStyle(
                      color: _ok ? p.stateLive : p.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: SzSpacing.l),
            const _Option(
              icon: Icons.autorenew_rounded,
              title: 'Als Abo',
              text:
                  'Ohne eigenes Eisbad: Premium als Abo, bezahlt über den '
                  'App Store bzw. Google Play und dort jederzeit kündbar.',
              children: [
                SizedBox(height: SzSpacing.m),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: Key('premium-subscribe'),
                    onPressed: null,
                    child: Text('Verfügbar mit dem App-Release'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.text,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String text;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(SzSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: p.accentSolar),
                const SizedBox(width: SzSpacing.s),
                Expanded(child: Text(title, style: t.titleMedium)),
              ],
            ),
            const SizedBox(height: SzSpacing.s),
            Text(text, style: t.bodyMedium),
            ...children,
          ],
        ),
      ),
    );
  }
}
