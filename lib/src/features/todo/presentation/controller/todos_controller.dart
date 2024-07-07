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
    if (_sortingOption == SortingOption.manual) {
      state = AsyncData([...state.value!, todo]);
    } else {
      final List<Todo> newState = [...state.value!];
      bool inserted = false;
      for (int i = 0; i < newState.length; i++) {
        final t = newState[i];
        bool shouldInsert = false;
        if (_sortingOption == SortingOption.alphaAsc &&
            todo.text.compareTo(t.text) < 0) {
          shouldInsert = true;
        } else if (_sortingOption == SortingOption.alphaDesc &&
            todo.text.compareTo(t.text) > 0) {
          shouldInsert = true;
        } else if (_sortingOption == SortingOption.duedateAsc &&
            todo.dueDateTime != null &&
            t.dueDateTime != null &&
            todo.dueDateTime!.isBefore(t.dueDateTime!)) {
          shouldInsert = true;
        } else if (_sortingOption == SortingOption.duedateDesc &&
            todo.dueDateTime != null &&
            t.dueDateTime != null &&
            todo.dueDateTime!.isAfter(t.dueDateTime!)) {
          shouldInsert = true;
        }
        if (shouldInsert) {
          newState.insert(i, todo);
          inserted = true;
          break;
        }
      }
      if (!inserted) {
        newState.add(todo);
      }
      state = AsyncData(newState);
    }
  }

  // Todo:Update The Remaining Methods To Also Take Into Account The Sorting Option

  Future<void> updateTodo(Todo todo) async {
    await _todosRepository!.updateTodo(todo);
    state =
        AsyncData(state.value!.map((t) => t.id == todo.id ? todo : t).toList());
  }

  Future<void> deleteTodo(Todo todo) async {
    await _todosRepository!.deleteTodo(todo);
    ref.read(totalRowsProvider.notifier).decrementRows();

    final List<Todo> filteredList = [];
    for (final t in state.value!) {
      if (t.id == todo.id) continue;
      if (t.todoIndex < todo.todoIndex) {
        filteredList.add(t);
      } else {
        filteredList.add(t.copyWith(todoIndex: t.todoIndex - 1));
      }
    }
    state = AsyncData(filteredList);
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

    // Update the todoIndex property for each Todo
    for (int i = 0; i < newState.length; i++) {
      newState[i] = newState[i].copyWith(todoIndex: i);
    }

    // Set the state with the updated todoIndex properties
    state = AsyncData(newState);

    await _todosRepository!.reorderNote(oldIndex, newIndex, item.id);
  }
}
