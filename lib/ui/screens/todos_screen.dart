import 'package:flutter/material.dart';
import 'package:nerdy_todo/ui/screens/todos_view_model.dart';
import 'package:nerdy_todo/ui/theme.dart';
import 'package:nerdy_todo/ui/widgets/todo_sheet.dart';
import 'package:provider/provider.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({Key? key}) : super(key: key);

  showAddTodoSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return const TodoSheet();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Things to do'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<TodosState>(
            builder: (_, state, __) {
              return ListView.builder(
                itemCount: state.todos.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      AppTodoWidget(
                        index: index,
                        key: Key(state.todos[index].id),
                      ),
                      if (state.todos[index].children.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.todos[index].children.length,
                            itemBuilder: (context, childIndex) {
                              return AppTodoWidget(
                                index: index,
                                isChild: true,
                                childIndex: childIndex,
                                key: Key('$index-$childIndex'),
                              );
                            },
                          ),
                        )
                    ],
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAddTodoSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ));
  }
}

class AppCheckbox extends StatelessWidget {
  const AppCheckbox(
      {Key? key,
      required this.isCompleted,
      required this.index,
      this.childIndex})
      : super(key: key);

  final bool isCompleted;
  final int index;
  final int? childIndex;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final state = Provider.of<TodosState>(context, listen: false);
        state.toggleTodoCompleted(index, childIndex);
      },
      child: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            border: Border.all(
                color: isCompleted
                    ? Theme.of(context).colorScheme.secondary
                    : lightGrey,
                width: 1.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  size: 16.0,
                  color: Colors.white,
                )
              : null),
    );
  }
}

class AppTodoWidget extends StatefulWidget {
  const AppTodoWidget({
    Key? key,
    required this.index,
    this.isChild = false,
    this.childIndex,
  }) : super(key: key);

  final int index;
  final bool isChild;
  final int? childIndex;

  @override
  State<AppTodoWidget> createState() => _AppTodoWidgetState();
}

class _AppTodoWidgetState extends State<AppTodoWidget> {
  var padding = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < 0 &&
            widget.childIndex == null) {
          return;
        }
        final state = Provider.of<TodosState>(context, listen: false);
        if (details.primaryVelocity! > 100 &&
            widget.index != 0 &&
            !widget.isChild) {
          setState(() {
            padding = 64;
          });
          state.addTodoChild(
            widget.index,
            widget.childIndex,
          );
          return;
        }
        if (details.primaryVelocity! < -100) {
          setState(() {
            padding = 0;
          });
          state.parentTodoChild(
              state.todos[widget.index].children[widget.childIndex!].id);
          return;
        }
      },
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(left: padding),
        child: Consumer<TodosState>(
          builder: (_, state, __) {
            final todo = widget.isChild
                ? state.todos[widget.index].children[widget.childIndex!]
                : state.todos[widget.index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCheckbox(
                    isCompleted: todo.isCompleted,
                    index: widget.index,
                    childIndex: widget.childIndex,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                      child: Text(todo.title,
                          style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontSize: 24))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
