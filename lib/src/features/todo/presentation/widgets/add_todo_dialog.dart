import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/features/todo/application/total_rows.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';

class AddTodoDialog extends ConsumerStatefulWidget {
  const AddTodoDialog({
    super.key,
  });

  @override
  ConsumerState<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<AddTodoDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Todo :'),
      content: SizedBox(
        width: 300,
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 1,
          keyboardType: TextInputType.text,
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel")),
        ElevatedButton(onPressed: saveTodo, child: const Text("Save")),
      ],
    );
  }

  void saveTodo() async {
    Navigator.pop(context);

    if (_controller.text.trim().isEmpty) return;

    int index = ref.watch(totalRowsProvider);
    ref
        .read(todosControllerProvider.notifier)
        .insertTodo(Todo.fromText(_controller.text.trim(), index));

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Todo Added !')));
    }
  }
}
