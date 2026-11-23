import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models.dart';
import 'order_details_page.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final shown = order.items.take(4).toList();
    final extra = order.items.length - shown.length;
    return Semantics(
      button: true,
      label: 'Order ${order.number}',
      child: AppCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailsPage(order: order)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ${order.number}',
                          style: context.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(shortDate(order.date),
                          style: context.text.bodySmall),
                    ],
                  ),
                ),
                OrderStatusChip(order.status),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                for (final item in shown)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpace.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: SizedBox(
                          width: 48,
                          height: 58,
                          child: ProductImage(item.image)),
                    ),
                  ),
                if (extra > 0)
                  Container(
                    width: 48,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text('+$extra', style: context.text.labelMedium),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            const Divider(),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                      '${order.units} ${order.units == 1 ? 'item' : 'items'}  ·  ${order.deliveryMethod} delivery',
                      style: context.text.bodySmall),
                ),
                Text(money(order.total), style: context.text.titleMedium),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: context.palette.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
