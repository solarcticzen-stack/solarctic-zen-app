import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/community/community.dart';
import 'community_feeds.dart';
import 'community_widgets.dart';
import 'map_view.dart';
import 'premium_screen.dart';

enum CommunityView { map, events, offers, chat }

/// Community Hub (FEATURES.md §M): freiwillig, mit eigenem Profil.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    return ListenableBuilder(
      listenable: CommunityProfileListenable(s.communityProfile),
      builder: (context, _) => s.communityProfile.profile == null
          ? const _JoinView()
          : _Hub(me: s.communityProfile.profile!),
    );
  }
}

class _Hub extends StatefulWidget {
  const _Hub({required this.me});

  final CommunityProfile me;

  @override
  State<_Hub> createState() => _HubState();
}

class _HubState extends State<_Hub> {
  CommunityView _view = CommunityView.map;

  Future<void> _settings(BuildContext context) async {
    final s = AppServices.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.sz.bgElevated,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheet) {
          final me = s.communityProfile.profile;
          if (me == null) return const SizedBox.shrink();
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SzSpacing.pageMargin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    key: const Key('premium-open'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.workspace_premium_rounded),
                    title: Text(
                      me.canPublish ? 'Premium aktiv' : 'Premium freischalten',
                    ),
                    subtitle: const Text(
                      'Mit Solarctic-Zen Eisbad oder als Abo',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.pop(sheet);
                      PremiumScreen.open(context);
                    },
                  ),
                  if (s.isPreview)
                    SwitchListTile(
                      key: const Key('premium-demo'),
                      contentPadding: EdgeInsets.zero,
                      value: me.canPublish,
                      title: const Text('Premium-Mitglied (Demo)'),
                      subtitle: const Text(
                        'Nur in der Vorschau, zum Ausprobieren.',
                      ),
                      onChanged: (on) async {
                        await s.communityProfile.save(
                          me.copyWith(
                            tier: on ? MemberTier.premium : MemberTier.member,
                          ),
                        );
                        setSheet(() {});
                      },
                    ),
                  if (me.blocked.isNotEmpty)
                    ListTile(
                      key: const Key('unblock-all'),
                      contentPadding: EdgeInsets.zero,
                      title: Text('${me.blocked.length} blockierte Mitglieder'),
                      trailing: TextButton(
                        onPressed: () async {
                          await s.communityProfile.save(
                            me.copyWith(blocked: {}),
                          );
                          setSheet(() {});
                        },
                        child: const Text('Alle freigeben'),
                      ),
                    ),
                  const SizedBox(height: SzSpacing.s),
                  OutlinedButton(
                    key: const Key('leave-community'),
                    onPressed: () async {
                      Navigator.of(sheet).pop();
                      await s.communityProfile.save(null);
                    },
                    child: const Text('Community verlassen'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final me = widget.me;
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SzSpacing.pageMargin,
        SzSpacing.pageMargin,
        SzSpacing.pageMargin,
        SzSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Community',
                      maxLines: 1,
                      style: t.headlineMedium,
                    ),
                  ),
                ),
              ),
              InkWell(
                key: const Key('community-me'),
                borderRadius: BorderRadius.circular(SzRadius.full),
                onTap: () => _settings(context),
                child: Padding(
                  padding: const EdgeInsets.all(SzSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              me.handle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodyMedium?.copyWith(
                                color: p.textPrimary,
                              ),
                            ),
                            if (me.canPublish)
                              Text(
                                'Premium',
                                key: const Key('premium-badge'),
                                style: TextStyle(
                                  color: p.accentSolar,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SzSpacing.s),
                      SzAvatar(
                        symbol: me.symbol,
                        colorIndex: me.colorIndex,
                        size: 36,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (s.community.isLocalOnly) ...[
            const SizedBox(height: SzSpacing.s),
            const LocalOnlyBanner(),
          ],
          const SizedBox(height: SzSpacing.m),
          SegmentedButton<CommunityView>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: CommunityView.map,
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Karte', key: Key('community-map'), maxLines: 1),
                ),
              ),
              ButtonSegment(
                value: CommunityView.events,
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Termine',
                    key: Key('community-events'),
                    maxLines: 1,
                  ),
                ),
              ),
              ButtonSegment(
                value: CommunityView.offers,
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Angebote',
                    key: Key('community-offers'),
                    maxLines: 1,
                  ),
                ),
              ),
              ButtonSegment(
                value: CommunityView.chat,
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Chat', key: Key('community-chat'), maxLines: 1),
                ),
              ),
            ],
            selected: {_view},
            onSelectionChanged: (v) => setState(() => _view = v.first),
          ),
          const SizedBox(height: SzSpacing.m),
          Expanded(
            child: switch (_view) {
              CommunityView.map => CommunityMapView(me: me),
              CommunityView.events => EventsView(me: me),
              CommunityView.offers => OffersView(me: me),
              CommunityView.chat => ChatView(me: me),
            },
          ),
        ],
      ),
    );
  }
}

