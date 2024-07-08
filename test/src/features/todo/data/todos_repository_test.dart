import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_todo_app/src/features/todo/data/todos_repository.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/shared/database_helper.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('TodosRepository Integration Tests', () {
    late TodosRepository todosRepository;
    late Database db;

    setUp(() async {
      sqfliteFfiInit();

      databaseFactory = databaseFactoryFfi;

      final databaseHelper = DatabaseHelper.instance;

      db = await openDatabase(inMemoryDatabasePath, version: 2);

      databaseHelper.testSetDatabase(db);

      todosRepository = TodosRepository(databaseHelper);
    });

    // write function to insert some test todos into the database, each todo has one day as increment in due date
    Future<void> insertTestTodos() async {
      final todos = [
        Todo.fromText('Todo 1', 1,
            dueDateTime: DateTime.now().add(const Duration(days: 1))),
        Todo.fromText('Todo 2', 2,
            dueDateTime: DateTime.now().add(const Duration(days: 2))),
        Todo.fromText('Todo 3', 3,
            dueDateTime: DateTime.now().add(const Duration(days: 3))),
      ];

      for (final todo in todos) {
        await todosRepository.insertTodo(todo);
      }
    }

    setUp(() async {
      sqfliteFfiInit();

      databaseFactory = databaseFactoryFfi;

      final databaseHelper = DatabaseHelper.instance;

      db = await openDatabase(inMemoryDatabasePath, version: 2);

      databaseHelper.testSetDatabase(db);

      todosRepository = TodosRepository(databaseHelper);

      await insertTestTodos();
    });

    tearDown(() async {
      await db.close();
    });
  });
}
