import 'package:flutter/material.dart';
import '../address_store.dart';
import '../auth.dart';
import '../theme.dart';
import '../models/order.dart';
import '../order_manager.dart';
import 'addresses.dart';

const _paymentMethods = [
  ('📱', 'UPI', 'Google Pay, PhonePe, etc.'),
  ('💳', 'Debit Card', 'Visa, Mastercard'),
  ('🏦', 'Net Banking', 'All major banks'),
  ('💰', 'Cash on Delivery', 'Pay on delivery'),
];

void showCheckoutSheet(BuildContext context, VoidCallback onConfirm) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _CheckoutSheet(onConfirm: onConfirm),
  );
}

class _CheckoutSheet extends StatefulWidget {
  final VoidCallback onConfirm;

  const _CheckoutSheet({required this.onConfirm});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  bool _attemptedConfirm = false;

  @override
  void initState() {
    super.initState();
    addressStore.load();
  }

  void _confirm() {
    setState(() => _attemptedConfirm = true);
    if (addressStore.selected == null) return;
    Navigator.pop(context);
    widget.onConfirm();
  }

  Future<void> _chooseAddress() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddressesScreen(selecting: true)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _addAddress() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddressEditorSheet(),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FractionallySizedBox(
      heightFactor: .9,
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: c.t0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: c.t2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: Listenable.merge([addressStore, orderManager, auth]),
                builder: (context, _) {
                  final address = addressStore.selected;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CheckoutSection(
                          title: 'Deliver to',
                          icon: '📍',
                          content: address == null
                              ? _NoAddress(
                                  showError: _attemptedConfirm,
                                  onAdd: _addAddress,
                                )
                              : _SelectedAddress(
                                  address: address,
                                  onChange: _chooseAddress,
                                ),
                        ),
                        const SizedBox(height: 16),
                        _CheckoutSection(
                          title: 'Payment Method',
                          icon: '💳',
                          content: Column(
                            children: [
                              for (final (icon, label, description)
                                  in _paymentMethods) ...[
                                _PaymentOption(
                                  icon: icon,
                                  label: label,
                                  description: description,
                                  selected:
                                      orderManager.paymentMethod == label,
                                  onTap: () =>
                                      orderManager.setPaymentMethod(label),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: GestureDetector(
                onTap: _confirm,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A6818), Color(0xFF1EB040)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A6818).withValues(alpha: .25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedAddress extends StatelessWidget {
  final Address address;
  final VoidCallback onChange;

  const _SelectedAddress({required this.address, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: c.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconForLabel(address.label), size: 17, color: c.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: c.t0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address.formatted,
                      style:
                          TextStyle(fontSize: 12, height: 1.35, color: c.t1),
                    ),
                    if (address.recipientName.isNotEmpty ||
                        address.phone.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        [address.recipientName, address.phone]
                            .where((s) => s.isNotEmpty)
                            .join(' · '),
                        style: TextStyle(fontSize: 11.5, color: c.t2),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(
                onPressed: onChange,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Change', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('🛵', style: TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              'Arrives in about ${address.location.deliveryTimeMinutes} mins from our $kStoreArea store',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: c.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoAddress extends StatelessWidget {
  final bool showError;
  final VoidCallback onAdd;

  const _NoAddress({required this.showError, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add where we should deliver this order.',
          style: TextStyle(fontSize: 12.5, color: c.t2),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: Icon(Icons.add_location_alt_outlined,
                size: 17, color: c.primary),
            label: Text(
              'Add delivery address',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: c.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: showError ? c.primary : c.border,
                  width: showError ? 1.5 : 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),
        if (showError) ...[
          const SizedBox(height: 7),
          Text(
            'An address is needed before we can deliver.',
            style: TextStyle(fontSize: 11.5, color: c.primary),
          ),
        ],
      ],
    );
  }
}

class _CheckoutSection extends StatelessWidget {
  final String title;
  final String icon;
  final Widget content;

  const _CheckoutSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: c.t0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.primaryBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? c.primary : c.border),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.t0,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 10, color: c.t2),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: c.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
