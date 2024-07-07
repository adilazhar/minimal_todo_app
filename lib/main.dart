import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'minimal_todo_app.dart';

// Todo : Add Filtering And Sorting And Keep Them Persistent
// Filtering : All,No Due DateTime, Over Due Date , Due Today, Upcoming Or See Todos For A specific Date

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
