import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../catalog.dart';
import '../catalog_store.dart';
import '../theme.dart';
import 'admin.dart';

/// A photo the user just added, still waiting on the AI to identify what's
/// in it. Shows as a spinner placeholder until it resolves into zero, one,
/// or many [_Draft] cards.
class _PendingPhoto {
  final Uint8List bytes;
  _PendingPhoto(this.bytes);
}

class _Draft {
  final Uint8List imageBytes;
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final unitController = TextEditingController();
  final packLabelController = TextEditingController();
  final priceController = TextEditingController();
  final mrpController = TextEditingController();
  final emojiController = TextEditingController(text: '🛒');
  String category = kCategories.firstWhere((c) => c.key != 'all').key;

  String? analyzeError;
  bool saved = false;

  _Draft(this.imageBytes);

  void dispose() {
    nameController.dispose();
    brandController.dispose();
    unitController.dispose();
    packLabelController.dispose();
    priceController.dispose();
    mrpController.dispose();
    emojiController.dispose();
  }
}

class BulkAddScreen extends StatefulWidget {
  const BulkAddScreen({super.key});

  @override
  State<BulkAddScreen> createState() => _BulkAddScreenState();
}

class _BulkAddScreenState extends State<BulkAddScreen> {
  final List<_PendingPhoto> _pending = [];
  final List<_Draft> _drafts = [];
  bool _savingAll = false;

  @override
  void dispose() {
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _addFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(maxWidth: 2000, imageQuality: 90);
    for (final file in picked) {
      _addPending(await file.readAsBytes());
    }
  }

