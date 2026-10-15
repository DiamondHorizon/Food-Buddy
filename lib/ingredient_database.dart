import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class IngredientDatabase {
  // Singleton instance
  static final IngredientDatabase instance = IngredientDatabase._init();
  static Database? _database;

  IngredientDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ingredient_database.db');
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

  // Create tables and insert starter ingredients here
  Future _createDB(Database db, int version) async {
    // Create the table
    // id - Unique identifier, automatically handled
    // name - Ingredient name
    await db.execute('''
      CREATE TABLE Ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Insert pre-populated ingredients
    await db.insert('Ingredients', {
      'name': 'Example Ingredient',
    });
  }

  // Fetch all ingredients in the database
  Future<List<Map<String, dynamic>>> getIngredients() async {
    final db = await instance.database;
    return await db.query('Ingredients');
  }

  // Insert a new item into the database
  Future<int> insertItem(String name) async {
    final db = await instance.database;
    return await db.insert(
      'Ingredients',
      {'name': name},
    );
  }
}