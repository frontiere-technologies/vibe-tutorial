import 'package:flutter/foundation.dart';

import '../api/trl_api.dart';
import 'app_controller.dart';

/// One walk through the questionnaire for one component: answers in
/// flowchart order, stopping at the first "yes"; the result is always the
/// back end's preview, never computed here.
class AssessmentFlowController extends ChangeNotifier {
  AssessmentFlowController({required this.app, required this.componentId, bool resume = false}) {
    final component = app.componentById(componentId);
    if (resume && component != null && component.isAssessed) {
      _answers = [...component.answers];
      _evaluatedHeritageTrl = component.evaluatedHeritageTrl;
      _preview = component.assessment;
    }
  }

  final AppController app;
  final String componentId;

  List<bool> _answers = [];
  int? _evaluatedHeritageTrl;
  Assessment? _preview;
  bool _isBusy = false;
  String? _error;

  List<bool> get answers => List.unmodifiable(_answers);
  int? get evaluatedHeritageTrl => _evaluatedHeritageTrl;
  Assessment? get preview => _preview;
  bool get isBusy => _isBusy;
  String? get error => _error;

  List<Question> get questions => app.questions;
  int get targetTrl => app.project?.targetTrl ?? defaultTargetTrl;

  /// The questionnaire ends at the first "yes" or after ten "no".
  bool get isComplete => _answers.contains(true) || _answers.length == questions.length;

  Question? get currentQuestion => isComplete ? null : questions[_answers.length];

  /// Only a "yes" to the heritage question allows an evaluated TRL.
  bool get canEvaluateHeritage => _answers.length == heritageQuestionNumber && _answers.last;

  Future<void> answer(bool yes) async {
    if (isComplete || _isBusy) return;
    _answers = [..._answers, yes];
    notifyListeners();
    if (isComplete) await _updatePreview();
  }

  void undo() {
    if (_answers.isEmpty || _isBusy) return;
    _answers = _answers.sublist(0, _answers.length - 1);
    _evaluatedHeritageTrl = null;
    _preview = null;
    _error = null;
    notifyListeners();
  }

  Future<void> setEvaluatedHeritageTrl(int? trl) async {
    if (!canEvaluateHeritage || trl == _evaluatedHeritageTrl) return;
    _evaluatedHeritageTrl = trl;
    await _updatePreview();
  }

  Future<Component?> save() async {
    if (!isComplete) return null;
    return _guard(
      () => app.saveAssessment(
        componentId,
        answers: _answers,
        evaluatedHeritageTrl: _evaluatedHeritageTrl,
      ),
    );
  }

  Future<void> _updatePreview() async {
    final result = await _guard(
      () => app.api.assess(
        answers: _answers,
        targetTrl: targetTrl,
        evaluatedHeritageTrl: _evaluatedHeritageTrl,
      ),
    );
    if (result != null) {
      _preview = result;
      notifyListeners();
    }
  }

  Future<T?> _guard<T>(Future<T> Function() call) async {
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      return await call();
    } on TrlApiException catch (e) {
      _error = e.message;
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
