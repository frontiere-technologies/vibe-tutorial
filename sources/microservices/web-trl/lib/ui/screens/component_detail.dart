import 'package:flutter/material.dart';

import '../../api/models.dart';
import '../../state/app_controller.dart';
import '../responsive.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/status_pill.dart';
import '../widgets/trl_badge.dart';
import '../widgets/trl_ladder.dart';
import 'assessment_screen.dart';

/// The detail of one component, as a full page (compact and medium windows).
class ComponentDetailPage extends StatelessWidget {
  const ComponentDetailPage({super.key, required this.componentId});

  final String componentId;

  static Future<void> open(BuildContext context, String componentId) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => ComponentDetailPage(componentId: componentId)));

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context).componentById(componentId);
    return Scaffold(
      appBar: AppBar(title: Text(c?.subsystem ?? 'Component')),
      body: ComponentDetailView(componentId: componentId),
    );
  }
}

/// The detail of one component, embeddable beside the list.
class ComponentDetailView extends StatelessWidget {
  const ComponentDetailView({super.key, required this.componentId});

  final String componentId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = app.componentById(componentId);
    if (c == null) {
      return const EmptyState(icon: Icons.search_off, title: 'Component not found');
    }
    final size = WindowSize.of(context);
    final a = c.assessment;
    return ListView(
      padding: EdgeInsets.fromLTRB(size.gutter, Space.lg, size.gutter, Space.xxxl),
      children: [
        MaxWidth(
          maxWidth: ContentWidth.reading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(component: c),
              const SizedBox(height: Space.xl),
              if (a == null)
                Card(
                  child: EmptyState(
                    icon: Icons.quiz_outlined,
                    title: 'Not assessed yet',
                    message: 'Answer up to ten yes/no questions, in the order of the NASA flowchart, to get its TRL.',
                    action: FilledButton.icon(
                      key: const ValueKey('start-assessment'),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start assessment'),
                      onPressed: () => AssessmentScreen.open(context, c.id),
                    ),
                  ),
                )
              else ...[
                _ResultCard(component: c, assessment: a),
                const SizedBox(height: Space.lg),
                SectionCard(
                  title: 'Answers',
                  subtitle: 'In flowchart order, ending at the first yes',
                  child: AnswerTrail(questions: app.questions, answers: c.answers),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.component});

  final Component component;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TrlBadge.of(component, size: 72),
      const SizedBox(width: Space.lg),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              component.subsystem.toUpperCase(),
              style: context.text.labelSmall?.copyWith(color: context.colors.primary),
            ),
            const SizedBox(height: Space.xs),
            Text(component.name, style: context.text.headlineSmall),
            const SizedBox(height: Space.xs),
            Text(component.description, style: context.text.bodyMedium),
          ],
        ),
      ),
    ],
  );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.component, required this.assessment});

  final Component component;
  final Assessment assessment;

  @override
  Widget build(BuildContext context) {
    final a = assessment;
    return SectionCard(
      title: 'Assessment',
      trailing: FilledButton.tonalIcon(
        key: const ValueKey('reassess'),
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Reassess'),
        onPressed: () => AssessmentScreen.open(context, component.id),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(a.outcome, style: context.text.titleLarge),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              StatusPill(assessment: a),
              if (a.isHeritage) HeritagePill(assessment: a),
            ],
          ),
          const SizedBox(height: Space.xl),
          TrlLadder(trl: a.trl, targetTrl: a.targetTrl, flowchartTrl: a.flowchartTrl),
          if (a.decidingQuestion != null) ...[
            const SizedBox(height: Space.lg),
            QuestionQuote(question: a.decidingQuestion!),
          ],
          if (a.isRethink) ...[
            const SizedBox(height: Space.lg),
            Text(
              'Every question was answered "no": the flowchart gives no TRL. Reconsider the use of this technology.',
              style: context.text.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
