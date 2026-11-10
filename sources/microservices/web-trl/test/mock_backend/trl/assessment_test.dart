// Port of sources/libraries/trl/tests/test_assess.py. The Python checks for
// non-bool answers and non-int targets have no Dart counterpart: the type
// system rules them out.
import 'package:flutter_test/flutter_test.dart';
import 'package:web_trl/mock_backend/trl/assessment.dart';

List<bool> yesAt(int n) => [...List.filled(n - 1, false), true];

void main() {
  group('assess', () {
    test('each question gives its TRL', () {
      const expected = [9, 5, 8, 7, 6, 5, 4, 3, 2, 1];
      for (var n = 1; n <= 10; n++) {
        final r = assess(yesAt(n));
        expect(r.trl, expected[n - 1], reason: 'question $n');
        expect(r.flowchartTrl, expected[n - 1]);
        expect(r.decidingQuestion!.number, n);
        expect(r.heritageEvaluated, isFalse);
      }
    });

    test('heritage is five, not nine or eight', () {
      final r = assess([false, true]);
      expect(r.trl, 5);
      expect(r.decidingQuestion!.number, 2);
      expect(r.outcome, 'TRL 5 (initially, until differences are evaluated)');
      expect(r.meetsTarget, isFalse);
      expect(r.gap, 1);
    });

    test('all no rethinks', () {
      final r = assess(List.filled(10, false));
      expect(r.trl, isNull);
      expect(r.flowchartTrl, isNull);
      expect(r.decidingQuestion, isNull);
      expect(r.outcome, 'Rethink position regarding this technology!');
      expect(r.meetsTarget, isFalse);
      expect(r.gap, 6);
    });

    test('default target is six', () {
      final r = assess(yesAt(5));
      expect(defaultTargetTrl, 6);
      expect(r.targetTrl, 6);
      expect(r.meetsTarget, isTrue);
      expect(r.gap, 0);
      expect(r.outcome, 'TRL 6');
    });

    test('below target gap', () {
      var r = assess(yesAt(7));
      expect(r.meetsTarget, isFalse);
      expect(r.gap, 2);
      r = assess(yesAt(7), targetTrl: 4);
      expect(r.meetsTarget, isTrue);
      expect(r.gap, 0);
      expect(assess(yesAt(1), targetTrl: 9).meetsTarget, isTrue);
    });

    test('rejects bad answer sequences', () {
      final bad = [
        <bool>[],
        List.filled(3, false),
        List.filled(11, false),
        [true, false],
        [false, true, true],
      ];
      for (final answers in bad) {
        expect(() => assess(answers), throwsArgumentError, reason: '$answers');
      }
    });

    test('error messages match the Python library', () {
      String message(void Function() f) {
        try {
          f();
        } on ArgumentError catch (e) {
          return e.message as String;
        }
        return '';
      }

      expect(
        message(() => assess(yesAt(5), targetTrl: 0)),
        'target_trl must be an int from 1 to 9',
      );
      expect(message(() => assess(List.filled(11, false))), 'at most ten answers are allowed');
      expect(message(() => assess([true, false])), 'no answers are allowed after the first True');
      expect(message(() => assess([false])), 'without a True, all ten questions must be answered');
      expect(
        message(() => assess([false, true], evaluatedHeritageTrl: 8)),
        'evaluated_heritage_trl must be an int: 5, 6 or 7',
      );
      expect(
        message(() => assess([true], evaluatedHeritageTrl: 6)),
        'evaluated_heritage_trl applies only when question 2 is the first yes',
      );
    });

    test('rejects bad target', () {
      for (final target in [0, 10, -1]) {
        expect(() => assess(yesAt(5), targetTrl: target), throwsArgumentError, reason: '$target');
      }
    });

    test('equal inputs give equal results', () {
      expect(assess(yesAt(5)), assess(List.unmodifiable(yesAt(5))));
      expect(assess(yesAt(5)).hashCode, assess(yesAt(5)).hashCode);
      expect(assess(yesAt(5)), isNot(assess(yesAt(4))));
    });
  });

  group('evaluated heritage', () {
    test('evaluated six meets KDP C', () {
      final r = assess([false, true], evaluatedHeritageTrl: 6);
      expect(r.trl, 6);
      expect(r.flowchartTrl, 5);
      expect(r.heritageEvaluated, isTrue);
      expect(r.decidingQuestion!.number, 2);
      expect(r.meetsTarget, isTrue);
      expect(r.gap, 0);
      expect(r.outcome, 'TRL 6 (heritage, differences evaluated; flowchart TRL 5)');
    });

    test('evaluated seven against target eight', () {
      final r = assess([false, true], targetTrl: 8, evaluatedHeritageTrl: 7);
      expect(r.trl, 7);
      expect(r.flowchartTrl, 5);
      expect(r.heritageEvaluated, isTrue);
      expect(r.meetsTarget, isFalse);
      expect(r.gap, 1);
    });

    test('evaluated five is flagged and short', () {
      final r = assess([false, true], evaluatedHeritageTrl: 5);
      expect(r.trl, 5);
      expect(r.heritageEvaluated, isTrue);
      expect(r.meetsTarget, isFalse);
      expect(r.gap, 1);
    });

    test('rejects out-of-range evaluated TRL', () {
      for (final bad in [4, 8, 9]) {
        expect(
          () => assess([false, true], evaluatedHeritageTrl: bad),
          throwsArgumentError,
          reason: '$bad',
        );
      }
    });

    test('rejects evaluated TRL without heritage yes', () {
      for (final answers in [
        [true],
        yesAt(5),
        List.filled(10, false),
      ]) {
        expect(
          () => assess(answers, evaluatedHeritageTrl: 6),
          throwsArgumentError,
          reason: '$answers',
        );
      }
    });

    test('unevaluated heritage unchanged', () {
      final r = assess([false, true], evaluatedHeritageTrl: null);
      expect(r.heritageEvaluated, isFalse);
      expect(r.trl, 5);
    });
  });
}
