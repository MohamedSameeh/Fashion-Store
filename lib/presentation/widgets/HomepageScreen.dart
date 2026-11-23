import 'dart:async';

import 'package:depi_final_project/presentation/widgets/homepage_new_sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../cubits/catalog/catalog_cubit.dart';
import '../models/product_model.dart';

class Homepagescreen extends StatefulWidget {
  const Homepagescreen({super.key});

  @override
  State<Homepagescreen> createState() => _HomepagescreenState();
}

class _Slide {
  const _Slide(this.image, this.kicker, this.title, this.cta, this.route);
  final String image;
  final String kicker;
  final String title;
  final String cta;
  final String route;
}

class _HomepagescreenState extends State<Homepagescreen> {
  static const _slides = [
    _Slide('assets/images/12.jpg', 'NEW SEASON', 'Soft tailoring\nfor warm days',
        'Shop new in', 'new_view_all'),
    _Slide('assets/images/11.jpg', 'UP TO 30% OFF', 'The mid-season\nsale is on',
        'Shop the sale', 'sales_view_all'),
    _Slide('assets/images/3.jpg', 'MENSWEAR', 'Workwear in\nbold colour',
        'Shop men', 'new_men'),
  ];

  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!_pageController.hasClients) return;
      final next = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.xxl),
            children: [
              _topBar(context),
              _searchField(context),
              _carousel(context),
              _categories(context),
              if (state is CatalogError)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.xxl),
                  child: ErrorState(
                    message: state.message,
                    onRetry: () => context.read<CatalogCubit>().retry(),
                  ),
                )
              else if (state is CatalogLoaded)
                ..._sections(context, state.products)
              else
                ..._loadingSections(),
            ],
          );
        },
      ),
    );
  }

  Widget _topBar(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, 6, 4),
        child: Row(
          children: [
            const BrandMark(size: 20),
            const Spacer(),
            IconButton(
              tooltip: context.isDark
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              onPressed: () => ThemeController.instance.toggle(context),
              icon: Icon(context.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
            ),
          ],
        ),
      );

  Widget _searchField(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.sm, AppSpace.lg, AppSpace.lg),
        child: Semantics(
          button: true,
          label: 'Search products',
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: () => Navigator.of(context).pushNamed('search'),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: context.colors.outline),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: context.palette.textMuted),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text('Search jackets, sneakers, bags...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium!
                              .copyWith(color: context.palette.textMuted)),
                    ),
                  ),
                  Icon(Icons.tune_rounded,
                      size: 20, color: context.palette.textMuted),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _carousel(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: SizedBox(
            height: 400,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final s = _slides[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ProductImage(s.image),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.35, 1],
                              colors: [Colors.transparent, Color(0xD9000000)],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.kicker,
                                  style: context.text.labelSmall!.copyWith(
                                      color: Colors.white, letterSpacing: 2)),
                              const SizedBox(height: 6),
                              Text(s.title,
                                  style: context.text.headlineLarge!
                                      .copyWith(color: Colors.white)),
                              const SizedBox(height: 14),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.ink,
                                  minimumSize: const Size(0, 44),
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pushNamed(s.route),
                                child: Text(s.cta),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  left: 20,
                  bottom: 16,
                  child: Row(
                    children: List.generate(_slides.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: AppDurations.normal,
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 22 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: active ? 1 : 0.5),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _categories(BuildContext context) {
    const cats = [
      ('Women', 'assets/images/5.jpg', 'clothes_women'),
      ('Men', 'assets/images/2.jpg', 'clothes_men'),
      ('Kids', 'assets/images/kids_wear.jpg', 'clothes_kids'),
      ('Shoes', 'assets/images/mens_shoes.jpg', 'shoes_men'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.xl, AppSpace.lg, 0),
      child: Row(
        children: [
          for (final c in cats)
            Expanded(
              child: Semantics(
                button: true,
                label: 'Category ${c.$1}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () => Navigator.of(context).pushNamed(c.$3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: context.colors.outline, width: 1),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: ClipOval(child: ProductImage(c.$2)),
                        ),
                        const SizedBox(height: 8),
                        ExcludeSemantics(
                            child:
                                Text(c.$1, style: context.text.labelMedium)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _sections(BuildContext context, List<Product> products) {
    final saleProducts = products.where((p) => p.discount > 0).toList()
      ..sort((a, b) => b.discount.compareTo(a.discount));
    final newProducts = products.where((p) => p.subcateg == 'New').toList();
    final topRated = products.where((p) => p.reviewCount > 0).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    if (products.isEmpty) {
      return const [
        SizedBox(
          height: 320,
          child: EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'The store is being stocked',
            message: 'New arrivals will show up here very soon.',
          ),
        ),
      ];
    }

    return [
      if (saleProducts.isNotEmpty) ...[
        SectionHeader(
          title: 'Sale',
          subtitle: 'Mid-season sale, while stocks last',
          onViewAll: () => Navigator.of(context).pushNamed('sales_view_all'),
        ),
        HomepageNewSale(type: 'Sale', products: saleProducts),
      ],
      _deliveryBanner(context),
      if (newProducts.isNotEmpty) ...[
        SectionHeader(
          title: 'New',
          subtitle: "You've never seen it before",
          onViewAll: () => Navigator.of(context).pushNamed('new_view_all'),
        ),
        HomepageNewSale(type: 'New', products: newProducts),
      ],
      if (topRated.length >= 4) ...[
        const SectionHeader(
            title: 'Top rated', subtitle: 'Loved by our customers'),
        HomepageNewSale(type: 'Top', products: topRated.take(8).toList()),
      ],
    ];
  }

  Widget _deliveryBanner(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.xxl, AppSpace.lg, 0),
        child: Container(
          padding: const EdgeInsets.all(AppSpace.lg),
          decoration: BoxDecoration(
            color: context.isDark ? AppColors.darkSurfaceAlt : AppColors.ink,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: AppColors.brand, shape: BoxShape.circle),
                child: const Icon(Icons.local_shipping_outlined,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Free standard delivery',
                        style: context.text.titleSmall!
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('On every order over \$150',
                        style: context.text.bodySmall!
                            .copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  List<Widget> _loadingSections() => [
        for (var s = 0; s < 2; s++) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpace.lg, AppSpace.xxl, AppSpace.lg, AppSpace.md),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Skeleton(width: 110, height: 28)),
          ),
          SizedBox(
            height: 296,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
              itemBuilder: (_, __) => const SizedBox(
                width: 164,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Skeleton(radius: AppRadius.lg)),
                    SizedBox(height: 12),
                    Skeleton(width: 120, height: 14),
                    SizedBox(height: 8),
                    Skeleton(width: 70, height: 14),
                    SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ];
}
