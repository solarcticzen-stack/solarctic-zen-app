import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'app_services.dart';
import 'data/community_demo_repository.dart';
import 'data/db/app_database.dart';
import 'data/db/drift_repository.dart';
import 'data/memory_repository.dart';
import 'domain/community/community.dart';
import 'domain/knowledge/article.dart';
import 'domain/milestones/milestone.dart';
import 'domain/profile/tips.dart';
import 'domain/profile/user_profile.dart';
import 'domain/questionnaire/questionnaire.dart';
import 'domain/session/session_repository.dart';
import 'domain/warmup/warmup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<Map<String, Object?>> json(String path) async =>
      jsonDecode(await rootBundle.loadString(path)) as Map<String, Object?>;

  final catalog = MilestoneCatalog.fromJson(
    await json('assets/milestones/catalog.v1.json'),
  );
  final warmup = WarmupCatalog.fromJson(
    await json('assets/warmup/catalog.v1.json'),
  );
  final tips = TipCatalog.fromJson(await json('assets/tips/catalog.v1.json'));
  const knowledgeDir = 'assets/knowledge/de';
  final knowledgeIndex = await json('$knowledgeDir/index.json');
  final articleTexts = {
    for (final f in knowledgeIndex['articles']! as List<Object?>)
      f! as String: await rootBundle.loadString('$knowledgeDir/$f'),
  };
  final knowledge = buildKnowledgeCatalog(
    knowledgeIndex,
    (f) => articleTexts[f]!,
  );

  // Geräte: SQLite. Browser-Vorschau: Arbeitsspeicher (ADR-019).
  final SessionRepository sessions;
  final SettingsStore settings;
  final QuestionnaireRepository questionnaires;
  if (kIsWeb) {
    sessions = InMemorySessionRepository();
    settings = InMemorySettingsStore();
    questionnaires = InMemoryQuestionnaireRepository();
  } else {
    final db = AppDatabase.onDevice();
    sessions = DriftSessionRepository(db);
    settings = DriftSettingsStore(db);
    questionnaires = DriftQuestionnaireRepository(db);
  }

  final profile = ProfileController(settings);
  await profile.load();
  final communityProfile = CommunityProfileController(settings);
  await communityProfile.load();
  // Bis zur Server-Anbindung: lokal, mit gekennzeichneten Beispieldaten.
  final community = LocalCommunityRepository();

  runApp(
    SolarcticZenApp(
      services: (child) => AppServices(
        sessions: sessions,
        settings: settings,
        catalog: catalog,
        warmup: warmup,
        profile: profile,
        questionnaires: questionnaires,
        tips: tips,
        knowledge: knowledge,
        community: community,
        communityProfile: communityProfile,
        isPreview: kIsWeb,
        child: child,
      ),
    ),
  );
}
