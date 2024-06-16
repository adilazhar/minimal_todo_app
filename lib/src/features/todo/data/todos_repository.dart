import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/shared/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'todos_repository.g.dart';

@Riverpod(keepAlive: true)
TodosRepository todosRepo(TodosRepoRef ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return TodosRepository(dbHelper);
}

class TodosRepository {
  final DatabaseHelper _databaseHelper;

  TodosRepository(this._databaseHelper);

  Future<List<Todo>> getTodos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.todoTable,
      orderBy: '${DatabaseHelper.columnTodoIndex} ASC',
    );
    return maps.map((e) => Todo.fromMap(e)).toList();
  }

  Future<void> insertTodo(Todo todo) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseHelper.todoTable,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.todoTable,
      todo.toMap(),
      where: '${DatabaseHelper.columnTodoId} = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> getRowCount() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.todoTable}',
    );
    return result.first['count'] as int;
  }

  Future<void> deleteTodo(Todo todo) async {
    await deleteTodoSelection([todo]);
  }

  Future<void> deleteTodoSelection(List<Todo> todosList) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // First, delete the selected todos
      for (final todo in todosList) {
        await txn.delete(
          DatabaseHelper.todoTable,
          where: '${DatabaseHelper.columnTodoId} = ?',
          whereArgs: [todo.id],
        );
      }

      // Then, fetch the remaining todos and update their indices
      final List<Map<String, dynamic>> resultSet =
          await txn.query(DatabaseHelper.todoTable);
      // Create a new modifiable list from the result set
      final List<Map<String, dynamic>> remainingTodos =
          List<Map<String, dynamic>>.from(resultSet);
      // Now you can sort this new list
      remainingTodos.sort((a, b) => a[DatabaseHelper.columnTodoIndex]
          .compareTo(b[DatabaseHelper.columnTodoIndex]));

      for (int i = 0; i < remainingTodos.length; i++) {
        await txn.update(
          DatabaseHelper.todoTable,
          {DatabaseHelper.columnTodoIndex: i},
          where: '${DatabaseHelper.columnTodoId} = ?',
          whereArgs: [remainingTodos[i][DatabaseHelper.columnTodoId]],
        );
      }
    });
  }

  Future<void> reorderNote(int oldIndex, int newIndex, String id) async {
    final db = await _databaseHelper.database;

    if (oldIndex < newIndex) {
      await db.rawUpdate(
        'UPDATE ${DatabaseHelper.todoTable} SET ${DatabaseHelper.columnTodoIndex} = ${DatabaseHelper.columnTodoIndex} - 1 WHERE ${DatabaseHelper.columnTodoIndex} > ? AND ${DatabaseHelper.columnTodoIndex} <= ?',
        [oldIndex, newIndex],
      );
    } else {
      await db.rawUpdate(
        'UPDATE ${DatabaseHelper.todoTable} SET ${DatabaseHelper.columnTodoIndex} = ${DatabaseHelper.columnTodoIndex} + 1 WHERE ${DatabaseHelper.columnTodoIndex} >= ? AND ${DatabaseHelper.columnTodoIndex} < ?',
        [newIndex, oldIndex],
      );
    }

    await db.update(
      DatabaseHelper.todoTable,
      {DatabaseHelper.columnTodoIndex: newIndex},
      where: '${DatabaseHelper.columnTodoId} = ?',
      whereArgs: [id],
    );
  }
}
