import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../cubits/order/order_cubit.dart';
import '../../../cubits/order/order_state.dart';
import '../../../data/models.dart';
import '../Homepage/homePage.dart';
import 'order_card.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  OrderStatus? _status; // null = all

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderCubit()..fetchOrders(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderError) {
              return ErrorState(
                message: state.message,
                onRetry: () => context.read<OrderCubit>().fetchOrders(),
              );
            }
            if (state is! OrderLoaded) return const ListSkeleton(height: 180);

            if (state.orders.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message:
                    'When you place an order it will show up here so you can track it.',
                actionLabel: 'Start shopping',
                onAction: () {
                  Homepage.tab.value = Homepage.shop;
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              );
            }

            final orders = _status == null
                ? state.orders
                : state.orders.where((o) => o.status == _status).toList();

            return Column(
              children: [
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.lg, vertical: AppSpace.sm),
                    children: [
                      ChoiceChip(
                        label: Text('All (${state.orders.length})'),
                        selected: _status == null,
                        onSelected: (_) => setState(() => _status = null),
                      ),
                      for (final s in OrderStatus.values) ...[
                        const SizedBox(width: AppSpace.sm),
                        ChoiceChip(
                          label: Text(s.label),
                          selected: _status == s,
                          onSelected: (_) => setState(() => _status = s),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: orders.isEmpty
                      ? EmptyState(
                          icon: Icons.filter_list_off_rounded,
                          title: 'Nothing ${_status!.label.toLowerCase()}',
                          message:
                              'You have no orders with this status right now.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(AppSpace.lg, 4,
                              AppSpace.lg, AppSpace.xxl),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpace.md),
                          itemBuilder: (context, index) =>
                              OrderCard(order: orders[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
