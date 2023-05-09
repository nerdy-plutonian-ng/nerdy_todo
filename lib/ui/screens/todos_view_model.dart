import 'package:flutter/foundation.dart';
import 'package:nerdy_todo/data/models/todo.dart';

class TodosState with ChangeNotifier {
  final List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  removeTodo(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }

  toggleTodoCompleted(int index, [int? childIndex]) {
    if (childIndex != null) {
      _todos[index].children[childIndex] = _todos[index]
          .children[childIndex]
          .copyWith(
              isCompleted: !_todos[index].children[childIndex].isCompleted);
      if (_todos[index].children.any((element) => !element.isCompleted)) {
        _todos[index] = _todos[index].copyWith(isCompleted: false);
      } else {
        _todos[index] = _todos[index].copyWith(isCompleted: true);
      }
    } else {
      _todos[index] =
          _todos[index].copyWith(isCompleted: !_todos[index].isCompleted);
      if (_todos[index].isCompleted) {
        for (int i = 0; i < _todos[index].children.length; i++) {
          _todos[index].children[i] =
              _todos[index].children[i].copyWith(isCompleted: true);
        }
      } else {
        for (int i = 0; i < _todos[index].children.length; i++) {
          _todos[index].children[i] =
              _todos[index].children[i].copyWith(isCompleted: false);
        }
      }
    }
    notifyListeners();
  }

  updateTodoTitle(int index, String title) {
    _todos[index] = _todos[index].copyWith(title: title);
    notifyListeners();
  }

  addTodoChild(
    int index,
    int? childIndex,
  ) {
    if (childIndex == null) {
      if (index != 0) {
        final childChildren = _todos[index].children.map((e) => e.copyWith());
        final childTodo = _todos[index].copyWith(children: []);

        _todos[index - 1].children.addAll([childTodo, ...childChildren]);
        _todos.removeAt(index);
      }
    }
    notifyListeners();
  }

  parentTodoChild(String id) {
    final parent = _todos.indexWhere((e) => e.children.any((e) => e.id == id));
    final child = _todos[parent].children.indexWhere((e) => e.id == id);
    final childrenBelow = _todos[parent]
        .children
        .where((element) => _todos[parent].children.indexOf(element) > child)
        .toList();
    _todos.insert(parent + 1,
        _todos[parent].children[child].copyWith(children: childrenBelow));
    _todos[parent].children.removeRange(child, _todos[parent].children.length);
    notifyListeners();
  }
}
