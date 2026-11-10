import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Nine segments, TRL 1 to 9, filled up to [trl], with the target marked.
/// For an evaluated heritage component the flowchart TRL is marked too.
class TrlLadder extends StatelessWidget {
  const TrlLadder({super.key, required this.trl, required this.targetTrl, this.flowchartTrl});

  final int? trl;
  final int targetTrl;
  final int? flowchartTrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.trlColors;
    final scheme = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var level = 1; level <= 9; level++) ...[
              if (level > 1) const SizedBox(width: 4),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (trl ?? 0) >= level ? 1 : 0),
                  duration: Duration(milliseconds: 250 + level * 40),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) => Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.pill),
                      color: Color.lerp(scheme.surfaceContainerHighest, colors.trl(level), t),
                      border: level == flowchartTrl && flowchartTrl != trl
                          ? Border.all(color: colors.heritage, width: 2)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Space.sm),
        Row(
          children: [
            for (var level = 1; level <= 9; level++) ...[
              if (level > 1) const SizedBox(width: 4),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$level',
                      style: context.text.labelMedium?.copyWith(
                        color: level == trl ? scheme.onSurface : scheme.onSurfaceVariant,
                        fontWeight: level == trl ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                    if (level == targetTrl)
                      Icon(
                        Icons.flag_rounded,
                        size: 16,
                        color: scheme.primary,
                        semanticLabel: 'target',
                      )
                    else
                      const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
