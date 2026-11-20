import 'dart:math';

import 'package:meta/meta.dart';

/// Aufwärm-Impuls nach dem Bad (FEATURES.md A20, Notiz N-002).

@immutable
class WarmupText {
  const WarmupText({required this.title, required this.how});

  final String title;
  final String how;
}

@immutable
class WarmupExercise {
  const WarmupExercise({
    required this.id,
    required this.animation,
    required this.slipRisk,
    required this.texts,
  });

  final String id;

  /// Schlüssel der Animation; unbekannte Schlüssel zeigen ein Symbol.
  final String animation;

  /// Sprünge/Ausfallschritte: Hinweis auf rutschfesten Boden anzeigen.
  final bool slipRisk;
  final Map<String, WarmupText> texts;

  WarmupText text(String lang) =>
      texts[lang] ?? texts['de'] ?? texts.values.first;
}

@immutable
class WarmupCatalog {
  const WarmupCatalog({required this.version, required this.exercises});

  factory WarmupCatalog.fromJson(Map<String, Object?> json) {
    final list = <WarmupExercise>[];
    final ids = <String>{};
    for (final raw in json['exercises']! as List<Object?>) {
      final e = raw! as Map<String, Object?>;
      final id = e['id']! as String;
      if (!ids.add(id)) throw FormatException('Doppelte Übungs-ID $id');
      list.add(
        WarmupExercise(
          id: id,
          animation: e['animation']! as String,
          slipRisk: e['slip_risk'] as bool? ?? false,
          texts: (e['i18n']! as Map<String, Object?>).map((lang, t) {
            final m = t! as Map<String, Object?>;
            return MapEntry(
              lang,
              WarmupText(
                title: m['title']! as String,
                how: m['how']! as String,
              ),
            );
          }),
        ),
      );
    }
    if (list.isEmpty) throw const FormatException('Aufwärm-Katalog ist leer');
    return WarmupCatalog(
      version: (json['version']! as num).toInt(),
      exercises: list,
    );
  }

  final int version;
  final List<WarmupExercise> exercises;

  WarmupExercise? byId(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }
}

/// Wählt die nächste Übung: «immer etwas anderes».
///
/// Die zuletzt gezeigten Übungen ([recentIds], neueste zuerst) werden
/// gemieden, solange genug andere zur Verfügung stehen.
class WarmupPicker {
  WarmupPicker(this.catalog, {Random? random}) : _random = random ?? Random();

  final WarmupCatalog catalog;
  final Random _random;

  /// Wie viele der letzten Übungen gemieden werden (höchstens Katalog − 1).
  static const avoidLast = 3;

  WarmupExercise pick({List<String> recentIds = const [], String? exclude}) {
    final all = catalog.exercises;
    final blocked = <String>{?exclude};
    final maxAvoid = min(avoidLast, all.length - blocked.length - 1);
    for (final id in recentIds.take(max(0, maxAvoid))) {
      blocked.add(id);
    }
    var candidates = [
      for (final e in all)
        if (!blocked.contains(e.id)) e,
    ];
    if (candidates.isEmpty) {
      candidates = [
        for (final e in all)
          if (e.id != exclude) e,
      ];
    }
    if (candidates.isEmpty) candidates = all;
    return candidates[_random.nextInt(candidates.length)];
  }

  /// Neue Verlaufsliste (neueste zuerst, ohne Duplikate, begrenzt).
  static List<String> remember(
    List<String> recentIds,
    String id, {
    int keep = 5,
  }) => [id, ...recentIds.where((r) => r != id)].take(keep).toList();
}
