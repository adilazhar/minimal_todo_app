import 'dart:ui';

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

    Widget proxyDecor(Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(1, 3, animValue)!;
          final double scale = lerpDouble(1, 1.02, animValue)!;
          return Transform.scale(
            scale: scale,
            child: TodoItem(
              elevation: elevation,
              key: ValueKey(todosList[index].id),
              todo: todosList[index],
              ind: index,
            ),
          );
        },
        child: child,
      );
    }

    return todosList.isEmpty
        ? const Center(
            child: Text('Try Adding Some Todos !'),
          )
        : ReorderableListView.builder(
            itemCount: todosList.length,
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.all(10),
            proxyDecorator: proxyDecor,
            itemBuilder: (context, index) => TodoItem(
              key: ValueKey(todosList[index].id),
              todo: todosList[index],
              ind: index,
            ),
            onReorder: (oldIndex, newIndex) {
              if (oldIndex != newIndex - 1) {
                ref
                    .read(todosControllerProvider.notifier)
                    .reorderNote(oldIndex, newIndex);
              }
            },
          );
  }
}
