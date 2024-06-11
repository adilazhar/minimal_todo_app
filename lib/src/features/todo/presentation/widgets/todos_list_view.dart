import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';

import 'todo_item.dart';

class TodosListView extends ConsumerWidget {
  const TodosListView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosList = ref.watch(todosControllerProvider);

    return todosList.isEmpty
        ? const Center(
            child: Text('Try Adding Some Todos !'),
          )
        : ListView.builder(
            itemBuilder: (context, index) => TodoItem(
              key: ValueKey(todosList[index].id),
              todo: todosList[index],
            ),
            itemCount: todosList.length,
          );
  }
}
