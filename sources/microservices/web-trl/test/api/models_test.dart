import 'package:flutter_test/flutter_test.dart';
import 'package:web_trl/api/models.dart';

const _heritageJson = <String, Object?>{
  'trl': 6,
  'flowchart_trl': 5,
  'heritage_evaluated': true,
  'target_trl': 6,
  'meets_target': true,
  'gap': 0,
  'deciding_question': {
    'number': 2,
    'text': 'Has an identical unit in a different configuration/system architecture been successfully operated in space or the target environment or launched?',
    'trl_if_yes': 5,
    'note': 'TRL 5 initially, until differences are evaluated.',
  },
  'outcome': 'TRL 6 (heritage, differences evaluated; flowchart TRL 5)',
};

const _rethinkJson = <String, Object?>{
  'trl': null,
  'flowchart_trl': null,
  'heritage_evaluated': false,
  'target_trl': 6,
  'meets_target': false,
  'gap': 6,
  'deciding_question': null,
  'outcome': 'Rethink position regarding this technology!',
};

void main() {
  test('assessment uses the Python field names on the wire', () {
    final a = Assessment.fromJson(_heritageJson);
    expect(a.trl, 6);
    expect(a.flowchartTrl, 5);
    expect(a.heritageEvaluated, isTrue);
    expect(a.decidingQuestion!.trlIfYes, 5);
    expect(a.isHeritage, isTrue);
    expect(a.toJson(), _heritageJson);
  });

  test('rethink assessment round trip', () {
    final a = Assessment.fromJson(_rethinkJson);
    expect(a.isRethink, isTrue);
    expect(a.isHeritage, isFalse);
    expect(a.toJson(), _rethinkJson);
  });

  test('component and project round trip', () {
    final project = Project(
      id: 'p',
      name: 'Lyra',
      mission: 'm',
      phase: 'Phase B',
      milestone: 'KDP C',
      targetTrl: 6,
      components: [
        Component(
          id: 'c1',
          name: 'Star tracker',
          subsystem: 'ADCS',
          description: 'd',
          answers: const [false, true],
          evaluatedHeritageTrl: 6,
          assessment: Assessment.fromJson(_heritageJson),
        ),
        const Component(id: 'c2', name: 'OBC', subsystem: 'C&DH', description: 'd'),
      ],
    );
    final back = Project.fromJson(project.toJson());
    expect(back, project);
    expect(back.components[1].isAssessed, isFalse);
    expect(back.components[1].answers, isEmpty);
  });

  test('level count keeps the rethink bucket as null', () {
    final counts = [const LevelCount(9, 1), const LevelCount(null, 2)];
    expect(counts.map((c) => LevelCount.fromJson(c.toJson())), counts);
  });
}
