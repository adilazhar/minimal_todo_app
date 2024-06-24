import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'minimal_todo_app.dart';

// Todo : Add Responsiveness So That It Keeps It Size Consistent On Different Screnss

// Todo : Add Double Tap To Exit Fucntionality (Need To Test On Real Device)

// Todo : Fix Highlight color on the TodoItem when editing

// Todo : Add Theme + Set The Text Styling

// Todo : Add SplashScreen And write the initialization logic

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
