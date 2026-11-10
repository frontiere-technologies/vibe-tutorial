import 'package:flutter_test/flutter_test.dart';
import 'package:web_trl/mock_backend/mock_trl_api.dart';
import 'package:web_trl/state/app_controller.dart';
import 'package:web_trl/state/assessment_flow_controller.dart';

void main() {
  group('AppController', () {
    late AppController app;

    setUp(() async {
      app = AppController(MockTrlApi(latency: Duration.zero));
      await app.load();
    });

    test('loads project, questions and distribution', () {
      expect(app.isLoading, isFalse);
      expect(app.error, isNull);
      expect(app.project!.components, hasLength(13));
      expect(app.questions, hasLength(10));
      expect(app.distribution, hasLength(10));
    });

    test('summary counts from the seed', () {
      final s = app.summary;
      expect(s.total, 13);
      expect(s.assessed, 12);
      expect(s.meetingTarget, 5);
      expect(s.belowTarget, 7);
      expect(s.lowestTrl, 1);
      expect(s.rethinkCount, 1);
    });

    test('needs attention is sorted by gap, largest first', () {
      final gaps = app.needsAttention.map((c) => c.assessment!.gap).toList();
      expect(gaps, hasLength(7));
      expect(gaps.first, 6);
      final sorted = [...gaps]..sort((a, b) => b - a);
      expect(gaps, sorted);
    });

    test('changing the target refreshes the summary', () async {
      await app.setTargetTrl(4);
      expect(app.project!.targetTrl, 4);
      expect(app.summary.belowTarget, 4);
    });

    test('saving an assessment updates the project and the distribution', () async {
      await app.saveAssessment('cdh-flight-computer', answers: [false, false, false, false, true]);
      expect(app.summary.assessed, 13);
      expect(app.componentById('cdh-flight-computer')!.assessment!.trl, 6);
      expect(app.distribution.firstWhere((c) => c.trl == 6).count, 3);
    });

    test('adding a component', () async {
      final c = await app.addComponent(name: 'Magnetorquer', subsystem: 'ADCS', description: '');
      expect(app.componentById(c.id), isNotNull);
      expect(app.subsystems, contains('ADCS'));
    });

    test('text chart comes from the back end', () async {
      expect((await app.fetchTextChart()).split('\n').last, 'Below target: 7 of 12');
    });
  });

  group('AssessmentFlowController', () {
    late AppController app;

    setUp(() async {
      app = AppController(MockTrlApi(latency: Duration.zero));
      await app.load();
    });

    AssessmentFlowController flow() =>
        AssessmentFlowController(app: app, componentId: 'cdh-flight-computer');

    test('walks the questions and stops at the first yes', () async {
      final f = flow();
      expect(f.currentQuestion!.number, 1);
      await f.answer(false);
      expect(f.currentQuestion!.number, 2);
      await f.answer(false);
      await f.answer(true);
      expect(f.isComplete, isTrue);
      expect(f.currentQuestion, isNull);
      expect(f.preview!.trl, 8);
      expect(f.preview!.targetTrl, 6);
    });

    test('ten no gives rethink', () async {
      final f = flow();
      for (var i = 0; i < 10; i++) {
        await f.answer(false);
      }
      expect(f.isComplete, isTrue);
      expect(f.preview!.isRethink, isTrue);
    });

    test('undo reopens the last question', () async {
      final f = flow();
      await f.answer(true);
      f.undo();
      expect(f.isComplete, isFalse);
      expect(f.preview, isNull);
      expect(f.currentQuestion!.number, 1);
    });

    test('heritage can be evaluated, then saved', () async {
      final f = flow();
      await f.answer(false);
      await f.answer(true);
      expect(f.preview!.trl, 5);
      expect(f.canEvaluateHeritage, isTrue);
      await f.setEvaluatedHeritageTrl(7);
      expect(f.preview!.trl, 7);
      expect(f.preview!.heritageEvaluated, isTrue);
      await f.save();
      final saved = app.componentById('cdh-flight-computer')!;
      expect(saved.assessment!.trl, 7);
      expect(saved.evaluatedHeritageTrl, 7);
    });

    test('starts from the saved answers of an assessed component', () {
      final f = AssessmentFlowController(app: app, componentId: 'adcs-star-tracker', resume: true);
      expect(f.answers, [false, true]);
      expect(f.evaluatedHeritageTrl, 6);
      expect(f.isComplete, isTrue);
    });

    test('undo of the heritage yes clears the evaluated TRL', () async {
      final f = flow();
      await f.answer(false);
      await f.answer(true);
      await f.setEvaluatedHeritageTrl(6);
      f.undo();
      expect(f.evaluatedHeritageTrl, isNull);
    });
  });
}
