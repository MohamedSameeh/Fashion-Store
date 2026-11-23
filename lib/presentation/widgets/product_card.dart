import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../cubits/favorites/favorites_cubit.dart';
import '../models/product_model.dart';

/// Heart button bound to [FavoritesCubit].
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.product, this.size = 38});
  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavoritesCubit, Set<String>, bool>(
      selector: (ids) => ids.contains(product.id),
      builder: (context, isFavorite) {
        return Tooltip(
          message: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          child: Material(
            color: context.colors.surface,
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: Colors.black26,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () async {
                final added =
                    await context.read<FavoritesCubit>().toggle(product);
                if (!context.mounted) return;
                showAppSnack(context,
                    added ? 'Added to favorites' : 'Removed from favorites');
              },
              child: SizedBox(
                width: size,
                height: size,
                child: AnimatedSwitcher(
                  duration: AppDurations.fast,
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(isFavorite),
                    size: size * 0.52,
                    color: isFavorite
                        ? AppColors.brand
                        : context.palette.textMuted,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: product.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context)
            .pushNamed('details_screen', arguments: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: ProductImage(product.image),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: product.onSale
                        ? DiscountBadge(product.discount)
                        : product.subcateg == 'New'
                            ? const TagBadge('New')
                            : const SizedBox.shrink(),
                  ),
                  Positioned(
                    right: 8,
                    bottom: -14,
                    child: FavoriteButton(product: product),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 44),
              child: SizedBox(
                height: 16,
                child: RatingLabel(
                    rating: product.rating, count: product.reviewCount),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleSmall,
            ),
            const SizedBox(height: 2),
            PriceText(price: product.price, salePrice: product.salePrice),
          ],
        ),
      ),
    );
  }
}
