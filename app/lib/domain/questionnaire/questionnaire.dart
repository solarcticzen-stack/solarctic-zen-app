import 'package:meta/meta.dart';

/// Regelmässige Fragebögen (FEATURES.md §L, P5).
///
/// - WHO-5: validierter Wohlbefindens-Index der WHO (5 Fragen, Antworten 0–5,
///   Wert 0–100). Wortlaut und Nutzungsbedingungen vor Release mit der
///   offiziellen deutschen Fassung abgleichen.
/// - Schlaf: eigene Kurzfragen, **nicht klinisch geprüft**.
enum QuestionnaireKind { who5, sleep }

@immutable
class QuestionnaireDefinition {
  const QuestionnaireDefinition({
    required this.kind,
    required this.title,
    required this.intro,
    required this.items,
    required this.options,
    required this.validated,
  });

  final QuestionnaireKind kind;
  final String title;
  final String intro;
  final List<String> items;

  /// Antwortoptionen als (Wert, Beschriftung), höchster Wert zuerst.
  final List<(int, String)> options;

  /// `true` = wissenschaftlich geprüftes Instrument.
  final bool validated;

  int get minValue => options.map((o) => o.$1).reduce((a, b) => a < b ? a : b);
  int get maxValue => options.map((o) => o.$1).reduce((a, b) => a > b ? a : b);

  /// Wert 0–100 aus den Antworten.
  ///
  /// WHO-5: Summe × 4 (Standardauswertung). Schlaf: Mittelwert auf 0–100 skaliert.
  double score(List<int> answers) {
    if (answers.length != items.length) {
      throw ArgumentError(
        'Erwartet ${items.length} Antworten, erhalten ${answers.length}',
      );
    }
    for (final a in answers) {
      if (a < minValue || a > maxValue) {
        throw RangeError.range(a, minValue, maxValue, 'Antwort');
      }
    }
    final sum = answers.fold(0, (s, a) => s + a);
    return switch (kind) {
      QuestionnaireKind.who5 => sum * 4.0,
      QuestionnaireKind.sleep =>
        (sum / answers.length - minValue) / (maxValue - minValue) * 100,
    };
  }
}

abstract final class Questionnaires {
  /// Abstand zwischen zwei Befragungen (WHO-5 bezieht sich auf 2 Wochen).
  static const interval = Duration(days: 14);

  static const who5 = QuestionnaireDefinition(
    kind: QuestionnaireKind.who5,
    title: 'Wohlbefinden (WHO-5)',
    intro: 'Bitte gib an, was am ehesten zutrifft, wie du dich in den letzten zwei Wochen gefühlt hast.',
    validated: true,
    items: [
      'Ich war froh und guter Laune.',
      'Ich habe mich ruhig und entspannt gefühlt.',
      'Ich habe mich energisch und aktiv gefühlt.',
      'Beim Aufwachen habe ich mich frisch und ausgeruht gefühlt.',
      'Mein Alltag war voller Dinge, die mich interessieren.',
    ],
    options: [
      (5, 'Die ganze Zeit'),
      (4, 'Meistens'),
      (3, 'Etwas mehr als die Hälfte der Zeit'),
      (2, 'Etwas weniger als die Hälfte der Zeit'),
      (1, 'Ab und zu'),
      (0, 'Zu keinem Zeitpunkt'),
    ],
  );

  static const sleep = QuestionnaireDefinition(
    kind: QuestionnaireKind.sleep,
    title: 'Schlaf (Kurzfragen)',
    intro:
        'Wie war dein Schlaf in den letzten zwei Wochen? Diese Kurzfragen sind nicht klinisch geprüft '
        'und dienen nur deinem persönlichen Verlauf.',
    validated: false,
    items: [
      'Meine Schlafqualität war gut.',
      'Das Einschlafen fiel mir leicht.',
      'Ich habe die Nacht gut durchgeschlafen.',
      'Morgens habe ich mich erholt gefühlt.',
    ],
    options: [
      (5, 'Trifft voll zu'),
      (4, 'Trifft eher zu'),
      (3, 'Teils, teils'),
      (2, 'Trifft eher nicht zu'),
      (1, 'Trifft gar nicht zu'),
    ],
  );

  static QuestionnaireDefinition of(QuestionnaireKind k) => switch (k) {
    QuestionnaireKind.who5 => who5,
    QuestionnaireKind.sleep => sleep,
  };

  /// WHO-5 ≤ 28: deutlicher Hinweis auf Unterstützung (keine Diagnose).
  static const who5SupportThreshold = 28.0;

  /// WHO-5 ≤ 50: niedriges Wohlbefinden.
  static const who5LowThreshold = 50.0;
}

@immutable
class QuestionnaireResult {
  const QuestionnaireResult({
    required this.id,
    required this.kind,
    required this.answeredAt,
    required this.answers,
    required this.score,
  });

  final String id;
  final QuestionnaireKind kind;
  final DateTime answeredAt;
  final List<int> answers;

  /// 0–100.
  final double score;
}

/// Fällig, wenn noch nie beantwortet (Ausgangswert) oder das Intervall vorbei ist.
bool isQuestionnaireDue(
  QuestionnaireKind kind,
  Iterable<QuestionnaireResult> results, {
  required DateTime now,
}) {
  DateTime? last;
  for (final r in results) {
    if (r.kind == kind && (last == null || r.answeredAt.isAfter(last))) {
      last = r.answeredAt;
    }
  }
  return last == null ||
      !now.toUtc().isBefore(last.add(Questionnaires.interval));
}

/// Port für gespeicherte Fragebogen-Ergebnisse.
abstract interface class QuestionnaireRepository {
  Stream<List<QuestionnaireResult>> watchAll();
  Future<List<QuestionnaireResult>> all();
  Future<void> save(QuestionnaireResult result);
}
