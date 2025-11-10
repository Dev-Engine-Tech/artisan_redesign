import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../cubit/invoice_form_cubit.dart';

class CustomerField extends StatelessWidget {
  const CustomerField({
    required this.customerController,
    required this.addressController,
    super.key,
    this.readOnly = false,
  });

  final TextEditingController customerController;
  final TextEditingController addressController;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
      builder: (context, state) {
        final selected = state.selectedCustomer;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppSpacing.spaceXS,
                Icon(Icons.help_outline, size: 16, color: Colors.grey),
              ],
            ),
            AppSpacing.spaceSM,
            TextFormField(
              controller: customerController,
              readOnly: readOnly,
              decoration: InputDecoration(
                hintText: 'Select or enter a customer…',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusSM,
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusSM,
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusSM,
                  borderSide: const BorderSide(color: AppColors.orange),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: readOnly
                    ? null
                    : IconButton(
                        tooltip: 'Pick from customers',
                        icon: const Icon(Icons.people_outline),
                        onPressed: () => _showCustomerPicker(context),
                      ),
              ),
              onChanged: (_) {
                context.read<InvoiceFormCubit>().clearCustomer();
              },
            ),
            const SizedBox(height: 6),
            if (selected != null)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.withOpacity(0.4)),
                      borderRadius: AppRadius.radiusLG,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Colors.blue),
                        AppSpacing.spaceXS,
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Text(
                            '${selected.name} · ${selected.email}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextAppButton(
                    text: 'Clear',
                    onPressed: () {
                      context.read<InvoiceFormCubit>().clearCustomer();
                      customerController.clear();
                    },
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  void _showCustomerPicker(BuildContext context) {
    final cubit = context.read<InvoiceFormCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
                      return state.customers
                          .where((c) =>
                              c.name.toLowerCase().contains(q) ||
                              c.email.toLowerCase().contains(q) ||
                              (c.company?.toLowerCase().contains(q) ?? false))
                          .toList();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppSpacing.spaceSM,
                        Container(
                          height: 4,
                          width: 36,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AppSpacing.spaceMD,
                        const Text('Select Customer',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        AppSpacing.spaceMD,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: searchController,
                            onChanged: (_) => setSheetState(() {}),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search customers…',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        AppSpacing.spaceSM,
                        if (state.loadingCustomers)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          )
                        else if (state.customersError != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(state.customersError!,
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
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 16,
                                    child: Text(c.initials,
                                        style: const TextStyle(fontSize: 12)),
                                  ),
                                  title: Text(c.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  subtitle: Text(c.email),
                                  onTap: () {
                                    Navigator.pop(context);
                                    blocCtx
                                        .read<InvoiceFormCubit>()
                                        .selectCustomer(c);
                                    customerController.text = c.name;
                                    if ((c.address ?? '').isNotEmpty) {
                                      addressController.text = c.address!;
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        AppSpacing.spaceSM,
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
