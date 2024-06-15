import 'package:equatable/equatable.dart';

class Selection extends Equatable {
  final bool isSelectedState;
  final List<String> selectedTodos;

  const Selection({
    required this.isSelectedState,
    required this.selectedTodos,
  });

  factory Selection.initalState() {
    return const Selection(isSelectedState: false, selectedTodos: []);
  }

  Selection copyWith({
    bool? isSelectedState,
    List<String>? selectedTodos,
  }) {
    return Selection(
      isSelectedState: isSelectedState ?? this.isSelectedState,
      selectedTodos: selectedTodos ?? this.selectedTodos,
    );
  }

  @override
  List<Object> get props => [isSelectedState, selectedTodos];
}
