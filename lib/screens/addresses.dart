import 'package:flutter/material.dart';
import '../address_store.dart';
import '../auth.dart';
import '../models/order.dart';
import '../theme.dart';

const _labels = ['Home', 'Work', 'Other'];

IconData iconForLabel(String label) => switch (label) {
      'Work' => Icons.business_outlined,
      'Other' => Icons.place_outlined,
      _ => Icons.home_outlined,
    };

class AddressesScreen extends StatefulWidget {
  /// When true the screen is being used to choose an address for checkout,
  /// so tapping one selects it and closes.
  final bool selecting;

  const AddressesScreen({super.key, this.selecting = false});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    addressStore.load();
  }

  Future<void> _openEditor({Address? address}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressEditorSheet(address: address),
    );
  }

  Future<void> _confirmDelete(Address address) async {
    final c = context.c;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.surface,
        title: const Text('Delete address?'),
        content: Text(address.formatted, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: c.primary),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await addressStore.remove(address.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        title: Text(
          widget.selecting ? 'Choose address' : 'Delivery addresses',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListenableBuilder(
        listenable: addressStore,
        builder: (context, _) {
          final list = addressStore.addresses;
          if (addressStore.loading && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.greenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🏪', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'We deliver from our $kStoreArea store to nearby areas only.',
                        style: TextStyle(fontSize: 11.5, color: c.green),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? _EmptyAddresses(onAdd: () => _openEditor())
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 9),
                        itemBuilder: (context, i) => _AddressCard(
                          address: list[i],
                          selected: addressStore.selected?.id == list[i].id,
                          onTap: () {
                            addressStore.select(list[i].id);
                            if (widget.selecting) Navigator.pop(context);
                          },
                          onEdit: () => _openEditor(address: list[i]),
                          onDelete: () => _confirmDelete(list[i]),
                          onMakeDefault: () =>
                              addressStore.makeDefault(list[i].id),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: c.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyAddresses({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📍', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              'No saved addresses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: c.t0,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Add where you want your groceries delivered.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: c.t2),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeDefault;

  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeDefault,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: selected ? c.primaryBg : c.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: selected ? c.primary : c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(iconForLabel(address.label), size: 17, color: c.primary),
                  const SizedBox(width: 7),
                  Text(
                    address.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: c.t0,
                    ),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.greenBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'DEFAULT',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .5,
                          color: c.green,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle, size: 19, color: c.primary),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                address.formatted,
                style: TextStyle(fontSize: 12.5, height: 1.4, color: c.t1),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.schedule, size: 13, color: c.green),
                  const SizedBox(width: 4),
                  Text(
                    'Delivers in ${address.location.deliveryTimeMinutes} mins',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.green,
                    ),
                  ),
                ],
              ),
              if (address.recipientName.isNotEmpty ||
                  address.phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  [address.recipientName, address.phone]
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style: TextStyle(fontSize: 11.5, color: c.t2),
                ),
              ],
              Divider(height: 20, color: c.borderLight),
              Row(
                children: [
                  _MiniAction(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: onEdit,
                  ),
                  if (!address.isDefault)
                    _MiniAction(
                      icon: Icons.star_outline,
                      label: 'Set default',
                      onTap: onMakeDefault,
                    ),
                  const Spacer(),
                  _MiniAction(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    danger: true,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.label,
    this.danger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = danger ? c.primary : c.t1;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class AddressEditorSheet extends StatefulWidget {
  final Address? address;

  const AddressEditorSheet({super.key, this.address});

  @override
  State<AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<AddressEditorSheet> {
  late final _name = TextEditingController(
      text: widget.address?.recipientName ?? auth.profile?.displayName ?? '');
  late final _phone = TextEditingController(
      text: widget.address?.phone ?? auth.profile?.phone ?? '');
  late final _line1 = TextEditingController(text: widget.address?.line1 ?? '');
  late final _line2 = TextEditingController(text: widget.address?.line2 ?? '');
  late final _pincode =
      TextEditingController(text: widget.address?.pincode ?? kStorePincode);

  late String _label = widget.address?.label ?? 'Home';
  late String _area = widget.address?.area ?? kDeliveryLocations.first.name;
  late bool _makeDefault =
      widget.address?.isDefault ?? addressStore.addresses.isEmpty;

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line1.dispose();
    _line2.dispose();
    _pincode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_line1.text.trim().isEmpty) {
      setState(() => _error = 'Enter the flat, house or building');
      return;
    }
    if (_phone.text.replaceAll(RegExp(r'\D'), '').length < 10) {
      setState(() => _error = 'Enter a valid 10-digit phone number');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await addressStore.save(
        id: widget.address?.id,
        label: _label,
        recipientName: _name.text.trim(),
        phone: _phone.text.trim(),
        line1: _line1.text.trim(),
        line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
        area: _area,
        pincode: _pincode.text.trim().isEmpty ? null : _pincode.text.trim(),
        makeDefault: _makeDefault,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final location = kDeliveryLocations.firstWhere(
      (l) => l.name == _area,
      orElse: () => kDeliveryLocations.first,
    );

    return FractionallySizedBox(
      heightFactor: .92,
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.address == null ? 'Add address' : 'Edit address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: c.t0,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: c.t2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  Text(
                    'Save as',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: c.t1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final label in _labels) ...[
                        GestureDetector(
                          onTap: () => setState(() => _label = label),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color:
                                  _label == label ? c.primaryBg : c.bg,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: _label == label ? c.primary : c.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  iconForLabel(label),
                                  size: 15,
                                  color: _label == label ? c.primary : c.t2,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: _label == label ? c.primary : c.t1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Flat / House no / Building',
                    controller: _line1,
                  ),
                  _Field(
                    label: 'Street / Landmark (optional)',
                    controller: _line2,
                  ),
                  Text(
                    'Area',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: c.t1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: c.bg,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: c.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _area,
                        isExpanded: true,
                        style: TextStyle(fontSize: 13.5, color: c.t0),
                        items: [
                          for (final loc in kDeliveryLocations)
                            DropdownMenuItem(
                              value: loc.name,
                              child: Text(
                                '${loc.emoji}  ${loc.name} · ${loc.deliveryTimeMinutes} min',
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _area = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 13, color: c.t2),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Only areas near our $kStoreArea store are served. '
                          '${location.name} takes about ${location.deliveryTimeMinutes} minutes.',
                          style: TextStyle(fontSize: 11, color: c.t2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Field(label: 'Pincode', controller: _pincode),
                  Divider(height: 26, color: c.borderLight),
                  _Field(label: 'Receiver name', controller: _name),
                  _Field(
                    label: 'Receiver phone',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                  ),
                  CheckboxListTile(
                    value: _makeDefault,
                    onChanged: (v) => setState(() => _makeDefault = v ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: c.primary,
                    title: Text(
                      'Use as my default address',
                      style: TextStyle(fontSize: 12.5, color: c.t1),
                    ),
                  ),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(fontSize: 12, color: c.primary),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Save address',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13.5),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: c.bg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: c.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: c.border),
          ),
        ),
      ),
    );
  }
}
