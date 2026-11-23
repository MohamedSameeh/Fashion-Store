import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class MensNew extends StatelessWidget {
  const MensNew({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Men: new in',
      category: 'men',
      subcategory: 'New',
    );
  }
}
