import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ShoppingListDatabase {
  // Singleton instance
  static final ShoppingListDatabase instance = ShoppingListDatabase._init();
  static Database? _database;

  ShoppingListDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopping_list_database.db');
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

  // Create tables and insert starter shopping list items here
  Future _createDB(Database db, int version) async {
    // Create the table
    // id - Unique identifier, automatically handled
    // name - Ingredient name
    await db.execute('''
      CREATE TABLE ShoppingList (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        isCustom INTEGER NOT NULL DEFAULT 1, -- 1 = user added, 0 = auto-generated
        dismissed INTEGER NOT NULL DEFAULT 0 -- 1 = removed/purchased so auto-gen ignores it
      )
    ''');
  }

  // Fetch all items in the database
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await instance.database;
    return await db.query('ShoppingList');
  }

  // Insert a new item into the database
  Future<int> upsertItem(String name, {required bool isCustom, bool dismissed = false}) async {
    final db = await instance.database;
    return await db.insert(
      'ShoppingList',
      {
        'name': name.trim().toLowerCase(),
        'isCustom': isCustom ? 1 : 0,
        'dismissed': dismissed ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> clearDismissed() async {
    final db = await instance.database;
    return await db.update(
      'ShoppingList',
      {'dismissed': 0},
      where: 'dismissed = ?',
      whereArgs: [1],
    );
  }
}