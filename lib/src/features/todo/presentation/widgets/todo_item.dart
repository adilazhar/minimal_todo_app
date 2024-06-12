import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';

import 'my_popup_menu.dart';

class TodoItem extends ConsumerStatefulWidget {
  const TodoItem({
    super.key,
    required this.todo,
  });

  final Todo todo;

  @override
  ConsumerState<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends ConsumerState<TodoItem> {
  final _controller = TextEditingController();
  bool isEditing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(widget.todo.todoIndex.toString()),
        title: TextField(
          controller: _controller,
          maxLines: null,
          readOnly: !isEditing,
          focusNode: _focusNode,
          ignorePointers: !isEditing,
          decoration: const InputDecoration.collapsed(hintText: ""),
          onTapOutside: (event) => endEditing(),
          onEditingComplete: () => endEditing(),
        ),
        trailing: MyPopupMenu(
          todo: widget.todo,
          startEdit: startEditing,
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
}
