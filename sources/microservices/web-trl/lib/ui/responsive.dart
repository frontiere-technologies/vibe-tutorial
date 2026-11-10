import 'package:flutter/widgets.dart';

/// Window size classes, as in `AGENTS.md`: compact < 600, medium 600–1199,
/// expanded ≥ 1200 logical pixels wide.
enum WindowSize {
  compact,
  medium,
  expanded;

  static WindowSize ofWidth(double width) {
    if (width < 600) return WindowSize.compact;
    if (width < 1200) return WindowSize.medium;
    return WindowSize.expanded;
  }

  static WindowSize of(BuildContext context) => ofWidth(MediaQuery.sizeOf(context).width);

  bool get isCompact => this == WindowSize.compact;
  bool get isExpanded => this == WindowSize.expanded;

  /// Horizontal page padding.
  double get gutter => switch (this) {
    WindowSize.compact => 16,
    WindowSize.medium => 24,
    WindowSize.expanded => 32,
  };
}

/// Centres its child and caps its width.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.maxWidth, required this.child});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
