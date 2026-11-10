/// The back-end contract: what the UI receives, with its JSON wire format.
///
/// Field names follow the Python `trl` library (snake_case on the wire,
/// camelCase in Dart). See docs/superpowers/specs/2026-11-10-trl-web-app-design.md.
library;

import 'package:flutter/foundation.dart';

/// `HERITAGE_QUESTION_NUMBER` of the Python library.
const int heritageQuestionNumber = 2;

/// Evaluated TRLs allowed for a heritage component (`evaluated_heritage_trl`).
const List<int> evaluatedHeritageTrls = [5, 6, 7];

/// `DEFAULT_TARGET_TRL` of the Python library: TRL 6, expected at KDP C.
const int defaultTargetTrl = 6;

typedef Json = Map<String, Object?>;

@immutable
class Question {
  const Question({required this.number, required this.text, required this.trlIfYes, this.note});

  factory Question.fromJson(Json json) => Question(
    number: json['number']! as int,
    text: json['text']! as String,
    trlIfYes: json['trl_if_yes']! as int,
    note: json['note'] as String?,
  );

  final int number;
  final String text;
  final int trlIfYes;
  final String? note;

  bool get isHeritage => number == heritageQuestionNumber;

  Json toJson() => {'number': number, 'text': text, 'trl_if_yes': trlIfYes, 'note': note};

  @override
  bool operator ==(Object other) =>
      other is Question &&
      other.number == number &&
      other.text == text &&
      other.trlIfYes == trlIfYes &&
      other.note == note;

  @override
  int get hashCode => Object.hash(number, text, trlIfYes, note);
}

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

  factory Assessment.fromJson(Json json) {
    final q = json['deciding_question'] as Json?;
    return Assessment(
      trl: json['trl'] as int?,
      flowchartTrl: json['flowchart_trl'] as int?,
      heritageEvaluated: json['heritage_evaluated']! as bool,
      targetTrl: json['target_trl']! as int,
      meetsTarget: json['meets_target']! as bool,
      gap: json['gap']! as int,
      decidingQuestion: q == null ? null : Question.fromJson(q),
      outcome: json['outcome']! as String,
    );
  }

  final int? trl;
  final int? flowchartTrl;
  final bool heritageEvaluated;
  final int targetTrl;
  final bool meetsTarget;
  final int gap;
  final Question? decidingQuestion;
  final String outcome;

  /// All ten answers were "no": the flowchart gives no TRL.
  bool get isRethink => trl == null;

  /// Question 2 was the "yes": a reused unit in a different configuration.
  bool get isHeritage => decidingQuestion?.isHeritage ?? false;

  Json toJson() => {
    'trl': trl,
    'flowchart_trl': flowchartTrl,
    'heritage_evaluated': heritageEvaluated,
    'target_trl': targetTrl,
    'meets_target': meetsTarget,
    'gap': gap,
    'deciding_question': decidingQuestion?.toJson(),
    'outcome': outcome,
  };

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

/// A component of the product breakdown, with its saved answers and result.
@immutable
class Component {
  const Component({
    required this.id,
    required this.name,
    required this.subsystem,
    required this.description,
    this.answers = const [],
    this.evaluatedHeritageTrl,
    this.assessment,
  });

  factory Component.fromJson(Json json) {
    final a = json['assessment'] as Json?;
    return Component(
      id: json['id']! as String,
      name: json['name']! as String,
      subsystem: json['subsystem']! as String,
      description: json['description']! as String,
      answers: List<bool>.unmodifiable((json['answers']! as List).cast<bool>()),
      evaluatedHeritageTrl: json['evaluated_heritage_trl'] as int?,
      assessment: a == null ? null : Assessment.fromJson(a),
    );
  }

  final String id;
  final String name;
  final String subsystem;
  final String description;
  final List<bool> answers;
  final int? evaluatedHeritageTrl;
  final Assessment? assessment;

  bool get isAssessed => assessment != null;

  Json toJson() => {
    'id': id,
    'name': name,
    'subsystem': subsystem,
    'description': description,
    'answers': answers,
    'evaluated_heritage_trl': evaluatedHeritageTrl,
    'assessment': assessment?.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is Component &&
      other.id == id &&
      other.name == name &&
      other.subsystem == subsystem &&
      other.description == description &&
      listEquals(other.answers, answers) &&
      other.evaluatedHeritageTrl == evaluatedHeritageTrl &&
      other.assessment == assessment;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    subsystem,
    description,
    Object.hashAll(answers),
    evaluatedHeritageTrl,
    assessment,
  );
}

@immutable
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.mission,
    required this.phase,
    required this.milestone,
    required this.targetTrl,
    required this.components,
  });

  factory Project.fromJson(Json json) => Project(
    id: json['id']! as String,
    name: json['name']! as String,
    mission: json['mission']! as String,
    phase: json['phase']! as String,
    milestone: json['milestone']! as String,
    targetTrl: json['target_trl']! as int,
    components: List.unmodifiable(
      (json['components']! as List).map((c) => Component.fromJson(c as Json)),
    ),
  );

  final String id;
  final String name;
  final String mission;
  final String phase;
  final String milestone;
  final int targetTrl;
  final List<Component> components;

  Json toJson() => {
    'id': id,
    'name': name,
    'mission': mission,
    'phase': phase,
    'milestone': milestone,
    'target_trl': targetTrl,
    'components': [for (final c in components) c.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is Project &&
      other.id == id &&
      other.name == name &&
      other.mission == mission &&
      other.phase == phase &&
      other.milestone == milestone &&
      other.targetTrl == targetTrl &&
      listEquals(other.components, components);

  @override
  int get hashCode =>
      Object.hash(id, name, mission, phase, milestone, targetTrl, Object.hashAll(components));
}

/// One bucket of `trl_distribution`: a TRL (null for "rethink") and its count.
@immutable
class LevelCount {
  const LevelCount(this.trl, this.count);

  factory LevelCount.fromJson(Json json) => LevelCount(json['trl'] as int?, json['count']! as int);

  final int? trl;
  final int count;

  Json toJson() => {'trl': trl, 'count': count};

  @override
  bool operator ==(Object other) => other is LevelCount && other.trl == trl && other.count == count;

  @override
  int get hashCode => Object.hash(trl, count);
}
