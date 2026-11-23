import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../cubits/catalog/catalog_cubit.dart';
import '../Search/product_filter.dart';
import '../Search/search_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  List items = ['New', 'Clothes', 'Shoes', 'Accessories'];
  List womenNavigators = [
    'new_women',
    'clothes_women',
    'shoes_women',
    'accesories_women'
  ];
  List mensNavigators = [
    'new_men',
    'clothes_men',
    'shoes_men',
    'accesories_men'
  ];
  List kidsNavigators = [
    'new_kids',
    'clothes_kids',
    'shoes_kids',
    'accesories_kids'
  ];
  List womenImages = [
    'assets/images/12.jpg',
    'assets/images/11.jpg',
    'assets/images/shoes_women.jpg',
    'assets/images/accessories_women.jpg',
  ];
  List menImages = [
    'assets/images/10.jpg',
    'assets/images/mens_clothes.jpg',
    'assets/images/mens_shoes.jpg',
    'assets/images/mens_accesories.jpg',
  ];
  List kidsImages = [
    'assets/images/kids_wear.jpg',
    'assets/images/kids_clothes.jpg',
    'assets/images/kids_shoes.jpg',
    'assets/images/kids_accesories.jpg',
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Categories'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).pushNamed('search'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          tabs: const [Tab(text: 'Women'), Tab(text: 'Men'), Tab(text: 'Kids')],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          CustomWidget(
            category: 'woman',
            images: womenImages,
            items: items,
            navigators: womenNavigators,
          ),
          CustomWidget(
            category: 'men',
            images: menImages,
            items: items,
            navigators: mensNavigators,
          ),
          CustomWidget(
            category: 'kids',
            images: kidsImages,
            items: items,
            navigators: kidsNavigators,
          ),
        ],
      ),
    );
  }
}

/// One tab of the shop: sale banner + the four sub category cards.
class CustomWidget extends StatelessWidget {
  final String category;
  final List images;
  final List items;
  final List navigators;

  const CustomWidget(
      {super.key,
      required this.category,
      required this.images,
      required this.items,
      required this.navigators});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        final products = state is CatalogLoaded
            ? state.products.where((p) => p.category == category).toList()
            : null;
        final saleCount = products?.where((p) => p.onSale).length ?? 0;
        final maxOff = products == null || saleCount == 0
            ? 0
            : products.map((p) => p.discount).reduce((a, b) => a > b ? a : b);

        return ListView(
          padding: const EdgeInsets.all(AppSpace.lg),
          children: [
            Semantics(
              button: true,
              label: 'Shop the sale',
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SearchScreen(
                    initial: ProductFilter(
                        categories: {category},
                        onSaleOnly: true,
                        sort: ProductSort.discount),
                  ),
                )),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.xl, vertical: AppSpace.xl),
                  decoration: BoxDecoration(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MID-SEASON SALE',
                                style: context.text.headlineSmall!
                                    .copyWith(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              maxOff > 0
                                  ? 'Up to $maxOff% off, $saleCount styles'
                                  : 'New markdowns every week',
                              style: context.text.bodyMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            for (var index = 0; index < items.length; index++) ...[
              const SizedBox(height: AppSpace.md),
              _CategoryCard(
                title: '${items[index]}',
                image: '${images[index]}',
                count: products
                    ?.where((p) => p.subcateg == items[index])
                    .length,
                onTap: () =>
                    Navigator.of(context).pushNamed('${navigators[index]}'),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(
      {required this.title,
      required this.image,
      required this.count,
      required this.onTap});
  final String title;
  final String image;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: SizedBox(
          height: 112,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpace.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                          child:
                              Text(title, style: context.text.titleLarge)),
                      const SizedBox(height: 4),
                      count == null
                          ? const Skeleton(width: 60, height: 12)
                          : Text('$count ${count == 1 ? 'item' : 'items'}',
                              style: context.text.bodySmall),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 150, height: 112, child: ProductImage(image, alignment: const Alignment(0, 0.1))),
            ],
          ),
        ),
      ),
    );
  }
}
