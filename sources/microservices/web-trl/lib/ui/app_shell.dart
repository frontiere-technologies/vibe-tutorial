import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import 'responsive.dart';
import 'screens/components_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/overview_screen.dart';
import 'theme/tokens.dart';
import 'widgets/common.dart';

typedef _Destination = ({String label, IconData icon, IconData selectedIcon});

const List<_Destination> _destinations = [
  (
    label: 'Overview',
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard_rounded,
  ),
  (
    label: 'Components',
    icon: Icons.account_tree_outlined,
    selectedIcon: Icons.account_tree_rounded,
  ),
  (label: 'TRL guide', icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book_rounded),
];

/// Navigation that adapts to the window: bottom bar, rail, extended rail.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Local UI state: which destination is shown.
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final size = WindowSize.of(context);

    final Widget body;
    if (app.project == null) {
      body = app.error != null
          ? EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'The back end did not answer',
              message: app.error,
              action: FilledButton(onPressed: app.load, child: const Text('Retry')),
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      body = AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: switch (_index) {
            0 => const OverviewScreen(),
            1 => const ComponentsScreen(),
            _ => const GuideScreen(),
          },
        ),
      );
    }

    final appBar = AppBar(
      titleSpacing: size.gutter,
      title: Row(
        children: [
          const _Logo(),
          const SizedBox(width: Space.md),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'TRL '),
                  TextSpan(
                    text: 'Readiness',
                    style: TextStyle(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (!size.isCompact && app.project != null)
          Padding(
            padding: const EdgeInsets.only(right: Space.sm),
            child: Center(
              child: Text(
                app.project!.name,
                style: context.text.labelLarge?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ),
          ),
        _ThemeButton(app: app),
        SizedBox(width: size.gutter - Space.sm),
      ],
      bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider()),
    );

    if (size.isCompact) {
      return Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            extended: size.isExpanded,
            minExtendedWidth: 220,
            selectedIndex: _index,
            labelType: size.isExpanded ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            onDestinationSelected: (i) => setState(() => _index = i),
            leading: const SizedBox(height: Space.sm),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final trl = context.trlColors;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: [trl.trlLow, trl.trlHigh]),
      ),
      child: Icon(Icons.rocket_launch_rounded, size: 18, color: context.colors.surface),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({required this.app});

  final AppController app;

  @override
  Widget build(BuildContext context) {
    final (icon, next, tip) = switch (app.themeMode) {
      ThemeMode.system => (Icons.brightness_auto_outlined, ThemeMode.light, 'Theme: system'),
      ThemeMode.light => (Icons.light_mode_outlined, ThemeMode.dark, 'Theme: light'),
      ThemeMode.dark => (Icons.dark_mode_outlined, ThemeMode.system, 'Theme: dark'),
    };
    return IconButton(tooltip: tip, icon: Icon(icon), onPressed: () => app.themeMode = next);
  }
}
