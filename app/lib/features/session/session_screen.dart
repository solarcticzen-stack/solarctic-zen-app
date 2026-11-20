import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/hold_button.dart';
import '../../core/design_system/inputs.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/duration_format.dart';
import '../../core/format/formatters.dart';
import '../../domain/milestones/milestone.dart';
import '../../domain/session/countdown.dart';
import '../../domain/session/ice_session.dart';
import '../../domain/warmup/warmup.dart';
import '../guide/entry_guide.dart';
import '../profile/goal_widgets.dart';
import '../warmup/warmup_view.dart';

enum _Phase { prep, countdown, running, warmup, reflect }

/// Einstellungs-Schlüssel.
abstract final class SettingKeys {
  static const countdownSeconds = 'countdown_s';
  static const lastTempC = 'last_temp_c';

  /// Zuletzt gezeigte Aufwärm-Übungen, neueste zuerst, kommagetrennt.
  static const warmupRecent = 'warmup_recent';

  /// Aufwärm-Impuls an/aus (Profil). Standard: an.
  static const warmupEnabled = 'warmup_enabled';
}

/// Vollbild-Ablauf einer Eisbad-Session:
/// Vorbereitung → (Vorlauf) → Im Wasser → Reflexion.
///
/// Die Session wird beim Start sofort gespeichert und bei jeder Aktion
/// aktualisiert (Absturzsicherheit, ADR-004). Mit [resume] wird eine nach
/// einem Absturz gefundene, laufende Session fortgesetzt.
class SessionScreen extends StatefulWidget {
  const SessionScreen({this.resume, super.key});

  final IceSession? resume;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final AppServices _s = AppServices.of(context);

