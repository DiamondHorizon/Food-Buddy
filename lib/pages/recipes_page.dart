import 'package:flutter/material.dart';

import '../app_state.dart';
import '../app_theme.dart';
import '../page_header.dart';

class RecipesPage extends StatefulWidget {
  final AppState state;
  const RecipesPage({super.key, required this.state});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final Set<MealType> _filters = {};

  Future<void> _openAddDialog() async {
    final recipe = await showDialog<Recipe>(
      context: context,
      builder: (_) => const AddRecipeDialog(),
    );
    if (recipe != null) widget.state.addRecipe(recipe);
  }

  void _toggle(MealType m, bool on) {
    setState(() {
      if (on) {
        _filters.add(m);
      } else {
        _filters.remove(m);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final matches = widget.state.matches(meals: _filters);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Recipes',
            subtitle: 'Sorted by how many ingredients you already have',
            action: FilledButton.icon(
              onPressed: _openAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add recipe'),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _filters.isEmpty,
                onSelected: (_) => setState(_filters.clear),
              ),
              for (final m in MealType.values)
                FilterChip(
                  label: Text(m.label),
                  selected: _filters.contains(m),
                  onSelected: (on) => _toggle(m, on),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: matches.isEmpty
                ? Center(
                    child: Text(
                      _filters.isEmpty
                          ? 'No recipes yet. Add one to get started.'
                          : 'No recipes match these filters.',
                      style: TextStyle(color: AppShades.of(context).muted),
                    ),
                  )
                : ListView.separated(
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => RecipeCard(match: matches[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final RecipeMatch match;
  const RecipeCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final r = match.recipe;
    final complete = match.missing.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _MatchRing(have: match.have.length, total: r.ingredients.length),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          r.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: shades.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(r.meal.label),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    complete
                        ? 'You have everything for this.'
                        : 'Missing: ${match.missing.join(', ')}',
                    style: TextStyle(color: complete ? shades.matchComplete : shades.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchRing extends StatelessWidget {
  final int have;
  final int total;
  const _MatchRing({required this.have, required this.total});

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final complete = total > 0 && have == total;
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: total == 0 ? 0 : have / total,
              strokeWidth: 5,
              backgroundColor: shades.ink.withValues(alpha: 0.12),
              color: complete ? shades.matchComplete : shades.matchPartial,
            ),
          ),
          Text('$have/$total', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class AddRecipeDialog extends StatefulWidget {
  const AddRecipeDialog({super.key});

  @override
  State<AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<AddRecipeDialog> {
  final _name = TextEditingController();
  final _type = TextEditingController();
  final _instructions = TextEditingController();
  final _ingredientInput = TextEditingController();
  final List<String> _ingredients = [];
  MealType _meal = MealType.dinner;
  String? _nameError;
  String? _ingredientError;

  void _addIngredients() {
    final parts = _ingredientInput.text
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
    setState(() {
      for (final p in parts) {
        if (!_ingredients.contains(p)) _ingredients.add(p);
      }
      if (_ingredients.isNotEmpty) _ingredientError = null;
    });
    _ingredientInput.clear();
  }

  void _submit() {
    _addIngredients();
    final name = _name.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'Enter a recipe name.' : null;
      _ingredientError = _ingredients.isEmpty ? 'Add at least one ingredient.' : null;
    });
    if (_nameError != null || _ingredientError != null) return;

    Navigator.pop(
      context,
      Recipe(
        name: name,
        type: _type.text.trim(),
        meal: _meal,
        instructions: _instructions.text.trim(),
        ingredients: List.of(_ingredients),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    _instructions.dispose();
    _ingredientInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add recipe'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _name,
                autofocus: true,
                decoration: InputDecoration(labelText: 'Recipe name', errorText: _nameError),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _type,
                decoration: const InputDecoration(labelText: 'Type (optional)'),
              ),
              const SizedBox(height: 16),
              Text('Meal', style: TextStyle(color: AppShades.of(context).muted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in MealType.values)
                    ChoiceChip(
                      label: Text(m.label),
                      selected: _meal == m,
                      onSelected: (_) => setState(() => _meal = m),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientInput,
                      decoration: InputDecoration(
                        labelText: 'Ingredients',
                        hintText: 'e.g. egg, milk, flour',
                        errorText: _ingredientError,
                      ),
                      onSubmitted: (_) => _addIngredients(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Add ingredients',
                    onPressed: _addIngredients,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final i in _ingredients)
                    InputChip(
                      label: Text(i),
                      onDeleted: () => setState(() => _ingredients.remove(i)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _instructions,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Instructions'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Save recipe')),
      ],
    );
  }
}