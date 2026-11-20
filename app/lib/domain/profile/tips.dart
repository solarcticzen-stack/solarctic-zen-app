import 'package:meta/meta.dart';

import '../common/local_date.dart';
import 'user_profile.dart';

/// Evidenzstufe eines Tipps (FEATURES.md §E).
enum TipEvidence {
  good('Gut belegt'),
  early('Erste Hinweise'),
  insufficient('Unzureichend untersucht'),
  practice('Praxis-Tipp');

  const TipEvidence(this.label);
  final String label;
}

@immutable
class Tip {
  const Tip({
    required this.id,
    required this.goals,
    required this.evidence,
    required this.text,
  });

  final String id;

  /// Leer = allgemeiner Tipp für alle.
  final Set<BathGoal> goals;
  final TipEvidence evidence;
  final String text;
}

@immutable
class TipCatalog {
  const TipCatalog({
    required this.version,
    required this.tips,
    required this.reviewed,
  });

  factory TipCatalog.fromJson(Map<String, Object?> j) => TipCatalog(
    version: (j['version']! as num).toInt(),
    reviewed: !((j['status'] as String?) ?? '').startsWith('Entwurf'),
    tips: [
      for (final raw in j['tips']! as List<Object?>)
        if (raw case final Map<String, Object?> t)
          Tip(
            id: t['id']! as String,
            goals: {
              for (final g in t['goals']! as List<Object?>)
                ?BathGoal.values.asNameMap()[g],
            },
            evidence:
                TipEvidence.values.asNameMap()[t['evidence']] ??
                TipEvidence.practice,
            text: t['de']! as String,
          ),
    ],
  );

  final int version;
  final List<Tip> tips;

  /// `false`, solange der Katalog als Entwurf markiert ist.
  final bool reviewed;

  /// Tipp des Tages: passend zu den Zielen (sonst allgemein), wechselt täglich.
  /// Bei «krankheitsbedingt» steht der Arzt-Hinweis jeden dritten Tag vorne.
  Tip? forDay(UserProfile profile, LocalDate day) {
    final matching = [
      for (final t in tips)
        if (t.goals.any(profile.goals.contains)) t,
    ];
    final pool = matching.isEmpty
        ? [
            for (final t in tips)
              if (t.goals.isEmpty) t,
          ]
        : matching;
    if (pool.isEmpty) return null;
    final ordinal = day.daysSince(LocalDate(2000, 1, 1));
    if (profile.has(BathGoal.medical) && ordinal % 3 == 0) {
      final medical = pool.where((t) => t.goals.contains(BathGoal.medical));
      if (medical.isNotEmpty) return medical.first;
    }
    return pool[ordinal % pool.length];
  }
}
