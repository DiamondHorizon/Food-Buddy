import 'package:flutter/material.dart';

import '../app_state.dart';
import '../app_theme.dart';
import '../page_header.dart';
// idea: PLUFINDER
class InventoryPage extends StatelessWidget {
  final AppState state;
  const InventoryPage({super.key, required this.state});

  Future<void> _openAddDialog(BuildContext context, [StorageArea? area]) async {
    final item = await showDialog<Ingredient>(
      context: context,
      builder: (_) => AddIngredientDialog(initialArea: area ?? StorageArea.pantry),
    );
    if (item != null) state.addIngredient(item);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Inventory',
            subtitle: '${state.ingredients.length} ingredients on hand',
            action: FilledButton.icon(
              onPressed: () => _openAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add ingredient'),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                const areas = StorageArea.values;

                if (c.maxWidth >= 820) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final a in areas) ...[
                        Expanded(child: _section(context, a, fillHeight: true)),
                        if (a != areas.last) const SizedBox(width: 16),
                      ],
                    ],
                  );
                }

                return ListView(
                  children: [
                    for (final a in areas)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _section(context, a),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, StorageArea area, {bool fillHeight = false}) {
    return StorageSection(
      area: area,
      items: state.inArea(area),
      onRemove: state.removeIngredient,
      onAdd: () => _openAddDialog(context, area),
      fillHeight: fillHeight,
    );
  }
}

class StorageSection extends StatelessWidget {
  final StorageArea area;
  final List<Ingredient> items;
  final ValueChanged<Ingredient> onRemove;
  final VoidCallback onAdd;
  final bool fillHeight;

  const StorageSection({
    super.key,
    required this.area,
    required this.items,
    required this.onRemove,
    required this.onAdd,
    this.fillHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = items.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Nothing in the ${area.label.toLowerCase()} yet.',
              style: TextStyle(color: shades.muted),
            ),
          )
        : Column(
            children: [
              for (final item in items)
                ExpansionTile(
                  dense: true,
                  title: Text(item.name,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  subtitle: item.quantity.isEmpty ? null : Text(item.quantity),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => onRemove(item),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Expiration: ${item.expiration}'),
                          const SizedBox(height: 8),
                          const Text('Edit quantity function goes here'),
                        ],
                      )
                    )
                  ],
                ),
            ],
          );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            color: area.headerBg(isDark),
            child: Row(
              children: [
                Icon(area.icon, color: area.iconColor(isDark)),
                const SizedBox(width: 10),
                Text(
                  area.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: shades.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: area.dark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Add to ${area.label.toLowerCase()}',
                  icon: Icon(Icons.add, color: area.iconColor(isDark)),
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
          Container(height: 3, color: area.mid),
          if (fillHeight) Expanded(child: SingleChildScrollView(child: list)) else list,
        ],
      ),
    );
  }
}

class AddIngredientDialog extends StatefulWidget {
  final StorageArea initialArea;
  const AddIngredientDialog({super.key, this.initialArea = StorageArea.pantry});

  @override
  State<AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  final _name = TextEditingController();
  final _qty = TextEditingController();
  final _exp = TextEditingController();
  late StorageArea _area = widget.initialArea;
  String? _error;

  void _submit() {
    final name = _name.text.trim().toLowerCase();
    if (name.isEmpty) {
      setState(() => _error = 'Enter an ingredient name.');
      return;
    }
    Navigator.pop(context, Ingredient(name: name, quantity: _qty.text.trim(), expiration: _exp.text.trim(), area: _area));
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _exp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add ingredient'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Name', errorText: _error),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              decoration: const InputDecoration(
                labelText: 'Quantity (optional)',
                hintText: 'e.g. 2 cans, 500 g',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exp,
              decoration: const InputDecoration(
                labelText: 'Expiration Date (optional)',
                hintText: 'e.g. Nov 9, 2026',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            Text('Stored in', style: TextStyle(color: AppShades.of(context).muted)),
            const SizedBox(height: 8),
            SegmentedButton<StorageArea>(
              segments: [
                for (final a in StorageArea.values)
                  ButtonSegment(value: a, label: Text(a.label), icon: Icon(a.icon)),
              ],
              selected: {_area},
              onSelectionChanged: (s) => setState(() => _area = s.first),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Add ingredient')),
      ],
    );
  }
}