  _Phase _phase = _Phase.prep;
  bool _loaded = false;
  double? _temp;
  int _countdownS = Countdown.defaultSeconds;
  Countdown? _countdown;
  int? _lastSignalSecond;
  IceSession? _session;
  List<MilestoneStatus> _newMilestones = const [];
  int? _feeling;
  int? _overcome;
  int? _during;
  final _notes = TextEditingController();
  late final WarmupPicker _picker = WarmupPicker(_s.warmup, random: _s.random);
  WarmupExercise? _exercise;
  List<String> _recentWarmups = const [];
  Timer? _ticker;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      if (widget.resume != null) {
        _session = widget.resume;
        _phase = _Phase.running;
        _startTicker();
      }
      unawaited(_loadSettings());
    }
  }

  Future<void> _loadSettings() async {
    final cd = int.tryParse(
      await _s.settings.get(SettingKeys.countdownSeconds) ?? '',
    );
    final temp = double.tryParse(
      await _s.settings.get(SettingKeys.lastTempC) ?? '',
    );
    if (!mounted) return;
    setState(() {
      if (cd != null && Countdown.options.contains(cd)) _countdownS = cd;
      _temp = temp;
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final now = _s.now();
    final cd = _countdown;
    if (_phase == _Phase.countdown && cd != null) {
      final left = cd.secondsLeft(now);
      if (left <= 3 && left > 0 && left != _lastSignalSecond) {
        _lastSignalSecond = left;
        unawaited(HapticFeedback.mediumImpact());
        unawaited(SystemSound.play(SystemSoundType.click));
      }
      if (cd.isDone(now)) {
        unawaited(_beginSession(cd.endsAt));
        return;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notes.dispose();
    super.dispose();
  }

  // ---------- Aktionen ----------

  Future<void> _onStartPressed() async {
    await _s.settings.set(SettingKeys.countdownSeconds, '$_countdownS');
    await _s.settings.set(SettingKeys.lastTempC, _temp?.toString());
    final now = _s.now();
    if (_countdownS == 0) {
      await _beginSession(now);
    } else {
      setState(() {
        _countdown = Countdown(
          startedAt: now,
          length: Duration(seconds: _countdownS),
        );
        _lastSignalSecond = null;
        _phase = _Phase.countdown;
      });
      _startTicker();
    }
  }

  Future<void> _beginSession(DateTime at) async {
    if (_busy || _phase == _Phase.running) return;
    _busy = true;
    final session = IceSession.startNow(
      id: _s.idGenerator(now: at),
      now: at,
      utcOffsetMinutes: _s.utcOffsetMinutes(),
      tzName: DateTime.now().timeZoneName,
      waterTempC: _temp,
      countdownSeconds: _countdownS == 0 ? null : _countdownS,
    );
    await _s.sessions.save(session);
    unawaited(HapticFeedback.heavyImpact());
    unawaited(SystemSound.play(SystemSoundType.alert));
    if (!mounted) return;
    setState(() {
      _session = session;
      _phase = _Phase.running;
      _busy = false;
    });
    _startTicker();
  }

  Future<void> _togglePause() async {
    final s = _session!;
    final now = _s.now();
    final clock = s.clock.isPaused ? s.clock.resume(now) : s.clock.pause(now);
    final updated = s.withClock(clock, now);
    setState(() => _session = updated);
    await _s.sessions.save(updated);
  }

  Future<void> _end() async {
    final s = _session!;
    final now = _s.now();
    _ticker?.cancel();
    final before = MilestoneEngine.evaluate(
      _s.catalog,
      await _s.sessions.all(),
      today: _s.today(),
      externalAchievements: _s.externalAchievements,
    );
    final ended = s.withClock(s.clock.end(now), now);
    await _s.sessions.save(ended);
    final after = MilestoneEngine.evaluate(
      _s.catalog,
      await _s.sessions.all(),
      today: _s.today(),
      externalAchievements: _s.externalAchievements,
    );
    final had = {
      for (final m in before)
        if (m.achieved) m.definition.id,
    };
    final warmupOn =
        await _s.settings.get(SettingKeys.warmupEnabled) != 'false';
    final recentRaw = await _s.settings.get(SettingKeys.warmupRecent) ?? '';
    _recentWarmups = [
      for (final id in recentRaw.split(','))
        if (id.isNotEmpty) id,
    ];
    if (!mounted) return;
    setState(() {
      _session = ended;
      _newMilestones = [
        for (final m in after)
          if (m.achieved && !had.contains(m.definition.id)) m,
      ];
      _exercise = warmupOn ? _picker.pick(recentIds: _recentWarmups) : null;
      _phase = warmupOn ? _Phase.warmup : _Phase.reflect;
    });
  }

  void _otherWarmup() {
    setState(() {
      _exercise = _picker.pick(
        recentIds: _recentWarmups,
        exclude: _exercise?.id,
      );
    });
  }

  /// Aufwärm-Schritt abschliessen ([done] = erledigt, sonst übersprungen).
  Future<void> _finishWarmup({required bool done}) async {
    final s = _session!;
    final ex = _exercise!;
    final updated = s.copyWith(
      warmupExerciseId: () => ex.id,
      warmupDone: () => done,
      updatedAt: _s.now(),
    );
    await _s.sessions.save(updated);
    await _s.settings.set(
      SettingKeys.warmupRecent,
      WarmupPicker.remember(_recentWarmups, ex.id).join(','),
    );
    if (!mounted) return;
    setState(() {
      _session = updated;
      _phase = _Phase.reflect;
    });
  }

  Future<void> _finish() async {
    final s = _session!;
    final notes = _notes.text.trim();
    if (_feeling != null ||
        _overcome != null ||
        _during != null ||
        notes.isNotEmpty) {
      await _s.sessions.save(
        s.copyWith(
          feelingAfter: () => _feeling,
          overcomeRating: () => _overcome,
          duringRating: () => _during,
          notes: () => notes.isEmpty ? null : notes,
          updatedAt: _s.now(),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _cancelCountdown() {
    _ticker?.cancel();
    setState(() {
      _countdown = null;
      _phase = _Phase.prep;
    });
  }

  // ---------- Darstellung ----------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase == _Phase.prep,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SzSpacing.pageMargin),
            child: switch (_phase) {
              _Phase.prep => _buildPrep(context),
              _Phase.countdown => _buildCountdown(context),
              _Phase.running => _buildRunning(context),
              _Phase.warmup => WarmupView(
                exercise: _exercise!,
                onOther: _otherWarmup,
                onDone: () => _finishWarmup(done: true),
                onSkip: () => _finishWarmup(done: false),
              ),
              _Phase.reflect => _buildReflect(context),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrep(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Schliessen',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              Text('Bereit?', style: t.headlineMedium),
              const SizedBox(height: SzSpacing.l),
              const EntryGuideCard(compact: true),
              const SizedBox(height: SzSpacing.xl),
              const _Label('WASSERTEMPERATUR'),
              const SizedBox(height: SzSpacing.s),
              SzTempPicker(
                value: _temp,
                onChanged: (v) => setState(() => _temp = v),
              ),
              const SizedBox(height: SzSpacing.xl),
              const _Label('VORLAUF VOR DEM START'),
              const SizedBox(height: SzSpacing.s),
              Wrap(
                spacing: SzSpacing.s,
                runSpacing: SzSpacing.s,
                children: [
                  for (final o in Countdown.options)
                    ChoiceChip(
                      key: Key('countdown-$o'),
                      label: Text(o == 0 ? 'Aus' : '$o s'),
                      selected: _countdownS == o,
                      onSelected: (_) => setState(() => _countdownS = o),
                    ),
                ],
              ),
              const SizedBox(height: SzSpacing.s),
              Text(
                'Leg das Handy hin und steig in Ruhe ein – die Badezeit beginnt erst nach dem Vorlauf.',
                style: t.bodyMedium,
              ),
              const SizedBox(height: SzSpacing.xl),
              Text(
                'Nie allein, ruhig atmen, Kopf über Wasser. Aussteigen ist immer richtig.',
                style: t.bodyMedium?.copyWith(color: p.textSecondary),
              ),
            ],
          ),
        ),
        SizedBox(
          height: SzTouch.session,
          child: FilledButton.icon(
            key: const Key('prep-start'),
            onPressed: _busy ? null : _onStartPressed,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              _countdownS == 0
                  ? 'Ins Wasser'
                  : 'Vorlauf starten ($_countdownS s)',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final left = _countdown!.secondsLeft(_s.now());
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'RUHIG EINSTEIGEN',
                      style: t.labelSmall?.copyWith(
                        color: p.accentIce,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: SzSpacing.l),
                    FittedBox(
                      child: Text(
                        '$left',
                        key: const Key('countdown-value'),
                        style: t.displayLarge?.copyWith(
                          fontSize: 140,
                          height: 1,
                          color: p.accentGlacier,
                        ),
                      ),
                    ),
                    const SizedBox(height: SzSpacing.l),
                    Text(
                      EntryGuide.countdownCue,
                      key: const Key('countdown-cue'),
                      style: t.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SzSpacing.s),
                    Text(
                      'Die Badezeit startet danach automatisch.',
                      style: t.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: SzTouch.session,
                child: OutlinedButton(
                  key: const Key('countdown-cancel'),
                  onPressed: _cancelCountdown,
                  style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Abbrechen'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: SzSpacing.m),
            Expanded(
              child: SizedBox(
                height: SzTouch.session,
                child: FilledButton(
                  key: const Key('countdown-skip'),
                  onPressed: () => _beginSession(_s.now()),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Jetzt starten'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRunning(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final s = _session!;
    final elapsed = s.durationAt(_s.now());
    final paused = s.clock.isPaused;
    return Column(
      children: [
        _StatusRow(temp: s.waterTempC),
        const Spacer(),
        Text(
          paused ? 'PAUSIERT' : 'IM WASSER',
          style: t.labelSmall?.copyWith(
            color: paused ? p.stateCaution : p.accentIce,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: SzSpacing.l),
        FittedBox(
          child: Text(
            formatTimer(elapsed),
            key: const Key('session-timer'),
            style: t.displayLarge!.copyWith(
              fontSize: 104,
              height: 1,
              color: paused ? p.textSecondary : p.textPrimary,
            ),
            semanticsLabel: 'Badezeit ${formatTimer(elapsed)}',
          ),
        ),
        const Spacer(),
        Text('Aussteigen ist immer richtig.', style: t.bodyMedium),
        const SizedBox(height: SzSpacing.xl),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: SzTouch.session,
                child: OutlinedButton.icon(
                  key: const Key('session-pause'),
                  onPressed: _togglePause,
                  icon: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(paused ? 'Weiter' : 'Pause'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.textPrimary,
                    side: BorderSide(color: p.borderSubtle),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: SzSpacing.m),
            Expanded(
              child: SzHoldButton(
                key: const Key('session-end'),
                label: 'Beenden',
                onConfirmed: _end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReflect(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final s = _session!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Text('Gut gemacht', style: t.headlineMedium),
              const SizedBox(height: SzSpacing.s),
              Text(
                formatTimer(s.duration),
                key: const Key('summary-duration'),
                style: t.displayMedium?.copyWith(color: p.accentIce),
              ),
              if (s.waterTempC != null)
                Text('bei ${formatTemp(s.waterTempC!)}', style: t.bodyMedium),
              const SizedBox(height: SzSpacing.m),
              Text(
                s.warmupDone == true
                    ? 'Schön aufgewärmt. Zieh dich jetzt warm an.'
                    : 'Wärm dich jetzt in Ruhe wieder auf.',
                style: t.bodyLarge,
              ),
              if (energyText(_s, s) case final energy?) ...[
                const SizedBox(height: SzSpacing.s),
                Text(
                  'Energie (Schätzung): $energy',
                  key: const Key('energy-estimate'),
                  style: t.bodyMedium,
                ),
              ],
              if (_newMilestones.isNotEmpty) ...[
                const SizedBox(height: SzSpacing.l),
                _NewMilestonesCard(items: _newMilestones),
              ],
              const SizedBox(height: SzSpacing.xl),
              // Drei Bewertungen (N-005).
              SzRatingField(
                scale: RatingScale.overcome,
                value: _overcome,
                onChanged: (v) => setState(() => _overcome = v),
              ),
              const SizedBox(height: SzSpacing.l),
              SzRatingField(
                scale: RatingScale.during,
                value: _during,
                onChanged: (v) => setState(() => _during = v),
              ),
              const SizedBox(height: SzSpacing.l),
              SzRatingField(
                scale: RatingScale.after,
                value: _feeling,
                onChanged: (v) => setState(() => _feeling = v),
              ),
              const SizedBox(height: SzSpacing.l),
              TextField(
                key: const Key('notes'),
                controller: _notes,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notiz (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: SzSpacing.m),
              if (_s.isPreview)
                Text(
                  'Browser-Vorschau: Gespeichert wird nur bis zum Neuladen der Seite.',
                  style: TextStyle(color: p.stateCaution, fontSize: 13),
                ),
            ],
          ),
        ),
        const SizedBox(height: SzSpacing.m),
        SizedBox(
          height: SzTouch.session,
          child: FilledButton(
            key: const Key('reflect-done'),
            onPressed: _finish,
            child: const Text('Fertig'),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: context.sz.textSecondary, letterSpacing: 1.5),
  );
}

/// Eine kompakte Karte für alle neu erreichten Meilensteine, damit die
/// Reflexion (Empfinden, Notiz) nicht aus dem Bild geschoben wird.
/// Die Botschaft wird nur beim ersten (wichtigsten) Meilenstein gezeigt.
class _NewMilestonesCard extends StatelessWidget {
  const _NewMilestonesCard({required this.items});
  final List<MilestoneStatus> items;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final first = items.first.definition.text('de');
    return Container(
      key: const Key('new-milestones'),
      padding: const EdgeInsets.all(SzSpacing.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SzRadius.m),
        border: Border.all(color: p.accentSolar),
        color: p.bgSurface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.military_tech_rounded, color: p.accentSolar, size: 36),
          const SizedBox(width: SzSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items.length == 1 ? 'NEUER MEILENSTEIN' : 'NEUE MEILENSTEINE',
                  style: t.labelSmall?.copyWith(color: p.accentSolar),
                ),
                for (final m in items)
                  Text(m.definition.text('de').title, style: t.titleMedium),
                const SizedBox(height: SzSpacing.xs),
                Text(first.message, style: t.bodyMedium),
                // Neu freigeschaltete Wissensbeiträge (FEATURES.md E3).
                for (final m in items)
                  if (m.definition.articleUnlock case final id?)
                    if (AppServices.of(context).knowledge.byId(id)
                        case final article?)
                      Padding(
                        padding: const EdgeInsets.only(top: SzSpacing.s),
                        child: Text(
                          'Neu im Wissen: ${article.title}',
                          key: Key('new-article-${article.id}'),
                          style: t.bodyMedium?.copyWith(color: p.accentIce),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.temp});
  final double? temp;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: p.textSecondary);
    return Row(
      children: [
        Icon(Icons.favorite_border_rounded, size: 16, color: p.textTertiary),
        const SizedBox(width: SzSpacing.xs),
        Flexible(
          child: Text(
            'HF: kein Sensor',
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: SzSpacing.l),
        Icon(Icons.thermostat_rounded, size: 16, color: p.textTertiary),
        const SizedBox(width: SzSpacing.xs),
        Flexible(
          child: Text(
            temp == null ? 'Temp.: –' : formatTemp(temp!),
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
