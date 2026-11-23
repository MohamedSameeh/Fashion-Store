import 'package:flutter/material.dart';

import '../../../core/widgets/app_widgets.dart';
import '../Homepage/homePage.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.shopping_bag_outlined,
      title: 'Your bag is empty',
      message:
          'Looks like you have not added anything yet. Explore the collection and find something you love.',
      actionLabel: 'Start shopping',
      onAction: () {
        Homepage.tab.value = Homepage.shop;
        Navigator.of(context).popUntil((r) => r.isFirst);
      },
    );
  }
}
