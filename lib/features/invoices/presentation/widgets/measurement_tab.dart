import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../cubit/invoice_form_cubit.dart';

class MeasurementTab extends StatelessWidget {
  const MeasurementTab({super.key, this.readOnly = false});
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
                    child: Text('Item',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 1,
                    child: Text('Qty',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 2,
                    child: Text('UoM',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 32),
              ],
            ),
          ),
        ];

        for (var i = 0; i < state.measurements.length; i++) {
          final m = state.measurements[i];
          children.add(_MeasurementRow(
            readOnly: readOnly,
            item: m.item,
            quantity: m.quantity,
            uom: m.uom,
            onItemChanged: (v) => cubit.updateMeasurement(i, item: v),
            onQtyChanged: (v) => cubit.updateMeasurement(i, quantity: v),
            onUomChanged: (v) => cubit.updateMeasurement(i, uom: v),
            onDelete: () => cubit.removeMeasurement(i),
          ));
        }

        if (!readOnly)
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedAppButton(
                  text: 'Add Measurement',
                  height: 40,
                  width: 180,
                  onPressed: cubit.addMeasurement,
                ),
              ),
            ),
          );
        return ListView(padding: EdgeInsets.zero, children: children);
      },
    );
  }
}

class _MeasurementRow extends StatefulWidget {
  const _MeasurementRow({
    required this.readOnly,
    required this.item,
    required this.quantity,
    required this.uom,
    required this.onItemChanged,
    required this.onQtyChanged,
    required this.onUomChanged,
    required this.onDelete,
  });
  final bool readOnly;
  final String item;
  final double quantity;
  final String uom;
  final ValueChanged<String> onItemChanged;
  final ValueChanged<double> onQtyChanged;
  final ValueChanged<String> onUomChanged;
  final VoidCallback onDelete;

  @override
  State<_MeasurementRow> createState() => _MeasurementRowState();
}

class _MeasurementRowState extends State<_MeasurementRow> {
  late final TextEditingController _item;
  late final TextEditingController _qty;
  late final TextEditingController _uom;

  @override
  void initState() {
    super.initState();
    _item = TextEditingController(text: widget.item);
    _qty = TextEditingController(text: widget.quantity.toString());
    _uom = TextEditingController(text: widget.uom);
  }

  @override
  void didUpdateWidget(covariant _MeasurementRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) _item.text = widget.item;
    if (oldWidget.quantity != widget.quantity)
      _qty.text = widget.quantity.toString();
    if (oldWidget.uom != widget.uom) _uom.text = widget.uom;
  }

  @override
  void dispose() {
    _item.dispose();
    _qty.dispose();
    _uom.dispose();
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
              controller: _item,
              readOnly: widget.readOnly,
              decoration:
                  const InputDecoration.collapsed(hintText: 'Enter item'),
              onChanged: widget.onItemChanged,
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
              controller: _uom,
              readOnly: widget.readOnly,
              decoration: const InputDecoration.collapsed(hintText: 'UoM'),
              onChanged: widget.onUomChanged,
            ),
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
