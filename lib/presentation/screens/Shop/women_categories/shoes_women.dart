import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class ShoesWomen extends StatelessWidget {
  const ShoesWomen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Women: shoes',
      category: 'woman',
      subcategory: 'Shoes',
    );
  }
}
