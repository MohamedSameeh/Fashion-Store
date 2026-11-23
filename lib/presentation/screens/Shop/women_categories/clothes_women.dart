import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class ClothesWomen extends StatelessWidget {
  const ClothesWomen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Women: clothes',
      category: 'woman',
      subcategory: 'Clothes',
    );
  }
}
