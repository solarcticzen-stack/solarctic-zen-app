import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/data/memory_repository.dart';
import 'package:solarctic_zen/domain/profile/energy.dart';
import 'package:solarctic_zen/domain/profile/tips.dart';
import 'package:solarctic_zen/domain/profile/user_profile.dart';

import 'helpers.dart';

TipCatalog loadTips() => TipCatalog.fromJson(
  jsonDecode(File('assets/tips/catalog.v1.json').readAsStringSync())
      as Map<String, Object?>,
);

void main() {
  group('Profil', () {
    test('JSON hin und zurück, unbekannte Ziele werden ignoriert', () {
      final p = UserProfile(
        sex: Sex.female,
        heightCm: 170,
        weightKg: 62.5,
        birthYear: 1990,
        goals: {BathGoal.sleep, BathGoal.weightLoss},
        safetyAcknowledgedAt: DateTime.utc(2026, 11, 19),
        onboardingCompletedAt: DateTime.utc(2026, 11, 19),
      );
      final back = UserProfile.fromJson(p.toJson());
      expect(back.sex, Sex.female);
      expect(back.heightCm, 170);
      expect(back.weightKg, 62.5);
      expect(back.goals, {BathGoal.sleep, BathGoal.weightLoss});
      expect(back.onboarded, isTrue);
      final withUnknown = UserProfile.fromJson({
        ...p.toJson(),
        'goals': ['sleep', 'future_goal'],
      });
      expect(withUnknown.goals, {BathGoal.sleep});
    });

    test('freiwillige Angaben lassen sich wieder entfernen', () {
      const p = UserProfile(weightKg: 80, birthYear: 1980);
      final cleared = p.copyWith(weightKg: () => null, birthYear: () => null);
      expect(cleared.weightKg, isNull);
      expect(cleared.birthYear, isNull);
    });

    test(
      'Controller speichert in den Einstellungen und meldet Änderungen',
      () async {
        final store = InMemorySettingsStore();
        final c = ProfileController(store);
        var calls = 0;
        c.addListener(() => calls++);
        await c.save(const UserProfile(goals: {BathGoal.mental}));
        final reloaded = ProfileController(store);
        await reloaded.load();
        expect(reloaded.profile.goals, {BathGoal.mental});
        expect(calls, 1);
      },
    );
  });

  group('Tipps', () {
    final tips = loadTips();

    test(
      'Katalog: jedes Ziel hat mindestens einen Tipp, Entwurf ist markiert',
      () {
        for (final g in BathGoal.values) {
          expect(
            tips.tips.any((t) => t.goals.contains(g)),
            isTrue,
            reason: g.name,
          );
        }
        expect(tips.reviewed, isFalse, reason: 'Fachreview steht aus');
      },
    );

    test('keine Heilsversprechen in den Texten', () {
      final banned = RegExp(
        r'heilt|garantiert|nachweislich|verbrennt|entgiftet',
        caseSensitive: false,
      );
      for (final t in tips.tips) {
        expect(banned.hasMatch(t.text), isFalse, reason: t.id);
      }
    });

    test('Tipp passt zu den Zielen und wechselt täglich', () {
      const p = UserProfile(goals: {BathGoal.sleep});
      final a = tips.forDay(p, d(2026, 11, 19))!;
      final b = tips.forDay(p, d(2026, 11, 20))!;
      expect(a.goals, contains(BathGoal.sleep));
      expect(b.goals, contains(BathGoal.sleep));
      expect(a.id, isNot(b.id));
    });

    test('ohne Ziele: allgemeine Tipps', () {
      final t = tips.forDay(const UserProfile(), d(2026, 11, 19))!;
      expect(t.goals, isEmpty);
    });

    test('krankheitsbedingt: Arzt-Hinweis erscheint regelmässig', () {
      const p = UserProfile(goals: {BathGoal.medical, BathGoal.sleep});
      final days = [
        for (var i = 0; i < 9; i++)
          tips.forDay(p, d(2026, 11, 1).addDays(i))!.id,
      ];
      expect(
        days.where((id) => id == 'medical.doctor').length,
        greaterThanOrEqualTo(3),
      );
    });
  });

  test('Energie: Platzhalter 70 kcal, als Platzhalter gekennzeichnet', () {
    const e = PlaceholderEnergyEstimator();
    expect(e.isPlaceholder, isTrue);
    expect(e.estimateKcal(session(d(2026, 11, 19)), const UserProfile()), 70);
  });
}
