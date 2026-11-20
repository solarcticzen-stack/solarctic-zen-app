import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/formatters.dart';
import '../../domain/common/local_date.dart';
import '../../domain/community/community.dart';
import 'map_view.dart';
import 'premium_screen.dart';

/// Knopf zum Eintragen – nur Premium-Mitglieder (FEATURES.md §M).
class PublishButton extends StatelessWidget {
  const PublishButton({
    required this.label,
    required this.onPublish,
    super.key,
  });

  final String label;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final me = AppServices.of(context).communityProfile.profile;
    return FilledButton.icon(
      onPressed: () {
        if (me != null && me.canPublish) {
          onPublish();
        } else {
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              key: const Key('premium-required'),
              title: const Text('Nur für Premium-Mitglieder'),
              content: const Text(
                'Orte, Termine und Angebote können Premium-Mitglieder eintragen – '
                'mit einem Solarctic-Zen Eisbad inklusive oder als Abo. '
                'Chat und Karte stehen allen Mitgliedern offen.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Später'),
                ),
                FilledButton(
                  key: const Key('premium-learn'),
                  onPressed: () {
                    Navigator.pop(context);
                    PremiumScreen.open(context);
                  },
                  child: const Text('Premium freischalten'),
                ),
              ],
            ),
          );
        }
      },
      icon: const Icon(Icons.add_rounded, size: 18),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
    );
  }
}

