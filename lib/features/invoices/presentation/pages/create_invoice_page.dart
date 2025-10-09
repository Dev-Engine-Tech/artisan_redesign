import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme.dart';
import '../../domain/entities/invoice.dart';
import '../../../catalog/domain/entities/catalog_item.dart';
import '../../../catalog/domain/usecases/get_my_catalog_items.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/usecases/get_customers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/invoice_form_cubit.dart';
import '../widgets/customer_field.dart';
import '../widgets/label_cell.dart';
import '../widgets/lines_tab.dart';
import '../widgets/materials_tab.dart';
import '../widgets/measurement_tab.dart';

enum InvoiceMode { create, edit, view }

class CreateInvoicePage extends StatefulWidget {
  final Invoice? invoice;
  final InvoiceMode mode;

  const CreateInvoicePage({
    Key? key,
    this.invoice,
    this.mode = InvoiceMode.create,
  }) : super(key: key);

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage>
    with SingleTickerProviderStateMixin {
  bool _hydrated = false;
  late TabController _tabController;
  final _customerController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _productController = TextEditingController();
  final _termsController = TextEditingController();
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  // Dynamic lists migrated to InvoiceFormCubit (sections, lines, materials, measurements)

  // Form pickers are handled by InvoiceFormCubit now

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _populateFromInvoice();
  }

  bool get _isReadOnly => widget.mode == InvoiceMode.view;

  String _getAppBarTitle() {
    switch (widget.mode) {
      case InvoiceMode.create:
        return 'Create Invoice';
      case InvoiceMode.edit:
        return 'Draft Invoice';
      case InvoiceMode.view:
        if (widget.invoice?.status == InvoiceStatus.draft) {
          return 'Draft Invoice';
        } else if (widget.invoice?.status == InvoiceStatus.validated) {
          return 'Validated Invoice';
        } else if (widget.invoice?.status == InvoiceStatus.paid) {
          return 'Paid Invoice';
        } else {
          return 'Invoice';
        }
    }
  }

  void _populateFromInvoice() {
    if (widget.invoice != null) {
      final invoice = widget.invoice!;

      // Populate basic fields
      _customerController.text = invoice.clientName;
      _deliveryAddressController.text =
          invoice.clientEmail; // Using clientEmail as address for now
      _termsController.text = invoice.notes ?? '';
      _invoiceDate = invoice.issueDate;
      _dueDate = invoice.dueDate;

      // Note: Materials and measurements would need to be stored separately in a real app
      // For now, we'll leave them empty when viewing existing invoices
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerController.dispose();
    _deliveryAddressController.dispose();
    _productController.dispose();
    _termsController.dispose();

    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InvoiceFormCubit(
        getCustomers: GetIt.I<GetCustomers>(),
        getMyCatalogItems: GetIt.I<GetMyCatalogItems>(),
      )..loadInitial(),
      child: Builder(builder: (provCtx) {
        if (!_hydrated && widget.invoice != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            try {
              provCtx.read<InvoiceFormCubit>().hydrateFromInvoice(widget.invoice!);
            } catch (_) {}
          });
          _hydrated = true;
        }
        return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Invoice Title and Form
          Expanded(
            child: Builder(builder: (context) {
              final bottomSafe = MediaQuery.of(context).viewPadding.bottom;
              // Add extra bottom padding so content doesn't collide with bottom bar
              final bottomPad = 16.0 + bottomSafe + 80.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Invoice',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Draft',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Fields Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomerField(
                              customerController: _customerController,
                              addressController: _deliveryAddressController,
                              readOnly: _isReadOnly,
                            ),
                            const SizedBox(height: 16),
                            _buildFormField(
                              'Delivery Address',
                              '',
                              _deliveryAddressController,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSelectableDateField(
                                'Invoice Date', _formatDate(_invoiceDate)),
                            const SizedBox(height: 16),
                            _buildSelectableDateField(
                                'Due Date', _formatDate(_dueDate)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text(
                                  'Currency',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text('in',
                                    style: TextStyle(color: Colors.grey)),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('NGN'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.orange,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.orange,
                    tabs: const [
                      Tab(text: 'Invoice Lines'),
                      Tab(text: 'Materials'),
                      Tab(text: 'Measurement'),
                    ],
                  ),

                  // Tab Content (scrollable inside, height tuned to viewport)
                  Builder(builder: (context) {
                    final vh = MediaQuery.of(context).size.height;
                    final tabHeight = (vh * 0.5).clamp(420.0, 560.0);
                    return SizedBox(
                      height: tabHeight,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          LinesTab(),
                          MaterialsTab(),
                          MeasurementTab(),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Totals Section (computed by InvoiceFormCubit)
                  BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
                    builder: (context, state) {
                      final cubit = context.read<InvoiceFormCubit>();
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildTotalRow('Subtotal (Invoice):', 'NGN ${cubit.invoiceLinesTotal.toStringAsFixed(2)}'),
                            _buildTotalRow('Subtotal (Materials):', 'NGN ${cubit.materialsTotal.toStringAsFixed(2)}'),
                            const Divider(),
                            _buildTotalRow('Total:', 'NGN ${cubit.grandTotal.toStringAsFixed(2)}', isBold: true),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Terms & Conditions Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terms & Conditions:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextFormField(
                          controller: _termsController,
                          readOnly: _isReadOnly,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: 'Enter terms and conditions...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              );
            }),
          ),

          // Spacer removed to avoid minor vertical overflows
        ],
        ),
        bottomNavigationBar: _buildBottomActionBar(),
      );
    }));
  }

  Widget _buildBottomActionBar() {
    List<Widget> buttons = [];

    // Always show Share button
    buttons.add(
      Expanded(
        child: ElevatedButton.icon(
          onPressed: _shareInvoice,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF654321),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.share, color: Colors.white),
          label: const Text(
            'Share',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );

    buttons.add(const SizedBox(width: 8));

    // Show Create Job button for draft and validated invoices
    if (widget.mode != InvoiceMode.view ||
        (widget.invoice?.status == InvoiceStatus.draft ||
            widget.invoice?.status == InvoiceStatus.validated)) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _createJob,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.work, color: Colors.white),
            label: const Text(
              'Create Job',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );

      buttons.add(const SizedBox(width: 8));
    }

    // Add main action button (Confirm/Pay) - but not for paid invoices
    if (!(widget.mode == InvoiceMode.view &&
        widget.invoice?.status == InvoiceStatus.paid)) {
      String buttonText;
      VoidCallback onPressed;

      switch (widget.mode) {
        case InvoiceMode.create:
        case InvoiceMode.edit:
          buttonText = 'Confirm';
          onPressed = _confirmInvoice;
          break;
        case InvoiceMode.view:
          if (widget.invoice?.status == InvoiceStatus.validated) {
            buttonText = 'Pay';
            onPressed = _payInvoice;
          } else {
            buttonText = 'Confirm';
            onPressed = _confirmInvoice;
          }
          break;
      }

      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.check, color: Colors.white),
            label: Text(
              buttonText,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: buttons,
        ),
      ),
    );
  }

