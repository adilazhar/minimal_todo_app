import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_todo_app/src/utils/setting/presentation/controller/app_setting_controller.dart';

class NightModeButton extends ConsumerWidget {
  const NightModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appSettingControllerProvider.select(
      (value) => value.value!.isDarkMode,
    ));
    return IconButton(
        onPressed: () => ref
            .read(appSettingControllerProvider.notifier)
            .updateDarkMode(!isDarkMode),
        icon: Icon(isDarkMode ? Icons.sunny : Icons.nightlight_rounded));
  }
}
