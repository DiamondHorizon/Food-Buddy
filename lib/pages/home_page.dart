import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_state.dart';
import '../app_theme.dart';
import '../page_header.dart';
import 'inventory_page.dart';
import 'recipes_page.dart';

String _greeting(int hour) => switch (hour) {
      >= 5 && < 12 => 'Good morning',
      >= 12 && < 17 => 'Good afternoon',
      >= 17 && < 22 => 'Good evening',
      _ => 'Late-night cravings?',
    };

class HomePage extends StatelessWidget {
  final AppState state;
  const HomePage({super.key, required this.state});

  void _open(BuildContext context, RecipeMatch m) {
    state.recordOpen(m.recipe);
    showDialog<void>(
      context: context,
      builder: (_) => RecipeDetailDialog(
        match: m,
        state: state,
        onFavorite: () => state.toggleFavorite(m.recipe),
        onHide: () => state.toggleHidden(m.recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final now = DateTime.now();
    final slot = mealForHour(now.hour);
    final picks = state.recommendations(now: now);
    final mostOpened = state
        .matches()
        .where((m) => m.recipe.clicks > 0 && !m.recipe.hidden)
        .toList()
      ..sort((a, b) => b.recipe.clicks.compareTo(a.recipe.clicks));

    Widget mainFeed({bool includeBottomShoppingList = false}) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PageHeader(
            title: _greeting(now.hour),
            subtitle: "It's ${slot.label.toLowerCase()} time. Here's what fits right now.",
          ),
          const SizedBox(height: 24),
          const _Heading('Recommended for you'),
          const SizedBox(height: 12),
          if (picks.isEmpty)
            Text(
              'Add a few recipes and suggestions will show up here.',
              style: TextStyle(color: shades.muted),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final m in picks)
                  _PickCard(match: m, slot: slot, onTap: () => _open(context, m)),
              ],
            ),
          if (mostOpened.isNotEmpty) ...[
            const SizedBox(height: 28),
            const _Heading('Most opened'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final m in mostOpened.take(5))
                    ListTile(
                      title: Text(m.recipe.name),
                      subtitle: Text(
                        '${m.have.length}/${m.recipe.ingredients.length} ingredients on hand',
                      ),
                      trailing: Text(
                        'Opened ${m.recipe.clicks}×',
                        style: TextStyle(color: shades.muted),
                      ),
                      onTap: () => _open(context, m),
                    ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: mainFeed()),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                child: SizedBox(
                  width: 340,
                  child: _ShoppingListPanel(state: state, isSidePanel: true),
                ),
              ),
            ],
          );
        }

        return mainFeed(includeBottomShoppingList: true);
      },
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppShades.of(context).ink,
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  final RecipeMatch match;
  final MealType slot;
  final VoidCallback onTap;

  const _PickCard({required this.match, required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final r = match.recipe;
    final total = r.ingredients.length;
    final fraction = total == 0 ? 0.0 : match.have.length / total;
    final fitsNow = r.meal == slot || r.type.toLowerCase() == slot.name;

    final reasons = [
      if (fitsNow) 'Good for ${slot.label.toLowerCase()}',
      if (r.clicks > 0) 'Opened ${r.clicks}×',
      '${match.have.length}/$total on hand',
    ];

    return SizedBox(
      width: 270,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        r.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: shades.ink,
                        ),
                      ),
                    ),
                    if (r.favorite) Icon(Icons.star_rounded, color: primary, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final reason in reasons)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: shades.ink,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: shades.ink.withValues(alpha: 0.12),
                  color: fraction == 1 ? shades.matchComplete : shades.matchPartial,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShoppingListPanel extends StatefulWidget {
  final AppState state;
  final bool isSidePanel;

  const _ShoppingListPanel({
    required this.state,
    required this.isSidePanel,
  });

  @override
  State<_ShoppingListPanel> createState() => _ShoppingListPanelState();
}

class _ShoppingListPanelState extends State<_ShoppingListPanel> {
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _submitCustomItem() async {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    _customController.clear();
    await widget.state.addCustomShoppingItem(text);
  }

  Future<void> _shareShoppingList() async {
    final items = widget.state.shoppingList;
    if (items.isEmpty) return;

    final buffer = StringBuffer('Shopping List:\n');
    for (final item in items) {
      buffer.writeln('- ${item.name}');
    }

    // Required on iPad/macOS so the share popover knows where to anchor
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    await Share.share(
      buffer.toString().trim(),
      subject: 'My Shopping List',
      sharePositionOrigin: origin,
    );
  }

  Future<void> _checkOffAndAddToInventory(ShoppingItem item) async {
    final added = await showDialog<Ingredient>(
      context: context,
      builder: (_) => AddIngredientDialog(initialName: item.name),
    );
    if (added != null) {
      await widget.state.addIngredient(added);
      await widget.state.dismissShoppingItem(item.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final items = widget.state.shoppingList;

    final listContent = items.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Nothing on your shopping list. Missing ingredients from recommended recipes will appear here automatically.',
              style: TextStyle(color: shades.muted, fontSize: 13.5),
            ),
          )
        : ListView.separated(
            shrinkWrap: !widget.isSidePanel,
            physics: widget.isSidePanel
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Checkbox(
                  value: false,
                  onChanged: (_) => _checkOffAndAddToInventory(item),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  item.isCustom ? 'Custom item' : 'From recommendations',
                  style: TextStyle(fontSize: 11.5, color: shades.muted),
                ),
                trailing: IconButton(
                  tooltip: 'Remove from list',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => widget.state.dismissShoppingItem(item.name),
                ),
              );
            },
          );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: widget.isSidePanel ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Shopping List',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: shades.ink,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Share shopping list',
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: items.isEmpty ? null : _shareShoppingList,
                ),
                IconButton(
                  tooltip: 'Restore dismissed suggestions',
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => widget.state.resetDismissedShoppingItems(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Items
          if (widget.isSidePanel)
            Expanded(child: listContent)
          else
            listContent,

          const Divider(height: 1),

          // Bottom Custom Item Input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customController,
                    decoration: const InputDecoration(
                      hintText: 'Add custom item...',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _submitCustomItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Add to shopping list',
                  icon: const Icon(Icons.add),
                  onPressed: _submitCustomItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}