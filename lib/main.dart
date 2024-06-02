import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'sync_helper.dart';
import 'app_config.dart';

void main() {
  runApp(CRUDApp());
}

class CRUDApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> _todoItems = [];
  TextEditingController _textEditingController = TextEditingController();
  final String _listId = 'your-list-id'; // Ubah sesuai ID list Anda

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  void _loadTodoItems() async {
    List<Map<String, dynamic>> items = await DatabaseHelper().getTodoItems();
    setState(() {
      _todoItems = items;
    });
  }

  void _addTodoItem(String task) async {
    await DatabaseHelper().insertTodoItem(task, _listId);
    _loadTodoItems();
    _textEditingController.clear();
  }

  void _updateTodoItem(String id, String newTask) async {
    await DatabaseHelper().updateTodoItem(id, newTask);
    _loadTodoItems();
  }

  void _deleteTodoItem(String id) async {
    await DatabaseHelper().deleteTodoItem(id);
    _loadTodoItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () async {
              await SyncHelper().syncData();
              _loadTodoItems();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: 'Add Task',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _addTodoItem(_textEditingController.text);
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_todoItems[index]['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          String editedTask = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController editController = TextEditingController(text: _todoItems[index]['description']);
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
                                      Navigator.of(context).pop(editController.text);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          if (editedTask != null && editedTask.isNotEmpty) {
                            _updateTodoItem(_todoItems[index]['id'], editedTask);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTodoItem(_todoItems[index]['id']);
                        },
                      ),
                    ],
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
