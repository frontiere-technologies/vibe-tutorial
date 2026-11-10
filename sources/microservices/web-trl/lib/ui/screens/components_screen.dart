import 'package:flutter/material.dart';

import '../../api/trl_api.dart';
import '../../state/app_controller.dart';
import '../responsive.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/status_pill.dart';
import '../widgets/trl_badge.dart';
import 'component_detail.dart';

enum ComponentFilter {
  all('All'),
  belowTarget('Below target'),
  heritage('Heritage'),
  notAssessed('Not assessed');

  const ComponentFilter(this.label);

  final String label;

  bool matches(Component c) => switch (this) {
    ComponentFilter.all => true,
    ComponentFilter.belowTarget => c.isAssessed && !c.assessment!.meetsTarget,
    ComponentFilter.heritage => c.assessment?.isHeritage ?? false,
    ComponentFilter.notAssessed => !c.isAssessed,
  };
}

/// The product breakdown, grouped by subsystem; master-detail when expanded.
class ComponentsScreen extends StatefulWidget {
  const ComponentsScreen({super.key});

  @override
  State<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends State<ComponentsScreen> {
  // Local UI state: the filter and, in the expanded layout, the selection.
  ComponentFilter _filter = ComponentFilter.all;
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final size = WindowSize.of(context);
    final visible = app.project!.components.where(_filter.matches).toList();
    // Expanded layout: keep an explicit selection (even if a save moved it out
    // of the filter), else show the first visible component.
    final String? selected;
    if (!size.isExpanded) {
      selected = null;
    } else if (_selectedId != null && app.componentById(_selectedId!) != null) {
      selected = _selectedId;
    } else {
      selected = visible.isEmpty ? null : visible.first.id;
    }

    final list = _ComponentList(
      app: app,
      filter: _filter,
      selectedId: selected,
      onFilter: (f) => setState(() {
        _filter = f;
        _selectedId = null;
      }),
      onSelect: (id) {
        if (size.isExpanded) {
          setState(() => _selectedId = id);
        } else {
          ComponentDetailPage.open(context, id);
        }
      },
    );

    if (!size.isExpanded) return list;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 440, child: list),
        const VerticalDivider(width: 1),
        Expanded(
          child: selected == null
              ? const EmptyState(icon: Icons.touch_app_outlined, title: 'Select a component')
              : ComponentDetailView(key: ValueKey(selected), componentId: selected),
        ),
      ],
    );
  }
}

class _ComponentList extends StatelessWidget {
  const _ComponentList({
    required this.app,
    required this.filter,
    required this.selectedId,
    required this.onFilter,
    required this.onSelect,
  });

  final AppController app;
  final ComponentFilter filter;
  final String? selectedId;
  final ValueChanged<ComponentFilter> onFilter;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final size = WindowSize.of(context);
    final all = app.project!.components;
    final visible = all.where(filter.matches).toList();
    final gutter = size.isExpanded ? Space.xl : size.gutter;

    final children = <Widget>[
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Components', style: context.text.headlineSmall),
                Text('${all.length} in the product breakdown', style: context.text.bodySmall),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            key: const ValueKey('add-component'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add'),
            onPressed: () => _addComponent(context, app, onSelect),
          ),
        ],
      ),
      const SizedBox(height: Space.lg),
      Wrap(
        spacing: Space.sm,
        runSpacing: Space.sm,
        children: [
          for (final f in ComponentFilter.values)
            FilterChip(
              key: ValueKey('filter-${f.name}'),
              label: Text('${f.label} · ${all.where(f.matches).length}'),
              selected: f == filter,
              showCheckmark: false,
              onSelected: (_) => onFilter(f),
            ),
        ],
      ),
      const SizedBox(height: Space.md),
    ];

    if (visible.isEmpty) {
      children.add(
        const EmptyState(icon: Icons.filter_alt_off_outlined, title: 'Nothing matches this filter'),
      );
    }
    for (final subsystem in app.subsystems) {
      final group = visible.where((c) => c.subsystem == subsystem).toList();
      if (group.isEmpty) continue;
      children
        ..add(
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.sm, Space.lg, Space.sm, Space.sm),
            child: Text(
              '${subsystem.toUpperCase()} · ${group.length}',
              style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ),
        )
        ..add(
          Card(
            child: Column(
              children: [
                for (var i = 0; i < group.length; i++) ...[
                  if (i > 0) const Divider(indent: 72),
                  _ComponentTile(
                    component: group[i],
                    selected: group[i].id == selectedId,
                    onTap: () => onSelect(group[i].id),
                  ),
                ],
              ],
            ),
          ),
        );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(gutter, Space.lg, gutter, Space.xxxl),
      children: [
        MaxWidth(
          maxWidth: ContentWidth.reading,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ],
    );
  }

  static Future<void> _addComponent(
    BuildContext context,
    AppController app,
    ValueChanged<String> onSelect,
  ) async {
    final added = await showDialog<Component>(
      context: context,
      builder: (_) => _AddComponentDialog(app: app),
    );
    if (added != null) onSelect(added.id);
  }
}

class _ComponentTile extends StatelessWidget {
  const _ComponentTile({required this.component, required this.selected, required this.onTap});

  final Component component;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = component.assessment;
    return ListTile(
      key: ValueKey('component-${component.id}'),
      selected: selected,
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.xs),
      leading: TrlBadge.of(component),
      title: Text(component.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: Space.xs),
        child: Wrap(
          spacing: Space.xs,
          runSpacing: Space.xs,
          children: [
            StatusPill(assessment: a),
            if (a != null && a.isHeritage) HeritagePill(assessment: a),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _AddComponentDialog extends StatefulWidget {
  const _AddComponentDialog({required this.app});

  final AppController app;

  @override
  State<_AddComponentDialog> createState() => _AddComponentDialogState();
}

class _AddComponentDialogState extends State<_AddComponentDialog> {
  final _name = TextEditingController();
  final _subsystem = TextEditingController();
  final _description = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _subsystem.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final c = await widget.app.addComponent(
        name: _name.text,
        subsystem: _subsystem.text,
        description: _description.text,
      );
      if (mounted) Navigator.pop(context, c);
    } on TrlApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add a component'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: Space.md),
          TextField(
            controller: _subsystem,
            decoration: const InputDecoration(labelText: 'Subsystem'),
          ),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final s in widget.app.subsystems)
                ActionChip(label: Text(s), onPressed: () => setState(() => _subsystem.text = s)),
            ],
          ),
          const SizedBox(height: Space.md),
          TextField(
            controller: _description,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: Space.md),
            Text(_error!, style: context.text.bodySmall?.copyWith(color: context.colors.error)),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: _busy ? null : _submit, child: const Text('Add')),
    ],
  );
}
