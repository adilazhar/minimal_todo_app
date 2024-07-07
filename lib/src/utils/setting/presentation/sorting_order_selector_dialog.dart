import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting.dart';
import 'package:minimal_todo_app/src/utils/setting/presentation/controller/app_setting_controller.dart';

class SortingOrderSelectorDialog extends ConsumerWidget {
  const SortingOrderSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSortingOption = ref.watch(appSettingControllerProvider
        .select((value) => value.value!.sortingOption));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Gap(10),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Select Sorting Order',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          RadioListTile<SortingOption>(
            title: const Text('Manual'),
            value: SortingOption.manual,
            groupValue: selectedSortingOption,
            onChanged: (value) {
              ref
                  .read(appSettingControllerProvider.notifier)
                  .updateSortingOption(value!);
            },
          ),
          RadioListTile<SortingOption>(
            title: const Text('Alphabetical Ascending'),
            value: SortingOption.alphaAsc,
            groupValue: selectedSortingOption,
            onChanged: (value) {
              ref
                  .read(appSettingControllerProvider.notifier)
                  .updateSortingOption(value!);
            },
          ),
          RadioListTile<SortingOption>(
            title: const Text('Alphabetical Descending'),
            value: SortingOption.alphaDesc,
            groupValue: selectedSortingOption,
            onChanged: (value) {
              ref
                  .read(appSettingControllerProvider.notifier)
                  .updateSortingOption(value!);
            },
          ),
          RadioListTile<SortingOption>(
            title: const Text('Due Date Ascending'),
            value: SortingOption.duedateAsc,
            groupValue: selectedSortingOption,
            onChanged: (value) {
              ref
                  .read(appSettingControllerProvider.notifier)
                  .updateSortingOption(value!);
            },
          ),
          RadioListTile<SortingOption>(
            title: const Text('Due Date Descending'),
            value: SortingOption.duedateDesc,
            groupValue: selectedSortingOption,
            onChanged: (value) {
              ref
                  .read(appSettingControllerProvider.notifier)
                  .updateSortingOption(value!);
            },
          ),
        ],
      ),
    );
  }
}
