/// TRL distribution of a list of assessed components, as counts and as a
/// text bar chart.
///
/// Dart port of `sources/libraries/trl/chart.py`.
library;

import 'assessment.dart';

const String barChar = '█';
const int maxBarWidth = 40;
const int labelWidth = 8;

/// Count components per reported TRL, from 9 down to 1, then null for "rethink".
///
/// Every level is present, with 0 when no component is at it. A heritage
/// component counts at its reported TRL (the evaluated one, if any).
Map<int?, int> trlDistribution(List<Assessment> assessments) {
  final counts = <int?, int>{for (var level = 9; level >= 1; level--) level: 0, null: 0};
  for (final a in assessments) {
    counts[a.trl] = counts[a.trl]! + 1;
  }
  return counts;
}

/// Return the TRL distribution as a text bar chart (no trailing newline).
///
/// Counts are right-aligned before the bars so every bar starts in the same
/// column. A line marks the target TRL; "rethink" outcomes count as below it.
/// Bars are one character per component, scaled to [maxBarWidth] when the
/// largest count is bigger; a non-zero count always shows at least one character.
String renderTrlChart(List<Assessment> assessments, {int targetTrl = defaultTargetTrl}) {
  if (targetTrl < 1 || targetTrl > 9) {
    throw ArgumentError('target_trl must be an int from 1 to 9');
  }
  final counts = trlDistribution(assessments);
  final total = counts.values.fold(0, (a, b) => a + b);
  final largest = counts.values.fold(0, (a, b) => a > b ? a : b);
  final countWidth = '$largest'.length;
  var below = 0;
  counts.forEach((level, n) {
    if (level == null || level < targetTrl) below += n;
  });

  final noun = total == 1 ? 'component' : 'components';
  final lines = <String>['TRL distribution — $total $noun, target TRL $targetTrl'];
  counts.forEach((level, n) {
    final label = level == null ? 'Rethink' : 'TRL $level';
    var row = '${label.padRight(labelWidth)} | ${'$n'.padLeft(countWidth)}';
    final bar = _barLength(n, largest);
    if (bar > 0) row += ' ${barChar * bar}';
    lines.add(row);
    if (level == targetTrl) {
      lines.add('---------- target TRL $targetTrl ----------');
    }
  });
  lines.add('Below target: $below of $total');
  return lines.join('\n');
}

int _barLength(int count, int largest) {
  if (count == 0) return 0;
  if (largest <= maxBarWidth) return count;
  final scaled = _roundHalfEven(count * maxBarWidth / largest);
  return scaled < 1 ? 1 : scaled;
}

/// Python's `round()`: halves go to the even neighbour.
int _roundHalfEven(double x) {
  final floor = x.floor();
  final diff = x - floor;
  if (diff > 0.5) return floor + 1;
  if (diff < 0.5) return floor;
  return floor.isEven ? floor : floor + 1;
}
