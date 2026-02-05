import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'clemopi.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables
  Future _onCreate(Database db, int version) async {
    // Example: Create a cache table
    await db.execute('''
      CREATE TABLE cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        expires_at INTEGER
      )
    ''');

    // Example: Create a user data table
    await db.execute('''
      CREATE TABLE user_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
        name TEXT,
        email TEXT,
        phone TEXT,
        data TEXT,
        last_updated INTEGER NOT NULL
      )
    ''');

    // Example: Create a scooter cache table
    await db.execute('''
      CREATE TABLE scooter_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scooter_id TEXT NOT NULL UNIQUE,
        battery_level INTEGER,
        latitude REAL,
        longitude REAL,
        status TEXT,
        last_synced INTEGER NOT NULL
      )
    ''');

    print('Database tables created');
  }

  // Handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Add migration logic here if needed
      print('Database upgraded from version $oldVersion to $newVersion');
    }
  }

  // Generic CRUD operations

  // Insert data
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Query all rows
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  // Query with condition
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  // Update data
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // Delete data
  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // Delete all from table
  Future<int> deleteAll(String table) async {
    final db = await database;
    return await db.delete(table);
  }

  // Execute raw query
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // Execute raw insert/update/delete
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Clear expired cache
  Future<void> clearExpiredCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await delete(
      'cache',
      where: 'expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: [now],
    );
  }
}
