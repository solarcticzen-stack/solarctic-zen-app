import 'package:meta/meta.dart';

import '../common/local_date.dart';
import '../session/ice_session.dart';
import '../stats/stats_engine.dart';

/// Texte eines Meilensteins in einer Sprache.
@immutable
class MilestoneText {
  const MilestoneText({
    required this.title,
    required this.description,
    required this.message,
  });

  factory MilestoneText.fromJson(Map<String, Object?> json) => MilestoneText(
    title: json['title']! as String,
    description: json['description']! as String,
    message: json['message']! as String,
  );

  final String title;
  final String description;
  final String message;
}

enum MilestoneCategory {
  routine,
  count,
  duration,
  experience,
  mindfulness,
  knowledge,
}

/// Ergebnis einer Regel über die chronologische Session-Liste.
@immutable
class RuleResult {
  const RuleResult({
    required this.current,
    required this.target,
    this.achievedBy,
  });

  /// Session, mit der die Regel erstmals erfüllt war.
  final IceSession? achievedBy;
  final num current;
  final num target;
}

/// Basis aller Regeltypen. Neue Meilensteine = neuer Katalogeintrag;
/// neuer Regeltyp = neue Unterklasse + Tests (docs/DATABASE_SCHEMA.md §5).
@immutable
sealed class MilestoneRule {
  const MilestoneRule();

  /// Liefert `null` für unbekannte Regeltypen (Vorwärtskompatibilität:
  /// ein neuerer Remote-Katalog bricht eine ältere App nicht).
  static MilestoneRule? fromJson(Map<String, Object?> json) {
    int i(String k) => (json[k]! as num).toInt();
    return switch (json['type']) {
      'session_count' => SessionCountRule(i('min')),
      'total_duration' => TotalDurationRule(
        Duration(seconds: i('min_seconds')),
      ),
      'consecutive_active_weeks' => ConsecutiveWeeksRule(
        i('min_weeks'),
        sessionsPerWeek: (json['sessions_per_week'] as num?)?.toInt() ?? 1,
      ),
      'sessions_in_calendar_month' => SessionsInMonthRule(i('min')),
      'first_session_with_temp' => FirstTempRule(
        (json['max_c']! as num).toDouble(),
      ),
      'return_after_break' => ReturnAfterBreakRule(i('min_break_weeks')),
      'sessions_with_reflection' => ReflectionCountRule(i('min')),
      _ => null,
    };
  }

  /// [sessions]: abgeschlossen, chronologisch sortiert.
  RuleResult evaluate(
    List<IceSession> sessions, {
    required LocalDate today,
    required Set<LocalDate> pausedWeeks,
  });
}

class SessionCountRule extends MilestoneRule {
  const SessionCountRule(this.min);
  final int min;

  @override
  RuleResult evaluate(
    List<IceSession> s, {
    required LocalDate today,
    required Set<LocalDate> pausedWeeks,
  }) => RuleResult(
    current: s.length < min ? s.length : min,
    target: min,
    achievedBy: s.length >= min ? s[min - 1] : null,
  );
}

class TotalDurationRule extends MilestoneRule {
  const TotalDurationRule(this.min);
  final Duration min;

  @override
  RuleResult evaluate(
    List<IceSession> s, {
    required LocalDate today,
    required Set<LocalDate> pausedWeeks,
  }) {
    var total = Duration.zero;
    IceSession? hit;
    for (final x in s) {
      total += x.duration;
      if (hit == null && total >= min) hit = x;
    }
    final cur = total < min ? total : min;
    return RuleResult(
      current: cur.inSeconds,
      target: min.inSeconds,
      achievedBy: hit,
    );
  }
}

class ConsecutiveWeeksRule extends MilestoneRule {
  const ConsecutiveWeeksRule(this.minWeeks, {this.sessionsPerWeek = 1});
  final int minWeeks;
  final int sessionsPerWeek;

