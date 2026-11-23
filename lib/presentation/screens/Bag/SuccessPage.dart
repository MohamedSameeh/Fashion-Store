import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models.dart';
import '../Homepage/homePage.dart';
import '../order/order_details_page.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key, required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xxl),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: context.palette.success.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 56, color: context.palette.success),
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
              Text('Order placed!', style: context.text.displaySmall),
              const SizedBox(height: AppSpace.sm),
              Text(
                'Thank you for choosing our app. We are getting your order ready.',
                textAlign: TextAlign.center,
                style: context.text.bodyLarge!
                    .copyWith(color: context.palette.textMuted),
              ),
              const SizedBox(height: AppSpace.xxl),
              AppCard(
                child: Column(
                  children: [
                    _row(context, 'Order number', order.number),
                    _row(context, 'Items', '${order.units}'),
                    _row(context, 'Delivery', order.deliveryMethod),
                    _row(context, 'Total', money(order.total)),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              LoadingButton(
                label: 'Track order',
                icon: Icons.local_shipping_outlined,
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => OrderDetailsPage(order: order)),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Homepage.tab.value = Homepage.home;
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: const Text('Continue shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: context.text.bodyMedium!
                      .copyWith(color: context.palette.textMuted)),
            ),
            Text(value, style: context.text.titleSmall),
          ],
        ),
      );
}
