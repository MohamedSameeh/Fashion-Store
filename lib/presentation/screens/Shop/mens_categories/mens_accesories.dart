import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class MensAccesories extends StatelessWidget {
  const MensAccesories({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Men: accessories',
      category: 'men',
      subcategory: 'Accessories',
    );
  }
}
