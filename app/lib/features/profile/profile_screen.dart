import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../session/session_screen.dart' show SettingKeys;
import 'profile_form.dart';
import 'safety_content.dart';

/// Profil und Einstellungen (FEATURES.md §L, P2).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen()));

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AppServices _s = AppServices.of(context);
  late final ProfileDraft _draft = ProfileDraft.from(_s.profile.profile);
  bool _warmupEnabled = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final v = await _s.settings.get(SettingKeys.warmupEnabled);
    if (mounted) setState(() => _warmupEnabled = v != 'false');
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final err = _draft.validate(_s.today().year);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() => _error = null);
    await _s.profile.save(_draft.applyTo(_s.profile.profile));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profil gespeichert')));
  }

  Future<void> _setWarmup(bool on) async {
    setState(() => _warmupEnabled = on);
    await _s.settings.set(SettingKeys.warmupEnabled, on ? 'true' : 'false');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    Widget section(String text) => Padding(
      padding: const EdgeInsets.only(top: SzSpacing.xxl, bottom: SzSpacing.s),
      child: Text(text, style: t.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(backgroundColor: p.bgBase, title: const Text('Profil')),
      body: ListView(
        key: const Key('profile-list'),
        padding: const EdgeInsets.fromLTRB(
          SzSpacing.pageMargin,
          0,
          SzSpacing.pageMargin,
          SzSpacing.xxl,
        ),
        children: [
          section('Über dich'),
          AboutYouFields(draft: _draft),
          section('Warum Eisbaden?'),
          GoalSelector(draft: _draft),
          if (_error != null) ...[
            const SizedBox(height: SzSpacing.l),
            Text(
              _error!,
              key: const Key('profile-error'),
              style: TextStyle(color: p.stateDanger),
            ),
          ],
          const SizedBox(height: SzSpacing.xl),
          SizedBox(
            height: SzTouch.min,
            child: FilledButton(
              key: const Key('profile-save'),
              onPressed: _save,
              child: const Text('Profil speichern'),
            ),
          ),
          section('Einstellungen'),
          SwitchListTile(
            key: const Key('setting-warmup'),
            contentPadding: EdgeInsets.zero,
            value: _warmupEnabled,
            onChanged: _setWarmup,
            title: const Text('Aufwärm-Impuls nach dem Bad'),
            subtitle: const Text(
              'Zeigt nach dem Beenden eine kurze Übung zum Aufwärmen.',
            ),
          ),
          section('Sicherheit'),
          ListTile(
            key: const Key('open-safety'),
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.health_and_safety_outlined, color: p.accentIce),
            title: const Text('Sicherheitshinweise'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    backgroundColor: p.bgBase,
                    title: const Text('Sicher ins Eisbad'),
                  ),
                  body: ListView(
                    padding: const EdgeInsets.all(SzSpacing.pageMargin),
                    children: const [SafetyRulesList()],
                  ),
                ),
              ),
            ),
          ),
          section('Deine Daten'),
          Text(
            'Alle Angaben, Eisbäder und Fragebögen sind nur auf diesem Gerät gespeichert.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: SzSpacing.s),
          Text(
            'Export und «Alle Daten löschen» folgen in einem der nächsten Schritte.',
            style: TextStyle(color: p.stateCaution, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