  @override
  RuleResult evaluate(
    List<IceSession> s, {
    required LocalDate today,
    required Set<LocalDate> pausedWeeks,
  }) {
    final perWeek = <LocalDate, int>{};
    final qualified = <LocalDate>{};
    IceSession? hit;
    for (final x in s) {
      final w = x.localDate.weekStart;
      final n = perWeek.update(w, (v) => v + 1, ifAbsent: () => 1);
      if (n == sessionsPerWeek) {
        qualified.add(w);
        if (hit == null &&
            longestRun(qualified, pausedWeeks: pausedWeeks) >= minWeeks) {
          hit = x;
        }
      }
    }
    final run = currentRun(qualified, today, pausedWeeks: pausedWeeks);
    return RuleResult(
      current: hit != null ? minWeeks : (run < minWeeks ? run : minWeeks),
      target: minWeeks,
      achievedBy: hit,
    );
  }
}

class SessionsInMonthRule extends MilestoneRule {
  const SessionsInMonthRule(this.min);
  final int min;

  @override
  RuleResult evaluate(
    List<IceSession> s, {
    required LocalDate today,
    required Set<LocalDate> pausedWeeks,
  }) {
    final perMonth = <LocalDate, int>{};
    IceSession? hit;
    for (final x in s) {
      final n = perMonth.update(
        x.localDate.monthStart,
        (v) => v + 1,
        ifAbsent: () => 1,
      );
      if (hit == null && n >= min) hit = x;
    }
    final thisMonth = perMonth[today.monthStart] ?? 0;
    return RuleResult(
      current: hit != null ? min : (thisMonth < min ? thisMonth : min),
      target: min,
      achievedBy: hit,
    );
  }
}

class FirstTempRule extends MilestoneRule {
  const FirstTempRule(this.maxC);
  final double maxC;

  @override
  RuleResult evaluate(
    List<IceSession> s, {
    required LocalDate today,
    required Set<LocalDate> pausedWeeks,
  }) {
    for (final x in s) {
      final t = x.waterTempC;
      if (t != null && t <= maxC) {
        return RuleResult(current: 1, target: 1, achievedBy: x);
      }
    }
    return const RuleResult(current: 0, target: 1);
  }
}

class ReturnAfterBreakRule extends MilestoneRule {
  const ReturnAfterBreakRule(this.minBreakWeeks);
  final int minBreakWeeks;

  @override
  RuleResult evaluate(
    List<IceSession> s, {
    required LocalDate today,
    required Set<LocalDate> pausedWeeks,
  }) {
    for (var i = 1; i < s.length; i++) {
      final gapWeeks =
          s[i].localDate.weekStart.daysSince(s[i - 1].localDate.weekStart) ~/
              7 -
          1;
      if (gapWeeks >= minBreakWeeks) {
        return RuleResult(current: 1, target: 1, achievedBy: s[i]);
      }
    }
    return const RuleResult(current: 0, target: 1);
  }
}

class ReflectionCountRule extends MilestoneRule {
  const ReflectionCountRule(this.min);
  final int min;

  @override
  RuleResult evaluate(
    List<IceSession> s, {
    required LocalDate today,
    required Set<LocalDate> pausedWeeks,
  }) {
    var n = 0;
    IceSession? hit;
    for (final x in s) {
      if (x.hasReflection) {
        n++;
        if (n == min) hit = x;
      }
    }
    return RuleResult(current: n < min ? n : min, target: min, achievedBy: hit);
  }
}

/// Ein Meilenstein aus dem Katalog.
@immutable
class MilestoneDefinition {
  const MilestoneDefinition({
    required this.id,
    required this.category,
    required this.rule,
    required this.texts,
    this.requires = const [],
    this.articleUnlock,
  });

  final String id;
  final MilestoneCategory category;
  final MilestoneRule rule;

  /// Voraussetzungen: IDs anderer Meilensteine oder externer Erfolge
  /// (z. B. `knowledge.safety_basics`).
  final List<String> requires;
  final String? articleUnlock;
  final Map<String, MilestoneText> texts;

  /// Text in [lang], sonst Deutsch, sonst irgendeiner.
  MilestoneText text(String lang) =>
      texts[lang] ?? texts['de'] ?? texts.values.first;
}

/// Versionierter Meilenstein-Katalog (assets/milestones/catalog.v1.json).
@immutable
class MilestoneCatalog {
  const MilestoneCatalog({required this.version, required this.milestones});

