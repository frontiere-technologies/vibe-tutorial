import 'package:flutter/material.dart';

import '../../api/models.dart';
import '../theme/tokens.dart';

/// Horizontal bars, TRL 9 at the top down to "Rethink", with a dashed line
/// under the target row — the graphical twin of `render_trl_chart`.
class DistributionChart extends StatelessWidget {
  const DistributionChart({super.key, required this.counts, required this.targetTrl});

  final List<LevelCount> counts;
  final int targetTrl;

  @override
  Widget build(BuildContext context) {
    final largest = counts.fold<int>(1, (m, c) => c.count > m ? c.count : m);
    final rows = <Widget>[];
    for (final c in counts) {
      rows.add(_BarRow(count: c, largest: largest, targetTrl: targetTrl));
      if (c.trl == targetTrl) rows.add(_TargetLine(targetTrl: targetTrl));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.count, required this.largest, required this.targetTrl});

  final LevelCount count;
  final int largest;
  final int targetTrl;

  @override
  Widget build(BuildContext context) {
    final trl = context.trlColors;
    final level = count.trl;
    final color = level == null
        ? trl.rethink
        : level >= targetTrl
        ? trl.meets
        : trl.below;
    final label = level == null ? 'Rethink' : 'TRL $level';
    final fraction = count.count / largest;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: count.count > 0 ? context.colors.onSurface : context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Align(
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraction),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, f, _) => Container(
                    height: 18,
                    width: count.count == 0
                        ? 3
                        : (constraints.maxWidth * f).clamp(6, constraints.maxWidth),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.sm),
                      gradient: count.count == 0
                          ? null
                          : LinearGradient(colors: [color.withValues(alpha: 0.55), color]),
                      color: count.count == 0 ? context.colors.surfaceContainerHighest : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${count.count}',
              textAlign: TextAlign.right,
              style: context.text.labelLarge?.copyWith(
                color: count.count > 0 ? context.colors.onSurface : context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetLine extends StatelessWidget {
  const _TargetLine({required this.targetTrl});

  final int targetTrl;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(painter: _DashPainter(color), size: const Size(0, 1)),
          ),
          const SizedBox(width: Space.sm),
          Icon(Icons.flag_rounded, size: 14, color: color),
          const SizedBox(width: Space.xs),
          Text('target TRL $targetTrl', style: context.text.labelMedium?.copyWith(color: color)),
          const SizedBox(width: Space.sm),
          SizedBox(
            width: 24,
            child: CustomPaint(painter: _DashPainter(color), size: const Size(0, 1)),
          ),
        ],
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset((x + 4).clamp(0, size.width), 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
