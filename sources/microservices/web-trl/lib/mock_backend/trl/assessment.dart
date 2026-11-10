/// Assess a Technology Readiness Level from the answers to the TMA flowchart.
///
/// Dart port of `sources/libraries/trl/assessment.py`: same fields, same
/// rules, same error messages (`ValueError` becomes `ArgumentError`).
library;

import 'package:flutter/foundation.dart';

import 'questions.dart';

const int defaultTargetTrl = 6;

/// Result of [assess].
///
/// [trl] is the reported TRL; it differs from [flowchartTrl] when an evaluated
/// heritage TRL was applied ([heritageEvaluated] is true). A question-2
/// ("heritage") result of TRL 5 is provisional until the differences are
/// evaluated. For the "rethink" outcome, [trl], [flowchartTrl] and
/// [decidingQuestion] are null and [gap] equals [targetTrl] (measured from 0).
@immutable
class Assessment {
  const Assessment({
    required this.trl,
    required this.flowchartTrl,
    required this.heritageEvaluated,
    required this.targetTrl,
    required this.meetsTarget,
    required this.gap,
    required this.decidingQuestion,
    required this.outcome,
  });

  final int? trl;
  final int? flowchartTrl;
  final bool heritageEvaluated;
  final int targetTrl;
  final bool meetsTarget;
  final int gap;
  final Question? decidingQuestion;
  final String outcome;

  @override
  bool operator ==(Object other) =>
      other is Assessment &&
      other.trl == trl &&
      other.flowchartTrl == flowchartTrl &&
      other.heritageEvaluated == heritageEvaluated &&
      other.targetTrl == targetTrl &&
      other.meetsTarget == meetsTarget &&
      other.gap == gap &&
      other.decidingQuestion == decidingQuestion &&
      other.outcome == outcome;

  @override
  int get hashCode => Object.hash(
    trl,
    flowchartTrl,
    heritageEvaluated,
    targetTrl,
    meetsTarget,
    gap,
    decidingQuestion,
    outcome,
  );
}

/// Walk the flowchart: answers end at the first true, or are ten false.
///
/// [targetTrl] (1-9) is the level to meet; [evaluatedHeritageTrl] (5, 6 or 7)
/// is allowed only when question 2 is the first yes.
Assessment assess(
  List<bool> answers, {
  int targetTrl = defaultTargetTrl,
  int? evaluatedHeritageTrl,
}) {
  final given = List<bool>.unmodifiable(answers);
  if (targetTrl < 1 || targetTrl > 9) {
    throw ArgumentError('target_trl must be an int from 1 to 9');
  }
  if (given.length > questions.length) {
    throw ArgumentError('at most ten answers are allowed');
  }
  final firstYes = given.indexOf(true);
  if (firstYes >= 0) {
    if (firstYes != given.length - 1) {
      throw ArgumentError('no answers are allowed after the first True');
    }
  } else if (given.length != questions.length) {
    throw ArgumentError('without a True, all ten questions must be answered');
  }
  if (evaluatedHeritageTrl != null) {
    if (!const {5, 6, 7}.contains(evaluatedHeritageTrl)) {
      throw ArgumentError('evaluated_heritage_trl must be an int: 5, 6 or 7');
    }
    if (firstYes < 0 || given.length != heritageQuestionNumber) {
      throw ArgumentError('evaluated_heritage_trl applies only when question 2 is the first yes');
    }
  }

  if (firstYes < 0) {
    return Assessment(
      trl: null,
      flowchartTrl: null,
      heritageEvaluated: false,
      targetTrl: targetTrl,
      meetsTarget: false,
      gap: targetTrl,
      decidingQuestion: null,
      outcome: rethink,
    );
  }

  final question = questions[given.length - 1];
  final flowchartTrl = question.trlIfYes;
  var trl = flowchartTrl;
  var heritageEvaluated = false;
  final String outcome;
  if (evaluatedHeritageTrl != null) {
    trl = evaluatedHeritageTrl;
    heritageEvaluated = true;
    outcome = 'TRL $trl (heritage, differences evaluated; flowchart TRL $flowchartTrl)';
  } else if (question.number == heritageQuestionNumber) {
    outcome = 'TRL $trl (initially, until differences are evaluated)';
  } else {
    outcome = 'TRL $trl';
  }
  return Assessment(
    trl: trl,
    flowchartTrl: flowchartTrl,
    heritageEvaluated: heritageEvaluated,
    targetTrl: targetTrl,
    meetsTarget: trl >= targetTrl,
    gap: targetTrl - trl > 0 ? targetTrl - trl : 0,
    decidingQuestion: question,
    outcome: outcome,
  );
}
