import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../catalog.dart';
import '../catalog_store.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/product_image.dart';
import 'store_widgets.dart';

class StoreProductsView extends StatefulWidget {
  const StoreProductsView({super.key});

  @override
  State<StoreProductsView> createState() => _StoreProductsViewState();
}

class _StoreProductsViewState extends State<StoreProductsView> {
  String _query = '';
  String _category = 'all';

  List<Product> get _visible {
    final q = _query.trim().toLowerCase();
    return kProducts.where((p) {
      if (_category != 'all' && p.category != _category) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openEditor({Product? product}) async {
    await showDialog(
      context: context,
      builder: (_) => ProductEditorDialog(product: product),
    );
    if (mounted) setState(() {});
  }

  Future<void> _confirmDelete(Product product) async {
    final c = context.c;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.surface,
        title: const Text('Remove product?'),
        content: Text(
          '"${product.name}" will be removed from the shop. '
          'Past orders that include it are not affected.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: c.primary),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await catalogStore.deleteRemoteProduct(product.id);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} removed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not remove: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListenableBuilder(
      listenable: catalogStore,
      builder: (context, _) {
        final visible = _visible;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StoreHeader(
              title: 'Products',
              subtitle: '${kProducts.length} in the shop',
              onRefresh: () async {
                await catalogStore.loadRemoteProducts();
                if (mounted) setState(() {});
              },
              action: FilledButton.icon(
                onPressed: () => _openEditor(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                  backgroundColor: kNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            if (!catalogStore.loadedFromServer)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: c.primaryBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.primary.withValues(alpha: .35)),
                  ),
                  child: Text(
                    'Showing the offline copy of the catalog — changes cannot be '
                    'saved until the connection is back. Tap refresh to retry.',
                    style: TextStyle(fontSize: 11.5, color: c.primary),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: StoreSearchField(
                hint: 'Search by product or brand',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final cat in kCategories)
                    GestureDetector(
                      onTap: () => setState(() => _category = cat.key),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: _category == cat.key ? kNavy : c.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _category == cat.key ? kNavy : c.border,
                          ),
                        ),
                        child: Text(
                          '${cat.emoji} ${cat.label}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color:
                                _category == cat.key ? Colors.white : c.t1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? const StoreEmptyState(
                      emoji: '📦',
                      title: 'No matching products',
                      body: 'Try a different search or category.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => _ProductRow(
                        product: visible[i],
                        onEdit: () => _openEditor(product: visible[i]),
                        onDelete: () => _confirmDelete(visible[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onEdit,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: 62,
                height: 62,
                child: ProductImage(product: product),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: c.t0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${product.brand} · ${product.unit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: c.t2),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '₹${product.price}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: c.t0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (product.mrp != null)
                    Text(
                      '₹${product.mrp}',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: c.t2,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit',
                icon: Icon(Icons.edit_outlined, size: 18, color: c.t1),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Remove',
                icon: Icon(Icons.delete_outline, size: 18, color: c.primary),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add (product == null) or edit an existing product.
class ProductEditorDialog extends StatefulWidget {
  final Product? product;

  const ProductEditorDialog({super.key, this.product});

  @override
  State<ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<ProductEditorDialog> {
  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _brand = TextEditingController(text: widget.product?.brand ?? '');
  late final _unit = TextEditingController(text: widget.product?.unit ?? '');
  late final _packLabel =
      TextEditingController(text: widget.product?.packLabel ?? '');
  late final _price =
      TextEditingController(text: widget.product?.price.toString() ?? '');
  late final _mrp =
      TextEditingController(text: widget.product?.mrp?.toString() ?? '');
  late final _emoji =
      TextEditingController(text: widget.product?.emoji ?? '🛒');

  late String _category = widget.product?.category ??
      kCategories.firstWhere((c) => c.key != 'all').key;
  late Flag _flag = widget.product?.flag ?? Flag.none;

  Uint8List? _newImage;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.product != null;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _unit.dispose();
    _packLabel.dispose();
    _price.dispose();
    _mrp.dispose();
    _emoji.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (mounted) setState(() => _newImage = bytes);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final brand = _brand.text.trim();
    final unit = _unit.text.trim();
    final packLabel = _packLabel.text.trim();
    final price = int.tryParse(_price.text.trim());
    final mrp = _mrp.text.trim().isEmpty ? null : int.tryParse(_mrp.text.trim());

    if (name.isEmpty || brand.isEmpty || price == null) {
      setState(() => _error = 'Name, brand and a valid price are required');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (_isEdit) {
        await catalogStore.updateRemoteProduct(
          id: widget.product!.id,
          name: name,
          brand: brand,
          category: _category,
          emoji: _emoji.text.trim().isEmpty ? '🛒' : _emoji.text.trim(),
          unit: unit.isEmpty ? '1 unit' : unit,
          packLabel: packLabel.isEmpty ? name : packLabel,
          price: price,
          mrp: mrp,
          flag: _flag.name,
          newImageBytes: _newImage,
        );
      } else {
        await catalogStore.createRemoteProduct(
          name: name,
          brand: brand,
          category: _category,
          emoji: _emoji.text.trim().isEmpty ? '🛒' : _emoji.text.trim(),
          unit: unit.isEmpty ? '1 unit' : unit,
          packLabel: packLabel.isEmpty ? name : packLabel,
          price: price,
          mrp: mrp,
          imageBytes: _newImage,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? '$name updated' : '$name added')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not save: $e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Dialog(
      backgroundColor: c.surface,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? 'Edit product' : 'Add product',
                      style: TextStyle(
                        fontSize: 17,
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
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                shrinkWrap: true,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: c.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c.border),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _newImage != null
                              ? Image.memory(_newImage!, fit: BoxFit.cover)
                              : widget.product != null
                                  ? ProductImage(product: widget.product!)
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined,
                                            color: c.t2),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Photo',
                                          style: TextStyle(
                                              fontSize: 10, color: c.t2),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            _Field(label: 'Product name', controller: _name),
                            _Field(label: 'Brand', controller: _brand),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap the image to ${widget.product?.imageUrl() == null ? 'add' : 'replace'} the photo',
                    style: TextStyle(fontSize: 10.5, color: c.t2),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Labelled(
                          label: 'Category',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _category,
                              isExpanded: true,
                              isDense: true,
                              style:
                                  TextStyle(fontSize: 13, color: c.t0),
                              items: [
                                for (final cat
                                    in kCategories.where((c) => c.key != 'all'))
                                  DropdownMenuItem(
                                    value: cat.key,
                                    child: Text('${cat.emoji} ${cat.label}'),
                                  ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _category = v!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Labelled(
                          label: 'Badge',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Flag>(
                              value: _flag,
                              isExpanded: true,
                              isDense: true,
                              style:
                                  TextStyle(fontSize: 13, color: c.t0),
                              items: const [
                                DropdownMenuItem(
                                    value: Flag.none, child: Text('None')),
                                DropdownMenuItem(
                                    value: Flag.bestseller,
                                    child: Text('Bestseller')),
                                DropdownMenuItem(
                                    value: Flag.sale, child: Text('Sale')),
                                DropdownMenuItem(
                                    value: Flag.isNew, child: Text('New')),
                              ],
                              onChanged: (v) => setState(() => _flag = v!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _Field(
                              label: 'Pack size (e.g. 1 kg)',
                              controller: _unit)),
                      const SizedBox(width: 10),
                      Expanded(
                          child:
                              _Field(label: 'Emoji', controller: _emoji)),
                    ],
                  ),
                  _Field(
                      label: 'Description / pack label',
                      controller: _packLabel),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Selling price ₹',
                          controller: _price,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Field(
                          label: 'MRP ₹ (optional)',
                          controller: _mrp,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _error!,
                        style: TextStyle(fontSize: 12, color: c.primary),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: kNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _isEdit ? 'Save changes' : 'Add to shop',
                          style: const TextStyle(fontWeight: FontWeight.w800),
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

class _Labelled extends StatelessWidget {
  final String label;
  final Widget child;

  const _Labelled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: c.t1,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: c.border),
          ),
          child: child,
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Labelled(
        label: label,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 9),
          ),
        ),
      ),
    );
  }
}