  /// Unbekannte Regeltypen oder Kategorien werden übersprungen.
  factory MilestoneCatalog.fromJson(Map<String, Object?> json) {
    final list = <MilestoneDefinition>[];
    for (final raw in json['milestones']! as List<Object?>) {
      final m = raw! as Map<String, Object?>;
      final rule = MilestoneRule.fromJson(m['rule']! as Map<String, Object?>);
      final category = MilestoneCategory.values.asNameMap()[m['category']];
      if (rule == null || category == null) continue;
      final i18n = (m['i18n']! as Map<String, Object?>).map(
        (lang, t) =>
            MapEntry(lang, MilestoneText.fromJson(t! as Map<String, Object?>)),
      );
      list.add(
        MilestoneDefinition(
          id: m['id']! as String,
          category: category,
          rule: rule,
          texts: i18n,
          requires: [
            for (final r in (m['requires'] as List<Object?>?) ?? const [])
              r! as String,
          ],
          articleUnlock: m['article_unlock'] as String?,
        ),
      );
    }
    final ids = <String>{};
    for (final m in list) {
      if (!ids.add(m.id)) {
        throw FormatException('Doppelte Meilenstein-ID ${m.id}');
      }
    }
    return MilestoneCatalog(
      version: (json['version']! as num).toInt(),
      milestones: list,
    );
  }

  final int version;
  final List<MilestoneDefinition> milestones;
}

/// Zustand eines Meilensteins für die Anzeige.
@immutable
class MilestoneStatus {
  const MilestoneStatus({
    required this.definition,
    required this.current,
    required this.target,
    required this.locked,
    this.achievedAt,
    this.achievedSessionId,
  });

  final MilestoneDefinition definition;
  final num current;
  final num target;

  /// Voraussetzungen fehlen (z. B. Sicherheits-Grundlagen nicht gelesen).
  final bool locked;
  final DateTime? achievedAt;
  final String? achievedSessionId;

  bool get achieved => achievedAt != null;
  double get progress =>
      target == 0 ? 1 : (current / target).clamp(0, 1).toDouble();
}

abstract final class MilestoneEngine {
  /// Berechnet alle Meilensteine aus den Sessions (abgeleiteter Zustand, ADR-007).
  ///
  /// [externalAchievements]: erfüllte Voraussetzungen ausserhalb der Sessions,
  /// z. B. `knowledge.safety_basics`.
  static List<MilestoneStatus> evaluate(
    MilestoneCatalog catalog,
    Iterable<IceSession> sessions, {
    required LocalDate today,
    Set<String> externalAchievements = const {},
    Set<LocalDate> pausedWeeks = const {},
  }) {
    final list = completedChronological(sessions);
    final results = <String, RuleResult>{
      for (final m in catalog.milestones)
        m.id: m.rule.evaluate(list, today: today, pausedWeeks: pausedWeeks),
    };
    final achievedIds = <String>{
      for (final e in results.entries)
        if (e.value.achievedBy != null) e.key,
    };
    bool met(String req) =>
        externalAchievements.contains(req) || achievedIds.contains(req);

    return [
      for (final m in catalog.milestones)
        _status(m, results[m.id]!, locked: !m.requires.every(met)),
    ];
  }

  static MilestoneStatus _status(
    MilestoneDefinition m,
    RuleResult r, {
    required bool locked,
  }) {
    final by = locked ? null : r.achievedBy;
    return MilestoneStatus(
      definition: m,
      current: r.current,
      target: r.target,
      locked: locked,
      achievedAt: by?.startedAt,
      achievedSessionId: by?.id,
    );
  }

  /// Nächster Meilenstein für das Dashboard: noch nicht erreicht, nicht
  /// gesperrt, grösster Fortschritt; bei Gleichstand gilt die Reihenfolge im
  /// Katalog (dort steht «Erstes Eisbad» vorne).
  ///
  /// Temperatur-Meilensteine werden bewusst nie als «nächstes Ziel»
  /// vorgeschlagen – die App soll nicht zu kälterem Wasser drängen
  /// (FEATURES.md, Sicherheit).
  static MilestoneStatus? next(List<MilestoneStatus> all) {
    final open = [
      for (var i = 0; i < all.length; i++)
        if (!all[i].achieved &&
            !all[i].locked &&
            all[i].definition.category != MilestoneCategory.experience)
          (i, all[i]),
    ];
    if (open.isEmpty) return null;
    open.sort((a, b) {
      final p = b.$2.progress.compareTo(a.$2.progress);
      return p != 0 ? p : a.$1.compareTo(b.$1);
    });
    return open.first.$2;
  }
}
