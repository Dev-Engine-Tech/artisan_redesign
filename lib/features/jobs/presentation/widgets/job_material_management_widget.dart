import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/jobs/domain/entities/material.dart'
    as job_material;

class JobMaterialManagementWidget extends StatefulWidget {
  final List<job_material.Material> materials;
  final bool readOnly;
  final Function(List<job_material.Material>)? onMaterialsChanged;
  final String title;

  const JobMaterialManagementWidget({
    super.key,
    required this.materials,
    this.readOnly = true,
    this.onMaterialsChanged,
    this.title = 'Material List',
  });

  @override
  State<JobMaterialManagementWidget> createState() =>
      _JobMaterialManagementWidgetState();
}

class _JobMaterialManagementWidgetState
    extends State<JobMaterialManagementWidget> {
  late List<job_material.Material> _materials;

  @override
  void initState() {
    super.initState();
    _materials = List.from(widget.materials);
  }

  @override
  void didUpdateWidget(JobMaterialManagementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.materials != widget.materials) {
      _materials = List.from(widget.materials);
    }
  }

  double get totalCost {
    return _materials.fold(0.0, (sum, material) => sum + material.totalPrice);
  }

  void _addMaterial() {
    setState(() {
      _materials.add(
        const job_material.Material(
          id: 0,
          name: '',
          description: '',
          quantity: 1,
          price: 0.0,
          unit: 'pcs',
        ),
      );
    });
    _notifyChanges();
  }

  void _removeMaterial(int index) {
    setState(() {
      _materials.removeAt(index);
    });
    _notifyChanges();
  }

  void _updateMaterial(int index, job_material.Material material) {
    setState(() {
      _materials[index] = material;
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    widget.onMaterialsChanged?.call(_materials);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownHeader,
                    ),
              ),
            ),
            if (!widget.readOnly)
              IconButton(
                onPressed: _addMaterial,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.orange,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.softPeach,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_materials.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.black26,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.readOnly
                        ? 'No materials specified'
                        : 'No materials added yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  if (!widget.readOnly) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tap the + button to add materials',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black38,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Material Description',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brownHeader,
                                  ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Qty',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brownHeader,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Unit Price',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brownHeader,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Total',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brownHeader,
                                  ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      if (!widget.readOnly) const SizedBox(width: 40),
                    ],
                  ),
                ),
                ...List.generate(_materials.length, (index) {
                  return _MaterialRow(
                    material: _materials[index],
                    readOnly: widget.readOnly,
                    onChanged: (material) => _updateMaterial(index, material),
                    onRemove: () => _removeMaterial(index),
                  );
                }),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.softPeach.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Total Material Cost',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brownHeader,
                                  ),
                        ),
                      ),
                      const Expanded(flex: 2, child: SizedBox()),
                      const Expanded(flex: 3, child: SizedBox()),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'NGN ${totalCost.toStringAsFixed(0).replaceAllMapped(
                                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                (match) => '${match[1]},',
                              )}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brownHeader,
                                  ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      if (!widget.readOnly) const SizedBox(width: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MaterialRow extends StatefulWidget {
  final job_material.Material material;
  final bool readOnly;
  final Function(job_material.Material) onChanged;
  final VoidCallback onRemove;

  const _MaterialRow({
    required this.material,
    required this.readOnly,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_MaterialRow> createState() => _MaterialRowState();
}

class _MaterialRowState extends State<_MaterialRow> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material.name);
    _quantityController =
        TextEditingController(text: widget.material.quantity.toString());
    _priceController =
        TextEditingController(text: widget.material.price.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateMaterial() {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    final updatedMaterial = widget.material.copyWith(
      name: _nameController.text,
      quantity: quantity,
      price: price,
    );

    widget.onChanged(updatedMaterial);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.softBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: widget.readOnly
                ? Text(
                    widget.material.name.isEmpty
                        ? 'Unnamed Material'
                        : widget.material.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Material name',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    onChanged: (_) => _updateMaterial(),
                  ),
          ),
          Expanded(
            flex: 2,
            child: widget.readOnly
                ? Text(
                    '${widget.material.quantity} ${widget.material.unit}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  )
                : TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateMaterial(),
                  ),
          ),
          Expanded(
            flex: 3,
            child: widget.readOnly
                ? Text(
                    'NGN ${widget.material.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  )
                : TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      prefixText: 'NGN ',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateMaterial(),
                  ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'NGN ${widget.material.totalPrice.toStringAsFixed(0).replaceAllMapped(
                    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                    (match) => '${match[1]},',
                  )}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
          if (!widget.readOnly)
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.red.shade400,
                iconSize: 20,
              ),
            ),
        ],
      ),
    );
  }
}
