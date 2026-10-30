import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../app_theme.dart';
import '../page_header.dart';

enum _SearchBy { name, ingredient, servings }

extension on _SearchBy {
  String get label => switch (this) {
    _SearchBy.name => 'Name',
    _SearchBy.ingredient => 'Ingredient',
    _SearchBy.servings => 'Servings', 
    // TODO: implement only numbers foolproofing, advanced filtering (protein, calorie, date night approved, cook time)
  };
    // input for ingredients: quantity, measurement + custom unit, and ingredient, ingredient notes (large clove, quality type)
    // dessert should have its own category, two different fields can get confusing
    //image upload to and personal 
  String get hint => switch (this) {
    _SearchBy.name => 'Search by recipe name',
    _SearchBy.ingredient => 'e.g. egg, milk',
    _SearchBy.servings => 'Minimum servings, e.g. 4',
  };
}

class RecipesPage extends StatefulWidget {
  final AppState state;
  const RecipesPage({super.key, required this.state});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final Set<MealType> _filters = {};
  bool _showHidden = false;
  final _search = TextEditingController();
  String _query = '';
  _SearchBy _searchBy = _SearchBy.name;

  bool _matchesSearch(Recipe r) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return switch (_searchBy) {
      _SearchBy.name => r.name.toLowerCase().contains(q),
      _SearchBy.ingredient =>
        q
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .every((wanted) => r.ingredients.any((i) => i.contains(wanted))),
      _SearchBy.servings => switch (int.tryParse(q)) {
        null => true,
        final n => (r.servingSize ?? 0) >= n,
      },
    };
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openAddDialog() async {
    final recipe = await showDialog<Recipe>(
      context: context,
      builder: (_) => const AddRecipeDialog(),
    );
    if (recipe != null) widget.state.addRecipe(recipe);
  }

