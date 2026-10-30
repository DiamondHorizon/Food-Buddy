import 'package:flutter/material.dart';

import 'ingredient_database.dart';
import 'recipe_database.dart';
import 'app_theme.dart';

enum StorageArea { pantry, fridge, freezer }

extension StorageAreaStyle on StorageArea {
  String get label => switch (this) {
        StorageArea.pantry => 'Pantry',
        StorageArea.fridge => 'Fridge',
        StorageArea.freezer => 'Freezer',
      };

  Color get light => switch (this) {
        StorageArea.pantry => AppColors.pantryLight,
        StorageArea.fridge => AppColors.fridgeLight,
        StorageArea.freezer => AppColors.freezerLight,
      };

  Color get mid => switch (this) {
        StorageArea.pantry => AppColors.pantry,
        StorageArea.fridge => AppColors.fridge,
        StorageArea.freezer => AppColors.freezer,
      };

  Color get dark => switch (this) {
        StorageArea.pantry => AppColors.pantryDark,
        StorageArea.fridge => AppColors.fridgeDark,
        StorageArea.freezer => AppColors.freezerDark,
      };

  Color headerBg(bool isDark) => isDark ? Color.lerp(dark, Colors.black, 0.5)! : light;

  Color iconColor(bool isDark) => isDark ? Color.lerp(mid, Colors.white, 0.4)! : dark;

  IconData get icon => switch (this) {
        StorageArea.pantry => Icons.inventory_2_outlined,
        StorageArea.fridge => Icons.kitchen_outlined,
        StorageArea.freezer => Icons.ac_unit,
      };
}

StorageArea storageAreaFrom(Object? value) => StorageArea.values.firstWhere(
      (a) => a.name == value.toString().toLowerCase(),
      orElse: () => StorageArea.pantry,
    );

enum MealType { breakfast, lunch, dinner, snack, drink }

extension MealTypeLabel on MealType {
  String get label => name[0].toUpperCase() + name.substring(1);
}

MealType mealTypeFrom(Object? value) => MealType.values.firstWhere(
      (m) => m.name == value.toString().trim().toLowerCase(),
      orElse: () => MealType.dinner,
    );

enum Difficulty { easy, intermediate, advanced, difficult, experienced }

extension DifficultyLabel on Difficulty {
  String get label => name[0].toUpperCase() + name.substring(1);
}

Difficulty difficultyFrom(Object? value) => Difficulty.values.firstWhere(
      (m) => m.name == value.toString().trim().toLowerCase(),
      orElse: () => Difficulty.easy,
    );

class Ingredient {
  final int? id;
  final String name;
  final String quantity;
  final String expiration;
  final StorageArea area;

  const Ingredient({this.id, required this.name, this.quantity = '', this.expiration = '', required this.area});

  factory Ingredient.fromMap(Map<String, dynamic> row) => Ingredient(
        id: row['id'] as int?,
        name: (row['name'] as String).trim().toLowerCase(),
        quantity: (row['quantity'] as String?) ?? '',
        expiration: (row['expiration'] as String?) ?? '',
        area: storageAreaFrom(row['area']),
      );
}

class Recipe {
  final int? id;
  final String name;
  final String type;
  final MealType meal;
  final String instructions;
  final String dietRestriction;
  final int? duration;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final Difficulty difficulty;
  final int? servingSize;
  final List<String> ingredients;
  final bool favorite;
  final bool hidden;

  const Recipe({
    this.id,
    required this.name,
    this.type = '',
    required this.meal,
    this.instructions = '',
    this.dietRestriction = '',
    this.duration,
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.difficulty = Difficulty.easy,
    this.servingSize,
    required this.ingredients,
    this.favorite = false,
    this.hidden = false,
  });

  factory Recipe.fromMap(Map<String, dynamic> row) => Recipe(
        id: row['id'] as int?,
        name: row['name'] as String,
        type: (row['type'] as String?) ?? '',
        meal: mealTypeFrom(row['meal']),
        instructions: (row['instructions'] as String?) ?? '',
        dietRestriction: (row['dietRestriction'] as String?) ?? '',
        duration: (row['duration'] as num?)?.toInt(),
        calories: (row['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (row['protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (row['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (row['fat'] as num?)?.toDouble() ?? 0.0,
        difficulty: difficultyFrom(row['difficulty']),
        servingSize: (row['servingSize'] as num?)?.toInt(),
        ingredients: ((row['ingredients'] as String?) ?? '')
            .split(',')
            .map((s) => s.trim().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toList(),
        favorite: row['favorite'] == 1,
        hidden: row['hidden'] == 1,
      );
}

class RecipeMatch {
  final Recipe recipe;
  final List<String> have;
  final List<String> missing;
  const RecipeMatch(this.recipe, this.have, this.missing);
}

class AppState extends ChangeNotifier {
  List<Ingredient> ingredients = [];
  List<Recipe> recipes = [];
  bool darkMode = false;

  void toggleDarkMode() {
    darkMode = !darkMode;
    notifyListeners();
  }

  Future<void> load() async {
    final ingredientRows = await IngredientDatabase.instance.getIngredients();
    final recipeRows = await RecipeDatabase.instance.getRecipes();
    ingredients = ingredientRows.map(Ingredient.fromMap).toList();
    recipes = recipeRows.map(Recipe.fromMap).toList();
    notifyListeners();
  }

  Future<void> addIngredient(Ingredient item) async {
    await IngredientDatabase.instance.insertItem(
      item.name,
      area: item.area.name,
      quantity: item.quantity,
      expiration: item.expiration,
    );
    await load();
  }

  Future<void> removeIngredient(Ingredient item) async {
    if (item.id != null) await IngredientDatabase.instance.deleteItem(item.id!);
    ingredients.remove(item);
    notifyListeners();
  }
  // difficulty enum is stricter so I kept that
  Future<void> addRecipe(Recipe r) async {
    await RecipeDatabase.instance.insertItem(
      r.name, r.type, r.meal.label, r.instructions,
      ingredients: r.ingredients.join(', '),
      dietRestriction: r.dietRestriction,
      duration: r.duration,
      calories: r.calories,
      protein: r.protein,
      carbs: r.carbs,
      fat: r.fat,
      difficulty: r.difficulty.label,
    );
    await load();
  }

  Future<void> toggleFavorite(Recipe r) async {
    if (r.id == null) return;
    await RecipeDatabase.instance.setFavorite(r.id!, !r.favorite);
    await load();
  }

  Future<void> toggleHidden(Recipe r) async {
    if (r.id == null) return;
    await RecipeDatabase.instance.setHidden(r.id!, !r.hidden);
    await load();
  }

  List<Ingredient> inArea(StorageArea area) =>
      ingredients.where((i) => i.area == area).toList();

  List<RecipeMatch> matches({Set<MealType> meals = const {}}) {
    final owned = ingredients.map((i) => i.name).toSet();
    final results = <RecipeMatch>[];

    for (final r in recipes) {
      if (meals.isNotEmpty &&
          !meals.any((m) => m == r.meal || m.name == r.type.toLowerCase())) {
        continue;
      }
      final have = <String>[];
      final missing = <String>[];
      for (final ing in r.ingredients) {
        (owned.contains(ing) ? have : missing).add(ing);
      }
      results.add(RecipeMatch(r, have, missing));
    }

    results.sort((a, b) {
      final byHave = b.have.length.compareTo(a.have.length);
      if (byHave != 0) return byHave;
      return a.missing.length.compareTo(b.missing.length);
    });
    return results;
  }
}