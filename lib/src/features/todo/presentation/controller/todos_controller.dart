import 'package:minimal_todo_app/src/features/todo/application/total_rows.dart';
import 'package:minimal_todo_app/src/features/todo/data/todos_repository.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todos_controller.g.dart';

@Riverpod(keepAlive: true)
class TodosController extends _$TodosController {
  late final TodosRepository _todosRepository;
  @override
  List<Todo> build() {
    _todosRepository = ref.watch(todosRepoProvider);
    ref.read(totalRowsProvider);
    loadTodos();
    return [];
  }

  Future<void> loadTodos() async {
    state = await _todosRepository.getTodos();
  }

  Future<void> insertTodo(Todo todo) async {
    await _todosRepository.insertTodo(todo);
    ref.read(totalRowsProvider.notifier).incrementRows();
    state = [...state, todo];
  }

  Future<void> updateTodo(Todo todo) async {
    await _todosRepository.updateTodo(todo);
    state = state.map((t) => t.id == todo.id ? todo : t).toList();
  }

  Future<void> deleteTodo(Todo todo) async {
    await _todosRepository.deleteTodo(todo);
    ref.read(totalRowsProvider.notifier).decrementRows();

    final List<Todo> filteredList = [];
    for (final t in state) {
      if (t.id == todo.id) continue;
      if (t.todoIndex < todo.todoIndex) {
        filteredList.add(t);
      } else {
        filteredList.add(t.copyWith(todoIndex: t.todoIndex - 1));
      }
    }
    state = filteredList;
  }
}
