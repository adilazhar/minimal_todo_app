import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Todo extends Equatable {
  final String id;
  final String text;
  final int todoIndex;
  final DateTime? dueDateTime;
  final bool isTimeSetByUser;

  const Todo({
    required this.id,
    required this.text,
    required this.todoIndex,
    this.dueDateTime,
    this.isTimeSetByUser = false,
  });

  Todo copyWith({
    String? id,
    String? text,
    int? todoIndex,
    DateTime? dueDateTime,
    bool? isTimeSetByUser,
  }) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      todoIndex: todoIndex ?? this.todoIndex,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      isTimeSetByUser: isTimeSetByUser ?? this.isTimeSetByUser,
    );
  }

  String get formattedTime {
    if (dueDateTime == null) return '';
    final formatter = DateFormat('h:mm a');
    return formatter.format(dueDateTime!);
  }

  String get formattedDueDate {
    if (dueDateTime == null) return '';
    final formatter = DateFormat('E, MMM d, y');
    return formatter.format(dueDateTime!);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'todoIndex': todoIndex,
      'dueDateTime': dueDateTime?.toIso8601String(),
      'isTimeSetByUser': isTimeSetByUser ? 1 : 0,
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
      isTimeSetByUser: map['isTimeSetByUser'] == 1,
    );
  }

  factory Todo.fromText(String text, int index,
      {DateTime? dueDateTime, bool? isTimeSetByUser}) {
    return Todo(
        id: uuid.v4(),
        text: text,
        todoIndex: index,
        dueDateTime: dueDateTime,
        isTimeSetByUser: isTimeSetByUser ?? false);
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) => Todo.fromMap(json.decode(source));

  @override
  String toString() =>
      'Todo(id: $id, text: $text, todoIndex: $todoIndex, dueDateTime: $dueDateTime, isTimeSetByUser: $isTimeSetByUser)';

  @override
  List<Object?> get props =>
      [id, text, todoIndex, dueDateTime, isTimeSetByUser];
}
