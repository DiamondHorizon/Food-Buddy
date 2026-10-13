import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RecipeDatabase {
  // Singleton instance
  static final RecipeDatabase instance = RecipeDatabase._init();
  static Database? _database;

  RecipeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipe_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB, // This triggers only on first app launch
    );
  }

  // Create tables and insert starter recipes here
  Future _createDB(Database db, int version) async {
    // Create the table
    // id - Unique identifier, automatically handled
    // name - Recipe name
    // type - Appetizer, Entree, Dessert, Drink
    // meal - Breakfast, Lunch, Dinner
    // instructions - Cooking instructions
    await db.execute('''
      CREATE TABLE Recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT
        meal TEXT
        instructions TEXT NOT NULL
      )
    ''');

    // Insert pre-populated recipes
    await db.insert('Recipes', {
      'name': 'Example Recipe',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': 'Cook the things'
    });
  }

  // Fetch all recipes in the database
  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await instance.database;
    return await db.query('Recipes');
  }
}