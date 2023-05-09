class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final List<Todo> children;

  Todo(
      {required this.id,
      required this.title,
      required this.isCompleted,
      required this.children});

  copyWith(
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
