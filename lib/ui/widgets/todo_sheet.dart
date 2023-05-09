import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/todo.dart';
import '../screens/todos_view_model.dart';

class TodoSheet extends StatefulWidget {
  const TodoSheet({Key? key, this.index}) : super(key: key);

  final int? index;

  @override
  State<TodoSheet> createState() => _TodoSheetState();
}

class _TodoSheetState extends State<TodoSheet> {
  String? error;
  late TextEditingController _titleController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TodosState>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            '${widget.index == null ? 'New' : 'Edit'} todo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 16.0,
          ),
          TextField(
            controller: _titleController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Title',
              errorText: error,
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () {
                    state.addTodo(Todo(
                      title: _titleController.text,
                      isCompleted: false,
                      children: [],
                      id: const Uuid().v4(),
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Save')),
            ],
          )
        ],
      ),
    );
  }
}
