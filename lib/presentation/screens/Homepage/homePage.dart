import 'package:depi_final_project/cubits/cart/cart_cubit.dart';
import 'package:depi_final_project/cubits/cart/cart_state.dart';
import 'package:depi_final_project/cubits/catalog/catalog_cubit.dart';
import 'package:depi_final_project/cubits/favorites/favorites_cubit.dart';
import 'package:depi_final_project/presentation/screens/Bag/BagPage.dart';
import 'package:depi_final_project/presentation/screens/Profile/Profile_Page.dart';
import 'package:depi_final_project/presentation/screens/Shop/shop_screen.dart';
import 'package:depi_final_project/presentation/screens/favorites/favoritesScreen.dart';
import 'package:depi_final_project/presentation/widgets/HomepageScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  /// Selected bottom tab. Other screens set this to jump between tabs
  /// (for example "Start shopping" on the empty bag).
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);

  static const int home = 0, shop = 1, bag = 2, favorites = 3, profile = 4;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  static const List<Widget> _screens = [
    Homepagescreen(),
    ShopScreen(),
    BagPage(),
    FavoriteScreen(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    Homepage.tab.value = 0;
    context.read<CatalogCubit>().start();
    context.read<FavoritesCubit>().start();
    context.read<CartCubit>().loadCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Homepage.tab,
      builder: (context, index, _) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: index, children: _screens),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context).colorScheme.outline)),
            ),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => Homepage.tab.value = i,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded),
                  label: 'Shop',
                ),
                NavigationDestination(
                  icon: _BagIcon(selected: false),
                  selectedIcon: _BagIcon(selected: true),
                  label: 'Bag',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Favorites',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BagIcon extends StatelessWidget {
  const _BagIcon({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(selected
        ? Icons.shopping_bag_rounded
        : Icons.shopping_bag_outlined);
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final units = state is CartLoaded ? state.units : 0;
        return Badge(
          isLabelVisible: units > 0,
          label: Text('$units'),
          child: icon,
        );
      },
    );
  }
}
