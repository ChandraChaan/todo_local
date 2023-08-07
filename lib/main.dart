import 'package:flutter/material.dart';
import 'package:local_todo/sign_in.dart';
import 'package:local_todo/sign_up.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'user_provider.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MaterialApp(
        title: 'TODO App',
        home: HomePage(),
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tasks.txt');
    if (file.existsSync()) {
      setState(() {
        tasks = Task.fromFileString(file.readAsStringSync());
      });
    }
  }

  void _saveTasks() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tasks.txt');
    file.writeAsStringSync(Task.toFileString(tasks));
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
    _saveTasks();
  }

  void _editTask(int index, Task task) {
    setState(() {
      tasks[index] = task;
    });
    _saveTasks();
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: tasks.isEmpty
          ? Center(
              child: Text('No tasks yet. Add some tasks!'),
            )
          : ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(tasks[index].title),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _removeTask(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(tasks[index].title,
                          style: TextStyle(color: Colors.blue)),
                      subtitle: Text(tasks[index].description,
                          style: TextStyle(color: Colors.grey)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit',
                            onPressed: () {
                              _showEditTaskDialog(context, tasks[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () => _removeTask(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showAddTaskDialog(BuildContext context) async {
    final newTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return _AddTaskDialog();
      },
    );

    if (newTask != null) {
      _addTask(newTask);
    }
  }

  void _showEditTaskDialog(BuildContext context, Task task) async {
    final editedTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return _EditTaskDialog(task: task);
      },
    );

    if (editedTask != null) {
      _editTask(tasks.indexOf(task), editedTask);
    }
  }
}

class _AddTaskDialog extends StatefulWidget {
  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            String title = _titleController.text;
            String description = _descriptionController.text;
            if (title.isNotEmpty) {
              Navigator.of(context)
                  .pop(Task(title: title, description: description));
            }
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _EditTaskDialog extends StatefulWidget {
  final Task task;

  _EditTaskDialog({required this.task});

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            String title = _titleController.text;
            String description = _descriptionController.text;
            if (title.isNotEmpty) {
              Navigator.of(context)
                  .pop(Task(title: title, description: description));
            }
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ... Rest of the code remains the same ...

class Task {
  String title;
  String description;

  Task({required this.title, required this.description});

  static List<Task> fromFileString(String fileString) {
    List<Task> tasks = [];
    List<String> lines = fileString.split('\n');
    for (var line in lines) {
      if (line.isNotEmpty) {
        var parts = line.split(',');
        if (parts.length >= 2) {
          tasks.add(Task(title: parts[0], description: parts[1]));
        }
      }
    }
    return tasks;
  }

  static String toFileString(List<Task> tasks) {
    String fileString = '';
    for (var task in tasks) {
      fileString += '${task.title},${task.description}\n';
    }
    return fileString;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Center(
        child: userProvider.isLoggedIn
            ? const TodoList()
            : userProvider.showSignInForm
                ? const SignInForm()
                : const SignUpForm(),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue, // Customize the app bar background color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade400
            ], // Customize the background gradient colors
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                    'https://example.com/user_avatar.jpg'), // Replace with the actual image URL
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome, ${userProvider.name}!',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  userProvider.signOut();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Customize the button background color
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text('Sign Out', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
