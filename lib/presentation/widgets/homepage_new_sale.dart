import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../models/product_model.dart';
import 'product_card.dart';

/// Horizontal product rail used for the "Sale" and "New" sections on home.
class HomepageNewSale extends StatelessWidget {
  final List<Product> products;
  final String type;

  const HomepageNewSale({super.key, required this.products, required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 296,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
        itemBuilder: (context, index) => SizedBox(
          width: 164,
          child: ProductCard(product: products[index]),
        ),
      ),
    );
  }
}
