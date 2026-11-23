import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class NewWomen extends StatelessWidget {
  const NewWomen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Women: new in',
      category: 'woman',
      subcategory: 'New',
    );
  }
}
