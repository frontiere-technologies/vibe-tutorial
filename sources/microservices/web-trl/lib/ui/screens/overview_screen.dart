import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api/models.dart';
import '../../state/app_controller.dart';
import '../responsive.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/distribution_chart.dart';
import '../widgets/status_pill.dart';
import '../widgets/trl_badge.dart';
import 'component_detail.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final project = app.project!;
    final size = WindowSize.of(context);
    final chart = _ChartCard(app: app, project: project);
    final attention = _AttentionCard(components: app.needsAttention);
    return ListView(
      padding: EdgeInsets.fromLTRB(size.gutter, Space.lg, size.gutter, Space.xxxl),
      children: [
        MaxWidth(
          maxWidth: ContentWidth.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Hero(project: project),
              const SizedBox(height: Space.lg),
              _KpiGrid(summary: app.summary, targetTrl: project.targetTrl),
              const SizedBox(height: Space.lg),
              if (size.isExpanded)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: chart),
                    const SizedBox(width: Space.lg),
                    Expanded(flex: 2, child: attention),
                  ],
                )
              else ...[
                chart,
                const SizedBox(height: Space.lg),
                attention,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final trl = context.trlColors;
    final compact = WindowSize.of(context).isCompact;
    return Container(
      padding: EdgeInsets.all(compact ? Space.xl : Space.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [trl.heroStart, trl.heroEnd],
        ),
        border: Border.all(color: trl.hairline),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(
              Icons.satellite_alt_rounded,
              size: compact ? 72 : 120,
              color: context.colors.onSurface.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TECHNOLOGY READINESS',
                style: context.text.labelSmall?.copyWith(color: context.colors.primary),
              ),
              const SizedBox(height: Space.sm),
              Text(
                project.name,
                style: (compact ? context.text.headlineMedium : context.text.displaySmall),
              ),
              const SizedBox(height: Space.xs),
              Text(project.mission, style: context.text.bodyMedium),
              const SizedBox(height: Space.lg),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Pill(label: project.phase, color: context.colors.onSurface, icon: Icons.timeline),
                  Pill(
                    label: 'Next gate · ${project.milestone}',
                    color: context.colors.onSurface,
                    icon: Icons.door_front_door_outlined,
                  ),
                  _TargetMenu(targetTrl: project.targetTrl),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetMenu extends StatelessWidget {
  const _TargetMenu({required this.targetTrl});

  final int targetTrl;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;
    return PopupMenuButton<int>(
      key: const ValueKey('target-menu'),
      tooltip: 'Change the target TRL',
      initialValue: targetTrl,
      position: PopupMenuPosition.under,
      onSelected: (t) async {
        final app = AppScope.read(context);
        final messenger = ScaffoldMessenger.of(context);
        await app.setTargetTrl(t);
        messenger.showSnackBar(
          SnackBar(content: Text('Target set to TRL $t — results recomputed')),
        );
      },
      itemBuilder: (context) => [
        for (var t = 1; t <= 9; t++)
          PopupMenuItem(
            key: ValueKey('target-$t'),
            value: t,
            child: Text(t == 6 ? 'TRL 6 · KDP C default' : 'TRL $t'),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Text('Target TRL $targetTrl', style: context.text.labelMedium?.copyWith(color: color)),
            Icon(Icons.expand_more, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary, required this.targetTrl});

  final ProjectSummary summary;
  final int targetTrl;

  @override
  Widget build(BuildContext context) {
    final trl = context.trlColors;
    final lowest = summary.lowestTrl;
    final tiles = [
      KpiTile(
        icon: Icons.fact_check_outlined,
        label: 'Assessed',
        value: '${summary.assessed} / ${summary.total}',
        detail: summary.notAssessed == 0 ? 'All components' : '${summary.notAssessed} pending',
        color: context.colors.primary,
      ),
      KpiTile(
        icon: Icons.check_circle_outline,
        label: 'Meet target',
        value: '${summary.meetingTarget}',
        detail: 'TRL $targetTrl or above',
        color: trl.meets,
      ),
      KpiTile(
        icon: Icons.trending_down,
        label: 'Below target',
        value: '${summary.belowTarget}',
        detail: summary.rethinkCount > 0
            ? 'incl. ${summary.rethinkCount} rethink'
            : 'Before the gate',
        color: trl.below,
      ),
      KpiTile(
        icon: Icons.vertical_align_bottom,
        label: 'Lowest TRL',
        value: lowest == null ? '—' : 'TRL $lowest',
        detail: 'Integration not assessed',
        color: lowest == null ? trl.rethink : trl.trl(lowest),
      ),
    ];
    final columns = WindowSize.of(context).isCompact ? 2 : 4;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = Space.md;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final t in tiles) SizedBox(width: width, child: t)],
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.app, required this.project});

  final AppController app;
  final Project project;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: 'TRL distribution',
    subtitle: '${app.summary.assessed} assessed components against target TRL ${project.targetTrl}',
    trailing: IconButton(
      tooltip: 'Text report',
      icon: const Icon(Icons.notes_rounded),
      onPressed: () => _showTextReport(context, app),
    ),
    child: DistributionChart(counts: app.distribution, targetTrl: project.targetTrl),
  );

  static Future<void> _showTextReport(BuildContext context, AppController app) async {
    final text = await app.fetchTextChart();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text report'),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            text,
            style: context.text.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: context.colors.onSurface,
              height: 1.35,
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          FilledButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Report copied to the clipboard')));
            },
          ),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.components});

  final List<Component> components;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: 'Needs attention',
    subtitle: components.isEmpty
        ? 'Every assessed component meets the target'
        : 'Below target, largest gap first',
    padding: const EdgeInsets.fromLTRB(Space.xl, Space.xl, Space.md, Space.md),
    child: components.isEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: Space.lg),
            child: Icon(Icons.verified_outlined, size: 40, color: context.trlColors.meets),
          )
        : Column(
            children: [
              for (final c in components)
                ListTile(
                  key: ValueKey('attention-${c.id}'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: Space.sm),
                  leading: TrlBadge.of(c, size: 40),
                  title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(c.subsystem),
                  trailing: StatusPill(assessment: c.assessment),
                  onTap: () => ComponentDetailPage.open(context, c.id),
                ),
            ],
          ),
  );
}
