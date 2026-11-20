import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/inputs.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/duration_format.dart';
import '../../core/format/formatters.dart';
import '../../domain/common/local_date.dart';
import '../../domain/session/ice_session.dart';
import '../../domain/session/session_validation.dart';
import '../session/session_screen.dart' show SettingKeys;

/// Eisbad bearbeiten (A5) oder nachträglich eintragen (A6).
class SessionEditScreen extends StatefulWidget {
  const SessionEditScreen({this.existing, this.initialDay, super.key});

  /// `null` = neuer, manueller Eintrag.
  final IceSession? existing;

  /// Vorbelegter Tag für neue Einträge (z. B. aus dem Kalender).
  final LocalDate? initialDay;

  static Future<bool?> open(
    BuildContext context, {
    IceSession? existing,
    LocalDate? initialDay,
  }) => Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          SessionEditScreen(existing: existing, initialDay: initialDay),
    ),
  );

  @override
  State<SessionEditScreen> createState() => _SessionEditScreenState();
}

class _SessionEditScreenState extends State<SessionEditScreen> {
  late final AppServices _s = AppServices.of(context);
  bool _init = false;
  late LocalDate _day;
  late TimeOfDay _time;
  late int _seconds;
  double? _temp;
  int? _feeling;
  int? _overcome;
  int? _during;
  final _notes = TextEditingController();
  String? _error;

