import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_todo_app/src/features/todo/data/todos_repository.dart';
import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTodo extends Fake implements Todo {}

// a generic Listener class, used to keep track of when a provider notifies its listeners
class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTodo());
  });

  late ProviderContainer container;
  late MockTodosRepository mockTodosRepository;

  ProviderContainer createContainer({
    ProviderContainer? parent,
    List<Override> overrides = const [],
    List<ProviderObserver>? observers,
  }) {
    // Create a ProviderContainer, and optionally allow specifying parameters.
    final container = ProviderContainer(
      parent: parent,
      overrides: overrides,
      observers: observers,
    );

    // When the test ends, dispose the container.
    addTearDown(container.dispose);

    return container;
  }

  setUp(() {
    mockTodosRepository = MockTodosRepository();
    when(() => mockTodosRepository.getTodos()).thenAnswer(
      (_) => Future.value(const [
        Todo(id: '1', text: 'Test Todo 1', todoIndex: 0),
        Todo(id: '2', text: 'Test Todo 2', todoIndex: 1),
        Todo(id: '3', text: 'Test Todo 3', todoIndex: 2),
        Todo(id: '4', text: 'Test Todo 4', todoIndex: 3),
      ]),
    );

    when(() => mockTodosRepository.getRowCount()).thenAnswer(
      (_) => Future.value(4),
    );

    when(() => mockTodosRepository.insertTodo(any()))
        .thenAnswer((_) async => Future.value());

    when(() => mockTodosRepository.updateTodo(any()))
        .thenAnswer((_) async => Future.value());

    when(() => mockTodosRepository.deleteTodo(any())).thenAnswer((_) async {});
    when(() => mockTodosRepository.reorderNote(any(), any(), any()))
        .thenAnswer((_) async {});

    container = createContainer(overrides: [
      todosRepoProvider.overrideWithValue(mockTodosRepository),
    ]);
  });

  test('initial state is an empty list', () async {
    container.listen<AsyncValue<List<Todo>>>(todosControllerProvider,
        (previous, next) {
      expect(previous, const AsyncLoading<List<Todo>>());
      expect(
          next,
          equals(const AsyncData<List<Todo>>([
            Todo(id: '1', text: 'Test Todo 1', todoIndex: 0),
            Todo(id: '2', text: 'Test Todo 2', todoIndex: 1),
            Todo(id: '3', text: 'Test Todo 3', todoIndex: 2),
            Todo(id: '4', text: 'Test Todo 4', todoIndex: 3),
          ])));
    });

    verify(() => mockTodosRepository.getTodos()).called(1);
  });

  // test('initial state is an empty list', () async {
  //   final listener = Listener<AsyncValue<List<Todo>>>();
  //   // listen to the provider and call [listener] whenever its value changes
  //   container.listen(
  //     todosControllerProvider,
  //     listener.call,
  //     fireImmediately: true,
  //   );
  //   verify(
  //     // the build method returns a value immediately, so we expect AsyncLoading
  //     () => listener(null, const AsyncLoading<List<Todo>>()),
  //   );

  //   // Wait for the future to complete
  //   await container.read(todosControllerProvider.future);

  //   // Wait for the asynchronous operation to complete (fetching todos)
  //   await Future.delayed(const Duration(seconds: 1));

  //   // Verify the state transitions to AsyncData with fetched todos
  //   verify(() => listener(
  //       const AsyncLoading<List<Todo>>(),
  //       const AsyncData<List<Todo>>([
  //         Todo(id: '1', text: 'Test Todo 1', todoIndex: 0),
  //         Todo(id: '2', text: 'Test Todo 2', todoIndex: 1),
  //         Todo(id: '3', text: 'Test Todo 3', todoIndex: 2),
  //         Todo(id: '4', text: 'Test Todo 4', todoIndex: 3),
  //       ])));

  //   // verify that the listener is no longer called
  //   // verifyNoMoreInteractions(listener);
  //   verify(() => mockTodosRepository.getTodos()).called(1);
  // });

