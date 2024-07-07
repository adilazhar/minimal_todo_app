import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/features/todo/application/total_rows.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/selection_controller.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/widgets/todo_dialog.dart';
import 'package:minimal_todo_app/src/utils/setting/presentation/night_mode_button.dart';
import 'package:minimal_todo_app/src/utils/setting/presentation/sorting_order_selector_button.dart';

class AnimatedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AnimatedAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(totalRowsProvider);

    final selectedTodos = ref.watch(selectionControllerProvider.select(
      (value) => value.selectedTodos.length,
    ));
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, -1),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        child: AppBar(
          key: ValueKey<bool>(selectedTodos == 0),
          leading: selectedTodos == 0
              ? null
              : IconButton(
                  onPressed: () {
                    ref.read(selectionControllerProvider.notifier).resetState();
                  },
                  icon: const Icon(Icons.arrow_back_rounded)),
          title: selectedTodos == 0
              ? const Text('Todo List')
              : Text(selectedTodos.toString()),
          actions: selectedTodos == 0
              ? [
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: SortingOrderSelectorButton(),
                  ),
                  const NightModeButton(),
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: IconButton(
                        onPressed: () {
                          showAddTodoDialog(context);
                        },
                        icon: const Icon(Icons.add_rounded)),
                  )
                ]
              : [
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
        ));
  }

  void showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TodoDialog(
        isEditing: false,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
