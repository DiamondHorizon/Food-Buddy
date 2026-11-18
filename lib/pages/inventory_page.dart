import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_buddy/main.dart';

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
      onQuantityChanged: (item, newQty) => state.updateIngredientQuantity(item, newQty),
      fillHeight: fillHeight,
    );
  }
}

Color? getExpirationColor(String expirationStr) {
  if (expirationStr.isEmpty) return null;
  
  final expDate = DateTime.tryParse(expirationStr);
  if (expDate == null) return null;

  // Normalize both dates to midnight so time of day doesn't skew the day count
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(expDate.year, expDate.month, expDate.day);

  final diffDays = target.difference(today).inDays;

  if (diffDays < 0) {
    return Colors.red;    // Expired
  } else if (diffDays <= 7) {
    return Colors.orange; // Expiring this week (0-7 days)
  } else if (diffDays <= 14) {
    return Colors.amber;  // Expiring next week (8-14 days)
  }
  
  return null;
}

class QuantityEditor extends StatefulWidget {
  final String initialQuantity;
  final ValueChanged<String> onQuantityChanged;
  final double step;
  final double minQuantity;

  const QuantityEditor({
    super.key,
    required this.initialQuantity,
    required this.onQuantityChanged,
    this.step = 1.0,
    this.minQuantity = 0,
  });

  @override
  State<QuantityEditor> createState() => _QuantityEditorState();
}

class _QuantityEditorState extends State<QuantityEditor> {
  late TextEditingController _controller;
  late double _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = _parseAndClamp(widget.initialQuantity);
    _controller = TextEditingController(text: _formatNumber(_quantity));
  }

  @override
  void didUpdateWidget(covariant QuantityEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuantity != widget.initialQuantity) {
      final incoming = _parseAndClamp(widget.initialQuantity);
      if ((incoming - _quantity).abs() > 0.0001) {
        _quantity = incoming;
        _controller.text = _formatNumber(_quantity);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Parses the incoming string safely and enforces the positive lower bound.
  double _parseAndClamp(String raw) {
    final parsed = double.tryParse(raw.trim());
    if (parsed == null || parsed <= 0) {
      return widget.minQuantity < 0.0 ? 0.0 : widget.minQuantity;
    }
    return parsed < widget.minQuantity ? widget.minQuantity : parsed;
  }

  // Formats doubles cleanly (e.g., 2.0 -> "2", 1.5 -> "1.5", avoids floating-point noise like 1.2000000000000002).
  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return double.parse(value.toStringAsFixed(2)).toString();
  }

  void _updateValue(double newValue) {
    // Clamp to minimum positive bound and clean floating-point inaccuracies
    final clamped = newValue < widget.minQuantity
        ? widget.minQuantity
        : double.parse(newValue.toStringAsFixed(2));

    final formatted = _formatNumber(clamped);

    setState(() {
      _quantity = clamped;
      _controller.text = formatted;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });

    widget.onQuantityChanged(formatted);
  }

  void _commitTypedText() {
    final parsed = double.tryParse(_controller.text.trim());
    if (parsed == null || parsed < widget.minQuantity) {
      _updateValue(widget.minQuantity);
    } else {
      _updateValue(parsed);
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrement Button
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: _quantity > widget.minQuantity
              ? () {
                  final next = _quantity - widget.step;
                  _updateValue(next < widget.minQuantity ? widget.minQuantity : next);
                }
              : null,
          visualDensity: VisualDensity.compact,
        ),

        // Direct Decimal Number Input
        SizedBox(
          width: 56,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value.isEmpty || value.endsWith('.')) return;

              final parsed = double.tryParse(value);
              if (parsed != null && parsed >= widget.minQuantity) {
                final clean = double.parse(parsed.toStringAsFixed(2));
                setState(() => _quantity = clean);
                widget.onQuantityChanged(_formatNumber(clean));
              }
            },
            onEditingComplete: _commitTypedText,
          ),
        ),

        // Increment Button
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _updateValue(_quantity + widget.step),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class StorageSection extends StatelessWidget {
  final StorageArea area;
  final List<Ingredient> items;
  final ValueChanged<Ingredient> onRemove;
  final VoidCallback onAdd;
  final void Function(Ingredient item, String newQuantity) onQuantityChanged;
  final bool fillHeight;

  const StorageSection({
    super.key,
    required this.area,
    required this.items,
    required this.onRemove,
    required this.onAdd,
    required this.onQuantityChanged,
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
                Builder(
                  builder: (context) {
                    final expColor = getExpirationColor(item.expiration);
                    
                    return ExpansionTile(
                      dense: true,
                      // Optional: Add a colored indicator dot next to the item name if expiring/expired
                      title: Row(
                        children: [
                          if (expColor != null) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: expColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              item.name.toTitleCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: item.quantity.isEmpty ? null : Text(item.quantity),
                      trailing: IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () => onRemove(item),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Color-code the expiration text when expanded too!
                              Row(
                                children: [
                                  const Text('Expiration: '),
                                  Text(
                                    item.expiration.isEmpty ? 'None' : item.expiration,
                                    style: TextStyle(
                                      color: expColor,
                                      fontWeight: expColor != null ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                 QuantityEditor(
                                    key: ValueKey('qty_${item.id}'),
                                    initialQuantity: item.quantity,
                                    step: 1.0,
                                    minQuantity: 0,
                                    onQuantityChanged: (newQuantity) {
                                      onQuantityChanged(item, newQuantity);
                                    },
                                  ),
                                ],
                              )
                            ],
                          )
                        )
                      ],
                    );
                  }
                )
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
  final String? initialName;
  const AddIngredientDialog({super.key, this.initialArea = StorageArea.pantry, this.initialName});

  @override
  State<AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  final _name = TextEditingController();
  final _qty = TextEditingController();
  final _exp = TextEditingController();
  late StorageArea _area = widget.initialArea;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.text = widget.initialName ?? '';
  }

  // Function to open the native calendar popup
  Future<void> _pickExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Can't pick past dates if it's a new item
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        // Format to YYYY-MM-DD string for the database
        _exp.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _submit() {
    final name = _name.text.trim().toLowerCase();
    if (name.isEmpty) {
      setState(() => _error = 'Enter an ingredient name.');
      return;
    }
    final rawQty = _qty.text.trim();
    String cleanQty = '';

    if (rawQty.isNotEmpty) {
      final parsed = double.tryParse(rawQty);
      // Reject 0, negative numbers, or bare '.' by snapping to minimum positive bound (or defaulting to '1')
      if (parsed == null || parsed < 0) {
        cleanQty = '1';
      } else if (parsed == parsed.roundToDouble()) {
        cleanQty = parsed.toInt().toString();
      } else {
        cleanQty = double.parse(parsed.toStringAsFixed(2)).toString();
      }
    } else {
      cleanQty = '1';
    }
    Navigator.pop(context, Ingredient(name: name, quantity: cleanQty, expiration: _exp.text.trim(), area: _area));
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                labelText: 'Quantity (optional)',
                hintText: 'e.g. 2 cans, 500 g',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            // Expiration Date Field
            TextField(
              controller: _exp,
              readOnly: true, // Prevents manual keyboard typing mistakes!
              onTap: _pickExpirationDate, // Opens calendar when clicked
              decoration: InputDecoration(
                labelText: 'Expiration Date (Optional)',
                hintText: 'Select date',
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: _exp.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _exp.clear();
                          });
                        },
                      )
                    : null,
              ),
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