  void _shareInvoice() {
    // TODO: Implement share functionality
    // This would share the invoice via email, PDF, etc.
    // TODO: implement share invoice
  }

  void _createJob() {
    // TODO: Implement create job functionality
    // This would create a new job based on the invoice
    // TODO: implement create job
  }

  void _confirmInvoice() {
    // TODO: Implement invoice confirmation logic
    // This would update the invoice status from draft to validated
    Navigator.of(context).pop();
  }

  void _payInvoice() {
    // TODO: Implement payment logic
    // This would update the invoice status from validated to paid
    Navigator.of(context).pop();
  }

  Widget _buildFormField(
      String label, String hint, TextEditingController controller,
      {bool? readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.help_outline, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          readOnly: readOnly ?? _isReadOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppColors.orange),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  

  Widget _buildDateField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.help_outline, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context, String label) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: label == 'Invoice Date' ? _invoiceDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (label == 'Invoice Date') {
          _invoiceDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  // Management of sections/lines/materials/measurements moved to InvoiceFormCubit

  Widget _buildSelectableDateField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.help_outline, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isReadOnly ? null : () => _selectDate(context, label),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceLinesTab() {
    return const SizedBox.shrink();
  }

  Widget _buildInvoiceLineRow([dynamic a, dynamic b]) => const SizedBox.shrink();

  

  void _editSection(int index) {
    // No-op placeholder — handled in LinesTab via cubit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Section'),
        content: const Text('Section editing is handled in Lines tab.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  Widget _buildSectionCard([int sectionIndex = 0]) => const SizedBox.shrink();

  Widget _buildInvoiceLineCard([int a = 0, int b = 0]) => const SizedBox.shrink();

  double _calculateInvoiceLinesTotal() => 0.0;

  Widget _buildMaterialsTab() => const SizedBox.shrink();

  Widget _buildMaterialRow([dynamic a, dynamic onDelete]) => const SizedBox.shrink();

  Widget _buildMaterialCard([int index = 0]) => const SizedBox.shrink();

  double _calculateMaterialsTotal() => 0.0;

  Widget _buildMeasurementTab() {
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
                child:
                    Text('Item', style: TextStyle(fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Qty',
                    style: TextStyle(fontWeight: FontWeight.w600))),
            Expanded(
                flex: 2,
                child:
                    Text('UoM', style: TextStyle(fontWeight: FontWeight.w600))),
            SizedBox(width: 32),
          ],
        ),
      ),
    ];
    // migrated to MeasurementTab widget
    children.add(const SizedBox(height: 16));
    // migrated to MeasurementTab widget
    return ListView(padding: EdgeInsets.zero, children: children);
  }

  Widget _buildMeasurementRow([dynamic a, dynamic b]) => const SizedBox.shrink();

  Widget _buildMeasurementCard([int index = 0]) => const SizedBox.shrink();

  // Totals are computed by InvoiceFormCubit

  Widget _buildTotalRow(String label, String amount,
      {bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Obsolete local models removed (now handled by InvoiceFormCubit)
