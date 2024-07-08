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

  Future<void> updateTodo(Todo updatedTodo) async {
    await _todosRepository!.updateTodo(updatedTodo);
    List<Todo> newState = [...state.value!];

    if (_sortingOption == SortingOption.manual) {
      int index = newState.indexWhere((todo) => todo.id == updatedTodo.id);
      if (index != -1) {
        newState[index] = updatedTodo;
      }
    } else {
      newState.removeWhere((todo) => todo.id == updatedTodo.id);
      bool inserted = false;
      for (int i = 0; i < newState.length; i++) {
        if (_shouldInsertBefore(updatedTodo, newState[i])) {
          newState.insert(i, updatedTodo);
          inserted = true;
          break;
        }
      }
      if (!inserted) {
        newState.add(updatedTodo);
      }
    }

    state = AsyncData(newState);
  }

  bool _shouldInsertBefore(Todo updatedTodo, Todo currentTodo) {
    switch (_sortingOption) {
      case SortingOption.alphaAsc:
        return updatedTodo.text.compareTo(currentTodo.text) < 0;
      case SortingOption.alphaDesc:
        return updatedTodo.text.compareTo(currentTodo.text) > 0;
      case SortingOption.duedateAsc:
        return updatedTodo.dueDateTime != null &&
            currentTodo.dueDateTime != null &&
            updatedTodo.dueDateTime!.isBefore(currentTodo.dueDateTime!);
      case SortingOption.duedateDesc:
        return updatedTodo.dueDateTime != null &&
            currentTodo.dueDateTime != null &&
            updatedTodo.dueDateTime!.isAfter(currentTodo.dueDateTime!);
      default:
        return false;
    }
  }

  Future<void> deleteTodo(Todo todo) async {
    await _todosRepository!.deleteTodo(todo);
    ref.read(totalRowsProvider.notifier).decrementRows();

    List<Todo> newState = state.value!.where((t) => t.id != todo.id).toList();

    newState = _sortTodos(newState, _sortingOption);

    state = AsyncData(newState);
  }

  List<Todo> _sortTodos(List<Todo> todos, SortingOption sortingOption) {
    switch (sortingOption) {
      case SortingOption.manual:
        todos.sort((a, b) => a.todoIndex.compareTo(b.todoIndex));
        break;
      case SortingOption.alphaAsc:
        todos.sort((a, b) => a.text.compareTo(b.text));
        break;
      case SortingOption.alphaDesc:
        todos.sort((a, b) => b.text.compareTo(a.text));
        break;
      case SortingOption.duedateAsc:
        todos.sort((a, b) => (a.dueDateTime ?? DateTime(0))
            .compareTo(b.dueDateTime ?? DateTime(0)));
        break;
      case SortingOption.duedateDesc:
        todos.sort((a, b) => (b.dueDateTime ?? DateTime(0))
            .compareTo(a.dueDateTime ?? DateTime(0)));
        break;
    }
    return todos;
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
