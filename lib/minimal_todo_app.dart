import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/features/todo/presentation/controller/selection_controller.dart';
import 'package:minimal_todo_app/src/utils/setting/data/theme_data.dart';
import 'package:minimal_todo_app/src/utils/setting/presentation/controller/app_setting_controller.dart';

import 'src/features/todo/presentation/todos_home_screen.dart';

class MinimalTodoApp extends ConsumerStatefulWidget {
  const MinimalTodoApp({
    super.key,
  });

  @override
  ConsumerState<MinimalTodoApp> createState() => _MinimalTodoAppState();
}

class _MinimalTodoAppState extends ConsumerState<MinimalTodoApp> {
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    final appSettingController = ref.watch(appSettingControllerProvider);
    final isSelectedState = ref.watch(((selectionControllerProvider.select(
      (value) => value.isSelectedState,
    ))));
    return appSettingController.when(
      data: (data) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Minimal Todo App',
        theme: flexTodoLightTheme,
        darkTheme: flexTodoDarkTheme,
        themeMode: data.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: PopScope(
            canPop: false,
            onPopInvoked: (_) {
              if (isSelectedState) {
                ref.read(selectionControllerProvider.notifier).resetState();
              } else {
                if (tapped) {
                  Navigator.pop(context);
                } else {
                  tapped = true;
                  Timer(
                    const Duration(
                      seconds: 2,
                    ),
                    resetBackTimeout,
                  );
                  print('Press Back Again To Exit');
                  // Todo : Show Toast Instead of this print statement
                  // Fluttertoast.showToast(
                  //   msg: 'Press Back Again To Exit',
                  //   toastLength: Toast.LENGTH_SHORT,
                  //   gravity: ToastGravity.BOTTOM,
                  //   backgroundColor: Theme.of(context).colorScheme.surface,
                  //   textColor: Theme.of(context).colorScheme.onSurface,
                  // );
                }
              }
            },
            child: const TodosHomeScreen()),
      ),
      error: (error, stackTrace) => const SizedBox(),
      loading: () => const CircularProgressIndicator(),
    );
  }

  void resetBackTimeout() {
    tapped = false;
  }
}
