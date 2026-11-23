import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class MensShoes extends StatelessWidget {
  const MensShoes({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Men: shoes',
      category: 'men',
      subcategory: 'Shoes',
    );
  }
}
