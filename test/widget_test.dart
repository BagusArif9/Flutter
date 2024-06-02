import 'package:flutter/material.dart';

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
  List<String> _todoItems = [];

  TextEditingController _textEditingController = TextEditingController();

  void _addTodoItem(String task) {
    setState(() {
      _todoItems.add(task);
    });
    _textEditingController.clear();
  }

  void _updateTodoItem(int index, String newTask) {
    setState(() {
      _todoItems[index] = newTask;
    });
  }

  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoItems.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(_todoItems[index]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  String editedTask = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Edit Task'),
                        content: TextField(
                          controller: TextEditingController(text: _todoItems[index]),
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
                              Navigator.of(context).pop(_textEditingController.text);
                            },
                          ),
                        ],
                      );
                    },
                  );
                  if (editedTask != null && editedTask.isNotEmpty) {
                    _updateTodoItem(index, editedTask);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteTodoItem(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
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
            child: _buildTodoList(),
          ),
        ],
      ),
    );
  }
}
