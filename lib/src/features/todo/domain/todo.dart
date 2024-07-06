import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Todo extends Equatable {
  final String id;
  final String text;
  final int todoIndex;
  final DateTime? dueDateTime;

  const Todo({
    required this.id,
    required this.text,
    required this.todoIndex,
    this.dueDateTime,
  });

  Todo copyWith({
    String? id,
    String? text,
    int? todoIndex,
    DateTime? dueDateTime,
  }) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      todoIndex: todoIndex ?? this.todoIndex,
      dueDateTime: dueDateTime ?? this.dueDateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'todoIndex': todoIndex,
      'dueDateTime': dueDateTime?.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      todoIndex: map['todoIndex']?.toInt() ?? 0,
      dueDateTime: map['dueDateTime'] != null
          ? DateTime.parse(map['dueDateTime'])
          : null,
    );
  }

  factory Todo.fromText(String text, int index, {DateTime? dueDateTime}) {
    return Todo(
        id: uuid.v4(), text: text, todoIndex: index, dueDateTime: dueDateTime);
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) => Todo.fromMap(json.decode(source));

  @override
  String toString() =>
      'Todo(id: $id, text: $text, todoIndex: $todoIndex, dueDateTime: $dueDateTime)';

  @override
  List<Object?> get props => [id, text, todoIndex, dueDateTime];
}
