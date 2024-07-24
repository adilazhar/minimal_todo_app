// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:minimal_todo_app/src/features/todo/data/todos_repository.dart';
// import 'package:minimal_todo_app/src/features/todo/domain/todo.dart';
// import 'package:minimal_todo_app/src/features/todo/presentation/controller/todos_controller.dart';
// import 'package:minimal_todo_app/src/utils/setting/domain/app_setting.dart';
// import 'package:minimal_todo_app/src/utils/setting/presentation/controller/app_setting_controller.dart';
// import 'package:mockito/mockito.dart';

// class MockTodosRepository extends Mock implements TodosRepository {}

// class FakeAppSettingController extends Fake implements AppSettingController {
//   // ignore: avoid_public_notifier_properties
//   @override
//   AppSetting get value => const AppSetting(sortingOption: SortingOption.manual);
// }

// class Listener<T> extends Mock {
//   void call(T? previous, T next);
// }

// void main() {
//   late ProviderContainer container;
//   late MockTodosRepository mockTodosRepository;

//   ProviderContainer createContainer({
//     ProviderContainer? parent,
//     List<Override> overrides = const [],
//     List<ProviderObserver>? observers,
//   }) {
//     final container = ProviderContainer(
//       parent: parent,
//       overrides: overrides,
//       observers: observers,
//     );
//     addTearDown(container.dispose);
//     return container;
//   }

//   setUp(() {
//     mockTodosRepository = MockTodosRepository();

//     when(mockTodosRepository.getTodos(SortingOption.manual))
//         .thenAnswer((_) async => <Todo>[]);

//     container = createContainer(overrides: [
//       todosRepoProvider.overrideWithValue(mockTodosRepository),
//       appSettingControllerProvider.overrideWith(
//         () => FakeAppSettingController(),
//       ),
//     ]);
//   });

//   // generate the test for build method -> listen to the TodosController provider->assert that it goes from AsyncLoading to AsyncData which is an empty list-> assert that it calls the getTodos method from the repository
//   test('build', () async {
//     final listener = Listener<AsyncValue<List<Todo>>>();
//     container.listen(todosControllerProvider, listener.call,
//         fireImmediately: true);

//     verify(mockTodosRepository.getTodos(SortingOption.manual)).called(1);
//   });
// }
