// Port of sources/libraries/trl/tests/test_chart.py.
import 'package:flutter_test/flutter_test.dart';
import 'package:web_trl/mock_backend/trl/assessment.dart';
import 'package:web_trl/mock_backend/trl/chart.dart';

Assessment atQuestion(int n) => assess([...List.filled(n - 1, false), true]);

final trl9 = atQuestion(1);
final trl7 = atQuestion(4);
final trl6 = atQuestion(5);
final trl4 = atQuestion(7);
final heritage = assess([false, true]);
final heritageEvaluated6 = assess([false, true], evaluatedHeritageTrl: 6);
final rethinkResult = assess(List.filled(10, false));

void main() {
  group('trlDistribution', () {
    test('all levels and rethink present in chart order', () {
      final counts = trlDistribution([]);
      expect(counts.keys.toList(), [9, 8, 7, 6, 5, 4, 3, 2, 1, null]);
      expect(counts.values.toSet(), {0});
    });

    test('counts each level', () {
      final counts = trlDistribution([trl6, trl9, trl6, trl4, rethinkResult]);
      expect(counts[9], 1);
      expect(counts[6], 2);
      expect(counts[4], 1);
      expect(counts[null], 1);
      expect(counts.values.reduce((a, b) => a + b), 5);
    });

    test('heritage counts reported TRL', () {
      final counts = trlDistribution([heritage, heritageEvaluated6]);
      expect(counts[5], 1);
      expect(counts[6], 1);
    });
  });

  group('renderTrlChart', () {
    test('approved layout', () {
      final chart = renderTrlChart([trl9, trl7, ...List.filled(10, trl6)]);
      expect(
        chart,
        [
          'TRL distribution — 12 components, target TRL 6',
          'TRL 9    |  1 █',
          'TRL 8    |  0',
          'TRL 7    |  1 █',
          'TRL 6    | 10 ██████████',
          '---------- target TRL 6 ----------',
          'TRL 5    |  0',
          'TRL 4    |  0',
          'TRL 3    |  0',
          'TRL 2    |  0',
          'TRL 1    |  0',
          'Rethink  |  0',
          'Below target: 0 of 12',
        ].join('\n'),
      );
    });

    test('below target counts rethink', () {
      final chart = renderTrlChart([trl4, rethinkResult, trl6]);
      expect(chart.endsWith('Below target: 2 of 3'), isTrue);
      expect(chart.split('\n'), contains('Rethink  | 1 █'));
    });

    test('target line follows target row', () {
      final lines = renderTrlChart([trl7], targetTrl: 8).split('\n');
      final targetLine = lines.indexOf('---------- target TRL 8 ----------');
      expect(lines[targetLine - 1], 'TRL 8    | 0');
      expect(lines.first, 'TRL distribution — 1 component, target TRL 8');
      expect(lines.last, 'Below target: 1 of 1');
    });

    test('target one puts line below TRL 1', () {
      final lines = renderTrlChart([], targetTrl: 1).split('\n');
      expect(lines[lines.indexOf('TRL 1    | 0') + 1], '---------- target TRL 1 ----------');
    });

    test('empty list', () {
      final lines = renderTrlChart([]).split('\n');
      expect(lines.first, 'TRL distribution — 0 components, target TRL 6');
      expect(lines.last, 'Below target: 0 of 0');
      expect(lines.length, 13);
    });

    test('bars scaled to forty characters', () {
      final lines = renderTrlChart([...List.filled(80, trl6), trl9]).split('\n');
      expect(lines[1], 'TRL 9    |  1 █');
      expect(lines[4], 'TRL 6    | 80 ${'█' * 40}');
    });

    test('scaled bars round half to even, as Python round()', () {
      // 5 * 40 / 80 = 2.5 → Python round() gives 2.
      final lines = renderTrlChart([...List.filled(80, trl6), ...List.filled(5, trl4)]).split('\n');
      expect(lines[7], 'TRL 4    |  5 ██');
    });

    test('scaled bar keeps at least one character', () {
      final lines = renderTrlChart([...List.filled(200, trl6), trl9]).split('\n');
      expect(lines[1], 'TRL 9    |   1 █');
    });

    test('forty or fewer are not scaled', () {
      final lines = renderTrlChart(List.filled(40, trl6)).split('\n');
      expect(lines[4], 'TRL 6    | 40 ${'█' * 40}');
    });

    test('rejects bad target', () {
      for (final target in [0, 10]) {
        expect(() => renderTrlChart([trl6], targetTrl: target), throwsArgumentError);
      }
    });
  });
}
