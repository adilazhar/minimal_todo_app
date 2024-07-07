import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting.dart';
import 'package:minimal_todo_app/src/utils/setting/presentation/controller/app_setting_controller.dart';

import 'sorting_order_selector_dialog.dart';

class SortingOrderSelectorButton extends StatelessWidget {
  const SortingOrderSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return const SortingOrderSelectorDialog();
          },
        );
      },
      icon: const Icon(Icons.sort),
    );
  }
}
