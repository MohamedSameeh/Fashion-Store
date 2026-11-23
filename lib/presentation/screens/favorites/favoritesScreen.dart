import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../cubits/catalog/catalog_cubit.dart';
import '../../../cubits/favorites/favorites_cubit.dart';
import '../../widgets/product_card.dart';
import '../Homepage/homePage.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        title: const Text('Favorites'),
      ),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, catalog) {
          if (catalog is CatalogError) {
            return ErrorState(
              message: catalog.message,
              onRetry: () => context.read<CatalogCubit>().retry(),
            );
          }
          if (catalog is! CatalogLoaded) {
            return const SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: ProductGridSkeleton(count: 4));
          }
          return BlocBuilder<FavoritesCubit, Set<String>>(
            builder: (context, ids) {
              final favorites =
                  catalog.products.where((p) => ids.contains(p.id)).toList();
              if (favorites.isEmpty) {
                return EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'No favorites yet',
                  message:
                      'Tap the heart on any product to save it here for later.',
                  actionLabel: 'Browse the shop',
                  onAction: () {
                    Homepage.tab.value = Homepage.shop;
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.lg, AppSpace.sm, AppSpace.lg, AppSpace.xxl),
                gridDelegate: productGridDelegate,
                itemCount: favorites.length,
                itemBuilder: (context, index) =>
                    ProductCard(product: favorites[index]),
              );
            },
          );
        },
      ),
    );
  }
}
