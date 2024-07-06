import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_todo_app/src/features/todo/data/todos_repository.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/shared/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('TodosRepository Integration Tests', () {
    late TodosRepository todosRepository;
    late Database db;

    setUp(() async {
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
      final databaseHelper = DatabaseHelper.instance;
      String path = inMemoryDatabasePath;
      db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${DatabaseHelper.todoTable} (
              ${DatabaseHelper.columnTodoId} TEXT PRIMARY KEY,
              ${DatabaseHelper.columnTodoText} TEXT NOT NULL,
              ${DatabaseHelper.columnTodoIndex} INTEGER NOT NULL,
              ${DatabaseHelper.columnDueDateTime} TEXT
            )
          ''');
        },
      );

      databaseHelper.testSetDatabase(db);
      todosRepository = TodosRepository(databaseHelper);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> insertSevenTodos() async {
      // Insert 7 todos
      for (int i = 1; i <= 7; i++) {
        await todosRepository.insertTodo(Todo(
          id: '$i',
          text: 'Todo $i',
          todoIndex: i - 1,
          dueDateTime: DateTime(2025, 5, 8).add(Duration(days: i - 1)),
        ));
      }
    }

    test('Insert Todo', () async {
      final todo =
          Todo.fromText('Test Todo 1', 0, dueDateTime: DateTime(2025, 5, 8));
      await todosRepository.insertTodo(todo);

      final todos = await todosRepository.getTodos();

      expect(todos.length, 1);
      expect(todos.first.text, 'Test Todo 1');
      expect(todos.first.todoIndex, 0);
      expect(todos.first.dueDateTime, DateTime(2025, 5, 8));
    });

    test('Update Todo', () async {
      final todo =
          Todo.fromText('Test Todo', 0, dueDateTime: DateTime(2025, 5, 8));
      await todosRepository.insertTodo(todo);

      final todosBeforeUpdate = await todosRepository.getTodos();
      final updatedTodo = todosBeforeUpdate.first
          .copyWith(text: 'Updated Todo', dueDateTime: DateTime(2025, 5, 9));
      await todosRepository.updateTodo(updatedTodo);

      final todosAfterUpdate = await todosRepository.getTodos();

      expect(todosAfterUpdate.length, 1);
      expect(todosAfterUpdate.first.text, 'Updated Todo');
      expect(todosAfterUpdate.first.todoIndex, 0);
      expect(todosAfterUpdate.first.dueDateTime, DateTime(2025, 5, 9));
    });

    test('Get Row Count', () async {
      // Insert 3 todos
      await todosRepository.insertTodo(const Todo(
        id: '1',
        text: 'Todo 1',
        todoIndex: 0,
      ));
      await todosRepository.insertTodo(const Todo(
        id: '2',
        text: 'Todo 2',
        todoIndex: 1,
      ));
      await todosRepository.insertTodo(const Todo(
        id: '3',
        text: 'Todo 3',
        todoIndex: 2,
      ));

      // Get the row count
      final int rowCount = await todosRepository.getRowCount();

      // Verify the row count is 3
      expect(rowCount, 3);
    });

    test('Delete Single Todo', () async {
      // Insert 3 todos
      await todosRepository.insertTodo(const Todo(
        id: '1',
        text: 'Todo 1',
        todoIndex: 0,
      ));
      await todosRepository.insertTodo(const Todo(
        id: '2',
        text: 'Todo 2',
        todoIndex: 1,
      ));
      await todosRepository.insertTodo(const Todo(
        id: '3',
        text: 'Todo 3',
        todoIndex: 2,
      ));

      // Delete a single todo
      await todosRepository.deleteTodo(const Todo(
        id: '2',
        text: 'Todo 2',
        todoIndex: 1,
      ));

      // Get the remaining todos
      final todos = await todosRepository.getTodos();

      // Verify the todo is deleted and indices are updated
      expect(todos.length, 2);
      expect(todos[0].id, '1');
      expect(todos[0].todoIndex, 0);
      expect(todos[1].id, '3');
      expect(todos[1].todoIndex, 1);
    });

    test('Delete Multiple Todos  From Middle', () async {
      // Insert 4 todos
      await todosRepository.insertTodo(const Todo(
        id: '1',
        text: 'Todo 1',
        todoIndex: 0,
      ));
      await todosRepository.insertTodo(const Todo(
        id: '2',
        text: 'Todo 2',
        todoIndex: 1,
      ));
      await todosRepository.insertTodo(const Todo(
        id: '3',
        text: 'Todo 3',
        todoIndex: 2,
      ));
      await todosRepository.insertTodo(const Todo(
        id: '4',
        text: 'Todo 4',
        todoIndex: 3,
      ));

      // Delete multiple todos
      await todosRepository.deleteTodoSelection([
        const Todo(
          id: '2',
          text: 'Todo 2',
          todoIndex: 1,
        ),
        const Todo(
          id: '3',
          text: 'Todo 3',
          todoIndex: 2,
        ),
      ]);

      // Get the remaining todos
      final todos = await todosRepository.getTodos();

      // Verify the todos are deleted and indices are updated
      expect(todos.length, 2);
      expect(todos[0].id, '1');
      expect(todos[0].todoIndex, 0);
      expect(todos[1].id, '4');
      expect(todos[1].todoIndex, 1);
    });

    test('Delete First 3 Todos', () async {
      await insertSevenTodos();

      // Delete first 3 todos
      await todosRepository.deleteTodoSelection([
        const Todo(
          id: '1',
          text: 'Todo 1',
          todoIndex: 0,
        ),
        const Todo(
          id: '2',
          text: 'Todo 2',
          todoIndex: 1,
        ),
        const Todo(
          id: '3',
          text: 'Todo 3',
          todoIndex: 2,
        ),
      ]);

      // Get the remaining todos
      final todos = await todosRepository.getTodos();

      // Verify the todos are deleted and indices are updated
      expect(todos.length, 4);
      for (int i = 0; i < todos.length; i++) {
        expect(todos[i].id, '${i + 4}');
        expect(todos[i].todoIndex, i);
        expect(todos[i].dueDateTime, DateTime(2025, 5, 11 + i));
      }
    });

    test('Delete 3 Todos before the Last One', () async {
      await insertSevenTodos();

      // Delete 3 todos before the last one
      await todosRepository.deleteTodoSelection([
        const Todo(
          id: '4',
          text: 'Todo 4',
          todoIndex: 3,
        ),
        const Todo(
          id: '5',
          text: 'Todo 5',
          todoIndex: 4,
        ),
        const Todo(
          id: '6',
          text: 'Todo 6',
          todoIndex: 5,
        ),
      ]);

      // Get the remaining todos
      final todos = await todosRepository.getTodos();

      // Verify the todos are deleted and indices are updated
      expect(todos.length, 4);
      expect(todos[0].id, '1');
      expect(todos[0].todoIndex, 0);
      expect(todos[0].dueDateTime, DateTime(2025, 5, 8));
      expect(todos[1].id, '2');
      expect(todos[1].todoIndex, 1);
      expect(todos[1].dueDateTime, DateTime(2025, 5, 9));
      expect(todos[2].id, '3');
      expect(todos[2].todoIndex, 2);
      expect(todos[2].dueDateTime, DateTime(2025, 5, 10));
      expect(todos[3].id, '7');
      expect(todos[3].todoIndex, 3);
      expect(todos[3].dueDateTime, DateTime(2025, 5, 14));
    });

    test('Delete 2nd, 4th, and 6th Todos', () async {
      await insertSevenTodos();

      // Delete 2nd, 4th, and 6th todos
      await todosRepository.deleteTodoSelection([
        const Todo(
          id: '2',
          text: 'Todo 2',
          todoIndex: 1,
        ),
        const Todo(
          id: '4',
          text: 'Todo 4',
          todoIndex: 3,
        ),
        const Todo(
          id: '6',
          text: 'Todo 6',
          todoIndex: 5,
        ),
      ]);

      // Get the remaining todos
      final todos = await todosRepository.getTodos();

      // Verify the todos are deleted and indices are updated
      expect(todos.length, 4);
      expect(todos[0].id, '1');
      expect(todos[0].todoIndex, 0);
      expect(todos[0].dueDateTime, DateTime(2025, 5, 8));
      expect(todos[1].id, '3');
      expect(todos[1].todoIndex, 1);
      expect(todos[1].dueDateTime, DateTime(2025, 5, 10));
      expect(todos[2].id, '5');
      expect(todos[2].todoIndex, 2);
      expect(todos[2].dueDateTime, DateTime(2025, 5, 12));
      expect(todos[3].id, '7');
      expect(todos[3].todoIndex, 3);
      expect(todos[3].dueDateTime, DateTime(2025, 5, 14));
    });

    test('Reorder Note from lower to higher index', () async {
      await insertSevenTodos();

      // Reorder note with id '3' from index 2 to index 5
      await todosRepository.reorderNote(2, 5, '3');

      // Get the reordered todos
      final todos = await todosRepository.getTodos();

      // Verify the order of the todos
      expect(todos.length, 7);
      expect(todos[0].id, '1');
      expect(todos[0].todoIndex, 0);
      expect(todos[1].id, '2');
      expect(todos[1].todoIndex, 1);
      expect(todos[2].id, '4');
      expect(todos[2].todoIndex, 2);
      expect(todos[3].id, '5');
      expect(todos[3].todoIndex, 3);
      expect(todos[4].id, '6');
      expect(todos[4].todoIndex, 4);
      expect(todos[5].id, '3');
      expect(todos[5].todoIndex, 5);
      expect(todos[6].id, '7');
      expect(todos[6].todoIndex, 6);
    });

    test('Reorder Note from higher to lower index', () async {
      await insertSevenTodos();

      // Reorder note with id '6' from index 5 to index 2
      await todosRepository.reorderNote(5, 2, '6');

      // Get the reordered todos
      final todos = await todosRepository.getTodos();

      // Verify the order of the todos
      expect(todos.length, 7);
      expect(todos[0].id, '1');
      expect(todos[0].todoIndex, 0);
      expect(todos[1].id, '2');
      expect(todos[1].todoIndex, 1);
      expect(todos[2].id, '6');
      expect(todos[2].todoIndex, 2);
      expect(todos[3].id, '3');
      expect(todos[3].todoIndex, 3);
      expect(todos[4].id, '4');
      expect(todos[4].todoIndex, 4);
      expect(todos[5].id, '5');
      expect(todos[5].todoIndex, 5);
      expect(todos[6].id, '7');
      expect(todos[6].todoIndex, 6);
    });

    test('Reorder Note from index 0 to index 2', () async {
      await insertSevenTodos();

      // Reorder note with id '1' from index 0 to index 2
      await todosRepository.reorderNote(0, 2, '1');

      // Get the reordered todos
      final todos = await todosRepository.getTodos();

      // Verify the order of the todos
      expect(todos.length, 7);
      expect(todos[0].id, '2');
      expect(todos[0].todoIndex, 0);
      expect(todos[1].id, '3');
      expect(todos[1].todoIndex, 1);
      expect(todos[2].id, '1');
      expect(todos[2].todoIndex, 2);
      expect(todos[3].id, '4');
      expect(todos[3].todoIndex, 3);
      expect(todos[4].id, '5');
      expect(todos[4].todoIndex, 4);
      expect(todos[5].id, '6');
      expect(todos[5].todoIndex, 5);
      expect(todos[6].id, '7');
      expect(todos[6].todoIndex, 6);
    });

    test('Move first todo to last position', () async {
      await insertSevenTodos();

      // Reorder note with id '1' from index 0 to index 6 (last position)
      await todosRepository.reorderNote(0, 6, '1');

      // Get the reordered todos
      final todos = await todosRepository.getTodos();

      // Verify the order of the todos
      expect(todos.length, 7);
      expect(todos[0].id, '2');
      expect(todos[0].todoIndex, 0);
      expect(todos[1].id, '3');
      expect(todos[1].todoIndex, 1);
      expect(todos[2].id, '4');
      expect(todos[2].todoIndex, 2);
      expect(todos[3].id, '5');
      expect(todos[3].todoIndex, 3);
      expect(todos[4].id, '6');
      expect(todos[4].todoIndex, 4);
      expect(todos[5].id, '7');
      expect(todos[5].todoIndex, 5);
      expect(todos[6].id, '1');
      expect(todos[6].todoIndex, 6);
    });

    test('Move last todo to first position', () async {
      await insertSevenTodos();

      // Reorder note with id '7' from index 6 to index 0 (first position)
      await todosRepository.reorderNote(6, 0, '7');

      // Get the reordered todos
      final todos = await todosRepository.getTodos();

      // Verify the order of the todos
      expect(todos.length, 7);
      expect(todos[0].id, '7');
      expect(todos[0].todoIndex, 0);
      expect(todos[1].id, '1');
      expect(todos[1].todoIndex, 1);
      expect(todos[2].id, '2');
      expect(todos[2].todoIndex, 2);
      expect(todos[3].id, '3');
      expect(todos[3].todoIndex, 3);
      expect(todos[4].id, '4');
      expect(todos[4].todoIndex, 4);
      expect(todos[5].id, '5');
      expect(todos[5].todoIndex, 5);
      expect(todos[6].id, '6');
      expect(todos[6].todoIndex, 6);
    });
  });
}
