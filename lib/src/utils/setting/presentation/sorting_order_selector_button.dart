import 'package:flutter/material.dart';

import 'sorting_order_selector_dialog.dart';

class SortingOrderSelectorButton extends StatelessWidget {
  const SortingOrderSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          barrierColor: Colors.black.withOpacity(0.3),
          builder: (context) {
            return const SortingOrderSelectorDialog();
          },
        );
      },
      icon: const Icon(Icons.sort),
    );
  }
}
