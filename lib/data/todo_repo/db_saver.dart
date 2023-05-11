import 'package:nerdy_todo/data/models/todo.dart';
import 'package:nerdy_todo/data/todo_repo/todo_save.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbSaver implements TodoSaver {
  static DbSaver? _instance;

  late Database _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'todo.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
          CREATE TABLE todos(
            id TEXT PRIMARY KEY,
            title TEXT,
            isCompleted INTEGER
          )
        ''');
      db.execute('''
          CREATE TABLE children(
            id TEXT PRIMARY KEY,
            parentId TEXT,
            title TEXT,
            isCompleted INTEGER
          )
        ''');
    });
  }

  DbSaver._();

  factory DbSaver() {
    _instance ??= DbSaver._();
    return _instance!;
  }

  @override
  Future<bool> edit(Todo item, [String? parentId]) async {
    try {
      if (parentId == null) {
        final todo = item.toJson();
        todo.remove('children');
        return await _db
                .update('todos', todo, where: 'id = ?', whereArgs: [item.id]) >
            0;
      } else {
        final todo = item.toJson();
        todo.remove('children');
        return (await _db.update('children', todo,
                where: 'parentId = ?', whereArgs: [parentId])) >
            0;
      }
    } catch (e, s) {
      return false;
    }
  }

  @override
  Future<List<Todo>> getAll() async {
    try {
      var todos = await _db.query(
        'todos',
      );
      todos = todos.map((e) {
        return {...e, 'children': []};
      }).toList();
      final children = await _db.query('children');
      for (var child in children) {
        final index =
            todos.indexWhere((element) => element['id'] == child['parentId']);
        (todos[index]['children'] as List).add(child);
      }
      return todos.map((e) => Todo.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> remove(
    Todo item,
  ) async {
    try {
      return await _db.delete('todos', where: 'id = ?', whereArgs: [item.id]) >
          0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> addChildren(String parentId, List<Todo> children) async {
    try {
      if (children.isEmpty) return true;
      final batch = _db.batch();
      for (var child in children) {
        final todo = child.toJson();
        todo.remove('children');
        todo['parentId'] = parentId;
        batch.insert('children', todo);
      }
      return (await batch.commit()).isNotEmpty;
    } catch (e, s) {
      print(e);
      print(s);
      return false;
    }
  }

  @override
  Future<bool> removeChild(Todo item) async {
    try {
      return await _db
              .delete('children', where: 'id = ?', whereArgs: [item.id]) >
          0;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> removeChildren(String parentId) async {
    try {
      return await _db.delete('children',
              where: 'parentId = ?', whereArgs: [parentId]) >
          0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> save(Todo item) async {
    try {
      final batch = _db.batch();
      final todo = item.toJson();
      todo.remove('children');
      batch.insert('todos', todo);
      if (item.children.isNotEmpty) {
        final values = item.children.map((e) => e.toJson()).toList();
        for (var value in values) {
          value['parentId'] = todo['id'];
          batch.insert('children', value);
        }
      }
      return (await batch.commit()).isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
