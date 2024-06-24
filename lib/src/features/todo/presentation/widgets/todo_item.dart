import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/selection_controller.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';

import 'my_popup_menu.dart';

class TodoItem extends ConsumerStatefulWidget {
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
  ConsumerState<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends ConsumerState<TodoItem> {
  final _controller = TextEditingController();
  bool isEditing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final isSelectedState = ref.watch(selectionControllerProvider.select(
      (value) => value.isSelectedState,
    ));
    final isSelected = ref.watch(selectionControllerProvider.select(
      (value) => value.selectedTodos.contains(widget.todo.id),
    ));
    return Dismissible(
      key: widget.key!,
      onDismissed: (_) {
        ref.read(todosControllerProvider.notifier).deleteTodo(widget.todo);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Todo Removed !')));
      },
      child: GestureDetector(
        onDoubleTap: isSelectedState ? null : () => startEditing(),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: widget.elevation,
          child: ListTile(
            selected: isSelected,
            focusColor: Theme.of(context).colorScheme.surface,
            selectedTileColor: Theme.of(context).primaryColor.withAlpha(100),
            onLongPress: () => toggleSelectionState(),
            onTap: () => isSelectedState ? toggleSelection() : null,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: SizedBox(
              width: 20,
              child: isSelectedState
                  ? IgnorePointer(
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) {},
                      ),
                    )
                  : ReorderableDragStartListener(
                      index: widget.ind,
                      child: const Icon(Icons.drag_handle_rounded),
                    ),
            ),
            title: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  border: InputBorder.none,
                ),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                readOnly: !isEditing,
                focusNode: _focusNode,
                ignorePointers: !isEditing,
                decoration: const InputDecoration.collapsed(hintText: ""),
                onTapOutside: (event) => endEditing(),
                onEditingComplete: () => endEditing(),
              ),
            ),
            trailing: Visibility(
              visible: !isSelectedState,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: MyPopupMenu(
                todo: widget.todo,
                startEdit: startEditing,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _controller.text = widget.todo.text;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void startEditing() {
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    setState(() {
      isEditing = true;
    });
    _focusNode.requestFocus();
  }

  void endEditing() {
    if (!isEditing) return;

    String trimmedText = _controller.text.trim();
    _controller.text = trimmedText;

    _focusNode.unfocus();
    ref
        .read(todosControllerProvider.notifier)
        .updateTodo(widget.todo.copyWith(text: _controller.text));
    setState(() {
      isEditing = false;
    });
  }

  void toggleSelectionState() {
    ref.read(selectionControllerProvider.notifier).toggleState();
    toggleSelection();
  }

  void toggleSelection() {
    ref
        .read(selectionControllerProvider.notifier)
        .toggleSelection(widget.todo.id);
  }
}