/// Beitritt: Anzeigename (mit Vorschlägen), Avatar, Regeln, Einwilligung.
class _JoinView extends StatefulWidget {
  const _JoinView();

  @override
  State<_JoinView> createState() => _JoinViewState();
}

class _JoinViewState extends State<_JoinView> {
  late final AppServices _s = AppServices.of(context);
  late final List<String> _suggestions = Handles.suggestions(
    _s.random ?? Random(),
  );
  late final _handle = TextEditingController(text: _suggestions.first);
  AvatarSymbol _symbol = AvatarSymbol.snowflake;
  int _color = 0;
  bool _rules = false;
  String? _error;

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final err = Handles.validate(_handle.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final now = _s.now();
    await _s.communityProfile.save(
      CommunityProfile(
        id: _s.idGenerator(now: now),
        handle: _handle.text.trim(),
        symbol: _symbol,
        colorIndex: _color,
        joinedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: SzSpacing.xl, bottom: SzSpacing.s),
      child: Text(
        text,
        style: t.labelSmall?.copyWith(
          color: p.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
    return ListView(
      key: const Key('community-join'),
      padding: const EdgeInsets.all(SzSpacing.pageMargin),
      children: [
        Text('Community', style: t.headlineMedium),
        const SizedBox(height: SzSpacing.s),
        Text(
          'Finde Eisbäder und Badeplätze in deiner Nähe, gemeinsame Termine, Kurse – und tausch dich im Chat aus.',
          style: t.bodyLarge,
        ),
        const SizedBox(height: SzSpacing.m),
        Container(
          padding: const EdgeInsets.all(SzSpacing.m),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SzRadius.s),
            border: Border.all(color: p.borderSubtle),
          ),
          child: Text(
            'Sichtbar für andere sind nur dein Anzeigename, dein Avatar und was du selbst schreibst oder einträgst. '
            'Deine Eisbäder, Bewertungen und Gesundheitsangaben werden nie geteilt.',
            style: t.bodyMedium?.copyWith(color: p.textPrimary),
          ),
        ),
        label('ANZEIGENAME'),
        TextField(
          key: const Key('community-handle'),
          controller: _handle,
          maxLength: Handles.maxLength,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            counterText: '',
          ),
        ),
        const SizedBox(height: SzSpacing.s),
        Wrap(
          spacing: SzSpacing.s,
          runSpacing: SzSpacing.xs,
          children: [
            for (var i = 0; i < _suggestions.length; i++)
              ActionChip(
                key: Key('handle-suggestion-$i'),
                label: Text(_suggestions[i]),
                onPressed: () => setState(() => _handle.text = _suggestions[i]),
              ),
          ],
        ),
        label('AVATAR'),
        Row(
          children: [
            SzAvatar(symbol: _symbol, colorIndex: _color, size: 56),
            const SizedBox(width: SzSpacing.l),
            Expanded(
              child: Wrap(
                spacing: SzSpacing.xs,
                runSpacing: SzSpacing.xs,
                children: [
                  for (final sym in AvatarSymbol.values)
                    IconButton(
                      key: Key('avatar-symbol-${sym.name}'),
                      tooltip: sym.label,
                      isSelected: sym == _symbol,
                      onPressed: () => setState(() => _symbol = sym),
                      icon: Icon(
                        avatarIcon(sym),
                        color: sym == _symbol
                            ? p.accentPrimary
                            : p.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: SzSpacing.s),
        Wrap(
          spacing: SzSpacing.s,
          runSpacing: SzSpacing.s,
          children: [
            for (var i = 0; i < avatarColors.length; i++)
              GestureDetector(
                key: Key('avatar-color-$i'),
                onTap: () => setState(() => _color = i),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColors[i],
                    border: Border.all(
                      color: i == _color ? p.accentPrimary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        label('COMMUNITY-REGELN'),
        for (final rule in const [
          'Respektvoll bleiben – keine Beleidigungen oder Belästigung.',
          'Keine medizinischen Versprechen oder Heilsaussagen.',
          'Werbung nur als Angebot von Premium-Mitgliedern.',
          'Gemeldete Inhalte werden von Solarctic-Zen geprüft und können entfernt werden.',
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: SzSpacing.xs),
            child: Text(
              '• $rule',
              style: t.bodyMedium?.copyWith(color: p.textPrimary),
            ),
          ),
        CheckboxListTile(
          key: const Key('community-rules'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _rules,
          onChanged: (v) => setState(() => _rules = v ?? false),
          title: const Text(
            'Ich halte mich an die Community-Regeln und möchte beitreten.',
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: SzSpacing.s),
            child: Text(
              _error!,
              key: const Key('community-error'),
              style: TextStyle(color: p.stateDanger),
            ),
          ),
        const SizedBox(height: SzSpacing.l),
        SizedBox(
          height: SzTouch.session,
          child: FilledButton(
            key: const Key('community-join-button'),
            onPressed: _rules ? _join : null,
            child: const Text('Beitreten'),
          ),
        ),
      ],
    );
  }
}
