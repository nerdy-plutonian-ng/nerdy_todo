import 'package:nerdy_todo/data/models/todo.dart';

abstract class TodoSaver {
  Future<bool> save(Todo item);
  Future<bool> remove(Todo item);
  Future<bool> addChildren(String parentId, List<Todo> children);
  Future<bool> removeChild(Todo item);
  Future<bool> removeChildren(String parentId);
  Future<bool> edit(Todo item, [String? parentId]);
  Future<List<Todo>> getAll();
}
