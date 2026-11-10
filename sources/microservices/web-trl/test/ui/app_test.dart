import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_trl/mock_backend/mock_trl_api.dart';
import 'package:web_trl/state/app_controller.dart';
import 'package:web_trl/ui/app.dart';

const compact = Size(390, 844);
const medium = Size(800, 1100);
const expanded = Size(1400, 900);

Future<AppController> pumpApp(WidgetTester tester, Size size) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final controller = AppController(MockTrlApi(latency: Duration.zero));
  await tester.pumpWidget(TrlApp(controller: controller));
  await tester.runAsync(controller.load);
  await tester.pumpAndSettle();
  return controller;
}

Future<void> goTo(WidgetTester tester, String destination) async {
  await tester.tap(find.text(destination).last);
  await tester.pumpAndSettle();
}

/// Open the assessment of the one component not assessed in the seed.
Future<void> startFlightComputerAssessment(WidgetTester tester) async {
  await goTo(tester, 'Components');
  await tester.tap(find.byKey(const ValueKey('filter-notAssessed')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('component-cdh-flight-computer')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('start-assessment')));
  await tester.pumpAndSettle();
}

void main() {
  group('responsive shell', () {
    testWidgets('compact uses a bottom navigation bar', (tester) async {
      await pumpApp(tester, compact);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('medium uses a navigation rail', (tester) async {
      await pumpApp(tester, medium);
      expect(find.byType(NavigationBar), findsNothing);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
    });

    testWidgets('expanded uses an extended navigation rail', (tester) async {
      await pumpApp(tester, expanded);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
    });
  });

  for (final size in [compact, medium, expanded]) {
    final w = size.width.toInt();

    testWidgets('overview shows the seeded project at $w px', (tester) async {
      await pumpApp(tester, size);
      expect(find.text('Lyra Pathfinder'), findsWidgets);
      expect(find.text('Below target'), findsWidgets);
      expect(find.text('Needs attention'), findsOneWidget);
      expect(find.text('Self-healing radiator film'), findsWidgets);
    });

    testWidgets('components and guide render at $w px', (tester) async {
      await pumpApp(tester, size);
      await goTo(tester, 'Components');
      expect(find.text('Star tracker'), findsWidgets);
      expect(find.text('COMMUNICATIONS · 2'), findsOneWidget);
      await goTo(tester, 'TRL guide');
      expect(find.text('Basic principles observed and reported'), findsOneWidget);
    });
  }

  testWidgets('filter chips narrow the component list', (tester) async {
    await pumpApp(tester, expanded);
    await goTo(tester, 'Components');
    await tester.tap(find.byKey(const ValueKey('filter-notAssessed')));
    await tester.pumpAndSettle();
    expect(find.text('Flight computer'), findsWidgets);
    expect(find.text('Star tracker'), findsNothing);
  });

  testWidgets('heritage assessment flow: no, yes, evaluate 6, save', (tester) async {
    final controller = await pumpApp(tester, expanded);
    await startFlightComputerAssessment(tester);

    expect(find.text('Question 1 of 10'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('answer-no')));
    await tester.pumpAndSettle();
    expect(find.text('Question 2 of 10'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('answer-yes')));
    await tester.pumpAndSettle();

    expect(find.text('TRL 5 (initially, until differences are evaluated)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('heritage-6')));
    await tester.pumpAndSettle();
    expect(find.text('TRL 6 (heritage, differences evaluated; flowchart TRL 5)'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('save-assessment')));
    await tester.pumpAndSettle();
    final saved = controller.componentById('cdh-flight-computer')!;
    expect(saved.assessment!.trl, 6);
    expect(saved.assessment!.heritageEvaluated, isTrue);
    expect(find.text('TRL 6 (heritage, differences evaluated; flowchart TRL 5)'), findsOneWidget);
  });

  testWidgets('the flow explains that the first yes ends the questionnaire', (tester) async {
    await pumpApp(tester, compact);
    await startFlightComputerAssessment(tester);
    expect(find.text('Yes ends the questionnaire with TRL 9'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('answer-no')));
    await tester.pumpAndSettle();
    expect(find.text('Yes ends the questionnaire with TRL 5'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('answer-yes')));
    await tester.pumpAndSettle();
    expect(
      find.text('The questionnaire stops at the first yes (NASA TMA flowchart).'),
      findsOneWidget,
    );
  });

  testWidgets('ten no answers end with rethink, and undo reopens the question', (tester) async {
    await pumpApp(tester, compact);
    await startFlightComputerAssessment(tester);
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byKey(const ValueKey('answer-no')));
      await tester.pumpAndSettle();
    }
    expect(find.text('Rethink position regarding this technology!'), findsOneWidget);
    // No yes was given, so the "stops at the first yes" note does not apply.
    expect(find.textContaining('stops at the first yes'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('undo-answer')));
    await tester.pumpAndSettle();
    expect(find.text('Question 10 of 10'), findsOneWidget);
  });

  testWidgets('target change from the overview recomputes the project', (tester) async {
    final controller = await pumpApp(tester, medium);
    await tester.tap(find.byKey(const ValueKey('target-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('target-4')).last);
    await tester.pumpAndSettle();
    expect(controller.project!.targetTrl, 4);
    expect(controller.summary.belowTarget, 4);
  });
}
