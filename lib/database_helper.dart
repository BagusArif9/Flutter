import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Future<Database> _getDatabase(String dbPath) async {
    return await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE todo(
          id INTEGER PRIMARY KEY,
          description TEXT,
          completed INTEGER,
          listId TEXT
        )
      ''');
    });
  }

  Future<List<Map<String, dynamic>>> getTodoItems(String dbPath) async {
    final db = await _getDatabase(dbPath);
    return await db.query('todo');
  }

  Future<void> insertTodoItem(String task, String listId, String dbPath) async {
    final db = await _getDatabase(dbPath);
    await db.insert('todo', {'description': task, 'completed': 0, 'listId': listId});
  }

  Future<void> updateTodoItem(String id, String newTask, String dbPath) async {
    final db = await _getDatabase(dbPath);
    await db.update('todo', {'description': newTask}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTodoItem(String id, String dbPath) async {
    final db = await _getDatabase(dbPath);
    await db.delete('todo', where: 'id = ?', whereArgs: [id]);
  }
}
