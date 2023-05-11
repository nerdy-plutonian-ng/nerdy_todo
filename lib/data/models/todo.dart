import 'dart:convert';

class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final List<Todo> children;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.children,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json["id"],
        title: json["title"],
        isCompleted: json["isCompleted"] == 1 ? true : false,
        children:
            List<Todo>.from(json["children"].map((x) => Todo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "isCompleted": isCompleted ? 1 : 0,
        "children": List<dynamic>.from(children.map((x) => x.toJson())),
      };

  static Todo todoFromJson(String str) => Todo.fromJson(json.decode(str));

  static String todoToJson(Todo data) => json.encode(data.toJson());

  Todo copyWith(
      {String? id, String? title, bool? isCompleted, List<Todo>? children}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      children: children ?? this.children,
    );
  }

  @override
  String toString() {
    return 'Todo{id: $id, title: $title, isCompleted: $isCompleted, children: $children}';
  }
}
