import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/domain/questionnaire/questionnaire.dart';

QuestionnaireResult r(QuestionnaireKind k, DateTime at) => QuestionnaireResult(
  id: '$k$at',
  kind: k,
  answeredAt: at,
  answers: const [],
  score: 0,
);

void main() {
  test('WHO-5: Summe × 4 ergibt 0–100', () {
    expect(Questionnaires.who5.score([5, 5, 5, 5, 5]), 100);
    expect(Questionnaires.who5.score([0, 0, 0, 0, 0]), 0);
    expect(Questionnaires.who5.score([3, 3, 4, 2, 3]), 60);
    expect(Questionnaires.who5.validated, isTrue);
    expect(Questionnaires.who5.items, hasLength(5));
  });

  test(
    'Schlaf-Kurzfragen: Mittelwert auf 0–100, als nicht geprüft markiert',
    () {
      expect(Questionnaires.sleep.score([1, 1, 1, 1]), 0);
      expect(Questionnaires.sleep.score([5, 5, 5, 5]), 100);
      expect(Questionnaires.sleep.score([3, 3, 3, 3]), 50);
      expect(Questionnaires.sleep.validated, isFalse);
    },
  );

  test('ungültige Antworten werden abgelehnt', () {
    expect(() => Questionnaires.who5.score([1, 2, 3]), throwsArgumentError);
    expect(() => Questionnaires.who5.score([6, 0, 0, 0, 0]), throwsRangeError);
    expect(() => Questionnaires.sleep.score([0, 1, 1, 1]), throwsRangeError);
  });

  test('fällig: sofort (Ausgangswert), danach alle 14 Tage je Fragebogen', () {
    final now = DateTime.utc(2026, 11, 19);
    expect(isQuestionnaireDue(QuestionnaireKind.who5, [], now: now), isTrue);
    final done = [
      r(QuestionnaireKind.who5, now.subtract(const Duration(days: 13))),
    ];
    expect(isQuestionnaireDue(QuestionnaireKind.who5, done, now: now), isFalse);
    expect(
      isQuestionnaireDue(QuestionnaireKind.sleep, done, now: now),
      isTrue,
      reason: 'eigener Rhythmus',
    );
    final old = [
      r(QuestionnaireKind.who5, now.subtract(const Duration(days: 14))),
    ];
    expect(isQuestionnaireDue(QuestionnaireKind.who5, old, now: now), isTrue);
  });
}
