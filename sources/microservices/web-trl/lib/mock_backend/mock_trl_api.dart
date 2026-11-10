/// Simulated back end: answers [TrlApi] in memory, using the Dart port of the
/// Python `trl` library. Every response goes through JSON, as it would over
/// HTTP, and library errors become 400s with the library's message.
library;

import 'dart:convert';

import '../api/trl_api.dart' as api;
import 'seed.dart';
import 'trl/assessment.dart' as trl;
import 'trl/chart.dart' as trl;
import 'trl/questions.dart' as trl;

class _Record {
  _Record(
    this.id,
    this.name,
    this.subsystem,
    this.description,
    this.answers,
    this.evaluatedHeritageTrl,
  );

  final String id;
  final String name;
  final String subsystem;
  final String description;
  List<bool> answers;
  int? evaluatedHeritageTrl;
}

class MockTrlApi implements api.TrlApi {
  MockTrlApi({this.latency = const Duration(milliseconds: 300)}) {
    reset();
  }

  /// Simulated network delay of every call.
  final Duration latency;

  late int _targetTrl;
  late List<_Record> _records;
  int _nextId = 1;

  /// Restore the seeded sample project.
  void reset() {
    _targetTrl = seedProject.targetTrl;
    _records = [
      for (final s in seedComponents)
        _Record(s.id, s.name, s.subsystem, s.description, s.answers, s.evaluatedHeritageTrl),
    ];
  }

  // ---- request handling -------------------------------------------------

  Future<T> _call<T>(Object? Function() handler, T Function(Object? json) parse) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final Object? body;
    try {
      body = handler();
    } on ArgumentError catch (e) {
      throw api.TrlApiException(400, '${e.message}');
    }
    return parse(jsonDecode(jsonEncode(body)));
  }

  _Record _find(String id) => _records.firstWhere(
    (r) => r.id == id,
    orElse: () => throw const api.TrlApiException(404, 'component not found'),
  );

  static Map<String, Object?> _questionJson(trl.Question q) => {
    'number': q.number,
    'text': q.text,
    'trl_if_yes': q.trlIfYes,
    'note': q.note,
  };

  static Map<String, Object?> _assessmentJson(trl.Assessment a) => {
    'trl': a.trl,
    'flowchart_trl': a.flowchartTrl,
    'heritage_evaluated': a.heritageEvaluated,
    'target_trl': a.targetTrl,
    'meets_target': a.meetsTarget,
    'gap': a.gap,
    'deciding_question': a.decidingQuestion == null ? null : _questionJson(a.decidingQuestion!),
    'outcome': a.outcome,
  };

  trl.Assessment? _assess(_Record r) => r.answers.isEmpty
      ? null
      : trl.assess(r.answers, targetTrl: _targetTrl, evaluatedHeritageTrl: r.evaluatedHeritageTrl);

  Map<String, Object?> _componentJson(_Record r) {
    final a = _assess(r);
    return {
      'id': r.id,
      'name': r.name,
      'subsystem': r.subsystem,
      'description': r.description,
      'answers': r.answers,
      'evaluated_heritage_trl': r.evaluatedHeritageTrl,
      'assessment': a == null ? null : _assessmentJson(a),
    };
  }

  Map<String, Object?> _projectJson() => {
    'id': seedProject.id,
    'name': seedProject.name,
    'mission': seedProject.mission,
    'phase': seedProject.phase,
    'milestone': seedProject.milestone,
    'target_trl': _targetTrl,
    'components': [for (final r in _records) _componentJson(r)],
  };

  List<trl.Assessment> _assessed() => [for (final r in _records) ?_assess(r)];

  // ---- endpoints ----------------------------------------------------------

  @override
  Future<List<api.Question>> fetchQuestions() => _call(
    () => [for (final q in trl.questions) _questionJson(q)],
    (json) => [for (final q in json! as List) api.Question.fromJson(q as api.Json)],
  );

  @override
  Future<api.Assessment> assess({
    required List<bool> answers,
    int targetTrl = api.defaultTargetTrl,
    int? evaluatedHeritageTrl,
  }) => _call(
    () => _assessmentJson(
      trl.assess(answers, targetTrl: targetTrl, evaluatedHeritageTrl: evaluatedHeritageTrl),
    ),
    (json) => api.Assessment.fromJson(json! as api.Json),
  );

  @override
  Future<api.Project> fetchProject() =>
      _call(_projectJson, (json) => api.Project.fromJson(json! as api.Json));

  @override
  Future<api.Component> saveAssessment(
    String componentId, {
    required List<bool> answers,
    int? evaluatedHeritageTrl,
  }) => _call(() {
    final r = _find(componentId);
    // Validate before storing, so a bad request leaves the record untouched.
    trl.assess(answers, targetTrl: _targetTrl, evaluatedHeritageTrl: evaluatedHeritageTrl);
    r
      ..answers = List.unmodifiable(answers)
      ..evaluatedHeritageTrl = evaluatedHeritageTrl;
    return _componentJson(r);
  }, (json) => api.Component.fromJson(json! as api.Json));

  @override
  Future<api.Component> addComponent({
    required String name,
    required String subsystem,
    required String description,
  }) => _call(() {
    if (name.trim().isEmpty) throw ArgumentError('name must not be empty');
    if (subsystem.trim().isEmpty) throw ArgumentError('subsystem must not be empty');
    final r = _Record(
      'new-${_nextId++}',
      name.trim(),
      subsystem.trim(),
      description.trim(),
      const [],
      null,
    );
    _records.add(r);
    return _componentJson(r);
  }, (json) => api.Component.fromJson(json! as api.Json));

  @override
  Future<api.Project> setTargetTrl(int targetTrl) => _call(() {
    // Same validation and message as the library.
    trl.renderTrlChart(const [], targetTrl: targetTrl);
    _targetTrl = targetTrl;
    return _projectJson();
  }, (json) => api.Project.fromJson(json! as api.Json));

  @override
  Future<List<api.LevelCount>> fetchDistribution() => _call(
    () => [
      for (final e in trl.trlDistribution(_assessed()).entries) {'trl': e.key, 'count': e.value},
    ],
    (json) => [for (final c in json! as List) api.LevelCount.fromJson(c as api.Json)],
  );

  @override
  Future<String> fetchTextChart() => _call(
    () => trl.renderTrlChart(_assessed(), targetTrl: _targetTrl),
    (json) => json! as String,
  );
}
