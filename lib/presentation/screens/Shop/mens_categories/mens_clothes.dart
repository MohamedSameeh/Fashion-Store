import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class MensClothes extends StatelessWidget {
  const MensClothes({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Men: clothes',
      category: 'men',
      subcategory: 'Clothes',
    );
  }
}
