import 'package:flutter/material.dart';

import '../../../widgets/categoriesDetails.dart';

class KidsNew extends StatelessWidget {
  const KidsNew({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage.category(
      title: 'Kids: new in',
      category: 'kids',
      subcategory: 'New',
    );
  }
}
