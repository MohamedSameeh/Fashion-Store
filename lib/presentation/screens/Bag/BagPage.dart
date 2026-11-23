import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/cart/cart_state.dart';
import 'CheckoutPage.dart';
import 'cart_iteam.dart';
import 'empty_cart.dart';

/// Shopping bag. Uses the app-wide [CartCubit] so the badge on the bottom
/// bar and this list always agree.
class BagPage extends StatelessWidget {
  const BagPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        title: const Text('My Bag'),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        buildWhen: (_, s) => s is! CheckoutSuccess && s is! CheckoutFailure,
        builder: (context, state) {
          if (state is CartLoading) {
            return const SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: ListSkeleton(count: 3, height: 128));
          }
          if (state is CartError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<CartCubit>().loadCartItems(),
            );
          }
          if (state is! CartLoaded) return const EmptyCart();

          final cartItems = state.cartItems;
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpace.lg),
                  itemCount: cartItems.length + 1,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpace.md),
                  itemBuilder: (context, index) {
                    if (index == cartItems.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Swipe an item to the left to remove it.',
                          textAlign: TextAlign.center,
                          style: context.text.bodySmall,
                        ),
                      );
                    }
                    return CartItemTile(item: cartItems[index]);
                  },
                ),
              ),
              BottomActionBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                            'Subtotal (${state.units} ${state.units == 1 ? 'item' : 'items'})',
                            style: context.text.bodyMedium!
                                .copyWith(color: context.palette.textMuted)),
                        const Spacer(),
                        Text(money(state.totalAmount),
                            style: context.text.titleLarge),
                      ],
                    ),
                    const SizedBox(height: AppSpace.md),
                    LoadingButton(
                      label: 'Check out',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CheckoutPage()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