  Future<void> _addFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2000,
      imageQuality: 90,
    );
    if (picked != null) _addPending(await picked.readAsBytes());
  }

  void _addPending(Uint8List bytes) {
    final pending = _PendingPhoto(bytes);
    setState(() => _pending.add(pending));
    _analyze(pending);
  }

  /// One photo can yield zero (nothing recognizable), one (a close-up), or
  /// many (a shelf) products — each becomes its own cropped, editable draft.
  Future<void> _analyze(_PendingPhoto pending) async {
    try {
      final products = await catalogStore.analyzeShelfPhoto(pending.bytes);
      for (final fields in products) {
        final boundingBox = fields['boundingBox'] as Map<String, dynamic>?;
        final cropped = boundingBox == null
            ? pending.bytes
            : catalogStore.cropToBoundingBox(pending.bytes, boundingBox);

        final draft = _Draft(cropped);
        draft.nameController.text = (fields['name'] as String?) ?? '';
        draft.brandController.text = (fields['brand'] as String?) ?? '';
        draft.unitController.text = (fields['unit'] as String?) ?? '';
        draft.packLabelController.text = (fields['packLabel'] as String?) ?? '';
        final price = fields['price'];
        draft.priceController.text = price == null ? '' : '$price';
        final emoji = fields['emoji'] as String?;
        if (emoji != null && emoji.isNotEmpty) draft.emojiController.text = emoji;
        final category = fields['category'] as String?;
        if (category != null && kCategories.any((c) => c.key == category)) {
          draft.category = category;
        }
        _drafts.add(draft);
      }
      if (products.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No recognizable products found in that photo')),
        );
      }
    } catch (e) {
      final draft = _Draft(pending.bytes);
      draft.analyzeError = 'AI couldn\'t read this photo — fill in details manually';
      _drafts.add(draft);
    } finally {
      if (mounted) setState(() => _pending.remove(pending));
    }
  }

  void _removeDraft(_Draft draft) {
    setState(() => _drafts.remove(draft));
    draft.dispose();
  }

  Future<void> _saveAll() async {
    setState(() => _savingAll = true);
    var successCount = 0;
    final failures = <String>[];

    for (final draft in _drafts.where((d) => !d.saved)) {
      final name = draft.nameController.text.trim();
      final brand = draft.brandController.text.trim();
      final unit = draft.unitController.text.trim();
      final packLabel = draft.packLabelController.text.trim();
      final price = int.tryParse(draft.priceController.text.trim());

      if (name.isEmpty || brand.isEmpty || unit.isEmpty || packLabel.isEmpty || price == null) {
        failures.add(name.isEmpty ? 'Unnamed product' : name);
        continue;
      }

      try {
        await catalogStore.createRemoteProduct(
          name: name,
          brand: brand,
          category: draft.category,
          emoji: draft.emojiController.text.trim().isEmpty
              ? '🛒'
              : draft.emojiController.text.trim(),
          unit: unit,
          packLabel: packLabel,
          price: price,
          mrp: draft.mrpController.text.trim().isEmpty
              ? null
              : int.tryParse(draft.mrpController.text.trim()),
          imageBytes: draft.imageBytes,
        );
        draft.saved = true;
        successCount++;
      } catch (e) {
        failures.add(name);
      }
    }

    if (!mounted) return;
    setState(() {
      _drafts.removeWhere((d) => d.saved);
      _savingAll = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failures.isEmpty
              ? '$successCount products added to the catalog'
              : '$successCount added · ${failures.length} need attention: ${failures.join(', ')}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      color: c.bg,
      child: Column(
        children: [
          const AdminAppBar(title: 'Bulk Add with AI'),
          Expanded(
            child: _drafts.isEmpty && _pending.isEmpty
                ? _EmptyState(onGallery: _addFromGallery, onCamera: _addFromCamera)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _AddMoreButton(
                              icon: Icons.photo_library,
                              label: 'Add from Gallery',
                              onTap: _addFromGallery,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _AddMoreButton(
                              icon: Icons.photo_camera,
                              label: 'Take Photo',
                              onTap: _addFromCamera,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (final pending in _pending) ...[
                        _PendingCard(bytes: pending.bytes),
                        const SizedBox(height: 12),
                      ],
                      for (final draft in _drafts) ...[
                        _DraftCard(draft: draft, onRemove: () => _removeDraft(draft)),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
          ),
          if (_drafts.isNotEmpty) _SaveAllBar(
            count: _drafts.length,
            saving: _savingAll,
            enabled: !_savingAll && _pending.isEmpty,
            onSave: _saveAll,
          ),
        ],
      ),
    );
  }
}

class _SaveAllBar extends StatelessWidget {
  final int count;
  final bool saving;
  final bool enabled;
  final VoidCallback onSave;

  const _SaveAllBar({
    required this.count,
    required this.saving,
    required this.enabled,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: GestureDetector(
        onTap: enabled ? onSave : null,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? c.primary : c.t3,
            borderRadius: BorderRadius.circular(12),
          ),
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Save All ($count)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _EmptyState({required this.onGallery, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Add products in bulk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: c.t0),
            ),
            const SizedBox(height: 6),
            Text(
              'Upload several package photos at once. AI reads the brand, name, size and price off each one — you just review and save.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: c.t2, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _AddMoreButton(
                    icon: Icons.photo_library,
                    label: 'Choose Photos',
                    onTap: onGallery,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AddMoreButton(
                    icon: Icons.photo_camera,
                    label: 'Take Photo',
                    onTap: onCamera,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddMoreButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: c.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.t1),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final Uint8List bytes;

  const _PendingCard({required this.bytes});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.memory(bytes, width: 84, height: 84, fit: BoxFit.cover),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: c.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI is scanning for products…',
                      style: TextStyle(fontSize: 12, color: c.t2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatefulWidget {
  final _Draft draft;
  final VoidCallback onRemove;

  const _DraftCard({required this.draft, required this.onRemove});

  @override
  State<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<_DraftCard> {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final draft = widget.draft;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.memory(draft.imageBytes, width: 84, height: 84, fit: BoxFit.cover),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.nameController.text.isEmpty
                            ? 'Untitled product'
                            : draft.nameController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: c.t0,
                        ),
                      ),
                      if (draft.analyzeError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            draft.analyzeError!,
                            style: TextStyle(fontSize: 11, color: c.primary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.close, size: 18, color: c.t2),
                ),
              ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  _MiniField(label: 'Name', controller: draft.nameController),
                  Row(
                    children: [
                      Expanded(child: _MiniField(label: 'Brand', controller: draft.brandController)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CategoryDropdown(
                          value: draft.category,
                          onChanged: (v) => setState(() => draft.category = v),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _MiniField(label: 'Unit', controller: draft.unitController)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniField(
                          label: 'Pack Label',
                          controller: draft.packLabelController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniField(
                          label: 'Price ₹',
                          controller: draft.priceController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniField(
                          label: 'MRP ₹ (optional)',
                          controller: draft.mrpController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.t1)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                style: TextStyle(fontSize: 12, color: c.t0),
                items: [
                  for (final cat in kCategories.where((c) => c.key != 'all'))
                    DropdownMenuItem(value: cat.key, child: Text(cat.label)),
                ],
                onChanged: (v) => onChanged(v!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _MiniField({required this.label, required this.controller, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.t1)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: c.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: c.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
