import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'minimal_todo_app.dart';

// Todo : Set App Orientation To Up And Only Up

// Todo : Add Responsiveness So That It Keeps It Size Consistent On Different Screnss

// Todo : Add Double Tap To Exit Fucntionality

// Todo : Fix Highlight color on the TodoItem when editing

// Todo : Modify The TodoController Notifier To AsyncNotifier class

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      const ProviderScope(
        child: MinimalTodoApp(),
      ),
    );
  });
}
