import 'package:minimal_todo_app/src/features/todo/data/todos_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'total_rows.g.dart';

@Riverpod(keepAlive: true)
class TotalRows extends _$TotalRows {
  late final TodosRepository _todosRepository;
  @override
  int build() {
    _todosRepository = ref.watch(todosRepoProvider);
    getTotalRows();
    return 0;
  }

  Future<void> getTotalRows() async {
    state = await _todosRepository.getRowCount();
  }

  void incrementRows() {
    state = state + 1;
  }

  void decrementRows() {
    state = state - 1;
  }
}
