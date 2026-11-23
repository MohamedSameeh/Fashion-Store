import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class KidsAccesories extends StatelessWidget {
  const KidsAccesories({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Kids: accessories',
      category: 'kids',
      subcategory: 'Accessories',
    );
  }
}
