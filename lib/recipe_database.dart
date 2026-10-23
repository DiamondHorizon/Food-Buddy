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
      version: 2,
      onCreate: _createDB, // This triggers only on first app launch
      onUpgrade: _upgradeDB,
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
        type TEXT,
        meal TEXT,
        instructions TEXT NOT NULL,
        ingredients TEXT,
        dietRestriction TEXT,
        duration INTEGER,
        calories REAL,
        protein REAL,
        carbs REAL,
        fat REAL,
        difficulty TEXT,
        servingSize INTEGER NOT NULL
      )
    ''');

    // Insert pre-populated recipes
    await db.insert('Recipes', {
      'name': 'Example Recipe',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': 'Cook the things',
      'ingredients': 'egg, milk, butter',
      'dietRestriction': 'None',
      'duration': 30,
      'calories': 500.0,
      'protein': 20.0,
      'carbs': 60.0,
      'fat': 10.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE Recipes ADD COLUMN ingredients TEXT');
    }
  }

  // Fetch all recipes in the database
  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await instance.database;
    return await db.query('Recipes');
  }

  // Insert a new item into the database
  Future<int> insertItem(String name, String type, String meal, String instructions,
      {String ingredients = '', int servingSize = 1}) async {
    final db = await instance.database;
    return await db.insert(
      'Recipes',
      {
        'name': name,
        'type': type,
        'meal': meal,
        'instructions': instructions,
        'ingredients': ingredients,
        'servingSize': servingSize,
      },
    );
  }
}