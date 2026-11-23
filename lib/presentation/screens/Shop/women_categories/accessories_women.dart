import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class AccessoriesWomen extends StatelessWidget {
  const AccessoriesWomen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Women: accessories',
      category: 'woman',
      subcategory: 'Accessories',
    );
  }
}