/// Gemeinsames Gerüst der Formulare.
class _FormScaffold extends StatelessWidget {
  const _FormScaffold({
    required this.title,
    required this.children,
    required this.onSave,
    this.error,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.bgBase,
        title: Text(title),
        leading: IconButton(
          tooltip: 'Abbrechen',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(SzSpacing.pageMargin),
                children: [
                  ...children,
                  if (error != null) ...[
                    const SizedBox(height: SzSpacing.l),
                    Text(
                      error!,
                      key: const Key('publish-error'),
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
                width: double.infinity,
                height: SzTouch.session,
                child: FilledButton(
                  key: const Key('publish-save'),
                  onPressed: onSave,
                  child: const Text('Veröffentlichen'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _label(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.only(top: SzSpacing.l, bottom: SzSpacing.s),
  child: Text(
    text,
    style: Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: context.sz.textSecondary, letterSpacing: 1.5),
  ),
);

Widget _field(
  String key,
  TextEditingController c, {
  String? hint,
  int lines = 1,
  int? maxLength,
}) => TextField(
  key: Key(key),
  controller: c,
  minLines: lines,
  maxLines: lines == 1 ? 1 : lines + 3,
  maxLength: maxLength,
  textCapitalization: TextCapitalization.sentences,
  decoration: InputDecoration(
    border: const OutlineInputBorder(),
    hintText: hint,
    isDense: true,
  ),
);

/// Prüft Pflichtlänge und Wortfilter gemeinsam für alle Formulare.
String? _check(
  String label,
  String value, {
  int min = 3,
  int max = 80,
  bool required = true,
}) {
  final v = value.trim();
  if (!required && v.isEmpty) return null;
  if (v.length < min || v.length > max) return '$label: $min–$max Zeichen.';
  if (ContentFilter.isBlocked(v)) {
    return '$label verstösst gegen die Community-Regeln.';
  }
  return null;
}

// ---------------------------------------------------------------- Orte

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({required this.start, super.key});

  final LatLng start;

  static Future<void> open(BuildContext context, LatLng start) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => AddPlaceScreen(start: start),
        ),
      );

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  PlaceType _type = PlaceType.privateBath;
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  late LatLng _point = widget.start;
  bool _addressConsent = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = AppServices.of(context);
    final me = s.communityProfile.profile!;
    final address = _address.text.trim();
    final err =
        _check('Name', _name.text) ??
        _check(
          'Beschreibung',
          _description.text,
          min: 0,
          max: 1000,
          required: false,
        ) ??
        _check('Adresse', address, min: 5, max: 160, required: false) ??
        (_type == PlaceType.privateBath &&
                address.isNotEmpty &&
                !_addressConsent
            ? 'Bitte bestätige, dass deine Adresse für Community-Mitglieder sichtbar wird.'
            : null);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    await s.community.addPlace(
      Place(
        id: s.idGenerator(now: s.now()),
        type: _type,
        name: _name.text.trim(),
        description: _description.text.trim(),
        lat: _point.latitude,
        lng: _point.longitude,
        address: address.isEmpty ? null : address,
        ownerId: me.id,
        ownerHandle: me.handle,
        createdAt: s.now(),
      ),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Ort eingetragen')));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return _FormScaffold(
      title: 'Ort eintragen',
      onSave: _save,
      error: _error,
      children: [
        _label(context, 'ART'),
        Wrap(
          spacing: SzSpacing.s,
          runSpacing: SzSpacing.s,
          children: [
            for (final type in PlaceType.values)
              ChoiceChip(
                key: Key('place-type-${type.name}'),
                avatar: Icon(
                  placeIcon(type),
                  size: 16,
                  color: placeColor(p, type),
                ),
                label: Text(type.label),
                selected: _type == type,
                onSelected: (_) => setState(() => _type = type),
              ),
          ],
        ),
        _label(context, 'NAME'),
        _field('place-name', _name, hint: 'z. B. Eisbad am Waldrand'),
        _label(context, 'BESCHREIBUNG'),
        _field(
          'place-description',
          _description,
          hint: 'Zugang, Zeiten, was man mitbringen sollte',
          lines: 3,
          maxLength: 1000,
        ),
        _label(context, 'ADRESSE'),
        _field('place-address', _address, hint: 'Strasse, PLZ Ort'),
        if (_type == PlaceType.privateBath) ...[
          CheckboxListTile(
            key: const Key('place-consent'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _addressConsent,
            onChanged: (v) => setState(() => _addressConsent = v ?? false),
            title: const Text(
              'Ich bin einverstanden, dass diese Adresse für alle Community-Mitglieder sichtbar ist.',
            ),
          ),
        ],
        _label(context, 'POSITION AUF DER KARTE'),
        Text(
          'Tippe auf die Karte, um den Punkt zu setzen.',
          style: t.bodyMedium,
        ),
        const SizedBox(height: SzSpacing.s),
        SizedBox(
          height: 220,
          child: BaseMap(
            options: MapOptions(
              initialCenter: widget.start,
              initialZoom: 8,
              onTap: (_, point) => setState(() => _point = point),
            ),
            children: [
              MarkerLayer(
                markers: [
                  Marker(
                    point: _point,
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.location_on_rounded,
                      color: placeColor(p, _type),
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: SzSpacing.xs),
        Text(
          '${_point.latitude.toStringAsFixed(4)}, ${_point.longitude.toStringAsFixed(4)}',
          key: const Key('place-point'),
          style: TextStyle(color: p.textTertiary, fontSize: 12),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Termine

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const AddEventScreen(),
    ),
  );

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  LocalDate? _day;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate(LocalDate today) async {
    final d = _day ?? today.addDays(7);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(d.year, d.month, d.day),
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 2, today.month, today.day),
      helpText: 'Datum des Termins',
    );
    if (picked != null) {
      setState(() => _day = LocalDate(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final s = AppServices.of(context);
    final me = s.communityProfile.profile!;
    final day = _day ?? s.today().addDays(7);
    final err =
        _check('Titel', _title.text) ??
        _check('Ort', _location.text, max: 120) ??
        _check(
          'Beschreibung',
          _description.text,
          min: 0,
          max: 2000,
          required: false,
        );
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final (utc, _) = s.localToUtc(day, _time.hour, _time.minute);
    if (!utc.isAfter(s.now())) {
      setState(() => _error = 'Der Termin muss in der Zukunft liegen.');
      return;
    }
    await s.community.addEvent(
      CommunityEvent(
        id: s.idGenerator(now: s.now()),
        title: _title.text.trim(),
        description: _description.text.trim(),
        startsAt: utc,
        location: _location.text.trim(),
        organizerId: me.id,
        organizerHandle: me.handle,
      ),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Termin eingetragen')));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final today = s.today();
    final day = _day ?? today.addDays(7);
    String two(int v) => v.toString().padLeft(2, '0');
    return _FormScaffold(
      title: 'Termin eintragen',
      onSave: _save,
      error: _error,
      children: [
        _label(context, 'TITEL'),
        _field(
          'event-title',
          _title,
          hint: 'z. B. Gemeinsames Winterschwimmen',
        ),
        _label(context, 'DATUM UND ZEIT'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('event-date'),
                onPressed: () => _pickDate(today),
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(formatDay(day)),
                ),
              ),
            ),
            const SizedBox(width: SzSpacing.s),
            OutlinedButton.icon(
              key: const Key('event-time'),
              onPressed: _pickTime,
              icon: const Icon(Icons.schedule_rounded, size: 18),
              label: Text('${two(_time.hour)}:${two(_time.minute)}'),
            ),
          ],
        ),
        _label(context, 'ORT'),
        _field('event-location', _location, hint: 'z. B. Steg beim Seebad'),
        _label(context, 'BESCHREIBUNG'),
        _field(
          'event-description',
          _description,
          hint: 'Treffpunkt, was mitbringen, Ablauf',
          lines: 3,
          maxLength: 2000,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Angebote

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const AddOfferScreen(),
    ),
  );

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  OfferCategory _category = OfferCategory.course;
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _contact = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = AppServices.of(context);
    final me = s.communityProfile.profile!;
    final err =
        _check('Titel', _title.text) ??
        _check('Beschreibung', _description.text, min: 10, max: 2000) ??
        _check('Ort/Region', _location.text, max: 120, required: false) ??
        _check('Kontakt', _contact.text, max: 160, required: false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    String? opt(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    await s.community.addOffer(
      Offer(
        id: s.idGenerator(now: s.now()),
        title: _title.text.trim(),
        category: _category,
        description: _description.text.trim(),
        location: opt(_location),
        contact: opt(_contact),
        providerId: me.id,
        providerHandle: me.handle,
        createdAt: s.now(),
      ),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Angebot veröffentlicht')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = context.sz;
    return _FormScaffold(
      title: 'Angebot eintragen',
      onSave: _save,
      error: _error,
      children: [
        Text(
          'Stell dich und deine Dienste vor, z. B. Kurse, Coaching oder die Nutzung deines Eisbads.',
          style: t.bodyMedium,
        ),
        _label(context, 'KATEGORIE'),
        Wrap(
          spacing: SzSpacing.s,
          runSpacing: SzSpacing.s,
          children: [
            for (final c in OfferCategory.values)
              ChoiceChip(
                key: Key('offer-category-${c.name}'),
                label: Text(c.label),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
              ),
          ],
        ),
        _label(context, 'TITEL'),
        _field(
          'offer-title',
          _title,
          hint: 'z. B. Einsteiger-Workshop Kälte & Atmung',
        ),
        _label(context, 'BESCHREIBUNG'),
        _field(
          'offer-description',
          _description,
          hint: 'Was, für wen, Dauer, Preis',
          lines: 4,
          maxLength: 2000,
        ),
        _label(context, 'ORT / REGION (FREIWILLIG)'),
        _field('offer-location', _location, hint: 'z. B. Region Bern'),
        _label(context, 'KONTAKT (FREIWILLIG)'),
        _field(
          'offer-contact',
          _contact,
          hint: 'Webseite, E-Mail oder «über den Chat»',
        ),
        const SizedBox(height: SzSpacing.m),
        Text(
          'Atemtechniken mit starkem, schnellem Atmen (Hyperventilation) nie im oder am Wasser üben lassen. '
          'Geschützte Marken- oder Methodennamen nur verwenden, wenn du dazu berechtigt bist.',
          style: TextStyle(color: p.stateCaution, fontSize: 12),
        ),
      ],
    );
  }
}
