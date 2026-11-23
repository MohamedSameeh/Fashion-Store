import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../data/models.dart';

/// One line of the bag: image, name, variant, quantity stepper, line total.
/// Swipe left to remove.
class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        cubit.deleteItem(item);
        showAppSnack(context, '${item.name} removed from your bag');
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpace.xxl),
        decoration: BoxDecoration(
          color: context.colors.error,
          borderRadius: AppRadius.card,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                  width: 84, height: 104, child: ProductImage(item.image)),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: SizedBox(
                height: 104,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleSmall),
                        ),
                        Tooltip(
                          message: 'Remove ${item.name}',
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => cubit.deleteItem(item),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.close_rounded,
                                  size: 18, color: context.palette.textMuted),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Size ${item.size}  ·  ${item.color}',
                        style: context.text.bodySmall),
                    const Spacer(),
                    Row(
                      children: [
                        QuantityStepper(
                          quantity: item.quantity,
                          onMinus: item.quantity > 1
                              ? () => cubit.updateQuantity(item, -1)
                              : null,
                          onPlus: () => cubit.updateQuantity(item, 1),
                        ),
                        const Spacer(),
                        Text(money(item.lineTotal),
                            style: context.text.titleMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
