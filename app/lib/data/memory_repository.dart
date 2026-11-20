import 'dart:async';

import '../domain/questionnaire/questionnaire.dart';
import '../domain/session/ice_session.dart';
import '../domain/session/session_repository.dart';

/// Speicherung im Arbeitsspeicher – für Tests und die Browser-Vorschau.
///
/// Daten gehen beim Neuladen verloren; die Vorschau weist darauf hin.
class InMemorySessionRepository implements SessionRepository {
  InMemorySessionRepository([Iterable<IceSession> initial = const []]) {
    for (final s in initial) {
      _byId[s.id] = s;
    }
  }

  final Map<String, IceSession> _byId = {};
  final StreamController<List<IceSession>> _changes =
      StreamController.broadcast();

  List<IceSession> _sorted() =>
      _byId.values.toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  @override
  Stream<List<IceSession>> watchAll() async* {
    yield _sorted();
    yield* _changes.stream;
  }

  @override
  Future<List<IceSession>> all() async => _sorted();

  @override
  Future<IceSession?> findActive() async {
    for (final s in _byId.values) {
      if (s.status == SessionStatus.active && s.deletedAt == null) return s;
    }
    return null;
  }

  @override
  Future<void> save(IceSession session) async {
    if (session.status == SessionStatus.active) {
      final other = await findActive();
      if (other != null && other.id != session.id) {
        throw StateError('Es läuft bereits eine Session (${other.id})');
      }
    }
    _byId[session.id] = session;
    _changes.add(_sorted());
  }

  @override
  Future<void> delete(String id, DateTime now) async {
    final s = _byId[id];
    if (s == null) return;
    _byId[id] = s.copyWith(deletedAt: () => now.toUtc(), updatedAt: now);
    _changes.add(_sorted());
  }

  Future<void> dispose() => _changes.close();
}

class InMemorySettingsStore implements SettingsStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> get(String key) async => _values[key];

  @override
  Future<void> set(String key, String? value) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }
}

class InMemoryQuestionnaireRepository implements QuestionnaireRepository {
  final List<QuestionnaireResult> _items = [];
  final StreamController<List<QuestionnaireResult>> _changes =
      StreamController.broadcast();

  List<QuestionnaireResult> _sorted() =>
      [..._items]..sort((a, b) => a.answeredAt.compareTo(b.answeredAt));

  @override
  Stream<List<QuestionnaireResult>> watchAll() async* {
    yield _sorted();
    yield* _changes.stream;
  }

  @override
  Future<List<QuestionnaireResult>> all() async => _sorted();

  @override
  Future<void> save(QuestionnaireResult result) async {
    _items
      ..removeWhere((r) => r.id == result.id)
      ..add(result);
    _changes.add(_sorted());
  }
}
