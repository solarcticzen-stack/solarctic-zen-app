import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/brand.dart';
import '../../core/design_system/tokens.dart';
import '../profile/profile_form.dart';
import '../profile/safety_content.dart';

/// Erster Start (FEATURES.md §L, P1):
/// Willkommen → Über dich → Warum Eisbaden? → Sicherheit → Einwilligung.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final AppServices _s = AppServices.of(context);
  late final ProfileDraft _draft = ProfileDraft.from(_s.profile.profile);
  int _step = 0;
  bool _safetyRead = false;
  bool _consent = false;
  String? _error;

  static const _steps = 5;

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 1) {
      final err = _draft.validate(_s.today().year);
      if (err != null) {
        setState(() => _error = err);
        return;
      }
    }
    setState(() {
      _error = null;
      _step++;
    });
  }

  Future<void> _finish() async {
    final now = _s.now();
    await _s.profile.save(
      _draft
          .applyTo(_s.profile.profile)
          .copyWith(
            safetyAcknowledgedAt: now,
            healthConsentAt: now,
            onboardingCompletedAt: now,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;

    final (title, body) = switch (_step) {
      0 => ('', _welcome(context)),
      1 => ('Über dich', AboutYouFields(draft: _draft)),
      2 => (
        'Warum Eisbaden?',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mehrfachauswahl möglich. Danach richten sich deine Tipps.',
              style: t.bodyMedium,
            ),
            const SizedBox(height: SzSpacing.l),
            GoalSelector(draft: _draft),
          ],
        ),
      ),
      3 => (
        'Sicher ins Eisbad',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafetyRulesList(),
            const SizedBox(height: SzSpacing.m),
            CheckboxListTile(
              key: const Key('ob-safety'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _safetyRead,
              onChanged: (v) => setState(() => _safetyRead = v ?? false),
              title: const Text('Ich habe die Sicherheitshinweise gelesen.'),
            ),
          ],
        ),
      ),
      _ => (
        'Deine Daten',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eisbäder, Bewertungen, Fragebögen und deine Angaben sind Gesundheitsdaten. '
              'Sie werden nur auf diesem Gerät gespeichert und nicht weitergegeben. '
              'Du kannst sie jederzeit ändern oder löschen.',
              style: t.bodyLarge,
            ),
            const SizedBox(height: SzSpacing.m),
            Text(
              'Die App stellt keine Diagnosen und ersetzt keine medizinische Beratung.',
              style: t.bodyMedium,
            ),
            const SizedBox(height: SzSpacing.m),
            CheckboxListTile(
              key: const Key('ob-consent'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _consent,
              onChanged: (v) => setState(() => _consent = v ?? false),
              title: const Text(
                'Ich willige ein, dass die App meine Angaben und Eisbad-Daten auf diesem Gerät speichert.',
              ),
            ),
          ],
        ),
      ),
    };

    final canContinue = switch (_step) {
      3 => _safetyRead,
      4 => _consent,
      _ => true,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SzSpacing.s,
                SzSpacing.s,
                SzSpacing.pageMargin,
                0,
              ),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      key: const Key('ob-back'),
                      tooltip: 'Zurück',
                      onPressed: () => setState(() {
                        _error = null;
                        _step--;
                      }),
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    const SizedBox(width: 48, height: 48),
                  const SizedBox(width: SzSpacing.s),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(SzRadius.full),
                      child: LinearProgressIndicator(
                        value: (_step + 1) / _steps,
                        minHeight: 4,
                        color: p.accentPrimary,
                        backgroundColor: p.bgElevated,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                key: Key('ob-step-$_step'),
                padding: const EdgeInsets.all(SzSpacing.pageMargin),
                children: [
                  if (title.isNotEmpty) ...[
                    Text(title, style: t.headlineMedium),
                    const SizedBox(height: SzSpacing.s),
                  ],
                  body,
                  if (_error != null) ...[
                    const SizedBox(height: SzSpacing.l),
                    Text(
                      _error!,
                      key: const Key('ob-error'),
                      style: TextStyle(color: p.stateDanger),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SzSpacing.pageMargin,
                0,
                SzSpacing.pageMargin,
                SzSpacing.l,
              ),
              child: SizedBox(
                height: SzTouch.session,
                child: FilledButton(
                  key: Key(_step == _steps - 1 ? 'ob-finish' : 'ob-next'),
                  onPressed: !canContinue
                      ? null
                      : _step == _steps - 1
                      ? _finish
                      : _next,
                  child: Text(switch (_step) {
                    0 => 'Los geht\'s',
                    4 => 'Fertig',
                    _ => 'Weiter',
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcome(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const SizedBox(height: SzSpacing.xl),
        Image.asset(
          dark ? SzBrandAssets.logoWhite : SzBrandAssets.logoBlack,
          key: const Key('ob-logo'),
          height: 180,
          semanticLabel: 'Solarctic-Zen – Premium Eisbäder',
        ),
        const SizedBox(height: SzSpacing.xxl),
        Text(
          'Willkommen',
          style: t.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SzSpacing.m),
        Text(
          'Dein Begleiter fürs Eisbaden: sicher einsteigen, ruhig bleiben, '
          'deine Routine sehen. Ein paar kurze Fragen, dann geht es los.',
          style: t.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