  void _openDetails(RecipeMatch match) {
    showDialog<void>(
      context: context,
      builder: (_) => RecipeDetailDialog(
        match: match,
        onFavorite: () => widget.state.toggleFavorite(match.recipe),
        onHide: () => widget.state.toggleHidden(match.recipe),
      ),
    );
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

  Widget _card(RecipeMatch m) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: RecipeCard(
      match: m,
      onTap: () => _openDetails(m),
      onFavorite: () => widget.state.toggleFavorite(m.recipe),
      onHide: () => widget.state.toggleHidden(m.recipe),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final matches = widget.state
        .matches(meals: _filters)
        .where((m) => _matchesSearch(m.recipe))
        .toList();
    final favorites = matches.where((m) => m.recipe.favorite).toList();
    final hidden = matches.where((m) => m.recipe.hidden).toList();
    final rest = matches
        .where((m) => !m.recipe.favorite && !m.recipe.hidden)
        .toList();

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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (value) => setState(() => _query = value),
                  keyboardType: _searchBy == _SearchBy.servings
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: _searchBy.hint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SegmentedButton<_SearchBy>(
                segments: [
                  for (final s in _SearchBy.values)
                    ButtonSegment(value: s, label: Text(s.label)),
                ],
                selected: {_searchBy},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() {
                  _searchBy = s.first;
                  _search.clear();
                  _query = '';
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                      _query.trim().isNotEmpty
                          ? 'No recipes match "$_query".'
                          : _filters.isEmpty
                          ? 'No recipes yet. Add one to get started.'
                          : 'No recipes match these filters.',
                      style: TextStyle(color: shades.muted),
                    ),
                  )
                : ListView(
                    children: [
                      if (favorites.isNotEmpty) ...[
                        _SectionLabel(
                          icon: Icons.star_rounded,
                          label: 'Favorites',
                          count: favorites.length,
                        ),
                        for (final m in favorites) _card(m),
                        const SizedBox(height: 12),
                      ],
                      if (rest.isNotEmpty) ...[
                        _SectionLabel(
                          icon: Icons.menu_book_outlined,
                          label: 'All recipes',
                          count: rest.length,
                        ),
                        for (final m in rest) _card(m),
                        const SizedBox(height: 12),
                      ],
                      if (hidden.isNotEmpty) ...[
                        _SectionLabel(
                          icon: Icons.visibility_off_outlined,
                          label: 'Hidden',
                          count: hidden.length,
                          expanded: _showHidden,
                          onTap: () =>
                              setState(() => _showHidden = !_showHidden),
                        ),
                        if (_showHidden)
                          for (final m in hidden) _card(m),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool? expanded;
  final VoidCallback? onTap;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.count,
    this.expanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: shades.muted),
            const SizedBox(width: 8),
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: shades.ink,
              ),
            ),
            if (expanded != null) ...[
              const SizedBox(width: 4),
              Icon(
                expanded! ? Icons.expand_less : Icons.expand_more,
                color: shades.muted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final RecipeMatch match;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onHide;

  const RecipeCard({
    super.key,
    required this.match,
    required this.onTap,
    required this.onFavorite,
    required this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final r = match.recipe;
    final complete = match.missing.isEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
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
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complete
                          ? 'You have everything for this.'
                          : 'Missing: ${match.missing.join(', ')}',
                      style: TextStyle(
                        color: complete ? shades.matchComplete : shades.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: r.favorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: onFavorite,
                icon: Icon(
                  r.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: r.favorite ? primary : shades.muted,
                ),
              ),
              IconButton(
                tooltip: r.hidden ? 'Unhide' : 'Hide',
                onPressed: onHide,
                icon: Icon(
                  r.hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: shades.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeDetailDialog extends StatelessWidget {
  final RecipeMatch match;
  final VoidCallback onFavorite;
  final VoidCallback onHide;

  const RecipeDetailDialog({
    super.key,
    required this.match,
    required this.onFavorite,
    required this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final r = match.recipe;
    final steps = r.instructions
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final details = [
      if (r.duration != null) (Icons.schedule, '${r.duration} min'),
      if (r.servingSize != null)
        (Icons.people_outline, 'Serves ${r.servingSize}'),
      (Icons.signal_cellular_alt, r.difficulty.label),
    ];

    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Expanded(child: Text(r.name)),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(r.meal.label)),
                if (r.type.isNotEmpty) Chip(label: Text(r.type)),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  for (final (icon, label) in details)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 18, color: shades.muted),
                        const SizedBox(width: 6),
                        Text(label, style: TextStyle(color: shades.muted)),
                      ],
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Ingredients (${match.have.length}/${r.ingredients.length} on hand)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (r.ingredients.isEmpty)
              Text(
                'No ingredients listed.',
                style: TextStyle(color: shades.muted),
              ),
            for (final ing in r.ingredients)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      match.have.contains(ing)
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: match.have.contains(ing)
                          ? shades.matchComplete
                          : shades.muted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(ing)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Instructions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (steps.isEmpty)
              Text(
                'No instructions yet.',
                style: TextStyle(color: shades.muted),
              ),
            if (steps.length == 1)
              SelectableText(steps.first, style: const TextStyle(height: 1.5)),
            if (steps.length > 1)
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${i + 1}.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SelectableText(
                          steps[i],
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onHide();
          },
          icon: Icon(
            r.hidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          label: Text(r.hidden ? 'Unhide' : 'Hide'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onFavorite();
          },
          icon: Icon(
            r.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
          ),
          label: Text(r.favorite ? 'Unfavorite' : 'Favorite'),
        ),
      ],
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
          Text(
            '$have/$total',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
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
  final TextEditingController _duration = TextEditingController();
  final _ingredientInput = TextEditingController();
  final List<String> _ingredients = [];
  MealType _meal = MealType.dinner;
  Difficulty _difficulty = Difficulty.easy;
  String? _nameError;
  String? _ingredientError;

  bool _showAdvanced = false; // Tracks if advanced fields are visible
  final TextEditingController _dietRestriction = TextEditingController();
  final TextEditingController _calories = TextEditingController();
  final TextEditingController _protein = TextEditingController();
  final TextEditingController _carbs = TextEditingController();
  final TextEditingController _fat = TextEditingController();

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
      _ingredientError = _ingredients.isEmpty
          ? 'Add at least one ingredient.'
          : null;
    });
    if (_nameError != null || _ingredientError != null) return;

    final durationValue = int.tryParse(_duration.text.trim());
    final calorieValue = double.tryParse(_calories.text.trim()) ?? 0;
    final double proteinValue = double.tryParse(_protein.text.trim()) ?? 0.0;
    final double carbValue = double.tryParse(_carbs.text.trim()) ?? 0.0;
    final double fatValue = double.tryParse(_fat.text.trim()) ?? 0.0;

    Navigator.pop(
      context,
      Recipe(
        name: name,
        type: _type.text.trim(),
        meal: _meal,
        instructions: _instructions.text.trim(),
        dietRestriction: _dietRestriction.text.trim(),
        duration: durationValue,
        calories: calorieValue,
        protein: proteinValue,
        carbs: carbValue,
        fat: fatValue,
        // difficulty: _difficulty,
        ingredients: List.of(_ingredients),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    _instructions.dispose();
    _duration.dispose();
    _dietRestriction.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
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
                decoration: InputDecoration(
                  labelText: 'Recipe name',
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _type,
                decoration: const InputDecoration(labelText: 'Type (optional)'),
              ),
              const SizedBox(height: 16),
              Text(
                'Meal',
                style: TextStyle(color: AppShades.of(context).muted),
              ),
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
                controller: _duration,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ), // Better mobile keyboard for decimals
                inputFormatters: [
                  // This regular expression strictly allows only numbers and a decimal point
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Prep Time (Hours)',
                  hintText: 'e.g. 0.5',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Difficulty',
                style: TextStyle(color: AppShades.of(context).muted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in Difficulty.values)
                    ChoiceChip(
                      label: Text(m.label),
                      selected: _difficulty == m,
                      onSelected: (_) => setState(() => _difficulty = m),
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
              const SizedBox(height: 16),
              // Advanced Collapsable Button
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAdvanced = !_showAdvanced; // Flips true <-> false
                  });
                },
                icon: Icon(
                  _showAdvanced ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(
                  _showAdvanced ? 'Hide Advanced' : 'Advanced Options',
                ),
              ),
              // Advanced Fields
              if (_showAdvanced) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _dietRestriction,
                  decoration: const InputDecoration(
                    labelText: 'Dietary Restrictions',
                    hintText: 'e.g. Gluten-Free, Vegan, Low-Carb',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _calories,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ), // Better mobile keyboard for decimals
                  inputFormatters: [
                    // This regular expression strictly allows only numbers and a decimal point
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    hintText: 'e.g. 450',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _protein,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ), // Better mobile keyboard for decimals
                  inputFormatters: [
                    // This regular expression strictly allows only numbers and a decimal point
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Protein (g)',
                    hintText: 'e.g. 30',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _carbs,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ), // Better mobile keyboard for decimals
                  inputFormatters: [
                    // This regular expression strictly allows only numbers and a decimal point
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Carbs (g)',
                    hintText: 'e.g. 45',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fat,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ), // Better mobile keyboard for decimals
                  inputFormatters: [
                    // This regular expression strictly allows only numbers and a decimal point
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Fat (g)',
                    hintText: 'e.g. 15',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save recipe')),
      ],
    );
  }
}
