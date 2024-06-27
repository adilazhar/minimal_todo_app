import 'package:flutter/material.dart';

import 'widgets/animated_app_bar.dart';
import 'widgets/todos_list_view.dart';

class TodosHomeScreen extends StatelessWidget {
  const TodosHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: const AnimatedAppBar(),
      body: const TodosListView(),
    );
  }
}
