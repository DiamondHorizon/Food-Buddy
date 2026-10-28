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
      version: 2,
      onCreate: _createDB, // This triggers only on first app launch
      onUpgrade: _upgradeDB,
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
        name TEXT NOT NULL,
        area TEXT NOT NULL DEFAULT 'pantry',
        quantity TEXT,
        expiration TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE Ingredients ADD COLUMN area TEXT NOT NULL DEFAULT 'pantry'");
      await db.execute('ALTER TABLE Ingredients ADD COLUMN quantity TEXT');
      await db.execute('ALTER TABLE Ingredients ADD COLUMN expiration TEXT');
    }
  }

  // Fetch all ingredients in the database
  Future<List<Map<String, dynamic>>> getIngredients() async {
    final db = await instance.database;
    return await db.query('Ingredients');
  }

  // Insert a new item into the database
  Future<int> insertItem(String name, {String area = 'pantry', String quantity = '', String expiration = ''}) async {
    final db = await instance.database;
    return await db.insert(
      'Ingredients',
      {'name': name, 'area': area, 'quantity': quantity, 'expiration': expiration},
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('Ingredients', where: 'id = ?', whereArgs: [id]);
  }
}