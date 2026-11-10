import 'package:flutter_test/flutter_test.dart';
import 'package:web_trl/api/trl_api.dart';
import 'package:web_trl/mock_backend/mock_trl_api.dart';

void main() {
  late MockTrlApi api;

  setUp(() => api = MockTrlApi(latency: Duration.zero));

  test('questions are the ten flowchart questions', () async {
    final qs = await api.fetchQuestions();
    expect(qs.map((q) => q.trlIfYes), [9, 5, 8, 7, 6, 5, 4, 3, 2, 1]);
  });

  test('seeded project covers every outcome', () async {
    final p = await api.fetchProject();
    expect(p.name, 'Lyra Pathfinder');
    expect(p.targetTrl, 6);
    expect(p.components, hasLength(13));
    expect(p.components.map((c) => c.subsystem).toSet(), hasLength(7));
    final assessed = p.components.where((c) => c.isAssessed).toList();
    expect(assessed.map((c) => c.assessment!.trl).toSet(), {1, 2, 3, 4, 5, 6, 7, 8, 9, null});
    expect(assessed.where((c) => c.assessment!.heritageEvaluated), isNotEmpty);
    expect(
      assessed.where((c) => c.assessment!.isHeritage && !c.assessment!.heritageEvaluated),
      isNotEmpty,
    );
    expect(p.components.where((c) => !c.isAssessed), hasLength(1));
  });

  test('assess previews without saving', () async {
    final a = await api.assess(answers: [false, true], evaluatedHeritageTrl: 7);
    expect(a.trl, 7);
    expect(a.flowchartTrl, 5);
    expect(a.outcome, 'TRL 7 (heritage, differences evaluated; flowchart TRL 5)');
  });

  test('invalid answers become a 400 with the library message', () async {
    await expectLater(
      api.assess(answers: [true, false]),
      throwsA(
        isA<TrlApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.message, 'message', 'no answers are allowed after the first True'),
      ),
    );
  });

  test('save assessment stores answers and recomputes with the project target', () async {
    final p = await api.fetchProject();
    final obc = p.components.firstWhere((c) => !c.isAssessed);
    final saved = await api.saveAssessment(obc.id, answers: [false, false, false, true]);
    expect(saved.assessment!.trl, 7);
    expect(saved.answers, [false, false, false, true]);
    final again = await api.fetchProject();
    expect(again.components.firstWhere((c) => c.id == obc.id), saved);
  });

  test('unknown component is a 404', () async {
    await expectLater(
      api.saveAssessment('nope', answers: [true]),
      throwsA(isA<TrlApiException>().having((e) => e.statusCode, 'statusCode', 404)),
    );
  });

  test('changing the target recomputes every assessment', () async {
    final p = await api.setTargetTrl(8);
    expect(p.targetTrl, 8);
    for (final c in p.components.where((c) => c.isAssessed)) {
      expect(c.assessment!.targetTrl, 8);
    }
    await expectLater(api.setTargetTrl(10), throwsA(isA<TrlApiException>()));
  });

  test('add component is not assessed', () async {
    final c = await api.addComponent(name: 'Magnetorquer', subsystem: 'ADCS', description: '');
    expect(c.isAssessed, isFalse);
    expect((await api.fetchProject()).components, hasLength(14));
    await expectLater(
      api.addComponent(name: ' ', subsystem: 'ADCS', description: ''),
      throwsA(isA<TrlApiException>()),
    );
  });

  test('distribution and text chart follow the Python library', () async {
    final counts = await api.fetchDistribution();
    expect(counts.map((c) => c.trl), [9, 8, 7, 6, 5, 4, 3, 2, 1, null]);
    expect(counts.fold<int>(0, (s, c) => s + c.count), 12);
    final chart = await api.fetchTextChart();
    expect(chart.split('\n').first, 'TRL distribution — 12 components, target TRL 6');
  });

  test('reset restores the seed', () async {
    await api.setTargetTrl(9);
    api.reset();
    expect((await api.fetchProject()).targetTrl, 6);
  });
}
