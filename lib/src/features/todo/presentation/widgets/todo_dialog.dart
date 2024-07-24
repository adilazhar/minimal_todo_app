import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:minimal_todo_app/src/features/todo/application/total_rows.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';
import 'package:intl/intl.dart';

class TodoDialog extends ConsumerStatefulWidget {
  const TodoDialog({
    required this.isEditing,
    this.todo,
    super.key,
  });

  final bool isEditing;
  final Todo? todo;

  @override
  ConsumerState<TodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<TodoDialog>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _textFieldFocusNode = FocusNode();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.isEditing) {
      _controller.text = widget.todo!.text;
      if (widget.todo?.dueDateTime != null) {
        selectedDate = widget.todo!.dueDateTime!;
        if (widget.todo!.isTimeSetByUser) {
          selectedTime = TimeOfDay.fromDateTime(widget.todo!.dueDateTime!);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Update Todo :' : 'Add Todo :')
          .animate(controller: _animationController)
          .fadeIn(delay: 100.ms, duration: 150.ms)
          .slideY(begin: 0.5, duration: 150.ms),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              focusNode: _textFieldFocusNode,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(labelText: 'Task'),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
            ),
            const Gap(16),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                  _textFieldFocusNode.unfocus();
                }
              },
              child: ListTile(
                enabled: selectedDate != null,
                tileColor: Theme.of(context).colorScheme.primaryContainer,
                textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                leading: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: selectedDate == null
                    ? const Text('Select Date')
                    : Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate!),
                        style: const TextStyle(fontSize: 12),
                      ),
                trailing: selectedDate == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            selectedTime = null;
                            selectedDate = null;
                          });
                        },
                      ),
              ),
            ),
            const Gap(16),
            ListTile(
              enabled: selectedDate != null,
              tileColor: Theme.of(context).colorScheme.primaryContainer,
              textColor: Theme.of(context).colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.access_time),
              title: selectedTime == null
                  ? const Text('Select Time')
                  : Text(
                      selectedTime!.format(context),
                      style: const TextStyle(fontSize: 12),
                    ),
              trailing: selectedTime == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          selectedTime = null;
                        });
                      },
                    ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
            ),
          ],
        ),
      )
          .animate(controller: _animationController)
          .fadeIn(delay: 200.ms, duration: 150.ms)
          .slideY(begin: 0.5, duration: 150.ms),
      actions: [
        OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"))
            .animate(controller: _animationController)
            .fadeIn(delay: 450.ms, duration: 150.ms)
            .slideY(begin: 0.5, duration: 150.ms),
        ElevatedButton(onPressed: saveTodo, child: const Text("Save"))
            .animate(controller: _animationController)
            .fadeIn(delay: 450.ms, duration: 150.ms)
            .slideY(begin: 0.5, duration: 150.ms),
      ],
    );
  }

  DateTime? getMergedDateTime() {
    if (selectedDate == null) return null;
    final date = selectedDate!;
    final time = selectedTime ?? const TimeOfDay(hour: 0, minute: 0);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void saveTodo() async {
    Navigator.of(context).pop();
    if (_controller.text.trim().isEmpty) return;

    final dateTime = getMergedDateTime();

    widget.isEditing
        ? ref.read(todosControllerProvider.notifier).updateTodo(widget.todo!
            .copyWith(
                text: _controller.text.trim(),
                dueDateTime: dateTime,
                isTimeSetByUser: selectedTime != null))
        : {
            ref.read(todosControllerProvider.notifier).insertTodo(Todo.fromText(
                _controller.text.trim(), ref.watch(totalRowsProvider),
                dueDateTime: dateTime, isTimeSetByUser: selectedTime != null))
          };

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.isEditing ? 'Todo Updated' : 'Todo Added !')));
    }
  }
}
