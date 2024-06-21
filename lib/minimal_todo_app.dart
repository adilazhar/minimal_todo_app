import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/utils/setting/data/theme_data.dart';
import 'package:minimal_todo_app/src/utils/setting/presentation/controller/app_setting_controller.dart';

import 'src/features/todo/presentation/todos_home_screen.dart';

class MinimalTodoApp extends ConsumerWidget {
  const MinimalTodoApp({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettingController = ref.watch(appSettingControllerProvider);
    return appSettingController.when(
      data: (data) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Minimal Todo App',
        theme: flexTodoLightTheme,
        darkTheme: flexTodoDarkTheme,
        themeMode: data.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const DoubleBack(child: TodosHomeScreen()),
      ),
      error: (error, stackTrace) => const SizedBox(),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
