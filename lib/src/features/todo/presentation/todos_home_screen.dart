import 'package:flutter/material.dart';

import 'widgets/add_todo_dialog.dart';
import 'widgets/todos_list_view.dart';

class TodosHomeScreen extends StatelessWidget {
  const TodosHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTodoDialog(context);
        },
        child: const Icon(Icons.add_rounded),
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
