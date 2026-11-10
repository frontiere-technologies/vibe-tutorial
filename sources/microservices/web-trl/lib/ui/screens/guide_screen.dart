import 'package:flutter/material.dart';

import '../content/trl_guide.dart';
import '../responsive.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Reference page: the nine levels, the KDP gates, the rules.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = WindowSize.of(context);
    final ladder = SectionCard(
      title: 'The nine levels',
      subtitle: 'Figure G.4-1 — from basic research to flight proven',
      child: Column(children: [for (var l = 9; l >= 1; l--) _LevelRow(level: l)]),
    );
    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Key decision points',
          subtitle: 'Technology products required at each gate (Table G.1-1)',
          child: Column(children: [for (final g in kdpGates) _GateRow(gate: g)]),
        ),
        const SizedBox(height: Space.lg),
        SectionCard(
          title: 'Rules of thumb',
          child: Column(children: [for (final r in trlRules) _RuleRow(rule: r)]),
        ),
      ],
    );
    return ListView(
      padding: EdgeInsets.fromLTRB(size.gutter, Space.lg, size.gutter, Space.xxxl),
      children: [
        MaxWidth(
          maxWidth: ContentWidth.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('TRL guide', style: context.text.headlineSmall),
              const SizedBox(height: Space.xs),
              Text(
                'A Technology Readiness Level describes what has been demonstrated, and under which conditions. '
                'It is assigned by answering the flowchart questions in order and stopping at the first yes.',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: Space.lg),
              if (size.isExpanded)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: ladder),
                    const SizedBox(width: Space.lg),
                    Expanded(child: side),
                  ],
                )
              else ...[
                ladder,
                const SizedBox(height: Space.lg),
                side,
              ],
              const SizedBox(height: Space.xl),
              Text(
                'Source: $guideSource',
                style: context.text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final color = context.trlColors.trl(level);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Text('$level', style: context.text.titleMedium?.copyWith(color: color)),
          ),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trlBand(level).toUpperCase(),
                  style: context.text.labelSmall?.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(trlDescriptions[level]!, style: context.text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GateRow extends StatelessWidget {
  const _GateRow({required this.gate});

  final Gate gate;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Space.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            gate.name,
            style: context.text.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gate.transition, style: context.text.labelLarge),
              const SizedBox(height: 2),
              Text(gate.products, style: context.text.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule});

  final Rule rule;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Space.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.auto_awesome_outlined, size: 18, color: context.colors.secondary),
        const SizedBox(width: Space.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rule.title, style: context.text.titleSmall),
              const SizedBox(height: 2),
              Text(rule.body, style: context.text.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}
