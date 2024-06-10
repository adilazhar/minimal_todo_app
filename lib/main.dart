import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MinimalTodoApp(),
    ),
  );
}

class MinimalTodoApp extends StatelessWidget {
  const MinimalTodoApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minimal Todo App',
      home: Scaffold(
        body: Center(
          child: Text('Minimal Todo App'),
        ),
      ),
    );
  }
}
