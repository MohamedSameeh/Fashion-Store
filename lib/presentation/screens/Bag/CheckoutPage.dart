import 'package:depi_final_project/presentation/screens/Bag/ShippingAddressesPage.dart';
import 'package:depi_final_project/presentation/screens/Bag/SuccessPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/cart/cart_state.dart';
import '../../../data/models.dart';
import '../../../data/store_repository.dart';

/// Orders at or above this subtotal get free standard delivery.
const double kFreeDeliveryThreshold = 150;

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const _payments = [
    ('Card ending 4242', Icons.credit_card_rounded, 'Saved card'),
    ('Cash on delivery', Icons.payments_outlined, 'Pay when it arrives'),
  ];

  DeliveryOption selectedDelivery = DeliveryOption.all.first;
  int _payment = 0;
  String? _addressId; // null = use the default address

  double _feeFor(DeliveryOption d, double subtotal) =>
      d.id == 'standard' && subtotal >= kFreeDeliveryThreshold ? 0 : d.fee;

  Address? _pick(List<Address> all) {
    if (all.isEmpty) return null;
    for (final a in all) {
      if (a.id == _addressId) return a;
    }
    return all.firstWhere((a) => a.isDefault, orElse: () => all.first);
  }

  Future<void> _changeAddress() async {
    final picked = await Navigator.push<Address>(
      context,
      MaterialPageRoute(
          builder: (_) => const ShippingAddressesPage(selectMode: true)),
    );
    if (picked != null) setState(() => _addressId = picked.id);
  }

  Widget _section(String title, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.only(top: AppSpace.xl, bottom: AppSpace.sm),
        child: Row(
          children: [
            Expanded(child: Text(title, style: context.text.titleMedium)),
            if (trailing != null) trailing,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listenWhen: (_, s) => s is CheckoutSuccess || s is CheckoutFailure,
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SuccessPage(order: state.order)),
          );
        } else if (state is CheckoutFailure) {
          showAppSnack(context, state.errorMessage);
        }
      },
      buildWhen: (_, s) => s is CartLoaded,
      builder: (context, state) {
        final loaded = state is CartLoaded ? state : null;
        final subtotal = loaded?.totalAmount ?? 0;
        final fee = _feeFor(selectedDelivery, subtotal);
        final submitting = state is CheckoutInProgress;

        return StreamBuilder<List<Address>>(
          stream: _addresses,
          builder: (context, snapshot) {
            final address = _pick(snapshot.data ?? const []);
            return Scaffold(
              appBar: AppBar(title: const Text('Checkout')),
              bottomNavigationBar: BottomActionBar(
                child: LoadingButton(
                  label: 'Submit order  ·  ${money(subtotal + fee)}',
                  loading: submitting,
                  onPressed: loaded == null || address == null
                      ? null
                      : () => context.read<CartCubit>().handleCheckout(
                            address: address,
                            delivery: DeliveryOption(
                                selectedDelivery.id,
                                selectedDelivery.label,
                                selectedDelivery.eta,
                                fee),
                            paymentLabel: _payments[_payment].$1,
                          ),
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.lg, 0, AppSpace.lg, AppSpace.xxl),
                children: [
                  _section('Shipping address'),
                  if (!snapshot.hasData)
                    const Skeleton(height: 92, radius: AppRadius.lg)
                  else if (address == null)
                    AppCard(
                      onTap: _changeAddress,
                      child: Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Text('Add a shipping address',
                                style: context.text.titleSmall),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.palette.surfaceAlt,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on_outlined,
                                size: 20),
                          ),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(address.name,
                                    style: context.text.titleSmall),
                                const SizedBox(height: 2),
                                Text(address.line,
                                    style: context.text.bodySmall),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _changeAddress,
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    ),
                  _section('Payment'),
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: RadioGroup<int>(
                      groupValue: _payment,
                      onChanged: (v) => setState(() => _payment = v ?? 0),
                      child: Column(
                        children: [
                          for (var i = 0; i < _payments.length; i++)
                            RadioListTile<int>(
                              value: i,
                              dense: true,
                              controlAffinity:
                                  ListTileControlAffinity.trailing,
                              secondary: Icon(_payments[i].$2),
                              title: Text(_payments[i].$1),
                              subtitle: Text(_payments[i].$3),
                            ),
                        ],
                      ),
                    ),
                  ),
                  _section('Delivery method'),
                  Row(
                    children: [
                      for (final d in DeliveryOption.all) ...[
                        Expanded(
                          child: DeliveryMethodButton(
                            option: d,
                            fee: _feeFor(d, subtotal),
                            isSelected: selectedDelivery.id == d.id,
                            onTap: () =>
                                setState(() => selectedDelivery = d),
                          ),
                        ),
                        if (d != DeliveryOption.all.last)
                          const SizedBox(width: AppSpace.sm),
                      ],
                    ],
                  ),
                  if (loaded != null) ...[
                    _section('Order summary',
                        trailing: Text(
                            '${loaded.units} ${loaded.units == 1 ? 'item' : 'items'}',
                            style: context.text.bodySmall)),
                    AppCard(
                      child: Column(
                        children: [
                          for (final item in loaded.cartItems)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpace.md),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                    child: SizedBox(
                                        width: 44,
                                        height: 52,
                                        child: ProductImage(item.image)),
                                  ),
                                  const SizedBox(width: AppSpace.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.text.titleSmall),
                                        Text(
                                            '${item.size} · ${item.color} · x${item.quantity}',
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
                          _SummaryRow('Order', money(subtotal)),
                          _SummaryRow(
                              'Delivery (${selectedDelivery.label})',
                              fee == 0 ? 'Free' : money(fee)),
                          const SizedBox(height: 4),
                          _SummaryRow('Total', money(subtotal + fee),
                              strong: true),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  late final Stream<List<Address>> _addresses = Repo.store.watchAddresses();
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.strong = false});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
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
}

class DeliveryMethodButton extends StatelessWidget {
  final DeliveryOption option;
  final double fee;
  final bool isSelected;
  final VoidCallback onTap;

  const DeliveryMethodButton({
    super.key,
    required this.option,
    required this.fee,
    required this.isSelected,
    required this.onTap,
  });

  static const _icons = {
    'standard': Icons.local_shipping_outlined,
    'express': Icons.bolt_rounded,
    'nextday': Icons.rocket_launch_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final c = isSelected ? context.colors.primary : context.colors.outline;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${option.label} delivery',
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.sm, vertical: AppSpace.md),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primaryContainer
                : context.colors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: c, width: isSelected ? 1.6 : 1),
          ),
          child: ExcludeSemantics(
            child: Column(
              children: [
                Icon(_icons[option.id] ?? Icons.local_shipping_outlined,
                    color: isSelected ? context.colors.primary : null),
                const SizedBox(height: 6),
                Text(option.label, style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(option.eta,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall!.copyWith(fontSize: 11)),
                const SizedBox(height: 4),
                Text(fee == 0 ? 'Free' : money(fee),
                    style: context.text.labelMedium!.copyWith(
                        color: fee == 0 ? context.palette.success : null)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
