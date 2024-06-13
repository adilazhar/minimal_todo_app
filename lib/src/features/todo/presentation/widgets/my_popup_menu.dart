import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';

class MyPopupMenu extends ConsumerWidget {
  const MyPopupMenu({
    super.key,
    required this.todo,
    required this.startEdit,
  });

  final Todo todo;
  final void Function() startEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        switch (result) {
          case 'Edit':
            startEdit();
            break;
          case 'Copy':
            Clipboard.setData(ClipboardData(text: todo.text)).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard !')),
              );
            });
            break;
          case 'Remove':
            {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title:
                      const Text('Are You Sure You Want To Delete This Todo ?'),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel")),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref
                              .read(todosControllerProvider.notifier)
                              .deleteTodo(todo);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Todo Removed !')));
                        },
                        child: const Text("Remove")),
                  ],
                ),
              );
            }
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'Copy',
          child: Text('Copy'),
        ),
        const PopupMenuItem<String>(
          value: 'Remove',
          child: Text('Remove'),
        ),
      ],
    );
  }
}
