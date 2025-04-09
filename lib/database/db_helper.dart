import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // If the database doesn't exist, create it
    _database = await _initDB();
    return _database!;
  }

  _initDB() async {
    // Get the path to the database
    String path = join(await getDatabasesPath(), 'plant_plan.db');

    // Open the database, if it doesn't exist, create it
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE plans(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plant_name TEXT,
          plan_json TEXT
        )
      ''');
      },
    );
  }

  // Insert a new plan
  Future<void> savePlan(String plantName, String planJson) async {
    final db = await database;
    await db.insert('plans', {
      'plant_name': plantName,
      'plan_json': planJson,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all saved plans
  Future<List<Map<String, dynamic>>> getPlans() async {
    final db = await database;
    return await db.query('plans');
  }

  Future<void> deletePlan(int id) async {
    final db = await database;
    await db.delete('plans', where: 'id = ?', whereArgs: [id]);
  }
}
