import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../domain/entities/invoice.dart';

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

class _CreateInvoicePageState extends State<CreateInvoicePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _customerController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _productController = TextEditingController();
  final _termsController = TextEditingController();
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  // Dynamic lists for invoice management
  final List<_InvoiceSection> _invoiceSections = [];
  final List<_InvoiceLineItem> _independentLines = [];
  final List<_InvoiceMaterialItem> _materials = [];
  final List<_InvoiceMeasurementItem> _measurements = [];

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
      _deliveryAddressController.text = invoice.clientEmail; // Using clientEmail as address for now
      _termsController.text = invoice.notes ?? '';
      _invoiceDate = invoice.issueDate;
      _dueDate = invoice.dueDate;

      // Populate invoice items as independent lines
      _independentLines.clear();
      for (final item in invoice.items) {
        _independentLines.add(_InvoiceLineItem(
          labelController: TextEditingController(text: item.description),
          quantityController: TextEditingController(text: item.quantity.toString()),
          unitPriceController: TextEditingController(text: item.unitPrice.toString()),
        ));
      }

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

    // Dispose dynamic items
    for (final section in _invoiceSections) {
      section.dispose();
    }
    for (final line in _independentLines) {
      line.dispose();
    }
    for (final material in _materials) {
      material.dispose();
    }
    for (final measurement in _measurements) {
      measurement.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                            _buildFormField(
                              'Customer',
                              'Search a name or Tax ID...',
                              _customerController,
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
                            _buildSelectableDateField('Invoice Date', _formatDate(_invoiceDate)),
                            const SizedBox(height: 16),
                            _buildSelectableDateField('Due Date', _formatDate(_dueDate)),
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
                                const Text('in', style: TextStyle(color: Colors.grey)),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
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

                  // Tab Content
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInvoiceLinesTab(),
                        _buildMaterialsTab(),
                        _buildMeasurementTab(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Totals Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildTotalRow('Total Invoice:',
                            'NGN ${_calculateInvoiceLinesTotal().toStringAsFixed(2)}'),
                        _buildTotalRow('Total Materials:',
                            'NGN ${_calculateMaterialsTotal().toStringAsFixed(2)}'),
                        const Divider(),
                        _buildTotalRow('Total:', 'NGN ${_calculateGrandTotal().toStringAsFixed(2)}',
                            isBold: true),
                      ],
                    ),
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
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );

      buttons.add(const SizedBox(width: 8));
    }

    // Add main action button (Confirm/Pay) - but not for paid invoices
    if (!(widget.mode == InvoiceMode.view && widget.invoice?.status == InvoiceStatus.paid)) {
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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _buildFormField(String label, String hint, TextEditingController controller,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  // Invoice Section Management
  void _addSection() {
    setState(() {
      _invoiceSections.add(_InvoiceSection(
        descriptionController: TextEditingController(),
      ));
    });
  }

  void _removeSection(int index) {
    setState(() {
      _invoiceSections[index].dispose();
      _invoiceSections.removeAt(index);
    });
  }

  void _addLineToSection(int sectionIndex) {
    setState(() {
      _invoiceSections[sectionIndex].items.add(_InvoiceLineItem(
            labelController: TextEditingController(),
            quantityController: TextEditingController(text: '1'),
            unitPriceController: TextEditingController(),
          ));
    });
  }

  void _addIndependentLine() {
    setState(() {
      _independentLines.add(_InvoiceLineItem(
        labelController: TextEditingController(),
        quantityController: TextEditingController(text: '1'),
        unitPriceController: TextEditingController(),
      ));
    });
  }

  void _removeIndependentLine(int index) {
    setState(() {
      _independentLines[index].dispose();
      _independentLines.removeAt(index);
    });
  }

  void _removeLineFromSection(int sectionIndex, int itemIndex) {
    setState(() {
      _invoiceSections[sectionIndex].items[itemIndex].dispose();
      _invoiceSections[sectionIndex].items.removeAt(itemIndex);
    });
  }

  // Material Management
  void _addMaterial() {
    setState(() {
      _materials.add(_InvoiceMaterialItem(
        descriptionController: TextEditingController(),
        quantityController: TextEditingController(text: '1'),
        unitPriceController: TextEditingController(),
      ));
    });
  }

  void _removeMaterial(int index) {
    setState(() {
      _materials[index].dispose();
      _materials.removeAt(index);
    });
  }

  // Measurement Management
  void _addMeasurement() {
    setState(() {
      _measurements.add(_InvoiceMeasurementItem(
        itemController: TextEditingController(),
        quantityController: TextEditingController(text: '1'),
        uomController: TextEditingController(),
      ));
    });
  }

  void _removeMeasurement(int index) {
    setState(() {
      _measurements[index].dispose();
      _measurements.removeAt(index);
    });
  }

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
    return Column(
      children: [
        const SizedBox(height: 16),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(
            children: [
              Expanded(
                  flex: 3, child: Text('Label', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(
                  flex: 2,
                  child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(
                  flex: 2, child: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w600))),
              SizedBox(width: 32),
            ],
          ),
        ),

        // Sections
        for (var i = 0; i < _invoiceSections.length; i++) ...[
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _invoiceSections[i].descriptionController.text.isEmpty
                        ? 'Section ${i + 1}'
                        : _invoiceSections[i].descriptionController.text,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () => _editSection(i),
                ),
                if (!_isReadOnly)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    onPressed: () => _removeSection(i),
                  ),
              ],
            ),
          ),
          // Section Items
          for (var j = 0; j < _invoiceSections[i].items.length; j++)
            _buildInvoiceLineRow(_invoiceSections[i].items[j], () => _removeLineFromSection(i, j)),
        ],

        // Independent Lines
        for (var i = 0; i < _independentLines.length; i++)
          _buildInvoiceLineRow(_independentLines[i], () => _removeIndependentLine(i)),

        const SizedBox(height: 16),

        // Action Buttons
        if (!_isReadOnly)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addIndependentLine,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF654321)),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Line', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addSection,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Section', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInvoiceLineRow(_InvoiceLineItem item, VoidCallback onDelete) {
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
              controller: item.labelController,
              readOnly: _isReadOnly,
              decoration: const InputDecoration.collapsed(hintText: 'Enter description'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: item.quantityController,
              readOnly: _isReadOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration.collapsed(hintText: '1'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: item.unitPriceController,
              readOnly: _isReadOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration.collapsed(hintText: 'NGN 0.00'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              'NGN ${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (!_isReadOnly)
            SizedBox(
              width: 32,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                onPressed: onDelete,
              ),
            ),
        ],
      ),
    );
  }

  void _editSection(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Section'),
        content: TextField(
          controller: _invoiceSections[index].descriptionController,
          decoration: const InputDecoration(labelText: 'Section Description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(int sectionIndex) {
    final section = _invoiceSections[sectionIndex];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: section.descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Section Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isReadOnly)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeSection(sectionIndex),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Section Items
            for (var i = 0; i < section.items.length; i++) _buildInvoiceLineCard(sectionIndex, i),

            const SizedBox(height: 8),

            // Add Line Button
            TextButton.icon(
              onPressed: () => _addLineToSection(sectionIndex),
              icon: const Icon(Icons.add),
              label: const Text('Add Line'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceLineCard(int sectionIndex, int itemIndex) {
    final item = _invoiceSections[sectionIndex].items[itemIndex];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // First Row - Label and Delete
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.labelController,
                    decoration: const InputDecoration(
                      labelText: 'Item Description',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isReadOnly)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _removeLineFromSection(sectionIndex, itemIndex),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Second Row - Qty, Price, Tax, Total
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: item.quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: item.unitPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                      prefixText: 'NGN ',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NGN ${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateInvoiceLinesTotal() {
    double total = 0.0;
    for (final section in _invoiceSections) {
      for (final item in section.items) {
        total += item.subtotal;
      }
    }
    return total;
  }

  Widget _buildMaterialsTab() {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(
            children: [
              Expanded(
                  flex: 3, child: Text('Material', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(
                  flex: 2,
                  child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(
                  flex: 2, child: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w600))),
              SizedBox(width: 32),
            ],
          ),
        ),

        // Materials
        for (var i = 0; i < _materials.length; i++)
          _buildMaterialRow(_materials[i], () => _removeMaterial(i)),

        const SizedBox(height: 16),

        // Action Button
        if (!_isReadOnly)
          ElevatedButton.icon(
            onPressed: _addMaterial,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Material', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  Widget _buildMaterialRow(_InvoiceMaterialItem item, VoidCallback onDelete) {
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
              controller: item.descriptionController,
              decoration: const InputDecoration.collapsed(hintText: 'Enter material description'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: item.quantityController,
              readOnly: _isReadOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration.collapsed(hintText: '1'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: item.unitPriceController,
              readOnly: _isReadOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration.collapsed(hintText: 'NGN 0.00'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              'NGN ${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (!_isReadOnly)
            SizedBox(
              width: 32,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                onPressed: onDelete,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(int index) {
    final material = _materials[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              controller: material.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Material Description',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: material.quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: material.unitPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Unit Price (NGN)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'NGN ${material.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          if (!_isReadOnly)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeMaterial(index),
            ),
        ],
      ),
    );
  }

  double _calculateMaterialsTotal() {
    return _materials.fold<double>(0.0, (prev, material) => prev + material.subtotal);
  }

  Widget _buildMeasurementTab() {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(
            children: [
              Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(flex: 2, child: Text('UoM', style: TextStyle(fontWeight: FontWeight.w600))),
              SizedBox(width: 32),
            ],
          ),
        ),

        // Measurements
        for (var i = 0; i < _measurements.length; i++)
          _buildMeasurementRow(_measurements[i], () => _removeMeasurement(i)),

        const SizedBox(height: 16),

        // Action Button
        if (!_isReadOnly)
          ElevatedButton.icon(
            onPressed: _addMeasurement,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Measurement', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  Widget _buildMeasurementRow(_InvoiceMeasurementItem item, VoidCallback onDelete) {
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
              controller: item.itemController,
              decoration: const InputDecoration.collapsed(hintText: 'Enter item'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: item.quantityController,
              readOnly: _isReadOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration.collapsed(hintText: '1'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: item.uomController,
              decoration: const InputDecoration.collapsed(hintText: 'Enter unit'),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          if (!_isReadOnly)
            SizedBox(
              width: 32,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                onPressed: onDelete,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeasurementCard(int index) {
    final measurement = _measurements[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: measurement.itemController,
              decoration: const InputDecoration(
                labelText: 'Item',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: measurement.quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Qty',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: measurement.uomController,
              decoration: const InputDecoration(
                labelText: 'UoM',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          if (!_isReadOnly)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeMeasurement(index),
            ),
        ],
      ),
    );
  }

  double _calculateMeasurementTotal() {
    // Measurements don't have monetary values, so return 0
    return 0.0;
  }

  double _calculateGrandTotal() {
    return _calculateInvoiceLinesTotal() + _calculateMaterialsTotal();
  }

  Widget _buildTotalRow(String label, String amount, {bool isBold = false, double fontSize = 14}) {
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

// Data models for dynamic invoice management
class _InvoiceSection {
  TextEditingController descriptionController;
  List<_InvoiceLineItem> items;

  _InvoiceSection({
    required this.descriptionController,
    List<_InvoiceLineItem>? items,
  }) : items = items ?? [];

  void dispose() {
    descriptionController.dispose();
    for (final item in items) {
      item.dispose();
    }
  }
}

class _InvoiceLineItem {
  TextEditingController labelController;
  TextEditingController quantityController;
  TextEditingController unitPriceController;

  _InvoiceLineItem({
    required this.labelController,
    required this.quantityController,
    required this.unitPriceController,
  });

  double get quantity => double.tryParse(quantityController.text) ?? 1.0;
  double get unitPrice => double.tryParse(unitPriceController.text) ?? 0.0;
  double get subtotal => quantity * unitPrice;

  void dispose() {
    labelController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}

class _InvoiceMaterialItem {
  TextEditingController descriptionController;
  TextEditingController quantityController;
  TextEditingController unitPriceController;

  _InvoiceMaterialItem({
    required this.descriptionController,
    required this.quantityController,
    required this.unitPriceController,
  });

  double get quantity => double.tryParse(quantityController.text) ?? 1.0;
  double get unitPrice => double.tryParse(unitPriceController.text) ?? 0.0;
  double get subtotal => quantity * unitPrice;

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}

class _InvoiceMeasurementItem {
  TextEditingController itemController;
  TextEditingController quantityController;
  TextEditingController uomController;

  _InvoiceMeasurementItem({
    required this.itemController,
    required this.quantityController,
    required this.uomController,
  });

  void dispose() {
    itemController.dispose();
    quantityController.dispose();
    uomController.dispose();
  }
}
