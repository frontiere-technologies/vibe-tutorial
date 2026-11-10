import 'package:flutter/material.dart';

import '../../api/models.dart';
import '../theme/tokens.dart';

/// A small coloured label: icon + text.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(Radii.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 6)],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelMedium?.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}

/// Status of a component against the target: meets, below by n, rethink, not assessed.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.assessment});

  /// Null when the component is not assessed yet.
  final Assessment? assessment;

  @override
  Widget build(BuildContext context) {
    final trl = context.trlColors;
    final a = assessment;
    if (a == null) {
      return Pill(
        label: 'Not assessed',
        color: context.colors.onSurfaceVariant,
        icon: Icons.schedule,
      );
    }
    if (a.isRethink) {
      return Pill(label: 'Rethink', color: trl.rethink, icon: Icons.report_outlined);
    }
    if (a.meetsTarget) {
      return Pill(
        label: 'Meets TRL ${a.targetTrl}',
        color: trl.meets,
        icon: Icons.check_circle_outline,
      );
    }
    final levels = a.gap == 1 ? 'level' : 'levels';
    return Pill(label: '${a.gap} $levels short', color: trl.below, icon: Icons.trending_down);
  }
}

/// Shown for heritage components: provisional until the differences are evaluated.
class HeritagePill extends StatelessWidget {
  const HeritagePill({super.key, required this.assessment});

  final Assessment assessment;

  @override
  Widget build(BuildContext context) => Pill(
    label: assessment.heritageEvaluated ? 'Heritage · evaluated' : 'Heritage · provisional',
    color: context.trlColors.heritage,
    icon: Icons.history,
  );
}
