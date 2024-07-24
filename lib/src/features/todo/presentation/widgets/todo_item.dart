import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/selection_controller.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/widgets/todo_dialog.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting.dart';
import 'package:minimal_todo_app/src/utils/setting/presentation/controller/app_setting_controller.dart';

class TodoItem extends ConsumerWidget {
  const TodoItem({
    super.key,
    required this.todo,
    required this.ind,
    this.elevation,
  });

  final Todo todo;
  final int ind;
  final double? elevation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectedState = ref.watch(selectionControllerProvider.select(
      (value) => value.isSelectedState,
    ));
    final isSelected = ref.watch(selectionControllerProvider.select(
      (value) => value.selectedTodos.contains(todo.id),
    ));
    final isManualSortingMode = ref.watch(appSettingControllerProvider
            .select((value) => value.value!.sortingOption)) ==
        SortingOption.manual;

    return Dismissible(
      key: key!,
      onDismissed: (_) => deleteTodo(ref, context),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Todo ?')
                .animate()
                .fadeIn(delay: 100.ms, duration: 150.ms)
                .slideY(begin: 0.5, duration: 150.ms),
            actions: [
              OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"))
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 150.ms)
                  .slideY(begin: 0.5, duration: 150.ms),
              ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Delete"))
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 150.ms)
                  .slideY(begin: 0.5, duration: 150.ms),
            ],
          ),
        );
      },
      child: GestureDetector(
        onDoubleTap: isSelectedState
            ? null
            : () => showDialog(
                  context: context,
                  builder: (context) => TodoDialog(
                    isEditing: true,
                    todo: todo,
                  ),
                ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: elevation,
          child: ListTile(
            enableFeedback: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            horizontalTitleGap: 10,
            selected: isSelected,
            focusColor: Theme.of(context).colorScheme.surface,
            selectedTileColor: Theme.of(context).primaryColor.withAlpha(100),
            onLongPress: () => toggleSelectionState(ref),
            onTap: () => isSelectedState ? toggleSelection(ref) : null,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: SizedBox(
              width: 30,
              height: double.infinity,
              child: isSelectedState
                  ? IgnorePointer(
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) {},
                      ),
                    )
                  : isManualSortingMode
                      ? ReorderableDragStartListener(
                          index: ind,
                          child: const Icon(Icons.drag_handle_rounded),
                        )
                      : const Icon(Icons.check),
            ),
            title: Text(
              todo.text,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: todo.dueDateTime != null
                ? SizedBox(
                    height: 20,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          if (todo.isTimeSetByUser)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const Gap(8),
                                  Text(
                                    todo.formattedTime,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          if (todo.isTimeSetByUser) const Gap(8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const Gap(8),
                                Text(
                                  todo.formattedDueDate,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void toggleSelectionState(WidgetRef ref) {
    ref.read(selectionControllerProvider.notifier).toggleState();
    toggleSelection(ref);
  }

  void toggleSelection(WidgetRef ref) {
    ref.read(selectionControllerProvider.notifier).toggleSelection(todo.id);
  }

  void deleteTodo(WidgetRef ref, BuildContext context) {
    ref.read(todosControllerProvider.notifier).deleteTodo(todo);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Todo Removed !')));
  }
}
