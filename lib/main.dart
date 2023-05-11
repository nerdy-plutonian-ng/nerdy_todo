import 'package:flutter/material.dart';
import 'package:nerdy_todo/data/todo_repo/db_saver.dart';
import 'package:nerdy_todo/ui/screens/todos_screen.dart';
import 'package:nerdy_todo/ui/screens/todos_view_model.dart';
import 'package:nerdy_todo/ui/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final todoSaver = DbSaver();
  await todoSaver.init();
  runApp(ChangeNotifierProvider(
    create: (_) => TodosState(todoSaver: todoSaver),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const TodosScreen(),
    );
  }
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: TodoListScreen(
        todoRepository: InMemoryTodoRepository(),
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  final TodoRepository todoRepository;

  const TodoListScreen({super.key, required this.todoRepository});

  @override
  TodoListScreenState createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  late final TodoListPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = TodoListPresenter(widget.todoRepository, this);
    _presenter.loadTodoList();
  }

  void updateList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: _presenter.todoList.length,
        itemBuilder: (context, index) {
          final item = _presenter.todoList[index];

          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              _presenter.removeTodoItem(item);
            },
            child: ListTile(
              title: Text(item.title),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await showDialog<String>(
            context: context,
            builder: (context) {
              return const TodoItemDialog();
            },
          );

          if (title != null) {
            _presenter.addTodoItem(title);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoItemDialog extends StatelessWidget {
  const TodoItemDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    late String title;

    return SimpleDialog(
      title: const Text('Add Todo Item'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Form(
            key: formKey,
            child: TextFormField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title must not be empty';
                }
                return null;
              },
              onSaved: (value) {
                title = value!;
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.of(context).pop(title);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class TodoListPresenter {
  final TodoRepository _repository;
  final _view;
  List<TodoItem> _todoList = [];

  TodoListPresenter(this._repository, this._view);

  List<TodoItem> get todoList => _todoList;

  Future<void> loadTodoList() async {
    _todoList = await _repository.fetchAll();
    _view.updateList();
  }

  Future<void> addTodoItem(String title) async {
    final item = TodoItem(title: title);
    await _repository.add(item);
    _todoList.add(item);
    _view.updateList();
  }

  Future<void> removeTodoItem(TodoItem item) async {
    await _repository.remove(item);
    _todoList.remove(item);
    _view.updateList();
  }
}

class TodoItem {
  final String title;

  TodoItem({required this.title});
}

abstract class TodoRepository {
  Future<List<TodoItem>> fetchAll();
  Future<void> add(TodoItem item);
  Future<void> remove(TodoItem item);
}

class InMemoryTodoRepository implements TodoRepository {
  final List<TodoItem> _todoList = [];

  @override
  Future<List<TodoItem>> fetchAll() async {
    return _todoList;
  }

  @override
  Future<void> add(TodoItem item) async {
    _todoList.add(item);
  }

  @override
  Future<void> remove(TodoItem item) async {
    _todoList.remove(item);
  }
}
