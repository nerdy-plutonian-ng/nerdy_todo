import 'package:flutter/foundation.dart';
import 'package:nerdy_todo/data/models/todo.dart';
import 'package:nerdy_todo/data/todo_repo/todo_save.dart';

class TodosState with ChangeNotifier {
  TodosState({required this.todoSaver}) {
    todoSaver.getAll().then((value) {
      _todos.addAll(value);
    });
  }

  final TodoSaver todoSaver;

  final List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  addTodo(Todo todo) {
    todoSaver.save(todo).then((res) {
      if (res) {
        _todos.add(todo);
        notifyListeners();
      }
    });
  }

  removeTodo(int index, [int? childIndex]) {
    if (childIndex != null) {
      todoSaver.removeChild(_todos[index].children[childIndex]).then((res) {
        _todos[index].children.removeAt(childIndex);
        notifyListeners();
      });
    } else {
      todoSaver.remove(_todos[index]).then((res) {
        if (res) {
          _todos.removeAt(index);
        }
        notifyListeners();
      });
    }
  }

  toggleTodoCompleted(int index, [int? childIndex]) async {
    if (childIndex != null) {
      final toggledChild = _todos[index].children[childIndex].copyWith(
          isCompleted: !_todos[index].children[childIndex].isCompleted);
      final res = await todoSaver.edit(toggledChild, _todos[index].id);
      if (res) {
        _todos[index].children[childIndex] = toggledChild;
        final toggled =
            _todos[index].children.any((element) => !element.isCompleted)
                ? _todos[index].copyWith(isCompleted: false)
                : _todos[index].copyWith(isCompleted: true);
        final res = await todoSaver.edit(
          toggled,
        );
        if (res) {
          _todos[index] = toggled;
        }
      }
      notifyListeners();
    } else {
      final toggled =
          _todos[index].copyWith(isCompleted: !_todos[index].isCompleted);
      if (toggled.isCompleted) {
        for (int i = 0; i < _todos[index].children.length; i++) {
          toggled.children[i] = toggled.children[i].copyWith(isCompleted: true);
        }
      } else {
        for (int i = 0; i < _todos[index].children.length; i++) {
          toggled.children[i] =
              toggled.children[i].copyWith(isCompleted: false);
        }
      }
      todoSaver.edit(toggled).then((res) {
        if (res) {
          _todos[index] = toggled;
          notifyListeners();
        }
      });
    }
  }

  updateTodoTitle(int index, String title, int? childIndex) async {
    if (childIndex == null) {
      final res = await todoSaver.edit(_todos[index].copyWith(title: title));
      if (res) {
        _todos[index] = _todos[index].copyWith(title: title);
      }
    } else {
      final res = await todoSaver.edit(
          _todos[index].children[childIndex!].copyWith(title: title),
          _todos[index].id);
      if (res) {
        _todos[index].children[childIndex] =
            _todos[index].children[childIndex].copyWith(title: title);
      }
    }
    notifyListeners();
  }

  addTodoChild(
    int index,
    int? childIndex,
  ) async {
    if (childIndex == null) {
      if (index != 0) {
        final childChildren = _todos[index].children.map((e) => e.copyWith());
        final childTodo = _todos[index].copyWith(children: []);

        final res = await todoSaver.addChildren(_todos[index - 1].id, [
          childTodo,
          ...childChildren,
        ]);
        if (res) {
          _todos[index - 1].children.addAll([childTodo, ...childChildren]);
          final res = await todoSaver.remove(_todos[index]);
          if (res) {
            _todos.removeAt(index);
          }
        }
      }
    }
    notifyListeners();
  }

  parentTodoChild(String id) async {
    final parent = _todos.indexWhere((e) => e.children.any((e) => e.id == id));
    final child = _todos[parent].children.indexWhere((e) => e.id == id);
    final childrenBelow = _todos[parent]
        .children
        .where((element) => _todos[parent].children.indexOf(element) > child)
        .toList();
    final res = await todoSaver.save(_todos[parent].children[child]);
    if (res) {
      _todos.insert(parent + 1, _todos[parent].children[child]);
      final resp =
          await todoSaver.addChildren(_todos[parent + 1].id, childrenBelow);
      if (resp) {
        _todos[parent + 1].children.addAll(childrenBelow);
        final response = await todoSaver.removeChildren(_todos[parent].id);
        if (response) {
          _todos[parent]
              .children
              .removeRange(child, _todos[parent].children.length);
        }
      }
    }
    notifyListeners();
  }
}
