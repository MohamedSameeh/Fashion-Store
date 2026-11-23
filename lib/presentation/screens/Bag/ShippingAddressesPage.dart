import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models.dart';
import '../../../data/store_repository.dart';

/// Saved shipping addresses: add, edit, delete, choose the default.
/// With [selectMode] a tap returns the address to the caller (checkout).
class ShippingAddressesPage extends StatefulWidget {
  const ShippingAddressesPage({super.key, this.selectMode = false});
  final bool selectMode;

  @override
  State<ShippingAddressesPage> createState() => _ShippingAddressesPageState();
}

class _ShippingAddressesPageState extends State<ShippingAddressesPage> {
  late final Stream<List<Address>> _stream = Repo.store.watchAddresses();

  Future<void> _edit([Address? existing]) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: existing?.name ?? '');
    final line = TextEditingController(text: existing?.line ?? '');
    final phone = TextEditingController(text: existing?.phone ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl,
            AppSpace.xl + MediaQuery.viewInsetsOf(context).bottom),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Add new address' : 'Edit address',
                  style: context.text.headlineSmall),
              const SizedBox(height: AppSpace.lg),
              TextFormField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: AppSpace.md),
              TextFormField(
                controller: line,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Street, city, postcode, country'),
                validator: (v) => (v ?? '').trim().length < 8
                    ? 'Enter the full address'
                    : null,
              ),
              const SizedBox(height: AppSpace.md),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Phone (optional)'),
              ),
              const SizedBox(height: AppSpace.xl),
              LoadingButton(
                label: existing == null ? 'Add address' : 'Save changes',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true) {
      await Repo.store.saveAddress(Address(
        id: existing?.id ?? '',
        name: name.text.trim(),
        line: line.text.trim(),
        phone: phone.text.trim(),
        isDefault: existing?.isDefault ?? false,
      ));
      if (mounted) {
        showAppSnack(
            context, existing == null ? 'Address added' : 'Address updated');
      }
    }
  }

  Future<void> _delete(Address a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('${a.name}\n${a.line}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await Repo.store.deleteAddress(a.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.selectMode ? 'Choose address' : 'Shipping addresses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add address'),
      ),
      body: StreamBuilder<List<Address>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorState(
                message: 'We could not load your addresses.');
          }
          if (!snapshot.hasData) return const ListSkeleton(count: 3);
          final addresses = snapshot.data!;
          if (addresses.isEmpty) {
            return EmptyState(
              icon: Icons.location_off_outlined,
              title: 'No addresses yet',
              message: 'Add a shipping address to check out faster.',
              actionLabel: 'Add address',
              onAction: () => _edit(),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.lg, AppSpace.lg, AppSpace.lg, 96),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpace.md),
            itemBuilder: (context, index) {
              final a = addresses[index];
              return AddressCard(
                address: a,
                onTap: widget.selectMode
                    ? () => Navigator.pop(context, a)
                    : null,
                onEdit: () => _edit(a),
                onDelete: () => _delete(a),
                onMakeDefault: () => Repo.store.setDefaultAddress(a.id),
              );
            },
          );
        },
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeDefault;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeDefault,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, 4, AppSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(address.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: AppSpace.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text('Default',
                            style: context.text.labelSmall!.copyWith(
                                color: context.colors.onPrimaryContainer)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(address.line, style: context.text.bodySmall),
                if (address.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(address.phone, style: context.text.bodySmall),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Address options',
            onSelected: (v) => switch (v) {
              'edit' => onEdit(),
              'default' => onMakeDefault(),
              _ => onDelete(),
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              if (!address.isDefault)
                const PopupMenuItem(
                    value: 'default', child: Text('Set as default')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
