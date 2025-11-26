import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/services.dart';
import 'package:artisans_circle/core/utils/input_utils.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../cubit/invoice_form_cubit.dart';
import 'label_cell.dart';
import 'package:artisans_circle/core/theme.dart';

Future<InvoiceLineData?> showLineItemModal(
  BuildContext context, {
  InvoiceLineData? initial,
}) async {
  final cubit = context.read<InvoiceFormCubit>();
  return showModalBottomSheet<InvoiceLineData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (ctx) {
      return BlocProvider.value(
        value: cubit,
        child: _LineItemForm(initial: initial),
      );
    },
  );
}

class _LineItemForm extends StatefulWidget {
  const _LineItemForm({this.initial});
  final InvoiceLineData? initial;

  @override
  State<_LineItemForm> createState() => _LineItemFormState();
}

class _LineItemFormState extends State<_LineItemForm> {
  late final TextEditingController _label;
  late final TextEditingController _qty;
  late final TextEditingController _price;
  late final TextEditingController _discountPct;
  late final TextEditingController _taxRatePct;
  String? _catalogId;
  final _qtyFormatter = InputUtils.digitsOnly;
  final _priceFormatter = InputUtils.digitsOnly;

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(text: widget.initial?.label ?? '');
    _qty = TextEditingController(
        text: (widget.initial?.quantity ?? 1).toStringAsFixed(0));
    _price = TextEditingController(
        text: (widget.initial?.unitPrice ?? 0).toStringAsFixed(0));
    final base =
        (widget.initial?.quantity ?? 0) * (widget.initial?.unitPrice ?? 0);
    final pct =
        base > 0 ? ((widget.initial?.discount ?? 0) / base) * 100.0 : 0.0;
    _discountPct = TextEditingController(text: pct.toString());
    _taxRatePct = TextEditingController(
        text: ((widget.initial?.taxRate ?? 0) * 100).toString());
    _catalogId = widget.initial?.catalogId;
  }

  @override
  void dispose() {
    _label.dispose();
    _qty.dispose();
    _price.dispose();
    _discountPct.dispose();
    _taxRatePct.dispose();
    super.dispose();
  }

  double get _qtyValue => double.tryParse(_qty.text.trim()) ?? 0;
  double get _priceValue => double.tryParse(_price.text.trim()) ?? 0;
  double get _discountPctValue =>
      (double.tryParse(_discountPct.text.trim()) ?? 0) / 100.0;
  double get _taxRateValue =>
      (double.tryParse(_taxRatePct.text.trim()) ?? 0) / 100.0;

  double get _previewSubtotal {
    final base = (_qtyValue * _priceValue);
    final afterDiscount =
        (base - (base * _discountPctValue)).clamp(0, double.infinity);
    final tax = afterDiscount * _taxRateValue;
    return afterDiscount + tax;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottom),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 36,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Line Item',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    AppSpacing.spaceMD,
                    LabelCell(
                      labelController: _label,
                      unitPriceController: _price,
                      catalogId: _catalogId,
                      onCatalogChanged: (id) => setState(() => _catalogId = id),
                    ),
                    AppSpacing.spaceMD,
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _qty,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_qtyFormatter],
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        AppSpacing.spaceMD,
                        Expanded(
                          child: TextField(
                            controller: _price,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_priceFormatter],
                            decoration: const InputDecoration(
                              labelText: 'Unit Price (NGN)',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.spaceMD,
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _discountPct,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Discount (%)',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        AppSpacing.spaceMD,
                        Expanded(
                          child: TextField(
                            controller: _taxRatePct,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tax Rate (%)',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.spaceMD,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Subtotal: NGN ${_previewSubtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    AppSpacing.spaceMD,
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedAppButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        AppSpacing.spaceMD,
                        Expanded(
                          child: PrimaryButton(
                            text: 'Save',
                            onPressed: () {
                              final qty =
                                  InputUtils.parseDouble(_qty.text.trim());
                              final price =
                                  InputUtils.parseDouble(_price.text.trim());
                              final base = (qty * price);
                              final discountAbs =
                                  (base * _discountPctValue).clamp(0, base);
                              final item = InvoiceLineData(
                                label: _label.text.trim(),
                                quantity: qty,
                                unitPrice: price,
                                discount: discountAbs.toDouble(),
                                taxRate: _taxRateValue,
                                catalogId: _catalogId,
                              );
                              Navigator.of(context).pop(item);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
