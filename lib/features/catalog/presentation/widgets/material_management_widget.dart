import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../../domain/entities/catalog_request.dart';
import '../bloc/catalog_requests_bloc.dart';

/// Widget for managing materials in catalog requests
/// Allows inline editing, adding, removing, and price modifications
class MaterialManagementWidget extends StatefulWidget {
  final String requestId;
  final List<CatalogMaterial> initialMaterials;
  final bool isEditable;
  final Function(List<CatalogMaterial>)? onMaterialsChanged;

  const MaterialManagementWidget({
    required this.requestId,
    required this.initialMaterials,
    super.key,
    this.isEditable = true,
    this.onMaterialsChanged,
  });

  @override
  State<MaterialManagementWidget> createState() =>
      _MaterialManagementWidgetState();
}

class _MaterialManagementWidgetState extends State<MaterialManagementWidget> {
  late List<_EditableMaterial> _materials;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _materials = widget.initialMaterials
        .map((material) => _EditableMaterial.fromCatalogMaterial(material))
        .toList();
  }

  @override
  void dispose() {
    for (final material in _materials) {
      material.dispose();
    }
    super.dispose();
  }

  void _addMaterial() {
    setState(() {
      _materials.add(_EditableMaterial.empty());
      _hasChanges = true;
    });
  }

  void _removeMaterial(int index) {
    setState(() {
      _materials[index].dispose();
      _materials.removeAt(index);
      _hasChanges = true;
      _notifyChanges();
    });
  }

  void _onMaterialChanged() {
    setState(() {
      _hasChanges = true;
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final catalogMaterials = _materials
        .where((m) => m.description.isNotEmpty)
        .map((m) => m.toCatalogMaterial())
        .toList();
    widget.onMaterialsChanged?.call(catalogMaterials);
  }

  void _saveMaterials() {
    final catalogMaterials = _materials
        .where((m) => m.description.isNotEmpty)
        .map((m) => m.toCatalogMaterial())
        .toList();

    context.read<CatalogRequestsBloc>().add(
          UpdateRequestMaterials(widget.requestId, catalogMaterials),
        );

    setState(() {
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Materials updated successfully')),
    );
  }

  void _sendToClient() {
    final catalogMaterials = _materials
        .where((m) => m.description.isNotEmpty)
        .map((m) => m.toCatalogMaterial())
        .toList();

    context.read<CatalogRequestsBloc>().add(
          SendMaterialModification(widget.requestId, catalogMaterials),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Material modifications sent to client')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with actions
        Row(
          children: [
            Expanded(
              child: Text(
                'Materials (${_materials.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (widget.isEditable) ...[
              if (_hasChanges) ...[
                TextAppButton(
                  text: 'Save',
                  onPressed: _saveMaterials,
                ),
                AppSpacing.spaceSM,
              ],
              IconButton(
                onPressed: _addMaterial,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Material',
              ),
            ],
          ],
        ),

        AppSpacing.spaceMD,

        // Materials list
        if (_materials.isEmpty)
          _buildEmptyState()
        else
          Column(
            children: [
              for (int i = 0; i < _materials.length; i++) _buildMaterialItem(i),

              // Total calculation
              if (_materials.isNotEmpty) _buildTotalSection(),
            ],
          ),

        // Action buttons
        if (widget.isEditable && _materials.isNotEmpty) ...[
          AppSpacing.spaceLG,
          _buildActionButtons(),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingXXXL,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          AppSpacing.spaceMD,
          Text(
            'No materials added yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          AppSpacing.spaceXS,
          Text(
            widget.isEditable
                ? 'Tap the + button to add materials'
                : 'Materials will appear here once added',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(int index) {
    final material = _materials[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with remove button
          Row(
            children: [
              Expanded(
                child: Text(
                  'Material ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownHeader,
                      ),
                ),
              ),
              if (widget.isEditable)
                IconButton(
                  onPressed: () => _removeMaterial(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remove Material',
                ),
            ],
          ),

          AppSpacing.spaceMD,

          // Description field
          TextField(
            controller: material.descriptionController,
            enabled: widget.isEditable,
            decoration: const InputDecoration(
              labelText: 'Description *',
              hintText: 'Enter material description',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            maxLines: 2,
            onChanged: (_) => _onMaterialChanged(),
          ),

          AppSpacing.spaceMD,

          // Quantity and price row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: material.quantityController,
                  enabled: widget.isEditable,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _onMaterialChanged(),
                ),
              ),
              AppSpacing.spaceMD,
              Expanded(
                flex: 3,
                child: TextField(
                  controller: material.priceController,
                  enabled: widget.isEditable,
                  decoration: const InputDecoration(
                    labelText: 'Price (₦)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _onMaterialChanged(),
                ),
              ),
            ],
          ),

          // Total for this material
          if (material.hasValidData) ...[
            AppSpacing.spaceSM,
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Text(
                  'Total: ₦${material.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    final totalPrice = _materials
        .where((m) => m.hasValidData)
        .fold<double>(0.0, (sum, material) => sum + material.totalPrice);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Materials Cost',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            '₦${totalPrice.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedAppButton(
            text: 'Save Changes',
            onPressed: _hasChanges ? _saveMaterials : null,
          ),
        ),
        AppSpacing.spaceMD,
        Expanded(
          child: PrimaryButton(
            text: 'Send to Client',
            onPressed: _sendToClient,
          ),
        ),
      ],
    );
  }
}

/// Helper class for managing editable material data
class _EditableMaterial {
  final TextEditingController descriptionController;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  _EditableMaterial({
    required this.descriptionController,
    required this.quantityController,
    required this.priceController,
  });

  factory _EditableMaterial.fromCatalogMaterial(CatalogMaterial material) {
    return _EditableMaterial(
      descriptionController: TextEditingController(text: material.description),
      quantityController: TextEditingController(
        text: material.quantity?.toString() ?? '1',
      ),
      priceController: TextEditingController(
        text: material.price?.toString() ?? '',
      ),
    );
  }

  factory _EditableMaterial.empty() {
    return _EditableMaterial(
      descriptionController: TextEditingController(),
      quantityController: TextEditingController(text: '1'),
      priceController: TextEditingController(),
    );
  }

  String get description => descriptionController.text.trim();
  int get quantity => int.tryParse(quantityController.text.trim()) ?? 1;
  int get price => int.tryParse(priceController.text.trim()) ?? 0;
  double get totalPrice => quantity * price.toDouble();

  bool get hasValidData => description.isNotEmpty && price > 0;

  CatalogMaterial toCatalogMaterial() {
    return CatalogMaterial(
      description: description,
      quantity: quantity,
      price: price,
    );
  }

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}