//   test('loadTodos updates state with fetched todos', () async {
//     final todosController = container.read(todosControllerProvider.notifier);

//     await todosController.loadTodos();

//     expect(
//       todosController.state,
  // equals([
  //   const Todo(id: '1', text: 'Test Todo 1', todoIndex: 0),
  //   const Todo(id: '2', text: 'Test Todo 2', todoIndex: 1),
  //   const Todo(id: '3', text: 'Test Todo 3', todoIndex: 2),
  //   const Todo(id: '4', text: 'Test Todo 4', todoIndex: 3),
  // ]),
//     );
//   });

//   test('getTodoById returns the correct todo item', () async {
//     final todosController = container.read(todosControllerProvider.notifier);

//     await todosController.loadTodos();

//     final todo = todosController.getTodoById('2');
//     expect(
//       todo,
//       equals(const Todo(id: '2', text: 'Test Todo 2', todoIndex: 1)),
//     );
//   });

//   test('getTodoById throws an error if the todo item does not exist', () async {
//     final todosController = container.read(todosControllerProvider.notifier);

//     await todosController.loadTodos();

//     expect(
//       () => todosController.getTodoById('non-existent-id'),
//       throwsA(isA<StateError>()),
//     );
//   });

//   test('insertTodo adds a new todo item to the state and increments total rows',
//       () async {
//     final todosController = container.read(todosControllerProvider.notifier);
//     const newTodo = Todo(id: '5', text: 'New Test Todo', todoIndex: 4);

//     // Initial load of todos and total rows
//     await todosController.loadTodos();

//     await todosController.insertTodo(newTodo);

//     expect(
//       todosController.state,
//       contains(newTodo),
//     );
//     expect(
//         todosController.state,
//         equals([
//           const Todo(id: '1', text: 'Test Todo 1', todoIndex: 0),
//           const Todo(id: '2', text: 'Test Todo 2', todoIndex: 1),
//           const Todo(id: '3', text: 'Test Todo 3', todoIndex: 2),
//           const Todo(id: '4', text: 'Test Todo 4', todoIndex: 3),
//           newTodo,
//         ]));

//     verify(() => mockTodosRepository.insertTodo(newTodo)).called(1);
//   });

//   test('updateTodo updates an existing todo item in the state', () async {
//     final todosController = container.read(todosControllerProvider.notifier);
//     const updatedTodo =
//         Todo(id: '2', text: 'Updated Test Todo 2', todoIndex: 1);

//     // Initial load of todos
//     await todosController.loadTodos();

//     await todosController.updateTodo(updatedTodo);

//     expect(
//       todosController.state,
//       equals([
//         const Todo(id: '1', text: 'Test Todo 1', todoIndex: 0),
//         const Todo(id: '2', text: 'Updated Test Todo 2', todoIndex: 1),
//         const Todo(id: '3', text: 'Test Todo 3', todoIndex: 2),
//         const Todo(id: '4', text: 'Test Todo 4', todoIndex: 3),
//       ]),
//     );

//     verify(() => mockTodosRepository.updateTodo(updatedTodo)).called(1);

//     final updatedState =
//         todosController.state.firstWhere((todo) => todo.id == '2');
//     expect(updatedState.text, equals('Updated Test Todo 2'));
//   });

//   test(
//       'deleteTodo removes a todo item from the state and decrements total rows',
//       () async {
//     final todosController = container.read(todosControllerProvider.notifier);
//     const todoToDelete = Todo(id: '2', text: 'Test Todo 2', todoIndex: 1);

//     await todosController.loadTodos();

//     await todosController.deleteTodo(todoToDelete);

//     expect(
//       todosController.state,
//       isNot(contains(todoToDelete)),
//     );

//     verify(() => mockTodosRepository.deleteTodo(todoToDelete)).called(1);

//     final remainingTodos = todosController.state;
//     expect(remainingTodos[0].todoIndex, equals(0));
//     expect(remainingTodos[1].todoIndex, equals(1));
//     expect(remainingTodos[2].todoIndex, equals(2));
//     // expect(container.read(totalRowsProvider), equals(0));
//   });

