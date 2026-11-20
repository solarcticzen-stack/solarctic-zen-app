import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../domain/community/community.dart';
import 'community_widgets.dart';
import 'publish_forms.dart';

/// Kartenkacheln von OpenStreetMap (Entwicklung). Für den Release wird ein
/// Kartenanbieter mit eigenem Schlüssel eingesetzt (FEATURES.md §M).
const osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const appPackageName = 'ch.solarcticzen.app';

/// Mitte der Schweiz als Startansicht.
const switzerlandCenter = LatLng(46.82, 8.23);

Color placeColor(SzPalette p, PlaceType t) => switch (t) {
  PlaceType.privateBath => p.accentIce,
  PlaceType.publicSpot => p.stateLive,
  PlaceType.club => p.accentSolar,
};

IconData placeIcon(PlaceType t) => switch (t) {
  PlaceType.privateBath => Icons.hot_tub_rounded,
  PlaceType.publicSpot => Icons.pool_rounded,
  PlaceType.club => Icons.groups_rounded,
};

/// Hintergrundkarte (mit OSM-Namensnennung) – wiederverwendet im Formular.
class BaseMap extends StatelessWidget {
  const BaseMap({
    required this.options,
    required this.children,
    this.controller,
    super.key,
  });

  final MapOptions options;
  final MapController? controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final p = context.sz;
    return ClipRRect(
      borderRadius: BorderRadius.circular(SzRadius.m),
      child: ColoredBox(
        color: p.bgElevated,
        child: Stack(
          children: [
            FlutterMap(
              mapController: controller,
              options: options,
              children: [
                if (s.mapTiles)
                  TileLayer(
                    urlTemplate: osmTileUrl,
                    userAgentPackageName: appPackageName,
                  ),
                ...children,
              ],
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: const Color(0xCCFFFFFF),
                child: const Text(
                  '© OpenStreetMap-Mitwirkende',
                  style: TextStyle(fontSize: 9, color: Color(0xFF333333)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityMapView extends StatefulWidget {
  const CommunityMapView({required this.me, super.key});

  final CommunityProfile me;

  @override
  State<CommunityMapView> createState() => _CommunityMapViewState();
}

class _CommunityMapViewState extends State<CommunityMapView> {
  final Set<PlaceType> _filter = {...PlaceType.values};
  final _map = MapController();
  bool _ready = false;

  LatLng get _center => _ready ? _map.camera.center : switzerlandCenter;

  void _showDetails(Place place) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.bgElevated,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SzSpacing.pageMargin),
          child: Column(
            key: Key('place-details-${place.id}'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(placeIcon(place.type), color: placeColor(p, place.type)),
                  const SizedBox(width: SzSpacing.s),
                  Expanded(
                    child: Text(
                      place.type.label,
                      style: t.labelSmall?.copyWith(color: p.textSecondary),
                    ),
                  ),
                  if (place.isDemo) const DemoTag(),
                  ContentActionsButton(
                    target: ReportTarget.place,
                    targetId: place.id,
                    authorId: place.ownerId,
                    authorHandle: place.ownerHandle,
                  ),
                ],
              ),
              const SizedBox(height: SzSpacing.s),
              Text(place.name, style: t.headlineMedium?.copyWith(fontSize: 22)),
              const SizedBox(height: SzSpacing.s),
              Text(place.description, style: t.bodyLarge),
              if (place.address != null) ...[
                const SizedBox(height: SzSpacing.m),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: p.textSecondary,
                    ),
                    const SizedBox(width: SzSpacing.xs),
                    Expanded(
                      child: Text(
                        place.address!,
                        key: const Key('place-address'),
                        style: t.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: SzSpacing.m),
              Text('Eingetragen von ${place.ownerHandle}', style: t.bodyMedium),
              const SizedBox(height: SzSpacing.s),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final me = widget.me;
    return StreamBuilder<List<Place>>(
      stream: s.community.watchPlaces(),
      builder: (context, snap) {
        final places = [
          for (final pl in snap.data ?? const <Place>[])
            if (_filter.contains(pl.type) && !me.blocked.contains(pl.ownerId))
              pl,
        ];
        return LayoutBuilder(
          builder: (context, box) => ListView(
            key: const Key('places-list'),
            children: [
              Wrap(
                spacing: SzSpacing.s,
                runSpacing: SzSpacing.xs,
                children: [
                  for (final type in PlaceType.values)
                    FilterChip(
                      key: Key('filter-${type.name}'),
                      avatar: Icon(
                        placeIcon(type),
                        size: 16,
                        color: placeColor(p, type),
                      ),
                      label: Text(type.label),
                      selected: _filter.contains(type),
                      onSelected: (on) => setState(
                        () => on ? _filter.add(type) : _filter.remove(type),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: SzSpacing.s),
              SizedBox(
                // Auf kleinen Geräten kleiner, damit Liste und Knopf sichtbar bleiben.
                height: (box.maxHeight * 0.5).clamp(180.0, 320.0),
                child: BaseMap(
                  controller: _map,
                  options: MapOptions(
                    initialCenter: switzerlandCenter,
                    initialZoom: 7,
                    onMapReady: () => _ready = true,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    MarkerLayer(
                      markers: [
                        for (final pl in places)
                          Marker(
                            point: LatLng(pl.lat, pl.lng),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              key: Key('marker-${pl.id}'),
                              onTap: () => _showDetails(pl),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: placeColor(p, pl.type),
                                  border: Border.all(color: p.bgBase, width: 2),
                                ),
                                child: Icon(
                                  placeIcon(pl.type),
                                  size: 20,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SzSpacing.s),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${places.length} ${places.length == 1 ? 'Ort' : 'Orte'}',
                      style: t.bodyMedium,
                    ),
                  ),
                  PublishButton(
                    key: const Key('add-place'),
                    label: 'Ort eintragen',
                    onPublish: () => AddPlaceScreen.open(context, _center),
                  ),
                ],
              ),
              for (final pl in places)
                ListTile(
                  key: Key('place-${pl.id}'),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    placeIcon(pl.type),
                    color: placeColor(p, pl.type),
                  ),
                  title: Text(pl.name),
                  subtitle: Text(pl.type.label, style: t.bodyMedium),
                  trailing: pl.isDemo ? const DemoTag() : null,
                  onTap: () {
                    if (_ready) _map.move(LatLng(pl.lat, pl.lng), 11);
                    _showDetails(pl);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
