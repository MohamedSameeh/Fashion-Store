import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../cubits/catalog/catalog_cubit.dart';
import '../models/product_model.dart';
import '../screens/Search/product_filter.dart';
import 'product_card.dart';

/// "View all" page for the home rails: `type` is `New` or `Sale`.
class CategoriesDetails extends StatelessWidget {
  final String type;
  const CategoriesDetails({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return ProductListingPage(
      title: type == 'Sale' ? 'Sale' : 'New arrivals',
      where: (p) => type == 'Sale' ? p.discount > 0 : p.subcateg == 'New',
      initialSort: type == 'Sale' ? ProductSort.discount : ProductSort.newest,
    );
  }
}

/// A product grid for one slice of the catalogue (category + sub category,
/// sale, new...) with a sort menu. Shared by every listing screen.
class ProductListingPage extends StatefulWidget {
  const ProductListingPage({
    super.key,
    required this.title,
    required this.where,
    this.initialSort = ProductSort.featured,
  });

  /// Listing for one main category (`woman`, `men`, `kids`) and sub category.
  factory ProductListingPage.category(
          {Key? key,
          required String title,
          required String category,
          required String subcategory}) =>
      ProductListingPage(
        key: key,
        title: title,
        where: (p) => p.category == category && p.subcateg == subcategory,
      );

  final String title;
  final bool Function(Product) where;
  final ProductSort initialSort;

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  late ProductSort _sort = widget.initialSort;

  @override
  void initState() {
    super.initState();
    context.read<CatalogCubit>().start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).pushNamed('search'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          if (state is CatalogError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<CatalogCubit>().retry(),
            );
          }
          if (state is! CatalogLoaded) {
            return const SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: ProductGridSkeleton());
          }

          final products =
              sortProducts(state.products.where(widget.where).toList(), _sort);
          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.checkroom_rounded,
              title: 'Nothing here yet',
              message:
                  'We are restocking ${widget.title.toLowerCase()}. Check back soon or browse the rest of the shop.',
              actionLabel: 'Back to shop',
              onAction: () => Navigator.of(context).pop(),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.lg, 4, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                            '${products.length} ${products.length == 1 ? 'item' : 'items'}',
                            style: context.text.bodySmall),
                      ),
                      SortMenuButton(
                        value: _sort,
                        onChanged: (s) => setState(() => _sort = s),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.lg, AppSpace.sm, AppSpace.lg, AppSpace.xxl),
                sliver: SliverGrid.builder(
                  gridDelegate: productGridDelegate,
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      ProductCard(product: products[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SortMenuButton extends StatelessWidget {
  const SortMenuButton(
      {super.key, required this.value, required this.onChanged});
  final ProductSort value;
  final ValueChanged<ProductSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProductSort>(
      tooltip: 'Sort products',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final s in ProductSort.values)
          PopupMenuItem(value: s, child: Text(s.label)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 18),
            const SizedBox(width: 4),
            Text(value.label, style: context.text.labelMedium),
          ],
        ),
      ),
    );
  }
}
