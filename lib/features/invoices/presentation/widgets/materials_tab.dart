import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../cubit/invoice_form_cubit.dart';

class MaterialsTab extends StatelessWidget {
  const MaterialsTab({super.key, this.readOnly = false});
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
      builder: (context, state) {
        final cubit = context.read<InvoiceFormCubit>();
        final children = <Widget>[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Material',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 1,
                    child: Text('Qty',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 2,
                    child: Text('Unit Price',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 2,
                    child: Text('Subtotal',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 32),
              ],
            ),
          ),
        ];

        for (var i = 0; i < state.materials.length; i++) {
          final m = state.materials[i];
          children.add(_MaterialRow(
            readOnly: readOnly,
            description: m.description,
            quantity: m.quantity,
            unitPrice: m.unitPrice,
            subtotal: m.subtotal,
            onDescChanged: (v) => cubit.updateMaterial(i, description: v),
            onQtyChanged: (v) => cubit.updateMaterial(i, quantity: v),
            onPriceChanged: (v) => cubit.updateMaterial(i, unitPrice: v),
            onDelete: () => cubit.removeMaterial(i),
          ));
        }

        if (!readOnly)
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: PrimaryButton(
                text: 'Add Material',
                onPressed: cubit.addMaterial,
              ),
            ),
          );
        // Summary for materials total
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Materials Total',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('NGN ${cubit.materialsTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        );
        return ListView(padding: EdgeInsets.zero, children: children);
      },
    );
  }
}

class _MaterialRow extends StatefulWidget {
  const _MaterialRow({
    required this.readOnly,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.onDescChanged,
    required this.onQtyChanged,
    required this.onPriceChanged,
    required this.onDelete,
  });
  final bool readOnly;
  final String description;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final ValueChanged<String> onDescChanged;
  final ValueChanged<double> onQtyChanged;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback onDelete;

  @override
  State<_MaterialRow> createState() => _MaterialRowState();
}

class _MaterialRowState extends State<_MaterialRow> {
  late final TextEditingController _desc;
  late final TextEditingController _qty;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _desc = TextEditingController(text: widget.description);
    _qty = TextEditingController(text: widget.quantity.toString());
    _price = TextEditingController(text: widget.unitPrice.toString());
  }

  @override
  void didUpdateWidget(covariant _MaterialRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.description != widget.description)
      _desc.text = widget.description;
    if (oldWidget.quantity != widget.quantity)
      _qty.text = widget.quantity.toString();
    if (oldWidget.unitPrice != widget.unitPrice)
      _price.text = widget.unitPrice.toString();
  }

  @override
  void dispose() {
    _desc.dispose();
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _desc,
              readOnly: widget.readOnly,
              decoration: const InputDecoration.collapsed(
                  hintText: 'Enter material description'),
              onChanged: widget.onDescChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _qty,
              readOnly: widget.readOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration.collapsed(hintText: '1'),
              onChanged: (v) => widget.onQtyChanged(double.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _price,
              readOnly: widget.readOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration.collapsed(hintText: 'NGN 0.00'),
              onChanged: (v) => widget.onPriceChanged(double.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
                'NGN ${(widget.quantity * widget.unitPrice).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (!widget.readOnly)
            SizedBox(
              width: 32,
              child: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 16),
                onPressed: widget.onDelete,
              ),
            ),
        ],
      ),
    );
  }
}
