import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:solarctic_zen/data/community_demo_repository.dart';
import 'package:solarctic_zen/data/memory_repository.dart';
import 'package:solarctic_zen/domain/community/community.dart';

void main() {
  final now = DateTime.utc(2026, 11, 20, 9);

  test('Namensvorschläge: eindeutig und gültig', () {
    final s = Handles.suggestions(Random(1), count: 5);
    expect(s.toSet().length, 5);
    for (final h in s) {
      expect(Handles.validate(h), isNull, reason: h);
    }
  });

  test('Namensprüfung: Länge, Zeichen, Wortfilter', () {
    expect(Handles.validate('Al'), isNotNull);
    expect(Handles.validate('A' * 25), isNotNull);
    expect(Handles.validate('Eis<script>'), isNotNull);
    expect(Handles.validate('Hurensohn 12'), isNotNull);
    expect(Handles.validate('Zoë Frost-Fan'), isNull);
  });

  test('Chat-Nachrichten: leer, zu lang, Wortfilter', () {
    expect(ChatLimits.validate('   '), isNotNull);
    expect(ChatLimits.validate('x' * 501), isNotNull);
    expect(ChatLimits.validate('Du Arschloch'), isNotNull);
    expect(ChatLimits.validate('Wer kommt am Sonntag?'), isNull);
  });

  test('Nur Premium darf veröffentlichen', () {
    final p = CommunityProfile(
      id: 'u',
      handle: 'Polarfuchs 12',
      symbol: AvatarSymbol.wave,
      colorIndex: 1,
      joinedAt: now,
    );
    expect(p.canPublish, isFalse);
    expect(p.copyWith(tier: MemberTier.premium).canPublish, isTrue);
  });

  test('Profil: JSON hin und zurück inkl. blockierter Mitglieder', () async {
    final store = InMemorySettingsStore();
    final c = CommunityProfileController(store);
    await c.save(
      CommunityProfile(
        id: 'u',
        handle: 'Firnluchs 33',
        symbol: AvatarSymbol.moon,
        colorIndex: 3,
        joinedAt: now,
        tier: MemberTier.premium,
        blocked: {'x'},
      ),
    );
    final again = CommunityProfileController(store);
    await again.load();
    expect(again.profile!.handle, 'Firnluchs 33');
    expect(again.profile!.tier, MemberTier.premium);
    expect(again.profile!.blocked, {'x'});
    await again.save(null);
    expect(
      await store.get('community_profile'),
      isNull,
      reason: 'Austreten löscht das Profil',
    );
  });

  test(
    'Lokales Repository: Demo-Daten gekennzeichnet, Hinzufügen wird gemeldet',
    () async {
      final r = LocalCommunityRepository(now: now);
      expect(r.isLocalOnly, isTrue);
      final places = await r.watchPlaces().first;
      expect(places, isNotEmpty);
      expect(
        places.every((p) => p.isDemo && p.name.startsWith('Demo')),
        isTrue,
      );
      final updates = r.watchChat().take(2).toList();
      await Future<void>.delayed(Duration.zero);
      await r.sendMessage(
        ChatMessage(
          id: 'm1',
          authorId: 'u',
          authorHandle: 'Ich',
          authorSymbol: AvatarSymbol.star,
          authorColor: 0,
          text: 'Hallo',
          sentAt: now,
        ),
      );
      final emitted = await updates;
      expect(emitted.last.last.text, 'Hallo');
    },
  );

  test('ohne Demo-Daten startet es leer', () async {
    final r = LocalCommunityRepository(seedDemo: false);
    expect(await r.watchPlaces().first, isEmpty);
  });

  test(
    'jeder neue Zuhörer bekommt sofort den Stand, danach Änderungen',
    () async {
      final r = LocalCommunityRepository(now: DateTime.utc(2026, 11, 20));
      final first = <int>[];
      final sub = r.watchChat().listen((m) => first.add(m.length));
      await Future<void>.delayed(Duration.zero);
      // Zweiter, späterer Zuhörer (z. B. nach einem Neuaufbau des Widgets).
      expect((await r.watchChat().first).length, 2);
      await r.sendMessage(
        ChatMessage(
          id: 'x',
          authorId: 'me',
          authorHandle: 'Ich',
          authorSymbol: AvatarSymbol.sun,
          authorColor: 0,
          text: 'Hallo',
          sentAt: DateTime.utc(2026, 11, 20),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(first, [2, 3]);
      await sub.cancel();
    },
  );
}
