import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../cubit/invoice_form_cubit.dart';
import 'label_cell.dart';
import 'line_item_modal.dart';

class LinesTab extends StatelessWidget {
  const LinesTab({super.key, this.readOnly = false});
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
                    child: Text('Label',
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

        // Sections
        for (var si = 0; si < state.sections.length; si++) {
          final section = state.sections[si];
          children.add(Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: section.description),
                    readOnly: readOnly,
                    decoration: const InputDecoration(
                      labelText: 'Section Description',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => cubit.updateSectionDescription(si, v),
                  ),
                ),
                if (!readOnly)
                  IconButton(
                      onPressed: () => cubit.removeSection(si),
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.red)),
              ],
            ),
          ));
          // Items
          for (var li = 0; li < section.items.length; li++) {
            final line = section.items[li];
            children.add(_LineRow(
              readOnly: readOnly,
              label: line.label,
              quantity: line.quantity,
              unitPrice: line.unitPrice,
              subtotal: line.subtotal,
              catalogId: line.catalogId,
              onLabelChanged: (v) =>
                  cubit.updateLineInSection(si, li, label: v),
              onCatalogChanged: (id) => cubit.updateLineInSection(si, li,
                  catalogId: id, clearCatalog: id == null),
              onQtyChanged: (v) =>
                  cubit.updateLineInSection(si, li, quantity: v),
              onPriceChanged: (v) =>
                  cubit.updateLineInSection(si, li, unitPrice: v),
              onEdit: () async {
                final updated = await showLineItemModal(context, initial: line);
                if (updated != null) {
                  cubit.updateLineInSection(
                    si,
                    li,
                    label: updated.label,
                    quantity: updated.quantity,
                    unitPrice: updated.unitPrice,
                    discount: updated.discount,
                    taxRate: updated.taxRate,
                    catalogId: updated.catalogId,
                    clearCatalog: updated.catalogId == null,
                  );
                }
              },
              onDelete: () => cubit.removeLineFromSection(si, li),
            ));
          }
          if (!readOnly)
            children.add(
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextAppButton(
                    text: 'Add Line',
                    onPressed: () async {
                      final created = await showLineItemModal(context);
                      if (created != null) {
                        cubit.addLineToSectionData(si, created);
                      }
                    },
                  ),
                ),
              ),
            );
        }

        // Independent lines
        for (var i = 0; i < state.independentLines.length; i++) {
          final line = state.independentLines[i];
          children.add(_LineRow(
            readOnly: readOnly,
            label: line.label,
            quantity: line.quantity,
            unitPrice: line.unitPrice,
            subtotal: line.subtotal,
            catalogId: line.catalogId,
            onLabelChanged: (v) => cubit.updateIndependentLine(i, label: v),
            onCatalogChanged: (id) => cubit.updateIndependentLine(i,
                catalogId: id, clearCatalog: id == null),
            onQtyChanged: (v) => cubit.updateIndependentLine(i, quantity: v),
            onPriceChanged: (v) => cubit.updateIndependentLine(i, unitPrice: v),
            onEdit: () async {
              final updated = await showLineItemModal(context, initial: line);
              if (updated != null) {
                cubit.updateIndependentLine(
                  i,
                  label: updated.label,
                  quantity: updated.quantity,
                  unitPrice: updated.unitPrice,
                  discount: updated.discount,
                  taxRate: updated.taxRate,
                  catalogId: updated.catalogId,
                  clearCatalog: updated.catalogId == null,
                );
              }
            },
            onDelete: () => cubit.removeIndependentLine(i),
          ));
        }

        if (!readOnly)
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  OutlinedAppButton(
                    text: 'Add Line',
                    onPressed: () async {
                      final created = await showLineItemModal(context);
                      if (created != null) {
                        cubit.addIndependentLineData(created);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  PrimaryButton(
                    text: 'Add Section',
                    onPressed: cubit.addSection,
                  ),
                ],
              ),
            ),
          );

        // Lines summary (base, discount, tax, total)
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
                builder: (context, state) {
                  final c = context.read<InvoiceFormCubit>();
                  Widget row(String label, String value, {bool bold = false}) {
                    final style = TextStyle(
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(label, style: style),
                          Text(value, style: style),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Invoice Summary',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      row('Base (Qty x Price):',
                          'NGN ${c.lineBaseTotal.toStringAsFixed(2)}'),
                      row('Total Discount:',
                          '- NGN ${c.lineDiscountTotal.toStringAsFixed(2)}'),
                      row('Total Tax:',
                          '+ NGN ${c.lineTaxTotal.toStringAsFixed(2)}'),
                      const Divider(height: 16),
                      row('Lines Total:',
                          'NGN ${c.invoiceLinesTotal.toStringAsFixed(2)}',
                          bold: true),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        return ListView(padding: EdgeInsets.zero, children: children);
      },
    );
  }
}

class _LineRow extends StatefulWidget {
  const _LineRow({
    required this.readOnly,
    required this.label,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.catalogId,
    required this.onLabelChanged,
    required this.onCatalogChanged,
    required this.onQtyChanged,
    required this.onPriceChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final bool readOnly;
  final String label;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final String? catalogId;
  final ValueChanged<String> onLabelChanged;
  final ValueChanged<String?> onCatalogChanged;
  final ValueChanged<double> onQtyChanged;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_LineRow> createState() => _LineRowState();
}

class _LineRowState extends State<_LineRow> {
  late final TextEditingController _label;
  late final TextEditingController _qty;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(text: widget.label);
    _qty = TextEditingController(text: widget.quantity.toString());
    _price = TextEditingController(text: widget.unitPrice.toString());
  }

  @override
  void didUpdateWidget(covariant _LineRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label) _label.text = widget.label;
    if (oldWidget.quantity != widget.quantity)
      _qty.text = widget.quantity.toString();
    if (oldWidget.unitPrice != widget.unitPrice)
      _price.text = widget.unitPrice.toString();
  }

  @override
  void dispose() {
    _label.dispose();
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
            child: LabelCell(
              readOnly: widget.readOnly,
              labelController: _label,
              unitPriceController: _price,
              catalogId: widget.catalogId,
              onCatalogChanged: widget.onCatalogChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _qty,
              readOnly: widget.readOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(),
                hintText: '1',
              ),
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
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(),
                hintText: 'NGN 0.00',
              ),
              onChanged: (v) => widget.onPriceChanged(double.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                'NGN ${widget.subtotal.toStringAsFixed(2)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (!widget.readOnly) ...[
            SizedBox(
              width: 32,
              child: IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.grey, size: 16),
                onPressed: widget.onEdit,
              ),
            ),
            SizedBox(
              width: 32,
              child: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 16),
                onPressed: widget.onDelete,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
