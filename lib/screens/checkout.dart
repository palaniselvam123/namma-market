import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/order.dart';
import '../order_manager.dart';

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
  late final _nameController =
      TextEditingController(text: orderManager.customerName);
  late final _phoneController =
      TextEditingController(text: orderManager.customerPhone);
  bool _attemptedConfirm = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? get _nameError =>
      _attemptedConfirm && _nameController.text.trim().isEmpty
          ? 'Enter your name'
          : null;

  String? get _phoneError {
    if (!_attemptedConfirm) return null;
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Enter your phone number';
    if (digits.length < 10) return 'Enter a valid 10-digit number';
    return null;
  }

  void _confirm() {
    setState(() => _attemptedConfirm = true);
    if (_nameError != null || _phoneError != null) return;

    orderManager.setCustomer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    Navigator.pop(context);
    widget.onConfirm();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CheckoutSection(
                      title: 'Your Details',
                      icon: '👤',
                      content: Column(
                        children: [
                          _CheckoutField(
                            hint: 'Full name',
                            controller: _nameController,
                            errorText: _nameError,
                            onChanged: (_) {
                              if (_attemptedConfirm) setState(() {});
                            },
                          ),
                          const SizedBox(height: 10),
                          _CheckoutField(
                            hint: 'Phone number',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            errorText: _phoneError,
                            onChanged: (_) {
                              if (_attemptedConfirm) setState(() {});
                            },
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'So the store can reach you about this delivery',
                              style: TextStyle(fontSize: 10.5, color: c.t2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CheckoutSection(
                      title: 'Delivery Address',
                      icon: '📍',
                      content: ListenableBuilder(
                        listenable: orderManager,
                        builder: (context, _) => GestureDetector(
                          onTap: () => _showAddressOptions(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: c.bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: c.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        orderManager.selectedLocation.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: c.t0,
                                        ),
                                      ),
                                      Text(
                                        'Delivery in ${orderManager.selectedLocation.deliveryTimeMinutes} mins',
                                        style: TextStyle(
                                            fontSize: 11, color: c.t2),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: c.t2, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CheckoutSection(
                      title: 'Payment Method',
                      icon: '💳',
                      content: ListenableBuilder(
                        listenable: orderManager,
                        builder: (context, _) => Column(
                          children: [
                            for (final (icon, label, description)
                                in _paymentMethods) ...[
                              _PaymentOption(
                                icon: icon,
                                label: label,
                                description: description,
                                selected: orderManager.paymentMethod == label,
                                onTap: () =>
                                    orderManager.setPaymentMethod(label),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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

class _CheckoutField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _CheckoutField({
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        isDense: true,
        filled: true,
        fillColor: c.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
      ),
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

void _showAddressOptions(BuildContext context) {
  final c = context.c;
  showDialog(
    context: context,
    useRootNavigator: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Delivery Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: c.t0,
                  ),
                ),
                const SizedBox(height: 14),
                for (final location in kDeliveryLocations) ...[
                  GestureDetector(
                    onTap: () {
                      orderManager.setDeliveryLocation(location);
                      Navigator.pop(dialogContext);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            orderManager.selectedLocation.name == location.name
                                ? c.primaryBg
                                : c.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: orderManager.selectedLocation.name ==
                                  location.name
                              ? c.primary
                              : c.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(location.emoji,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: c.t0,
                                  ),
                                ),
                                Text(
                                  'Arrives in ${location.deliveryTimeMinutes} mins',
                                  style:
                                      TextStyle(fontSize: 11, color: c.t2),
                                ),
                              ],
                            ),
                          ),
                          if (orderManager.selectedLocation.name ==
                              location.name)
                            Icon(Icons.check_circle, color: c.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
