import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class KidsClothes extends StatelessWidget {
  const KidsClothes({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Kids: clothes',
      category: 'kids',
      subcategory: 'Clothes',
    );
  }
}
