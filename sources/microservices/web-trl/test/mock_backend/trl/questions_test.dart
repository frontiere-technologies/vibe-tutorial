// Port of sources/libraries/trl/tests/test_questions.py.
import 'package:flutter_test/flutter_test.dart';
import 'package:web_trl/mock_backend/trl/questions.dart';

const _texts = [
  'Has an identical unit been successfully operated/launched in identical configuration/environment?',
  'Has an identical unit in a different configuration/system architecture been successfully operated in space or the target environment or launched?',
  'Has an identical unit been flight qualified but not yet operated in space or the target environment or launched?',
  'Has a prototype unit (or one similar enough to be considered a prototype) been successfully operated in space or the target environment or launched?',
  'Has a prototype unit (or one similar enough to be considered a prototype) been demonstrated in a relevant environment?',
  'Has a breadboard unit been demonstrated in a relevant environment?',
  'Has a breadboard unit been demonstrated in a laboratory environment?',
  'Has analytical and experimental proof-of-concept been demonstrated?',
  'Has concept or application been formulated?',
  'Have basic principles been observed and reported?',
];

void main() {
  test('ten questions in flowchart order', () {
    expect(questions.map((q) => q.number), List.generate(10, (i) => i + 1));
  });

  test('TRL for each question', () {
    expect(questions.map((q) => q.trlIfYes), [9, 5, 8, 7, 6, 5, 4, 3, 2, 1]);
  });

  test('texts verbatim', () {
    expect(questions.map((q) => q.text), _texts);
  });

  test('only the heritage question has a note', () {
    expect(heritageQuestionNumber, 2);
    expect(questions[1].note, 'TRL 5 initially, until differences are evaluated.');
    for (final q in questions.where((q) => q.number != 2)) {
      expect(q.note, isNull, reason: 'question ${q.number}');
    }
  });

  test('rethink text', () {
    expect(rethink, 'Rethink position regarding this technology!');
  });

  test('questions are immutable', () {
    expect(() => questions.add(questions.first), throwsUnsupportedError);
  });
}
