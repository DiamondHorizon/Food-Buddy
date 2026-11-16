import 'dart:convert';

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

enum MealType { breakfast, lunch, dinner, snack, dessert, drink }

extension MealTypeLabel on MealType {
  String get label => name[0].toUpperCase() + name.substring(1);
}

MealType mealTypeFrom(Object? value) => MealType.values.firstWhere(
      (m) => m.name == value.toString().trim().toLowerCase(),
      orElse: () => MealType.dinner,
    );

MealType mealForHour(int hour) => switch (hour) {
      >= 5 && < 11 => MealType.breakfast,
      >= 11 && < 15 => MealType.lunch,
      >= 15 && < 17 => MealType.snack,
      >= 17 && < 21 => MealType.dinner,
      _ => MealType.dessert,
    };

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

class RecipeIngredient {
  final String name;
  final String quantity; // e.g. "2 cups", "100g", "3"

  RecipeIngredient({required this.name, required this.quantity});

  // Serialization helpers if storing in SQLite as JSON text or comma-separated strings
  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity};
  
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => 
      RecipeIngredient(name: json['name'], quantity: json['quantity'] ?? '');
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
  final List<RecipeIngredient> ingredients;
  final bool favorite;
  final bool hidden;
  final int clicks;

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
    this.clicks = 0,
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
        ingredients: row['ingredients'] != null && (row['ingredients'] as String).isNotEmpty
          ? (jsonDecode(row['ingredients'] as String) as List)
              .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
        favorite: row['favorite'] == 1,
        hidden: row['hidden'] == 1,
        clicks: (row['clicks'] as num?)?.toInt() ?? 0,
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

  Future<void> addRecipe(Recipe r) async {
    await RecipeDatabase.instance.insertItem(
      r.name, r.type, r.meal.label, r.instructions,
      ingredients: jsonEncode(r.ingredients.map((i) => i.toJson()).toList()),
      servingSize: r.servingSize ?? 1,
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

  Future<void> recordOpen(Recipe r) async {
    if (r.id == null) return;
    await RecipeDatabase.instance.incrementClicks(r.id!);
    await load();
  }

  List<Ingredient> inArea(StorageArea area) =>
      ingredients.where((i) => i.area == area).toList();

  List<RecipeMatch> matches({Set<MealType> meals = const {}}) {
    final results = <RecipeMatch>[];

    for (final r in recipes) {
      if (meals.isNotEmpty &&
          !meals.any((m) => m == r.meal || m.name == r.type.toLowerCase())) {
        continue;
      }

      final have = <String>[];
      final missing = <String>[];

      for (final ing in r.ingredients) {
        final reqName = ing.name.trim().toLowerCase();

        // Find all matching items in inventory (in case an ingredient is split across fridge/pantry/freezer)
        final matchingItems = ingredients.where(
          (item) => item.name.isNotEmpty && reqName.contains(item.name),
        );

        bool hasEnough = false;

        if (matchingItems.isNotEmpty) {
          final double? requiredQty = double.tryParse(
            RegExp(r'\d+\.?\d*').stringMatch(ing.quantity) ?? '',
          );

          if (requiredQty == null || requiredQty <= 0) {
            // Recipe specifies no numeric amount (e.g., "salt" or "") -> owning it is enough
            hasEnough = true;
          } else {
            // Sum available quantities across matching inventory entries
            double ownedQty = 0.0;
            bool hasUnquantifiedStock = false;

            for (final item in matchingItems) {
              final double? parsed = double.tryParse(
                RegExp(r'\d+\.?\d*').stringMatch(item.quantity) ?? '',
              );
              if (parsed != null) {
                ownedQty += parsed;
              } else {
                // Inventory item exists without a numeric quantity
                hasUnquantifiedStock = true;
              }
            }

            hasEnough = ownedQty >= requiredQty || hasUnquantifiedStock;
          }
        }

        (hasEnough ? have : missing).add(ing.name);
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

  List<RecipeMatch> recommendations({DateTime? now, int limit = 6}) {
    final slot = mealForHour((now ?? DateTime.now()).hour);
    final scored = matches().where((m) => !m.recipe.hidden).map((m) {
      final r = m.recipe;
      final total = r.ingredients.length;
      final fitsNow = r.meal == slot || r.type.toLowerCase() == slot.name;
      final score = (fitsNow ? 3.0 : 0.0) +
          r.clicks.clamp(0, 10).toDouble() * 0.3 +
          (total == 0 ? 0.0 : m.have.length / total * 2) +
          (r.favorite ? 1.0 : 0.0);
      return (m, score);
    }).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return scored.take(limit).map((e) => e.$1).toList();
  }

  Future<void> markRecipeAsMade(Recipe recipe) async {
    // Fetch current inventory items from the database
    final inventoryRows = await IngredientDatabase.instance.getIngredients();

    for (final recipeIng in recipe.ingredients) {
      // Find matching item in inventory by name (case-insensitive)
      final match = inventoryRows.firstWhere(
        (item) => item['name'].toString().toLowerCase() == recipeIng.name.toLowerCase(),
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        final int itemId = match['id'];
        final String currentQtyStr = match['quantity'] ?? '';
        
        // Extract numbers from strings (e.g., "500 g" -> 500.0, "2 cups" -> 2.0)
        final double? invNum = double.tryParse(RegExp(r'\d+\.?\d*').stringMatch(currentQtyStr) ?? '');
        final double? recipeNum = double.tryParse(RegExp(r'\d+\.?\d*').stringMatch(recipeIng.quantity) ?? '');

        if (invNum != null && recipeNum != null) {
          final double newQty = invNum - recipeNum;
          if (newQty <= 0) {
            // If inventory hits 0 or below, remove the item completely
            await IngredientDatabase.instance.deleteItem(itemId);
          } else {
            // Otherwise, preserve the unit suffix (e.g. "cups" or "g") if it existed
            final String unitSuffix = currentQtyStr.replaceAll(RegExp(r'[\d.]+'), '').trim();
            final updatedQtyText = unitSuffix.isNotEmpty ? '$newQty $unitSuffix' : '$newQty';
            
            // Update the quantity in the database
            await IngredientDatabase.instance.updateItemQuantity(itemId, updatedQtyText);
          }
        }
      }
    }
    
    // Refresh your local inventory list so the UI reflects the subtraction
    await load();
  }

  Future<void> updateIngredientQuantity(Ingredient item, String newQuantity) async {
    if (item.id == null) return;

    await IngredientDatabase.instance.updateItemQuantity(item.id!, newQuantity);

    final index = ingredients.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      ingredients[index] = Ingredient(
        id: item.id,
        name: item.name,
        quantity: newQuantity,
        expiration: item.expiration,
        area: item.area,
      );
      notifyListeners();
    }
  }
}
