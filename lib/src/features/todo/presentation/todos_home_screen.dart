import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/features/todo/application/total_rows.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/selection_controller.dart';

import 'widgets/add_todo_dialog.dart';
import 'widgets/todos_list_view.dart';

class TodosHomeScreen extends ConsumerWidget {
  const TodosHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(totalRowsProvider);
    final selectedTodos = ref.watch(selectionControllerProvider.select(
      (value) => value.selectedTodos.length,
    ));
    return Scaffold(
      appBar: selectedTodos == 0
          ? AppBar(
              title: const Text('Todo List'),
              actions: [
                IconButton(
                    onPressed: () {
                      showAddTodoDialog(context);
                    },
                    icon: const Icon(Icons.add_rounded))
              ],
            )
          : AppBar(
              leading: IconButton(
                  onPressed: () {
                    ref.read(selectionControllerProvider.notifier).resetState();
                  },
                  icon: const Icon(Icons.arrow_back_rounded)),
              title: Text(selectedTodos.toString()),
              actions: [
                IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Todos Removed !')));
                      ref
                          .read(selectionControllerProvider.notifier)
                          .onDeleteButton();
                    },
                    icon: const Icon(Icons.delete_rounded)),
              ],
            ),
      body: const TodosListView(),
    );
  }

  void showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );
  }
}
