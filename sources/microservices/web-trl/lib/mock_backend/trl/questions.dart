/// The ten TMA questions of the NASA SE Handbook flowchart, in flowchart order.
///
/// Dart port of `sources/libraries/trl/questions.py`.
library;

import 'package:flutter/foundation.dart';

@immutable
class Question {
  const Question(this.number, this.text, this.trlIfYes, [this.note]);

  final int number;
  final String text;
  final int trlIfYes;
  final String? note;

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

const int heritageQuestionNumber = 2;

const String rethink = 'Rethink position regarding this technology!';

const List<Question> questions = [
  Question(
    1,
    'Has an identical unit been successfully operated/launched in identical configuration/environment?',
    9,
  ),
  Question(
    2,
    'Has an identical unit in a different configuration/system architecture been successfully operated in space or the target environment or launched?',
    5,
    'TRL 5 initially, until differences are evaluated.',
  ),
  Question(
    3,
    'Has an identical unit been flight qualified but not yet operated in space or the target environment or launched?',
    8,
  ),
  Question(
    4,
    'Has a prototype unit (or one similar enough to be considered a prototype) been successfully operated in space or the target environment or launched?',
    7,
  ),
  Question(
    5,
    'Has a prototype unit (or one similar enough to be considered a prototype) been demonstrated in a relevant environment?',
    6,
  ),
  Question(6, 'Has a breadboard unit been demonstrated in a relevant environment?', 5),
  Question(7, 'Has a breadboard unit been demonstrated in a laboratory environment?', 4),
  Question(8, 'Has analytical and experimental proof-of-concept been demonstrated?', 3),
  Question(9, 'Has concept or application been formulated?', 2),
  Question(10, 'Have basic principles been observed and reported?', 1),
];
