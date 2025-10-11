import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import '../../domain/entities/invoice.dart'
    show InvoiceItem; // not used, placeholder
import '../cubit/invoice_form_cubit.dart';

class LabelCell extends StatelessWidget {
  const LabelCell({
    super.key,
    required this.labelController,
    required this.unitPriceController,
    this.readOnly = false,
    this.catalogId,
    this.onCatalogChanged,
  });

  final TextEditingController labelController;
  final TextEditingController unitPriceController;
  final bool readOnly;
  final String? catalogId;
  final ValueChanged<String?>? onCatalogChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
      builder: (context, state) {
        var catalog = null as dynamic;
        try {
          catalog = state.catalogs.firstWhere((e) => e.id == catalogId);
        } catch (_) {
          catalog = null;
        }
        final typed = labelController.text.trim();
        final useLabel = typed.isNotEmpty
            ? typed
            : (catalogId != null && catalog != null ? catalog.title : null);
        final isCatalog = typed.isEmpty && catalogId != null && catalog != null;

        return TextField(
          controller: labelController,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: 'Label',
            hintText: 'Enter description or pick from catalog',
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: const OutlineInputBorder(),
            suffixIcon: readOnly
                ? null
                : IconButton(
                    tooltip: 'Select from catalog',
                    icon: const Icon(Icons.storefront_outlined),
                    onPressed: () => _showCatalogPicker(context),
                  ),
          ),
        );
      },
    );
  }

  void _showCatalogPicker(BuildContext context) {
    final cubit = context.read<InvoiceFormCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final searchController = TextEditingController();
        return BlocProvider.value(
            value: cubit,
            child: BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
                builder: (blocCtx, state) {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: StatefulBuilder(builder: (sheetCtx, setSheetState) {
                    List filtered() {
                      final q = searchController.text.trim().toLowerCase();
                      return state.catalogs
                          .where((c) =>
                              c.title.toLowerCase().contains(q) ||
                              c.description.toLowerCase().contains(q))
                          .toList();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          height: 4,
                          width: 36,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Select from Catalog',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: searchController,
                            onChanged: (_) => setSheetState(() {}),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search catalog...',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (state.loadingCatalogs)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          )
                        else if (state.catalogsError != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(state.catalogsError!,
                                style: const TextStyle(color: Colors.red)),
                          )
                        else
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filtered().length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final c = filtered()[index];
                                final priceText = (c.priceMax != null ||
                                        c.priceMin != null)
                                    ? 'NGN ${(c.priceMax ?? c.priceMin).toString()}'
                                    : '—';
                                return ListTile(
                                  leading:
                                      const Icon(Icons.inventory_2_outlined),
                                  title: Text(c.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  subtitle: Text(priceText),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Update controllers based on selection
                                    labelController.text = c.title;
                                    final current = double.tryParse(
                                            unitPriceController.text) ??
                                        0.0;
                                    final suggested = blocCtx
                                        .read<InvoiceFormCubit>()
                                        .suggestedPriceFromCatalog(c);
                                    if (current == 0 && suggested > 0) {
                                      unitPriceController.text =
                                          suggested.toString();
                                    }
                                    onCatalogChanged?.call(c.id);
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                ),
              );
            }));
      },
    );
  }
}
