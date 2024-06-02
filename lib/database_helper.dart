import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String path = join(await getDatabasesPath(), 'todo_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id TEXT PRIMARY KEY,
        description TEXT,
        completed BOOLEAN,
        list_id TEXT,
        created_at TEXT,
        completed_at TEXT,
        created_by TEXT,
        completed_by TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getTodoItems() async {
    Database db = await database;
    return await db.query('todos');
  }

  Future<void> insertTodoItem(String description, String listId) async {
    Database db = await database;
    await db.insert(
      'todos',
      {
        'id': 'some-unique-id', // Generate a unique ID here
        'description': description,
        'completed': false,
        'list_id': listId,
        'created_at': DateTime.now().toIso8601String(),
        'completed_at': null,
        'created_by': null,
        'completed_by': null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTodoItem(String id, String description) async {
    Database db = await database;
    await db.update(
      'todos',
      {'description': description},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTodoItem(String id) async {
    Database db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
