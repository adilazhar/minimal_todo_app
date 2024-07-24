import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_todo_app/src/features/todo/data/todos_repository.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/shared/database_helper.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late TodosRepository todosRepo;
  late Database db;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final databaseHelper = DatabaseHelper.instance;
    String path = inMemoryDatabasePath;
    db = await openDatabase(path,
        version: DatabaseHelper.databaseVersion,
        onCreate: databaseHelper.onCreate,
        onUpgrade: databaseHelper.onUpgrade);

    databaseHelper.testSetDatabase(db);
    todosRepo = TodosRepository(databaseHelper);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insert9Todos() async {
    List<Todo> todosList = [
      Todo(id: uuid.v4(), text: "Todo 1", todoIndex: 0),
      Todo(id: uuid.v4(), text: "Todo 2", todoIndex: 1),
      Todo(id: uuid.v4(), text: "Todo 3", todoIndex: 2),
      Todo(
          id: uuid.v4(),
          text: "Todo 4",
          todoIndex: 3,
          dueDateTime: DateTime(2025, 7, 24)),
      Todo(
          id: uuid.v4(),
          text: "Todo 5",
          todoIndex: 4,
          dueDateTime: DateTime(2025, 7, 25)),
      Todo(
          id: uuid.v4(),
          text: "Todo 6",
          todoIndex: 5,
          dueDateTime: DateTime(2025, 7, 26)),
      Todo(
        id: uuid.v4(),
        text: "Todo 7",
        todoIndex: 6,
        dueDateTime: DateTime(2025, 7, 27, 9, 30),
        isTimeSetByUser: true,
      ),
      Todo(
        id: uuid.v4(),
        text: "Todo 8",
        todoIndex: 7,
        dueDateTime: DateTime(2025, 7, 28, 14, 45),
        isTimeSetByUser: true,
      ),
      Todo(
        id: uuid.v4(),
        text: "Todo 9",
        todoIndex: 8,
        dueDateTime: DateTime(2025, 7, 29, 17, 15),
        isTimeSetByUser: true,
      ),
    ];
    for (int i = 0; i < todosList.length; i++) {
      await todosRepo.insertTodo(
        todosList[i],
      );
    }
  }

  group('getTodos', () {
    test('should return an empty list when no todos are present', () async {
      final todosList = await todosRepo.getTodos(SortingOption.manual);
      expect(todosList, isEmpty);
    });

    test('should return todos in order of todoIndex', () async {
      await insert9Todos();
      final todosList = await todosRepo.getTodos(SortingOption.manual);
      for (int i = 0; i < todosList.length; i++) {
        expect(todosList[i].todoIndex, i);
      }
    });

    test('should return todos in alphabetical order', () async {
      await insert9Todos();
      final todosList = await todosRepo.getTodos(SortingOption.alphaAsc);
      List<String> todoTexts = todosList.map((e) => e.text).toList();
      todoTexts.sort();
      for (int i = 0; i < todosList.length; i++) {
        expect(todosList[i].text, todoTexts[i]);
      }
    });

    test('should return todos in reverse alphabetical order', () async {
      await insert9Todos();
      final todosList = await todosRepo.getTodos(SortingOption.alphaDesc);
      List<String> todoTexts = todosList.map((e) => e.text).toList();
      todoTexts.sort((a, b) => b.compareTo(a));
      for (int i = 0; i < todosList.length; i++) {
        expect(todosList[i].text, todoTexts[i]);
      }
    });

    test('should return todos in increasing order of dueDateTime', () async {
      await insert9Todos();
      final todosList = await todosRepo.getTodos(SortingOption.duedateAsc);
      List<DateTime?> dueDateTimes =
          todosList.map((e) => e.dueDateTime).toList();
      dueDateTimes.sort((a, b) {
        if (a == null && b == null) {
          return 0;
        } else if (a == null) {
          return -1;
        } else if (b == null) {
          return 1;
        } else {
          return a.compareTo(b);
        }
      });
      for (int i = 0; i < todosList.length; i++) {
        expect(todosList[i].dueDateTime, dueDateTimes[i]);
      }
    });

    test('should return todos in decreasing order of dueDateTime', () async {
      await insert9Todos();
      final todosList = await todosRepo.getTodos(SortingOption.duedateDesc);
      List<DateTime?> dueDateTimes =
          todosList.map((e) => e.dueDateTime).toList();
      dueDateTimes.sort((a, b) {
        if (a == null && b == null) {
          return 0;
        } else if (a == null) {
          return -1;
        } else if (b == null) {
          return 1;
        } else {
          return b.compareTo(a);
        }
      });
      for (int i = 0; i < todosList.length; i++) {
        expect(todosList[i].dueDateTime, dueDateTimes[i]);
      }
    });
  });

  test('insertTodo should insert a todo', () async {
    await insert9Todos();
    final todosList = await todosRepo.getTodos(SortingOption.manual);
    expect(todosList.length, 9);
  });

  test('updateTodo should update a todo', () async {
    await insert9Todos();
    final todosList = await todosRepo.getTodos(SortingOption.manual);
    for (int i = 0; i < todosList.length; i++) {
      Todo updatedTodo = todosList[i].copyWith(
        text: "Updated Todo ${i + 1}",
        dueDateTime: DateTime(2025, 7, i + 1, i + 1, i + 1),
        isTimeSetByUser: true,
      );
      await todosRepo.updateTodo(updatedTodo);
    }
    final updatedTodosList = await todosRepo.getTodos(SortingOption.manual);
    for (int i = 0; i < updatedTodosList.length; i++) {
      expect(updatedTodosList[i].text, "Updated Todo ${i + 1}");
      expect(updatedTodosList[i].dueDateTime,
          DateTime(2025, 7, i + 1, i + 1, i + 1));
      expect(updatedTodosList[i].isTimeSetByUser, true);
    }
  });

  test('getRowCount should return the number of todos', () async {
    await insert9Todos();
    final count = await todosRepo.getRowCount();
    expect(count, 9);
  });

  group('deleteTodoSelection', () {
    test('should delete selected todo', () async {
      await insert9Todos();
      final todosList = await todosRepo.getTodos(SortingOption.manual);
      await todosRepo.deleteTodoSelection([todosList[0]]);
      final remainingTodos = await todosRepo.getTodos(SortingOption.manual);
      expect(remainingTodos.length, 8);
      for (int i = 0; i < remainingTodos.length; i++) {
        expect(remainingTodos[i].todoIndex, i);
      }
    });

    test('should delete selected todos', () async {
      await insert9Todos();
      final todosList = await todosRepo.getTodos(SortingOption.manual);
      await todosRepo.deleteTodoSelection([todosList[3], todosList[4]]);
      final remainingTodos = await todosRepo.getTodos(SortingOption.manual);
      expect(remainingTodos.length, 7);
      for (int i = 0; i < remainingTodos.length; i++) {
        expect(remainingTodos[i].todoIndex, i);
      }
    });
  });

  test('reorderNote should correctly reorder todos and update indexes',
      () async {
    await insert9Todos();

    final todosList = await todosRepo.getTodos(SortingOption.manual);

    Todo todoToMove = todosList[2];
    await todosRepo.reorderNote(2, 5, todoToMove.id);

    final reorderedTodosList = await todosRepo.getTodos(SortingOption.manual);

    expect(reorderedTodosList[5].id, todoToMove.id,
        reason: "Todo should be moved to index 5");
    for (int i = 0; i < reorderedTodosList.length; i++) {
      expect(reorderedTodosList[i].todoIndex, i);
    }
  });
}
