import 'dart:typed_data';

import 'package:depi_final_project/presentation/screens/Profile/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/cart/cart_state.dart';
import '../../../cubits/favorites/favorites_cubit.dart';
import '../../../data/models.dart';
import '../../../data/store_repository.dart';
import '../Bag/ShippingAddressesPage.dart';
import '../Homepage/homePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _MenuItem {
  const _MenuItem(this.icon, this.title, this.subtitle, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _ProfilePageState extends State<ProfilePage> {
  String searchQuery = '';
  Uint8List? _image;

  late final Stream<UserProfile?> _profile = Repo.store.watchProfile();
  late final Stream<List<OrderModel>> _orders = Repo.store.watchMyOrders();

  void selectImage() async {
    final Uint8List? img = await pickImage(ImageSource.gallery);
    if (img == null) return;
    setState(() => _image = img);
    try {
      await Repo.store.uploadProfileImage(img);
    } catch (_) {
      if (mounted) showAppSnack(context, 'Could not upload the photo');
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to see your bag and orders.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out')),
        ],
      ),
    );
    if (ok != true) return;
    await Repo.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('loginOrNot', false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, 'signIn', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserProfile?>(
        stream: _profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorState(message: 'Error loading user data');
          }
          final user = snapshot.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.xxl),
            children: [
              Text('My profile', style: context.text.headlineLarge),
              const SizedBox(height: AppSpace.lg),
              _header(context, user, loading: !snapshot.hasData),
              const SizedBox(height: AppSpace.lg),
              _stats(context),
              const SizedBox(height: AppSpace.lg),
              TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search settings...',
                  prefixIcon: Icon(Icons.search_rounded),
                  isDense: true,
                ),
              ),
              ..._menu(context),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, UserProfile? user,
      {required bool loading}) {
    return AppCard(
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: context.colors.primaryContainer,
                backgroundImage: _image != null
                    ? MemoryImage(_image!)
                    : (user != null && user.imageUrl.isNotEmpty
                        ? NetworkImage(user.imageUrl) as ImageProvider
                        : null),
                child: _image == null && (user?.imageUrl.isEmpty ?? true)
                    ? Text(user?.initials ?? '',
                        style: context.text.titleLarge!.copyWith(
                            color: context.colors.onPrimaryContainer))
                    : null,
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Tooltip(
                  message: 'Change photo',
                  child: Material(
                    color: context.colors.surface,
                    shape: CircleBorder(
                        side: BorderSide(color: context.colors.outline)),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: selectImage,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.photo_camera_outlined, size: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpace.lg),
          Expanded(
            child: loading
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 140, height: 18),
                      SizedBox(height: 8),
                      Skeleton(width: 190, height: 14),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name.isNotEmpty == true ? user!.name : 'Guest',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleLarge),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall),
                      if ((user?.phone ?? '').isNotEmpty)
                        Text(user!.phone, style: context.text.bodySmall),
                    ],
                  ),
          ),
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () =>
                Navigator.pushNamed(context, 'updateUserInformation'),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }

  Widget _stats(BuildContext context) {
    Widget stat(String value, String label, VoidCallback onTap) => Expanded(
          child: InkWell(
            borderRadius: AppRadius.card,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
              child: Column(
                children: [
                  Text(value, style: context.text.headlineSmall),
                  Text(label, style: context.text.bodySmall),
                ],
              ),
            ),
          ),
        );
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
      child: Row(
        children: [
          StreamBuilder<List<OrderModel>>(
            stream: _orders,
            builder: (context, s) => stat(
                s.hasData ? '${s.data!.length}' : '-',
                'Orders',
                () => Navigator.pushNamed(context, 'orders')),
          ),
          BlocBuilder<FavoritesCubit, Set<String>>(
            builder: (context, ids) => stat('${ids.length}', 'Favorites',
                () => Homepage.tab.value = Homepage.favorites),
          ),
          BlocBuilder<CartCubit, CartState>(
            builder: (context, s) => stat(
                '${s is CartLoaded ? s.units : 0}',
                'In bag',
                () => Homepage.tab.value = Homepage.bag),
          ),
        ],
      ),
    );
  }

  List<Widget> _menu(BuildContext context) {
    final account = [
      _MenuItem(Icons.receipt_long_outlined, 'My orders',
          'Track, review and buy again',
          () => Navigator.pushNamed(context, 'orders')),
      _MenuItem(Icons.shopping_bag_outlined, 'Cart', 'See my products',
          () => Homepage.tab.value = Homepage.bag),
      _MenuItem(Icons.favorite_border_rounded, 'Favorite', 'See my favorites',
          () => Homepage.tab.value = Homepage.favorites),
      _MenuItem(
          Icons.location_on_outlined,
          'Shipping addresses',
          'Manage where your orders go',
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ShippingAddressesPage()))),
    ];
    final store = [
      _MenuItem(Icons.insights_rounded, 'Store dashboard',
          'Sales, top products and order status',
          () => Navigator.pushNamed(context, 'owner_dashboard')),
    ];
    final settings = [
      _MenuItem(Icons.person_outline_rounded, 'Edit Profile',
          'Name, email and phone',
          () => Navigator.pushNamed(context, 'updateUserInformation')),
      _MenuItem(Icons.lock_outline_rounded, 'Edit Password',
          'Change your password',
          () => Navigator.pushNamed(context, 'forgot_password')),
      _MenuItem(Icons.groups_outlined, 'About US', 'The team behind the app',
          () => Navigator.pushNamed(context, 'aboutUS')),
    ];

    bool match(_MenuItem i) =>
        i.title.toLowerCase().contains(searchQuery.trim().toLowerCase());

    Widget group(String title, List<_MenuItem> items, {Widget? extra}) {
      final shown = items.where(match).toList();
      final showExtra = extra != null &&
          'dark mode'.contains(searchQuery.trim().toLowerCase());
      if (shown.isEmpty && !showExtra) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, AppSpace.xl, 0, AppSpace.sm),
            child: Text(title.toUpperCase(),
                style: context.text.labelSmall!.copyWith(
                    color: context.palette.textMuted, letterSpacing: 1.2)),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (showExtra) extra,
                for (var i = 0; i < shown.length; i++) ...[
                  if (i > 0 || showExtra)
                    const Divider(indent: 56, endIndent: 16),
                  ListTile(
                    leading: Icon(shown[i].icon),
                    title: Text(shown[i].title),
                    subtitle: Text(shown[i].subtitle),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: context.palette.textMuted),
                    onTap: shown[i].onTap,
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    final nothing = [...account, ...store, ...settings].where(match).isEmpty &&
        !'dark mode'.contains(searchQuery.trim().toLowerCase());

    return [
      if (nothing)
        Padding(
          padding: const EdgeInsets.only(top: AppSpace.xxxl),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 36, color: context.palette.textMuted),
              const SizedBox(height: AppSpace.sm),
              Text('No settings match "$searchQuery"',
                  style: context.text.bodyMedium),
            ],
          ),
        ),
      group('Account', account),
      group('Store owner', store),
      group(
        'Settings',
        settings,
        extra: SwitchListTile(
          secondary: Icon(context.isDark
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined),
          title: const Text('Dark mode'),
          subtitle: const Text('Easier on the eyes at night'),
          value: context.isDark,
          onChanged: (_) => ThemeController.instance.toggle(context),
        ),
      ),
      const SizedBox(height: AppSpace.xl),
      OutlinedButton.icon(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
            foregroundColor: context.colors.error,
            side: BorderSide(color: context.colors.outline)),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Log out'),
      ),
    ];
  }
}
