import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../cubits/cart/cart_cubit.dart';
import '../../cubits/catalog/catalog_cubit.dart';
import '../models/product_model.dart';
import '../screens/Homepage/homePage.dart';
import 'homepage_new_sale.dart';
import 'product_card.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late String selectedSize;
  late String selectedColor;
  int _imageIndex = 0;
  bool _adding = false;

  List<String> get sizes => widget.product.sizes.isNotEmpty
      ? widget.product.sizes
      : const ['S', 'M', 'L', 'XL'];
  List<String> get colors => widget.product.colors.isNotEmpty
      ? widget.product.colors
      : const ['Black', 'White', 'Red'];

  @override
  void initState() {
    super.initState();
    selectedSize = sizes.length > 2 ? sizes[sizes.length ~/ 2] : sizes.first;
    selectedColor = colors.first;
  }

  void shareProduct(Product product) {
    final shareText = 'Check out this product: ${product.name}\n'
        'Description: ${product.description}\n'
        'Price: ${money(product.salePrice)}\n';
    try {
      Share.share(shareText);
    } catch (_) {
      showAppSnack(context, 'Sharing is not available on this device');
    }
  }

  Future<void> _addToCart(Product product) async {
    setState(() => _adding = true);
    final ok = await context
        .read<CartCubit>()
        .add(product, size: selectedSize, color: selectedColor);
    if (!mounted) return;
    setState(() => _adding = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(ok
            ? '${product.name} added to your bag'
            : 'Could not add to bag. Please try again.'),
        action: ok
            ? SnackBarAction(
                label: 'View bag',
                onPressed: () {
                  Homepage.tab.value = Homepage.bag;
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              )
            : null,
      ));
  }

  @override
  Widget build(BuildContext context) {
    // Follow live catalogue updates (rating changes after a new review).
    final catalog = context.watch<CatalogCubit>().state;
    final product = (catalog is CatalogLoaded
            ? catalog.byId(widget.product.id)
            : null) ??
        widget.product;
    final related = catalog is CatalogLoaded
        ? catalog.products
            .where((p) =>
                p.category == product.category && p.id != product.id)
            .toList()
        : <Product>[];
    final imageHeight =
        (MediaQuery.sizeOf(context).width * 1.08).clamp(320.0, 520.0);

    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price', style: context.text.bodySmall),
                Text(money(product.salePrice),
                    style: context.text.titleLarge),
              ],
            ),
            const SizedBox(width: AppSpace.xl),
            Expanded(
              child: LoadingButton(
                label: 'Add to bag',
                icon: Icons.shopping_bag_outlined,
                loading: _adding,
                onPressed: () => _addToCart(product),
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: imageHeight,
            leading: _CircleAction(
              tooltip: 'Back',
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              _CircleAction(
                tooltip: 'Share',
                icon: Icons.ios_share_rounded,
                onTap: () => shareProduct(product),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 4),
                child: Center(child: FavoriteButton(product: product, size: 40)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: product.images.length,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemBuilder: (_, i) => ProductImage(product.images[i]),
                  ),
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _imageIndex ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: i == _imageIndex ? 1 : .6),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl, AppSpace.xl, AppSpace.xl, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${product.categoryLabel} / ${product.subcateg}'
                            .toUpperCase(),
                        style: context.text.labelSmall!.copyWith(
                            color: context.palette.textMuted,
                            letterSpacing: 1.2),
                      ),
                      const Spacer(),
                      if (product.onSale) DiscountBadge(product.discount),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(product.name, style: context.text.headlineMedium),
                  const SizedBox(height: AppSpace.sm),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    onTap: () => Navigator.of(context)
                        .pushNamed('rating_reviews', arguments: product),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RatingStars(product.rating, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            product.reviewCount == 0
                                ? 'No reviews yet'
                                : '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                            style: context.text.bodySmall,
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 18, color: context.palette.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  PriceText(
                      price: product.price,
                      salePrice: product.salePrice,
                      large: true),
                  const SizedBox(height: AppSpace.xl),
                  Row(
                    children: [
                      Text('Size', style: context.text.titleSmall),
                      const SizedBox(width: 8),
                      Text(selectedSize, style: context.text.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (final s in sizes)
                        ChoiceChip(
                          label: Text(s),
                          selected: s == selectedSize,
                          onSelected: (_) =>
                              setState(() => selectedSize = s),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xl),
                  Row(
                    children: [
                      Text('Color', style: context.text.titleSmall),
                      const SizedBox(width: 8),
                      Text(selectedColor, style: context.text.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Row(
                    children: [
                      for (final c in colors)
                        _ColorDot(
                          name: c,
                          selected: c == selectedColor,
                          onTap: () => setState(() => selectedColor = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xl),
                  Text('Details', style: context.text.titleSmall),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: context.text.bodyMedium!
                        .copyWith(color: context.palette.textMuted),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  const _InfoRow(
                      icon: Icons.local_shipping_outlined,
                      title: 'Free standard delivery over \$150',
                      subtitle: 'Express and next-day options at checkout'),
                  const SizedBox(height: AppSpace.md),
                  const _InfoRow(
                      icon: Icons.replay_rounded,
                      title: '30-day returns',
                      subtitle: 'Unworn items with tags attached'),
                ],
              ),
            ),
          ),
          if (related.isNotEmpty) ...[
            const SliverToBoxAdapter(
                child: SectionHeader(title: 'You may also like')),
            SliverToBoxAdapter(
              child: HomepageNewSale(type: 'Related', products: related),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: AppSpace.xxl)),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction(
      {required this.icon, required this.onTap, required this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: context.colors.surface,
          shape: const CircleBorder(),
          elevation: 2,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
                width: 40,
                height: 40,
                child:
                    Icon(icon, size: 20, color: context.colors.onSurface)),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot(
      {required this.name, required this.selected, required this.onTap});
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpace.md),
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Color $name',
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? context.colors.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorFromName(name),
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.outline),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall),
                Text(subtitle, style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      );
}
