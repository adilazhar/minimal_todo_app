import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:minimal_todo_app/src/features/todo/application/total_rows.dart';
import 'package:minimal_todo_app/src/features/todo/data/todos_repository.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting.dart';
import 'package:minimal_todo_app/src/utils/setting/presentation/controller/app_setting_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todos_controller.g.dart';

@Riverpod(keepAlive: true)
class TodosController extends _$TodosController {
  TodosRepository? _todosRepository;
  late SortingOption _sortingOption;
  bool _isFirstBuild = true;

  @override
  FutureOr<List<Todo>> build() async {
    _todosRepository ??= ref.watch(todosRepoProvider);
    _sortingOption = ref.watch(appSettingControllerProvider
        .select((value) => value.value!.sortingOption));

    final todosList = await _todosRepository!.getTodos(_sortingOption);
    if (_isFirstBuild) {
      _isFirstBuild = false;
      Future.microtask(
        () {
          FlutterNativeSplash.remove();
        },
      );
    }
    return todosList;
  }

  Todo getTodoById(String id) {
    return state.value!.firstWhere(
      (element) => element.id == id,
    );
  }

  Future<void> insertTodo(Todo todo) async {
    await _todosRepository!.insertTodo(todo);
    ref.read(totalRowsProvider.notifier).incrementRows();

    final List<Todo> updatedTodos =
        await _todosRepository!.getTodos(_sortingOption);
    state = AsyncData(updatedTodos);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    await _todosRepository!.updateTodo(updatedTodo);

    final List<Todo> updatedTodos =
        await _todosRepository!.getTodos(_sortingOption);
    state = AsyncData(updatedTodos);
  }

  Future<void> deleteTodo(Todo todo) async {
    await _todosRepository!.deleteTodo(todo);
    ref.read(totalRowsProvider.notifier).decrementRows();

    final List<Todo> updatedTodos =
        await _todosRepository!.getTodos(_sortingOption);
    state = AsyncData(updatedTodos);
  }

  Future<void> deleteTodosSelection(List<Todo> todosList) async {
    for (final todo in todosList) {
      await deleteTodo(todo);
    }
  }

  Future<void> reorderNote(int oldIndex, int newIndex) async {
    List<Todo> newState = List.from(state.value!);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = newState.removeAt(oldIndex);
    newState.insert(newIndex, item);

    for (int i = 0; i < newState.length; i++) {
      newState[i] = newState[i].copyWith(todoIndex: i);
    }

    state = AsyncData(newState);

    await _todosRepository!.reorderNote(oldIndex, newIndex, item.id);
  }
}
