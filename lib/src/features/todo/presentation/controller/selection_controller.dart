import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'selection.dart';

part 'selection_controller.g.dart';

@riverpod
class SelectionController extends _$SelectionController {
  @override
  Selection build() {
    return Selection.initalState();
  }

  void toggleState() {
    state = state.copyWith(isSelectedState: !state.isSelectedState);
  }

  void toggleSelection(String id) {
    if (state.selectedTodos.contains(id)) {
      state = state.copyWith(
          selectedTodos: state.selectedTodos
              .where(
                (ti) => ti != id,
              )
              .toList());

      //Set The State to Initial State if there is no todo selected
      if (state.selectedTodos.isEmpty) {
        resetState();
      }
    } else {
      state = state.copyWith(selectedTodos: [...state.selectedTodos, id]);
    }
  }

  void clearSelectedTodosList() {
    state = state.copyWith(selectedTodos: []);
  }

  void resetState() {
    state = Selection.initalState();
  }

  void onDeleteButton() {
    final List<Todo> selectedTodos = [];
    for (var id in state.selectedTodos) {
      selectedTodos
          .add(ref.read(todosControllerProvider.notifier).getTodoById(id));
    }
    ref
        .read(todosControllerProvider.notifier)
        .deleteTodosSelection(selectedTodos);
    resetState();
  }
}
