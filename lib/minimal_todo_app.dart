import 'package:flutter/material.dart';

import 'src/features/todo/presentation/todos_home_screen.dart';

class MinimalTodoApp extends StatelessWidget {
  const MinimalTodoApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minimal Todo App',
      home: TodosHomeScreen(),
    );
  }
}
