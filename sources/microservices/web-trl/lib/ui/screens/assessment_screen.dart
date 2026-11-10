import 'package:flutter/material.dart';

import '../../api/models.dart';
import '../../state/app_controller.dart';
import '../../state/assessment_flow_controller.dart';
import '../responsive.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/status_pill.dart';
import '../widgets/trl_badge.dart';
import '../widgets/trl_ladder.dart';

/// The questionnaire for one component, one question at a time.
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key, required this.componentId});

  final String componentId;

  static Future<void> open(BuildContext context, String componentId) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => AssessmentScreen(componentId: componentId),
    ),
  );

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  // The flow controller lives as long as this page: local, not app-wide, state.
  AssessmentFlowController? _flow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _flow ??= AssessmentFlowController(
      app: AppScope.read(context),
      componentId: widget.componentId,
    );
  }

  @override
  void dispose() {
    _flow?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = _flow!;
    final component = AppScope.of(context).componentById(widget.componentId);
    final size = WindowSize.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technology maturity assessment',
              style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            Text(component?.name ?? '', style: context.text.titleMedium),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: flow,
        builder: (context, _) => ListView(
          padding: EdgeInsets.fromLTRB(size.gutter, Space.md, size.gutter, Space.xxxl),
          children: [
            MaxWidth(
              maxWidth: ContentWidth.reading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Progress(flow: flow),
                  const SizedBox(height: Space.xl),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    layoutBuilder: (current, previous) =>
                        Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: flow.isComplete
                        ? _ResultPanel(key: const ValueKey('result'), flow: flow)
                        : _QuestionPanel(
                            key: ValueKey('q${flow.currentQuestion!.number}'),
                            flow: flow,
                          ),
                  ),
                  if (flow.error != null) ...[
                    const SizedBox(height: Space.lg),
                    Text(
                      flow.error!,
                      style: context.text.bodyMedium?.copyWith(color: context.colors.error),
                    ),
                  ],
                  if (flow.answers.isNotEmpty) ...[
                    const SizedBox(height: Space.xl),
                    SectionCard(
                      title: 'Your answers',
                      child: AnswerTrail(questions: flow.questions, answers: flow.answers),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.flow});

  final AssessmentFlowController flow;

  @override
  Widget build(BuildContext context) {
    final trl = context.trlColors;
    final scheme = context.colors;
    final total = flow.questions.length;
    final answers = flow.answers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          flow.isComplete ? 'Result' : 'Question ${answers.length + 1} of $total',
          style: context.text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Space.sm),
        Row(
          children: [
            for (var i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Radii.pill),
                    color: i < answers.length
                        ? (answers[i] ? trl.meets : scheme.outline)
                        : i == answers.length && !flow.isComplete
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({super.key, required this.flow});

  final AssessmentFlowController flow;

  @override
  Widget build(BuildContext context) {
    final q = flow.currentQuestion!;
    final compact = WindowSize.of(context).isCompact;
    final yesColor = context.trlColors.trl(q.trlIfYes);
    final buttons = [
      Expanded(
        child: OutlinedButton.icon(
          key: const ValueKey('answer-no'),
          icon: const Icon(Icons.close_rounded),
          label: const Text('No'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: flow.isBusy ? null : () => flow.answer(false),
        ),
      ),
      const SizedBox(width: Space.md),
      Expanded(
        child: FilledButton.icon(
          key: const ValueKey('answer-yes'),
          icon: const Icon(Icons.check_rounded),
          label: const Text('Yes'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: flow.isBusy ? null : () => flow.answer(true),
        ),
      ),
    ];
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? Space.xl : Space.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Q${q.number}',
                  style: context.text.headlineSmall?.copyWith(color: context.colors.primary),
                ),
                const Spacer(),
                Pill(label: 'Yes → TRL ${q.trlIfYes}', color: yesColor),
              ],
            ),
            const SizedBox(height: Space.lg),
            Text(q.text, style: compact ? context.text.titleLarge : context.text.headlineSmall),
            if (q.note != null) ...[
              const SizedBox(height: Space.md),
              Text(q.note!, style: context.text.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: Space.xxl),
            Row(children: buttons),
            if (flow.answers.isNotEmpty) ...[
              const SizedBox(height: Space.md),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('undo-answer'),
                  icon: const Icon(Icons.undo_rounded, size: 18),
                  label: const Text('Previous question'),
                  onPressed: flow.undo,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({super.key, required this.flow});

  final AssessmentFlowController flow;

  @override
  Widget build(BuildContext context) {
    final a = flow.preview;
    if (a == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(Space.xxxl),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                TrlBadge(assessment: a, size: 80),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.outcome, style: context.text.titleLarge),
                      const SizedBox(height: Space.sm),
                      Wrap(
                        spacing: Space.sm,
                        runSpacing: Space.sm,
                        children: [
                          StatusPill(assessment: a),
                          if (a.isHeritage) HeritagePill(assessment: a),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.xl),
            TrlLadder(trl: a.trl, targetTrl: a.targetTrl, flowchartTrl: a.flowchartTrl),
            if (a.decidingQuestion != null) ...[
              const SizedBox(height: Space.lg),
              QuestionQuote(question: a.decidingQuestion!),
            ],
            if (flow.canEvaluateHeritage) ...[
              const SizedBox(height: Space.xl),
              _HeritageChoice(flow: flow),
            ],
            const SizedBox(height: Space.xl),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: Space.md,
              spacing: Space.md,
              children: [
                TextButton.icon(
                  key: const ValueKey('undo-answer'),
                  icon: const Icon(Icons.undo_rounded, size: 18),
                  label: const Text('Change last answer'),
                  onPressed: flow.isBusy ? null : flow.undo,
                ),
                FilledButton.icon(
                  key: const ValueKey('save-assessment'),
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save assessment'),
                  onPressed: flow.isBusy
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final saved = await flow.save();
                          if (saved == null) return;
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(content: Text('${saved.name}: ${saved.assessment!.outcome}')),
                          );
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeritageChoice extends StatelessWidget {
  const _HeritageChoice({required this.flow});

  final AssessmentFlowController flow;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Space.lg),
    decoration: BoxDecoration(
      color: context.trlColors.heritage.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border.all(color: context.trlColors.heritage.withValues(alpha: 0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heritage component', style: context.text.titleSmall),
        const SizedBox(height: Space.xs),
        Text(
          'TRL 5 holds until the differences of the new configuration or environment are evaluated. '
          'If they are, record the evaluated TRL: 6 or 7 when close enough, never 8 or 9.',
          style: context.text.bodySmall,
        ),
        const SizedBox(height: Space.md),
        SegmentedButton<int>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: Space.sm),
          ),
          segments: [
            const ButtonSegment(
              value: 0,
              label: Text('Not yet', softWrap: false),
              tooltip: 'Differences not evaluated yet',
            ),
            for (final t in evaluatedHeritageTrls)
              ButtonSegment(
                value: t,
                label: Text('$t', key: ValueKey('heritage-$t')),
              ),
          ],
          selected: {flow.evaluatedHeritageTrl ?? 0},
          onSelectionChanged: flow.isBusy
              ? null
              : (s) => flow.setEvaluatedHeritageTrl(s.first == 0 ? null : s.first),
        ),
      ],
    ),
  );
}
