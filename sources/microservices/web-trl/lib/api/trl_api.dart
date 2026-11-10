/// The client interface the UI talks to. Today it is answered by the
/// simulated back end in `lib/mock_backend/`; an HTTP client against a Python
/// service wrapping `sources/libraries/trl` can implement it later.
library;

import 'models.dart';

export 'models.dart';

/// A failed call: `statusCode` as HTTP would give it (400 for invalid input,
/// carrying the library's `ValueError` message; 404 for an unknown id).
class TrlApiException implements Exception {
  const TrlApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'TrlApiException($statusCode): $message';
}

abstract interface class TrlApi {
  /// `GET /questions` — the ten TMA questions in flowchart order.
  Future<List<Question>> fetchQuestions();

  /// `POST /assess` — evaluate answers without saving (`trl.assess`).
  Future<Assessment> assess({
    required List<bool> answers,
    int targetTrl = defaultTargetTrl,
    int? evaluatedHeritageTrl,
  });

  /// `GET /project` — the project and its components.
  Future<Project> fetchProject();

  /// `PUT /components/{id}/assessment` — save answers, assessed against the project target.
  Future<Component> saveAssessment(
    String componentId, {
    required List<bool> answers,
    int? evaluatedHeritageTrl,
  });

  /// `POST /components` — add a component, not assessed yet.
  Future<Component> addComponent({
    required String name,
    required String subsystem,
    required String description,
  });

  /// `PUT /project/target` — change the target TRL; every assessment is recomputed.
  Future<Project> setTargetTrl(int targetTrl);

  /// `GET /project/distribution` — `trl.trl_distribution` of the assessed components.
  Future<List<LevelCount>> fetchDistribution();

  /// `GET /project/chart` — `trl.render_trl_chart` of the assessed components.
  Future<String> fetchTextChart();
}
