import 'package:flutter/material.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';

import 'my_popup_menu.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
  });

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        // leading: const Icon(Icons.check),
        leading: Text(todo.todoIndex.toString()),
        title: Text(todo.text),
        trailing: MyPopupMenu(
          todo: todo,
        ),
      ),
    );
  }
}
