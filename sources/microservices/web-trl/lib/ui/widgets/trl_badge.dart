import 'package:flutter/material.dart';

import '../../api/models.dart';
import '../theme/tokens.dart';

/// A rounded tile with the TRL number, coloured on the maturity ramp.
/// Shows "?" for "rethink" and a dash when not assessed.
class TrlBadge extends StatelessWidget {
  const TrlBadge({super.key, required this.assessment, this.size = 44, this.assessed = true});

  /// Badge for a component that may not be assessed yet.
  factory TrlBadge.of(Component component, {Key? key, double size = 44}) => TrlBadge(
    key: key,
    assessment: component.assessment,
    assessed: component.isAssessed,
    size: size,
  );

  final Assessment? assessment;
  final bool assessed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trl = context.trlColors;
    final a = assessment;
    final Color color;
    final String label;
    if (!assessed || a == null) {
      color = context.colors.outline;
      label = '–';
    } else if (a.isRethink) {
      color = trl.rethink;
      label = '?';
    } else {
      color = trl.trl(a.trl!);
      label = '${a.trl}';
    }
    final big = size >= 64;
    return Semantics(
      label: !assessed ? 'Not assessed' : (a!.isRethink ? 'Rethink' : 'TRL ${a.trl}'),
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.3),
          color: color.withValues(alpha: 0.14),
          border: Border.all(color: color.withValues(alpha: 0.55), width: big ? 1.5 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (big)
              Text(
                'TRL',
                style: context.text.labelSmall?.copyWith(
                  color: color,
                  fontSize: size * 0.14,
                  height: 1,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: size * (big ? 0.42 : 0.44),
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
