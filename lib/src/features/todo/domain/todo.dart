import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Todo extends Equatable {
  final String id;
  final String text;
  final int todoIndex;
  const Todo({
    required this.id,
    required this.text,
    required this.todoIndex,
  });

  Todo copyWith({
    String? id,
    String? text,
    int? todoIndex,
  }) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      todoIndex: todoIndex ?? this.todoIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'todoIndex': todoIndex,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      todoIndex: map['todoIndex']?.toInt() ?? 0,
    );
  }

  factory Todo.fromText(String text, int index) {
    return Todo(id: uuid.v4(), text: text, todoIndex: index);
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) => Todo.fromMap(json.decode(source));

  @override
  String toString() => 'Todo(id: $id, text: $text, todoIndex: $todoIndex)';

  @override
  List<Object> get props => [id, text, todoIndex];
}