//   test(
//       'deleteTodosSelection removes multiple todo items from the state and decrements total rows accordingly',
//       () async {
//     final todosController = container.read(todosControllerProvider.notifier);
//     // final totalRowsController = container.read(totalRowsProvider.notifier);

//     const todoToDelete1 = Todo(id: '2', text: 'Test Todo 2', todoIndex: 1);
//     const todoToDelete2 = Todo(id: '3', text: 'Test Todo 3', todoIndex: 2);

//     // when(() => mockTodosRepository.getRowCount()).thenAnswer((_) async => 4);

//     // Initial load of todos and total rows
//     await todosController.loadTodos();
//     // await totalRowsController.getTotalRows();

//     await todosController.deleteTodosSelection([todoToDelete1, todoToDelete2]);

//     expect(
//       todosController.state,
//       isNot(contains(todoToDelete1)),
//     );
//     expect(
//       todosController.state,
//       isNot(contains(todoToDelete2)),
//     );

//     verify(() => mockTodosRepository.deleteTodo(todoToDelete1)).called(1);
//     verify(() => mockTodosRepository.deleteTodo(todoToDelete2)).called(1);

//     // final totalRows = container.read(totalRowsProvider);
//     // expect(totalRows, equals(2)); // assuming initial total rows is 4

//     // Verify remaining todos' indices are adjusted correctly
//     final remainingTodos = todosController.state;
//     expect(remainingTodos[0].todoIndex, equals(0));
//     expect(remainingTodos[1].todoIndex, equals(1));
//   });

//   test('reorderNote reorders todo items in the state', () async {
//     final todosController = container.read(todosControllerProvider.notifier);

//     // Initial load of todos
//     await todosController.loadTodos();

//     // Initial state should match mock data
//     expect(todosController.state, [
//       const Todo(id: '1', text: 'Test Todo 1', todoIndex: 0),
//       const Todo(id: '2', text: 'Test Todo 2', todoIndex: 1),
//       const Todo(id: '3', text: 'Test Todo 3', todoIndex: 2),
//       const Todo(id: '4', text: 'Test Todo 4', todoIndex: 3),
//     ]);

//     // Reorder from index 1 to index 3
//     await todosController.reorderNote(1, 3);
//     expect(todosController.state, [
//       const Todo(id: '1', text: 'Test Todo 1', todoIndex: 0),
//       const Todo(id: '3', text: 'Test Todo 3', todoIndex: 1),
//       const Todo(id: '2', text: 'Test Todo 2', todoIndex: 2),
//       const Todo(id: '4', text: 'Test Todo 4', todoIndex: 3),
//     ]);
//     verify(() => mockTodosRepository.reorderNote(1, 2, '2')).called(1);

//     // Reorder from index 3 to index 0
//     await todosController.reorderNote(3, 0);
//     expect(todosController.state, [
//       const Todo(id: '4', text: 'Test Todo 4', todoIndex: 0),
//       const Todo(id: '1', text: 'Test Todo 1', todoIndex: 1),
//       const Todo(id: '3', text: 'Test Todo 3', todoIndex: 2),
//       const Todo(id: '2', text: 'Test Todo 2', todoIndex: 3),
//     ]);
//     verify(() => mockTodosRepository.reorderNote(3, 0, '4')).called(1);

//     // Reorder from index 2 to index 1
//     await todosController.reorderNote(2, 1);
//     expect(todosController.state, [
//       const Todo(id: '4', text: 'Test Todo 4', todoIndex: 0),
//       const Todo(id: '3', text: 'Test Todo 3', todoIndex: 1),
//       const Todo(id: '1', text: 'Test Todo 1', todoIndex: 2),
//       const Todo(id: '2', text: 'Test Todo 2', todoIndex: 3),
//     ]);
//     verify(() => mockTodosRepository.reorderNote(2, 1, '3')).called(1);
//   });
}
