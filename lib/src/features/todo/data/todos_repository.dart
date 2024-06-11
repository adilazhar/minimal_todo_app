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
    final db = await _databaseHelper.database;

    await db.rawUpdate('''
      UPDATE ${DatabaseHelper.todoTable}
      SET ${DatabaseHelper.columnTodoIndex} = ${DatabaseHelper.columnTodoIndex} - 1
      WHERE ${DatabaseHelper.columnTodoIndex} > ?
    ''', [todo.todoIndex]);

    await db.delete(
      DatabaseHelper.todoTable,
      where: '${DatabaseHelper.columnTodoId} = ?',
      whereArgs: [todo.id],
    );
  }
}
