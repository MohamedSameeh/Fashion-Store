import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class KidsShoes extends StatelessWidget {
  const KidsShoes({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Kids: shoes',
      category: 'kids',
      subcategory: 'Shoes',
    );
  }
}
