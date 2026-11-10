import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';

import '../api/trl_api.dart';

/// Counts shown on the overview, derived from what the back end returned.
@immutable
class ProjectSummary {
  const ProjectSummary({
    required this.total,
    required this.assessed,
    required this.meetingTarget,
    required this.belowTarget,
    required this.lowestTrl,
    required this.rethinkCount,
  });

  final int total;
  final int assessed;
  final int meetingTarget;

  /// Assessed components short of the target, "rethink" included.
  final int belowTarget;

  /// Lowest reported TRL among assessed components (null if none has a TRL).
  /// Integration effects are not assessed.
  final int? lowestTrl;
  final int rethinkCount;

  int get notAssessed => total - assessed;
}

/// App-wide state: the project, the questions and the distribution, kept in
/// step with the back end after every change.
class AppController extends ChangeNotifier {
  AppController(this.api);

  final TrlApi api;

  Project? _project;
  List<Question> _questions = const [];
  List<LevelCount> _distribution = const [];
  bool _isLoading = false;
  String? _error;
  ThemeMode _themeMode = ThemeMode.system;

  Project? get project => _project;
  List<Question> get questions => _questions;
  List<LevelCount> get distribution => _distribution;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        api.fetchQuestions(),
        api.fetchProject(),
        api.fetchDistribution(),
      ]);
      _questions = results[0] as List<Question>;
      _project = results[1] as Project;
      _distribution = results[2] as List<LevelCount>;
    } on TrlApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setTargetTrl(int targetTrl) async {
    _project = await api.setTargetTrl(targetTrl);
    notifyListeners();
  }

  Future<Component> saveAssessment(
    String componentId, {
    required List<bool> answers,
    int? evaluatedHeritageTrl,
  }) async {
    final saved = await api.saveAssessment(
      componentId,
      answers: answers,
      evaluatedHeritageTrl: evaluatedHeritageTrl,
    );
    await _refresh();
    return saved;
  }

  Future<Component> addComponent({
    required String name,
    required String subsystem,
    required String description,
  }) async {
    final added = await api.addComponent(
      name: name,
      subsystem: subsystem,
      description: description,
    );
    await _refresh();
    return added;
  }

  Future<String> fetchTextChart() => api.fetchTextChart();

  Future<void> _refresh() async {
    final results = await Future.wait([api.fetchProject(), api.fetchDistribution()]);
    _project = results[0] as Project;
    _distribution = results[1] as List<LevelCount>;
    notifyListeners();
  }

  // ---- derived views ------------------------------------------------------

  Component? componentById(String id) {
    for (final c in _project?.components ?? const <Component>[]) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Subsystems in the order they first appear in the product breakdown.
  List<String> get subsystems =>
      <String>{for (final c in _project?.components ?? const <Component>[]) c.subsystem}
          .toList(growable: false);

  ProjectSummary get summary {
    final components = _project?.components ?? const <Component>[];
    final assessed = components.where((c) => c.isAssessed).toList();
    int? lowest;
    var rethinkCount = 0;
    for (final c in _distribution) {
      if (c.count == 0) continue;
      if (c.trl == null) {
        rethinkCount = c.count;
      } else if (lowest == null || c.trl! < lowest) {
        lowest = c.trl;
      }
    }
    final meeting = assessed.where((c) => c.assessment!.meetsTarget).length;
    return ProjectSummary(
      total: components.length,
      assessed: assessed.length,
      meetingTarget: meeting,
      belowTarget: assessed.length - meeting,
      lowestTrl: lowest,
      rethinkCount: rethinkCount,
    );
  }

  /// Assessed components short of the target, largest gap first.
  List<Component> get needsAttention {
    final list = [
      for (final c in _project?.components ?? const <Component>[])
        if (c.isAssessed && !c.assessment!.meetsTarget) c,
    ];
    list.sort((a, b) => b.assessment!.gap.compareTo(a.assessment!.gap));
    return list;
  }
}

/// Makes the [AppController] available to the widget tree.
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({super.key, required AppController controller, required super.child})
    : super(notifier: controller);

  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Read without subscribing to changes (for callbacks).
  static AppController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
