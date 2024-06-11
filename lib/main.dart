import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'minimal_todo_app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MinimalTodoApp(),
    ),
  );
}
