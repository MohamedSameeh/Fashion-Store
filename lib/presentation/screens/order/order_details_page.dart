import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/catalog/catalog_cubit.dart';
import '../../../data/models.dart';
import '../Homepage/homePage.dart';

/// Order tracking: status timeline, items, delivery details, totals and a
/// "Buy again" action that puts the same items back in the bag.
class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key, required this.order});
  final OrderModel order;

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _reordering = false;

  OrderModel get order => widget.order;

  /// Estimate from the chosen delivery method (the backend stores the
  /// order date and the current status, not per-step timestamps).
  DateTime get _estimatedDelivery {
    final days = switch (order.deliveryMethod.toLowerCase()) {
      'next day' => 1,
      'express' => 2,
      _ => 5,
    };
    return order.date.add(Duration(days: days));
  }

  Future<void> _reorder() async {
    final catalog = context.read<CatalogCubit>().state;
    if (catalog is! CatalogLoaded) return;
    setState(() => _reordering = true);
    final cart = context.read<CartCubit>();
    var added = 0;
    for (final item in order.items) {
      final product = catalog.byId(item.productId);
      if (product == null) continue; // no longer in the catalogue
      if (await cart.add(product,
          size: item.size, color: item.color, quantity: item.quantity)) {
        added += item.quantity;
      }
    }
    if (!mounted) return;
    setState(() => _reordering = false);
    if (added == 0) {
      showAppSnack(context, 'These items are no longer available');
      return;
    }
    showAppSnack(
        context, '$added ${added == 1 ? 'item' : 'items'} added to your bag');
    Homepage.tab.value = Homepage.bag;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order ${order.number}')),
      bottomNavigationBar: BottomActionBar(
        child: LoadingButton(
          label: 'Buy again',
          icon: Icons.replay_rounded,
          loading: _reordering,
          onPressed: _reorder,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_headline, style: context.text.titleLarge),
                          const SizedBox(height: 2),
                          Text('Placed ${dateTimeLabel(order.date)}',
                              style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    OrderStatusChip(order.status),
                  ],
                ),
                const SizedBox(height: AppSpace.xl),
                OrderTimeline(
                    order: order, estimatedDelivery: _estimatedDelivery),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items', style: context.text.titleMedium),
                const SizedBox(height: AppSpace.md),
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.md),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: SizedBox(
                              width: 52,
                              height: 62,
                              child: ProductImage(item.image)),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall),
                              Text(
                                  'Size ${item.size} · ${item.color} · x${item.quantity}',
                                  style: context.text.bodySmall),
                            ],
                          ),
                        ),
                        Text(money(item.lineTotal),
                            style: context.text.titleSmall),
                      ],
                    ),
                  ),
                const Divider(),
                const SizedBox(height: AppSpace.md),
                _line(context, 'Order', money(order.itemsTotal)),
                _line(context, 'Delivery (${order.deliveryMethod})',
                    order.deliveryFee == 0 ? 'Free' : money(order.deliveryFee)),
                _line(context, 'Total', money(order.total), strong: true),
              ],
            ),
          ),
          if (order.addressLine.isNotEmpty || order.paymentLabel.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            AppCard(
              child: Column(
                children: [
                  if (order.addressLine.isNotEmpty)
                    _detail(context, Icons.location_on_outlined,
                        order.addressName, order.addressLine),
                  if (order.addressLine.isNotEmpty &&
                      order.paymentLabel.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpace.md),
                      child: Divider(),
                    ),
                  if (order.paymentLabel.isNotEmpty)
                    _detail(context, Icons.credit_card_rounded, 'Payment',
                        order.paymentLabel),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _headline => switch (order.status) {
        OrderStatus.processing => 'We are packing your order',
        OrderStatus.shipped => 'Your order is on its way',
        OrderStatus.delivered => 'Your order was delivered',
        OrderStatus.cancelled => 'This order was cancelled',
      };

  Widget _line(BuildContext context, String label, String value,
          {bool strong = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: strong
                      ? context.text.titleMedium
                      : context.text.bodyMedium!
                          .copyWith(color: context.palette.textMuted)),
            ),
            Text(value,
                style: strong
                    ? context.text.titleLarge
                    : context.text.titleSmall),
          ],
        ),
      );

  Widget _detail(
          BuildContext context, IconData icon, String title, String body) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.palette.textMuted),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(body, style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      );
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline(
      {super.key, required this.order, required this.estimatedDelivery});
  final OrderModel order;
  final DateTime estimatedDelivery;

  @override
  Widget build(BuildContext context) {
    final cancelled = order.status == OrderStatus.cancelled;
    // index of the last completed step
    final reached = switch (order.status) {
      OrderStatus.processing => 1,
      OrderStatus.shipped => 2,
      OrderStatus.delivered => 3,
      OrderStatus.cancelled => 1,
    };

    final steps = cancelled
        ? [
            ('Order placed', dateTimeLabel(order.date), Icons.receipt_long_outlined),
            ('Cancelled', 'The order was cancelled before shipping', Icons.close_rounded),
          ]
        : [
            ('Order placed', dateTimeLabel(order.date), Icons.receipt_long_outlined),
            ('Processing', 'Items are picked and packed', Icons.inventory_2_outlined),
            ('Shipped', '${order.deliveryMethod} delivery', Icons.local_shipping_outlined),
            (
              'Delivered',
              order.status == OrderStatus.delivered
                  ? 'Handed over to the customer'
                  : 'Estimated ${dayMonth(estimatedDelivery)}',
              Icons.home_outlined
            ),
          ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineStep(
            title: steps[i].$1,
            subtitle: steps[i].$2,
            icon: steps[i].$3,
            done: i <= reached,
            current: i == reached && order.status != OrderStatus.delivered,
            isLast: i == steps.length - 1,
            nextDone: i + 1 <= reached,
            color: cancelled && i == 1
                ? context.palette.textMuted
                : context.palette.success,
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.done,
    required this.current,
    required this.isLast,
    required this.nextDone,
    required this.color,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final bool done;
  final bool current;
  final bool isLast;
  final bool nextDone;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final idle = context.colors.outline;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: done ? color : context.colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: done ? color : idle, width: 1.5),
                  boxShadow: current
                      ? [
                          BoxShadow(
                              color: color.withValues(alpha: 0.28),
                              blurRadius: 0,
                              spreadRadius: 4)
                        ]
                      : null,
                ),
                child: Icon(done && !current ? Icons.check_rounded : icon,
                    size: 17,
                    color: done ? Colors.white : context.palette.textMuted),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: nextDone ? color : idle,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: context.text.titleSmall!.copyWith(
                          color: done ? null : context.palette.textMuted)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: context.text.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
