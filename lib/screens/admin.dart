import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../catalog.dart';
import '../catalog_store.dart';
import '../models.dart';
import '../supabase_config.dart';
import '../theme.dart';

/// Client-side-only gate — enough to keep casual shoppers out of the admin
/// panel for this POC. Not real auth: anyone reading the source (or the
/// public anon key) could bypass it. Fine for a small store demo, not for
/// production.
const _adminPassword = 'maharaja2026';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    return _unlocked
        ? const _AdminPanel()
        : _PasswordGate(onUnlock: () => setState(() => _unlocked = true));
  }
}

class _PasswordGate extends StatefulWidget {
  final VoidCallback onUnlock;
  const _PasswordGate({required this.onUnlock});

  @override
  State<_PasswordGate> createState() => _PasswordGateState();
}

class _PasswordGateState extends State<_PasswordGate> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text == _adminPassword) {
      widget.onUnlock();
    } else {
      setState(() => _error = 'Incorrect password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      color: c.bg,
      child: Column(
        children: [
          _AdminAppBar(title: 'Admin Access'),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔒', style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: c.t0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter the admin password to add products',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: c.t2),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      obscureText: true,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        errorText: _error,
                        filled: true,
                        fillColor: c.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: c.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _submit,
                      child: Container(
                        width: double.infinity,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Unlock',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAppBar extends StatelessWidget {
  final String title;
  const _AdminAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Icon(Icons.arrow_back, color: c.t1),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: c.t0,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPanel extends StatefulWidget {
  const _AdminPanel();

  @override
  State<_AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<_AdminPanel> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _unitController = TextEditingController();
  final _packLabelController = TextEditingController();
  final _priceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _emojiController = TextEditingController(text: '🛒');

  String _category = kCategories.firstWhere((c) => c.key != 'all').key;
  Uint8List? _imageBytes;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _unitController.dispose();
    _packLabelController.dispose();
    _priceController.dispose();
    _mrpController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  void _showImageSourceSheet() {
    final c = context.c;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final unit = _unitController.text.trim();
    final packLabel = _packLabelController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    final mrp = _mrpController.text.trim().isEmpty
        ? null
        : int.tryParse(_mrpController.text.trim());
    final emoji = _emojiController.text.trim().isEmpty
        ? '🛒'
        : _emojiController.text.trim();

    if (name.isEmpty ||
        brand.isEmpty ||
        unit.isEmpty ||
        packLabel.isEmpty ||
        price == null) {
      setState(() => _error = 'Fill in name, brand, unit, pack label and a valid price');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      String? imageUrl;
      if (_imageBytes != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.jpg';
        await supabase.storage
            .from('product-images')
            .uploadBinary(fileName, _imageBytes!);
        imageUrl = supabase.storage.from('product-images').getPublicUrl(fileName);
      }

      final row = await supabase
          .from('products')
          .insert({
            'name': name,
            'brand': brand,
            'category': _category,
            'emoji': emoji,
            'unit': unit,
            'pack_label': packLabel,
            'price': price,
            'mrp': mrp,
            'image_url': imageUrl,
          })
          .select()
          .single();

      final product = Product(
        id: 100000 + (row['id'] as int),
        name: name,
        brand: brand,
        category: _category,
        emoji: emoji,
        unit: unit,
        packLabel: packLabel,
        price: price,
        mrp: mrp,
        image: imageUrl,
      );
      catalogStore.addLocal(product);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added to the catalog')),
      );

      setState(() {
        _nameController.clear();
        _brandController.clear();
        _unitController.clear();
        _packLabelController.clear();
        _priceController.clear();
        _mrpController.clear();
        _emojiController.text = '🛒';
        _imageBytes = null;
        _saving = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not save product: $e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      color: c.bg,
      child: Column(
        children: [
          const _AdminAppBar(title: 'Add Product'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 32, color: c.t2),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to take a photo or upload an image',
                                style: TextStyle(fontSize: 12, color: c.t2),
                              ),
                            ],
                          )
                        : Image.memory(_imageBytes!, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 16),
                _Field(label: 'Product Name', controller: _nameController),
                _Field(label: 'Brand', controller: _brandController),
                const SizedBox(height: 4),
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.t1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _category,
                      isExpanded: true,
                      items: [
                        for (final cat in kCategories.where((c) => c.key != 'all'))
                          DropdownMenuItem(value: cat.key, child: Text(cat.label)),
                      ],
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _Field(label: 'Unit (e.g. 1 kg, 500 ml)', controller: _unitController),
                _Field(label: 'Pack Label (e.g. Whole Wheat Atta)', controller: _packLabelController),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Price (₹)',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'MRP (₹, optional)',
                        controller: _mrpController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                _Field(label: 'Emoji (fallback icon)', controller: _emojiController),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: c.primary, fontSize: 12)),
                ],
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _saving ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _saving ? c.t3 : c.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Add Product',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.t1,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: c.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: c.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
