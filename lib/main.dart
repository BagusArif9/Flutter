import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'sync_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite using FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Get the application documents directory
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final dbPath = join(documentsDirectory.path, 'todo_database.db');

  runApp(CRUDApp(
    apiUrl: 'https://664ad95ed7363928f51511a4.powersync.journeyapps.com',
    apiKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFjZSIsInJlZiI6ImxhbmFjZXVhZ2t3b2RvdnZjdWJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTYxMjc5MzksImV4cCI6MjAzMTcwMzkzOX0.zWJfJqC4vQh7C_h-UFezhp-e2IkXWe9ARn007yZ9z-s',
    dbPath: dbPath,
  ));
}

class CRUDApp extends StatelessWidget {
  final String apiUrl;
  final String apiKey;
  final String dbPath;

  const CRUDApp({
    Key? key,
    required this.apiUrl,
    required this.apiKey,
    required this.dbPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          color: Colors.blue,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      home: TodoListScreen(
        apiUrl: apiUrl,
        apiKey: apiKey,
        dbPath: dbPath,
        syncHelper: SyncHelper(apiUrl: apiUrl, apiKey: apiKey),
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  final SyncHelper syncHelper;
  final String apiUrl;
  final String apiKey;
  final String dbPath;

  TodoListScreen({
    Key? key,
    required this.syncHelper,
    required this.apiUrl,
    required this.apiKey,
    required this.dbPath,
  }) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> _todoItems = [];
  TextEditingController _textEditingController = TextEditingController();
  final String _listId = 'your-list-id';

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  void _loadTodoItems() async {
    List<Map<String, dynamic>> items =
        await DatabaseHelper().getTodoItems(widget.dbPath);
    setState(() {
      _todoItems = items;
    });
  }

  void _addTodoItem(String task) async {
  if (task.isNotEmpty) {
    await DatabaseHelper().insertTodoItem(task, _listId, widget.dbPath);
    _loadTodoItems();
    _textEditingController.clear();
    _syncData(context as BuildContext); // Pass context argument here
  }
}

  void _updateTodoItem(String id, String newTask) async {
  if (newTask.isNotEmpty) {
    await DatabaseHelper().updateTodoItem(id, newTask, widget.dbPath);
    _loadTodoItems();
    _syncData(context as BuildContext); // Pass context argument here
  }
}

  void _deleteTodoItem(String id) async {
  await DatabaseHelper().deleteTodoItem(id, widget.dbPath);
  _loadTodoItems();
  _syncData(context as BuildContext); // Pass context argument here
}
  void _syncData(BuildContext context) async {
  try {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('Data synchronized with PowerSync')),
    );
  } catch (e) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('Failed to synchronize data: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
  onPressed: () => _syncData(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Add a new task',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _addTodoItem(_textEditingController.text);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 2.0,
                    child: CheckboxListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _todoItems[index]['description'],
                              style: TextStyle(
                                decoration: _todoItems[index]['completed'] == 1
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              String? editedTask = await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  TextEditingController editController =
                                      TextEditingController(
                                    text: _todoItems[index]['description'],
                                  );
                                  return AlertDialog(
                                    title: Text('Edit Task'),
                                    content: TextField(
                                      controller: editController,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        labelText: 'Task Name',
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Save'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(editController.text);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (editedTask != null && editedTask.isNotEmpty) {
                                _updateTodoItem(
                                    _todoItems[index]['id'].toString(),
                                    editedTask);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteTodoItem(
                                  _todoItems[index]['id'].toString());
                            },
                          ),
                        ],
                      ),
                      value: _todoItems[index]['completed'] == 1,
                      onChanged: (bool? value) {
                        // Handle task completion
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
