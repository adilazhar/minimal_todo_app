import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/features/todo/application/total_rows.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';

class AddTodoDialog extends ConsumerStatefulWidget {
  const AddTodoDialog({
    super.key,
  });

  @override
  ConsumerState<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<AddTodoDialog>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();

  late final AnimationController _animationController;

  void _onDialogDismiss() async {
    _animationController.reverse();
    await Future.delayed(const Duration(milliseconds: 600));
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => _onDialogDismiss(),
      child: AlertDialog(
        title: const Text('Add Todo :')
            .animate(controller: _animationController)
            .fadeIn(delay: 100.ms, duration: 150.ms)
            .slideY(begin: 0.5, duration: 150.ms),
        content: SizedBox(
          width: 300,
          child: TextField(
            controller: _controller,
            autofocus: true,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        )
            .animate(controller: _animationController)
            .fadeIn(delay: 200.ms, duration: 150.ms)
            .slideY(begin: 0.5, duration: 150.ms),
        actions: [
          OutlinedButton(
                  onPressed: _onDialogDismiss, child: const Text("Cancel"))
              .animate(controller: _animationController)
              .fadeIn(delay: 450.ms, duration: 150.ms)
              .slideY(begin: 0.5, duration: 150.ms),
          ElevatedButton(onPressed: saveTodo, child: const Text("Save"))
              .animate(controller: _animationController)
              .fadeIn(delay: 450.ms, duration: 150.ms)
              .slideY(begin: 0.5, duration: 150.ms),
        ],
      ).animate(controller: _animationController).addEffects(
        [
          FadeEffect(
            duration: 500.ms,
          ),
          MoveEffect(
            duration: 500.ms,
            begin: const Offset(0, 50),
            curve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  void saveTodo() async {
    Navigator.of(context).pop();
    if (_controller.text.trim().isEmpty) return;

    int index = ref.watch(totalRowsProvider);
    ref
        .read(todosControllerProvider.notifier)
        .insertTodo(Todo.fromText(_controller.text.trim(), index));

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Todo Added !')));
    }
  }
}