  bool get _isNew => widget.existing == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final e = widget.existing;
    if (e != null) {
      final local = e.startedAt.add(Duration(minutes: e.utcOffsetMinutes));
      _day = e.localDate;
      _time = TimeOfDay(hour: local.hour, minute: local.minute);
      _seconds = e.duration.inSeconds;
      _temp = e.waterTempC;
      _feeling = e.feelingAfter;
      _overcome = e.overcomeRating;
      _during = e.duringRating;
      _notes.text = e.notes ?? '';
    } else {
      final today = _s.today();
      _day = widget.initialDay ?? today;
      if (_day == today) {
        // Jetzt minus 10 Minuten, auf 5 Minuten abgerundet.
        final local = _s.now().add(
          Duration(minutes: _s.utcOffsetMinutes() - 10),
        );
        _time = TimeOfDay(
          hour: local.hour,
          minute: local.minute - local.minute % 5,
        );
      } else {
        _time = const TimeOfDay(hour: 7, minute: 0);
      }
      _seconds = 120;
      _loadLastTemp();
    }
  }

  Future<void> _loadLastTemp() async {
    final t = double.tryParse(
      await _s.settings.get(SettingKeys.lastTempC) ?? '',
    );
    if (mounted && t != null) setState(() => _temp = t);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = _s.today();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_day.year, _day.month, _day.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year, today.month, today.day),
      helpText: 'Datum des Eisbads',
    );
    if (picked != null) {
      setState(() => _day = LocalDate(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Einstieg ins Wasser',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _changeSeconds(int delta) {
    setState(() {
      _seconds = (_seconds + delta).clamp(
        SessionLimits.minDuration.inSeconds,
        SessionLimits.maxDuration.inSeconds,
      );
    });
  }

  String _message(SessionProblem p) => switch (p) {
    DurationTooShort() => 'Die Dauer muss mindestens 5 Sekunden betragen.',
    DurationTooLong() =>
      'Mehr als 60 Minuten ist nicht plausibel – bitte Dauer prüfen.',
    EndsInFuture() => 'Das Eisbad kann nicht in der Zukunft liegen.',
    OverlapsOther(:final other) =>
      'Überschneidet sich mit dem Eisbad vom ${formatDay(other.localDate)} um '
          '${formatTime(other.startedAt, other.utcOffsetMinutes)} Uhr.',
  };

  Future<void> _save() async {
    final now = _s.now();
    final (utc, offset) = _s.localToUtc(_day, _time.hour, _time.minute);
    final duration = Duration(seconds: _seconds);
    final notes = _notes.text.trim();
    final base =
        widget.existing?.rescheduled(
          startedAt: utc,
          duration: duration,
          utcOffsetMinutes: offset,
          now: now,
        ) ??
        IceSession.manual(
          id: _s.idGenerator(now: now),
          startedAt: utc,
          duration: duration,
          utcOffsetMinutes: offset,
          tzName: DateTime.now().timeZoneName,
          now: now,
        );
    final candidate = base.copyWith(
      waterTempC: () => _temp,
      feelingAfter: () => _feeling,
      overcomeRating: () => _overcome,
      duringRating: () => _during,
      notes: () => notes.isEmpty ? null : notes,
      updatedAt: now,
    );
    final problems = validateSession(
      candidate,
      await _s.sessions.all(),
      now: now,
    );
    if (problems.isNotEmpty) {
      setState(() => _error = _message(problems.first));
      return;
    }
    await _s.sessions.save(candidate);
    if (_temp != null && _isNew) {
      await _s.settings.set(SettingKeys.lastTempC, '$_temp');
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isNew ? 'Eisbad nachgetragen' : 'Änderungen gespeichert',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final e = widget.existing;
    final hasPauses = e != null && e.clock.pauses.isNotEmpty;
    String two(int v) => v.toString().padLeft(2, '0');

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.bgBase,
        title: Text(_isNew ? 'Eisbad nachtragen' : 'Eisbad bearbeiten'),
        leading: IconButton(
          tooltip: 'Abbrechen',
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: SzSpacing.pageMargin,
                ),
                children: [
                  label('DATUM UND EINSTIEG'),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('edit-date'),
                          onPressed: _pickDate,
                          icon: const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                          ),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(formatDay(_day)),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(SzTouch.min),
                          ),
                        ),
                      ),
                      const SizedBox(width: SzSpacing.s),
                      OutlinedButton.icon(
                        key: const Key('edit-time'),
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule_rounded, size: 18),
                        label: Text(
                          '${two(_time.hour)}:${two(_time.minute)}',
                          key: const Key('edit-time-value'),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, SzTouch.min),
                        ),
                      ),
                    ],
                  ),
                  label('BADEZEIT'),
                  Row(
                    children: [
                      _Stepper(
                        keyPrefix: 'dur-min',
                        label: 'Minute',
                        short: 'Min',
                        onMinus: () => _changeSeconds(-60),
                        onPlus: () => _changeSeconds(60),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            formatTimer(Duration(seconds: _seconds)),
                            key: const Key('edit-duration'),
                            style: t.headlineMedium?.copyWith(
                              color: p.accentIce,
                            ),
                          ),
                        ),
                      ),
                      _Stepper(
                        keyPrefix: 'dur-sec',
                        label: '5 Sekunden',
                        short: '± 5 Sek',
                        onMinus: () => _changeSeconds(-5),
                        onPlus: () => _changeSeconds(5),
                      ),
                    ],
                  ),
                  if (hasPauses)
                    Padding(
                      padding: const EdgeInsets.only(top: SzSpacing.s),
                      child: Text(
                        'Änderst du Zeit oder Dauer, wird die Session ohne Pausen als durchgehende Badezeit gespeichert.',
                        style: t.bodyMedium,
                      ),
                    ),
                  label('WASSERTEMPERATUR'),
                  SzTempPicker(
                    value: _temp,
                    onChanged: (v) => setState(() => _temp = v),
                  ),
                  label('BEWERTUNG'),
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
                  label('NOTIZ'),
                  TextField(
                    key: const Key('edit-notes'),
                    controller: _notes,
                    minLines: 2,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Wie war es?',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: SzSpacing.l),
                    Text(
                      _error!,
                      key: const Key('edit-error'),
                      style: TextStyle(color: p.stateDanger),
                    ),
                  ],
                  const SizedBox(height: SzSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SzSpacing.pageMargin,
                SzSpacing.s,
                SzSpacing.pageMargin,
                SzSpacing.l,
              ),
              child: SizedBox(
                width: double.infinity,
                height: SzTouch.session,
                child: FilledButton(
                  key: const Key('edit-save'),
                  onPressed: _save,
                  child: Text(_isNew ? 'Eintragen' : 'Speichern'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.keyPrefix,
    required this.label,
    required this.short,
    required this.onMinus,
    required this.onPlus,
  });

  final String keyPrefix;
  final String label;

  /// Sichtbare Kurzbeschriftung unter den Knöpfen («Min», «Sek»).
  final String short;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      IconButton.outlined(
        key: Key('$keyPrefix-plus'),
        tooltip: '+ $label',
        onPressed: onPlus,
        icon: const Icon(Icons.add_rounded),
      ),
      IconButton.outlined(
        key: Key('$keyPrefix-minus'),
        tooltip: '− $label',
        onPressed: onMinus,
        icon: const Icon(Icons.remove_rounded),
      ),
      Text(
        short,
        style: TextStyle(color: context.sz.textSecondary, fontSize: 11),
      ),
    ],
  );
}
