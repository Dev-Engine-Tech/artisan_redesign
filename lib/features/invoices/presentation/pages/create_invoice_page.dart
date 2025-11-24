import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../../catalog/domain/usecases/get_my_catalog_items.dart';
import '../../../customers/domain/usecases/get_customers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/invoice_form_cubit.dart';
import '../widgets/customer_field.dart';
import '../widgets/lines_tab.dart';
import '../widgets/materials_tab.dart';
import '../widgets/measurement_tab.dart';
import '../../../../core/utils/responsive.dart';

enum InvoiceMode { create, edit, view }

// Private enum for overflow menu actions
enum _MenuAction { delete }

class CreateInvoicePage extends StatefulWidget {
  final Invoice? invoice;
  final InvoiceMode mode;

  const CreateInvoicePage({
    super.key,
    this.invoice,
    this.mode = InvoiceMode.create,
  });

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
  late final InvoiceFormCubit _formCubit;
  Invoice? _invoice; // Tracks the current invoice (after save/confirm)
  late InvoiceMode _mode; // Tracks current mode for edit/view behavior
  String _selectedCurrency = 'NGN';
  StreamSubscription? _formSub;
  bool _hasUnsavedChanges = false;
  List<Map<String, dynamic>>? _savedItemsSnapshot;

  // Overflow menu actions: handled via _MenuAction enum

  // Editability rules
  bool get _isFormReadOnly {
    final status = _invoice?.status;
    return status == InvoiceStatus.validated || status == InvoiceStatus.paid;
  }

  bool get _isCustomerEditable {
    final status = _invoice?.status;
    return status == null || status == InvoiceStatus.draft;
  }

  bool get _isLinesEditable {
    final status = _invoice?.status;
    return status != InvoiceStatus.paid;
  }

  bool get _areMaterialsEditable {
    final status = _invoice?.status;
    return status == null || status == InvoiceStatus.draft;
  }

  bool get _areMeasurementsEditable {
    final status = _invoice?.status;
    return status == null || status == InvoiceStatus.draft;
  }

  // Dynamic lists migrated to InvoiceFormCubit (sections, lines, materials, measurements)

  // Form pickers are handled by InvoiceFormCubit now

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _populateFromInvoice();
    _formCubit = InvoiceFormCubit(
      getCustomers: GetIt.I<GetCustomers>(),
      getMyCatalogItems: GetIt.I<GetMyCatalogItems>(),
    );
    _formCubit.loadInitial();
    _invoice = widget.invoice;
    _mode = widget.mode;
    _initUnsavedSnapshot();
    _formSub = _formCubit.stream.listen((s) {
      if (!mounted) return;
      // Only track unsaved changes when validated (lines editable)
      if (_invoice != null && _invoice!.status == InvoiceStatus.validated) {
        final current = _flattenFormItems(s);
        final saved = _savedItemsSnapshot ?? _mapInvoiceItems(_invoice!.items);
        final changed = !_sameItems(saved, current);
        if (changed != _hasUnsavedChanges) {
          setState(() => _hasUnsavedChanges = changed);
        }
      } else {
        if (_hasUnsavedChanges) setState(() => _hasUnsavedChanges = false);
      }
    });
    if (!_hydrated && widget.invoice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _formCubit.hydrateFromInvoice(widget.invoice!);
        } catch (_) {}
      });
      _hydrated = true;
    }
  }

  String _getAppBarTitle() {
    switch (_mode) {
      case InvoiceMode.create:
        return 'Create Invoice';
      case InvoiceMode.edit:
        return 'Draft Invoice';
      case InvoiceMode.view:
        if (_invoice?.status == InvoiceStatus.draft) {
          return 'Draft Invoice';
        } else if (_invoice?.status == InvoiceStatus.validated) {
          return 'Validated Invoice';
        } else if (_invoice?.status == InvoiceStatus.paid) {
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
      _deliveryAddressController.text = invoice.deliveryAddress ?? '';
      _selectedCurrency = invoice.currency ?? 'NGN';
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
    _formCubit.close();
    _formSub?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: _formCubit,
        child: Builder(builder: (context) {
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
                if (_invoice != null &&
                    _invoice!.id.isNotEmpty &&
                    _invoice!.status == InvoiceStatus.draft)
                  PopupMenuButton<_MenuAction>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (action) async {
                      switch (action) {
                        case _MenuAction.delete:
                          await _confirmAndDeleteInvoice();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final items = <PopupMenuEntry<_MenuAction>>[];
                      // Delete is only available for draft invoices
                      items.add(
                        const PopupMenuItem<_MenuAction>(
                          value: _MenuAction.delete,
                          child: Row(
                            children: [
                              Icon(Icons.delete_forever,
                                  color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete Invoice'),
                            ],
                          ),
                        ),
                      );
                      return items;
                    },
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                // Invoice Title and Form
                Expanded(
                  child: Builder(builder: (context) {
                    final bottomSafe =
                        MediaQuery.of(context).viewPadding.bottom;
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
                          AppSpacing.spaceSM,
                          Builder(builder: (_) {
                            final String statusText;
                            if (_invoice == null ||
                                (_invoice?.id.isEmpty ?? true)) {
                              statusText = 'New';
                            } else {
                              switch (_invoice!.status) {
                                case InvoiceStatus.draft:
                                  statusText = 'Draft';
                                  break;
                                case InvoiceStatus.validated:
                                  statusText = 'Validated';
                                  break;
                                case InvoiceStatus.paid:
                                  statusText = 'Paid';
                                  break;
                                case InvoiceStatus.pending:
                                  statusText = 'Pending';
                                  break;
                                case InvoiceStatus.overdue:
                                  statusText = 'Overdue';
                                  break;
                                case InvoiceStatus.cancelled:
                                  statusText = 'Cancelled';
                                  break;
                              }
                            }
                            return Text(
                              statusText,
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                          if (_invoice != null &&
                              _invoice!.invoiceNumber.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Invoice #: ${_invoice!.invoiceNumber}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          AppSpacing.spaceXXL,

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
                                      addressController:
                                          _deliveryAddressController,
                                      readOnly: !_isCustomerEditable,
                                    ),
                                    AppSpacing.spaceLG,
                                    _buildFormField(
                                      'Delivery Address',
                                      '',
                                      _deliveryAddressController,
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacing.spaceXXL,

                              // Right Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSelectableDateField('Invoice Date',
                                        _formatDate(_invoiceDate)),
                                    AppSpacing.spaceLG,
                                    _buildSelectableDateField(
                                        'Due Date', _formatDate(_dueDate)),
                                    AppSpacing.spaceLG,
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
                                        AppSpacing.spaceLG,
                                        DropdownButton<String>(
                                          value: _selectedCurrency,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'NGN',
                                                child: Text('NGN')),
                                            DropdownMenuItem(
                                                value: 'USD',
                                                child: Text('USD')),
                                            DropdownMenuItem(
                                                value: 'GBP',
                                                child: Text('GBP')),
                                            DropdownMenuItem(
                                                value: 'EUR',
                                                child: Text('EUR')),
                                            DropdownMenuItem(
                                                value: 'GHS',
                                                child: Text('GHS')),
                                            DropdownMenuItem(
                                                value: 'KES',
                                                child: Text('KES')),
                                          ],
                                          onChanged: _isFormReadOnly
                                              ? null
                                              : (v) => setState(() =>
                                                  _selectedCurrency =
                                                      v ?? 'NGN'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          AppSpacing.spaceXXXL,

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
                            final double tabHeight =
                                ((vh * 0.5).clamp(420.0, 560.0)).toDouble();
                            return SizedBox(
                              height: tabHeight,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  LinesTab(readOnly: !_isLinesEditable),
                                  MaterialsTab(
                                      readOnly: !_areMaterialsEditable),
                                  MeasurementTab(
                                      readOnly: !_areMeasurementsEditable),
                                ],
                              ),
                            );
                          }),

                          AppSpacing.spaceXXL,

                          // Totals Section (computed by InvoiceFormCubit)
                          BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
                            builder: (context, state) {
                              final cubit = context.read<InvoiceFormCubit>();
                              return Container(
                                width: double.infinity,
                                padding: context.responsivePadding,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: AppRadius.radiusMD,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildTotalRow('Subtotal (Invoice):',
                                        'NGN ${cubit.invoiceLinesTotal.toStringAsFixed(2)}'),
                                    _buildTotalRow('Subtotal (Materials):',
                                        'NGN ${cubit.materialsTotal.toStringAsFixed(2)}'),
                                    const Divider(),
                                    _buildTotalRow('Total:',
                                        'NGN ${cubit.grandTotal.toStringAsFixed(2)}',
                                        isBold: true),
                                  ],
                                ),
                              );
                            },
                          ),

                          AppSpacing.spaceXXL,

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
                              AppSpacing.spaceSM,
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: AppRadius.radiusSM,
                                ),
                                child: TextFormField(
                                  controller: _termsController,
                                  readOnly: _isFormReadOnly,
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter terms and conditions...',
                                    border: InputBorder.none,
                                    contentPadding: AppSpacing.paddingMD,
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

  Future<void> _confirmAndDeleteInvoice() async {
    if (_invoice == null || _invoice!.id.isEmpty) return;
    final allowDelete = _invoice!.status == InvoiceStatus.draft;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: Text(allowDelete
            ? 'This draft invoice will be permanently deleted.'
            : 'Only draft invoices can be deleted. Attempting to delete may fail.'),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          PrimaryButton(
            text: 'Delete',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = GetIt.I<InvoiceRepository>();
      await repo.deleteInvoice(_invoice!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice deleted')),
      );
      Navigator.of(context).pop(true); // Return to previous screen
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && e.response?.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only draft invoices can be deleted.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete invoice: $e')),
        );
      }
    }
  }

  Widget _buildBottomActionBar() {
    List<Widget> buttons = [];

    // Always show Share button
    buttons.add(
      Expanded(
        child: OutlinedAppButton(
          text: 'Share',
          onPressed: _shareInvoice,
        ),
      ),
    );

    buttons.add(AppSpacing.spaceSM);

    // Show Create Job button for draft and validated invoices
    final currentStatus =
        (_invoice == null || _invoice!.id.isEmpty) ? null : _invoice!.status;
    if (currentStatus == null ||
        currentStatus == InvoiceStatus.draft ||
        currentStatus == InvoiceStatus.validated) {
      buttons.add(
        Expanded(
          child: OutlinedAppButton(
            text: 'Create Job',
            onPressed: _createJob,
          ),
        ),
      );

      buttons.add(AppSpacing.spaceSM);
    }

    // Show Update button when validated (persist edited lines)
    if (currentStatus == InvoiceStatus.validated) {
      buttons.add(
        Expanded(
          child: OutlinedAppButton(
            text: _hasUnsavedChanges ? 'Update •' : 'Update',
            onPressed: () {
              _updateInvoice();
            },
          ),
        ),
      );

      buttons.add(AppSpacing.spaceSM);
    }

    // Add main action button (Save → Confirm → Paid)
    String buttonText = 'Save';
    VoidCallback? onPressed = _saveDraft;

    if (currentStatus == null) {
      // New/unsaved: Save
      buttonText = 'Save';
      onPressed = _saveDraft;
    } else if (currentStatus == InvoiceStatus.draft) {
      // Draft: Confirm
      buttonText = 'Confirm';
      onPressed = _confirmInvoice;
    } else if (currentStatus == InvoiceStatus.validated) {
      // Validated: Paid
      buttonText = 'Paid';
      onPressed = _payInvoice;
    } else if (currentStatus == InvoiceStatus.paid) {
      // Paid: show disabled Paid
      buttonText = 'Paid';
      onPressed = null;
    } else {
      // Fallback: allow confirm
      buttonText = 'Confirm';
      onPressed = _confirmInvoice;
    }

    buttons.add(
      Expanded(
        child: PrimaryButton(
          text: buttonText,
          onPressed: onPressed,
        ),
      ),
    );

    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
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

  void _shareInvoice() async {
    // Offer the three backend-driven options (A/B/C)
    if (_invoice == null || _invoice!.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please save/confirm the invoice first before sharing.'),
        ),
      );
      return;
    }

    final id = _invoice!.id;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Share Invoice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Generate Link and Share',
                height: 48,
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _sharePdfLink(id);
                },
              ),
              const SizedBox(height: 10),
              OutlinedAppButton(
                text: 'Download PDF and Share (File)',
                height: 48,
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _sharePdfFile(id);
                },
              ),
              const SizedBox(height: 10),
              TextAppButton(
                text: 'Send Email to Customer',
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _sendInvoiceEmail(id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sharePdfLink(String id) async {
    try {
      final dio = GetIt.I<Dio>();
      final resp = await dio.get(ApiEndpoints.invoicePdf(id));
      String? url;
      final data = resp.data;
      if (data is Map && data['pdf_url'] != null) {
        url = data['pdf_url'] as String;
      } else if (data is Map &&
          data['data'] is Map &&
          data['data']['pdf_url'] != null) {
        url = data['data']['pdf_url'] as String;
      }
      if (url == null || url.isEmpty) {
        throw Exception('No pdf_url in response');
      }
      Share.share(url, subject: 'Invoice ${_invoice?.invoiceNumber ?? id}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share link failed: $e')),
      );
    }
  }

  Future<void> _sharePdfFile(String id) async {
    try {
      final dio = GetIt.I<Dio>();
      final resp = await dio.get(
        ApiEndpoints.invoicePdf(id),
        queryParameters: {'download': 'true'},
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = resp.data as List<int>;
      final number = _invoice?.invoiceNumber ?? id;
      final tmp = Directory.systemTemp;
      final file = File('${tmp.path}/invoice_$number.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([
        XFile(file.path,
            mimeType: 'application/pdf', name: 'invoice_$number.pdf')
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share PDF failed: $e')),
      );
    }
  }

  Future<void> _sendInvoiceEmail(String id) async {
    try {
      final dio = GetIt.I<Dio>();
      final resp = await dio.post(ApiEndpoints.sendInvoice(id));
      final data = resp.data;
      final ok = (data is Map &&
          (data['email_sent'] == true ||
              (data['data'] is Map && data['data']['email_sent'] == true)));
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice emailed to customer')),
        );
      } else {
        String? url;
        if (data is Map && data['pdf_url'] != null) {
          url = data['pdf_url'] as String;
        }
        if (data is Map &&
            data['data'] is Map &&
            data['data']['pdf_url'] != null) {
          url = data['data']['pdf_url'] as String;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Email failed. Share link instead.${url != null ? '\n$url' : ''}')),
        );
        if (url != null) {
          Share.share(url);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send email failed: $e')),
      );
    }
  }

  void _createJob() {
    if (_invoice == null || _invoice!.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save/confirm the invoice first.')),
      );
      return;
    }
    _createJobFromInvoice(_invoice!.id);
  }

  Future<void> _createJobFromInvoice(String id) async {
    try {
      final dio = GetIt.I<Dio>();
      final resp = await dio.post(ApiEndpoints.createInvoiceJob(id));
      dynamic data = resp.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        data = Map<String, dynamic>.from(data['data']);
      }
      int? jobId;
      String? visibility;
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        final j = m['job_id'];
        if (j is int) {
          jobId = j;
        } else if (j != null) {
          jobId = int.tryParse(j.toString());
        }
        visibility = m['job_visibility']?.toString();
      }

      final idPart = jobId != null ? ' (ID: $jobId)' : '';
      final visPart = visibility != null ? ' • $visibility' : '';
      final text = 'Job created$idPart$visPart';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && (e.response?.data)['detail'] != null)
              ? (e.response?.data)['detail'].toString()
              : 'Failed to create job from invoice.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create job: $e')),
      );
    }
  }

  Future<void> _confirmInvoice() async {
    if (_invoice == null || _invoice!.id.isEmpty) {
      // Not saved yet; require save first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save as draft first')),
      );
      return;
    }
    try {
      final repo = GetIt.I<InvoiceRepository>();
      final updated = await repo.sendInvoice(_invoice!.id);
      if (!mounted) return;
      setState(() {
        _invoice = updated;
        _mode = InvoiceMode.view; // lock editing after validation
        // Initialize snapshot for unsaved tracking
        _savedItemsSnapshot = _mapInvoiceItems(updated.items);
        _hasUnsavedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice validated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to validate: $e')),
      );
    }
  }

  Future<void> _payInvoice() async {
    if (_invoice == null || _invoice!.id.isEmpty) return;
    try {
      // If validated, persist any pending line edits before paying
      if (_invoice!.status == InvoiceStatus.validated) {
        final ok = await _updateInvoice(silent: true);
        if (!ok) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Could not save changes. Please fix and retry Paid.')),
          );
          return;
        }
      }

      final repo = GetIt.I<InvoiceRepository>();
      final paid = await repo.markAsPaid(_invoice!.id, DateTime.now());
      if (!mounted) return;
      setState(() {
        _invoice = paid;
        _mode = InvoiceMode.view;
      });
      // Navigate back to list after marking as paid
      Navigator.of(context).pop(_invoice);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark paid: $e')),
      );
    }
  }

  Future<bool> _updateInvoice({bool silent = false}) async {
    if (_invoice == null || _invoice!.id.isEmpty) return false;
    try {
      final repo = GetIt.I<InvoiceRepository>();
      final cubit = _formCubit;
      final s = cubit.state;

      // Flatten all line items from sections and independent lines
      final allLines = <InvoiceLineData>[
        ...s.independentLines,
        ...s.sections.expand((sec) => sec.items),
      ];

      // Build domain invoice items
      final items = allLines
          .where((it) => it.label.trim().isNotEmpty)
          .map((it) => InvoiceItem(
                id: '',
                description: it.label.trim(),
                quantity: it.quantity.round().clamp(1, 1000000),
                unitPrice: it.unitPrice,
                amount: it.subtotal,
              ))
          .toList();

      // Recompute totals (validated stage ignores materials)
      final itemsBase =
          allLines.fold<double>(0, (p, e) => p + (e.quantity * e.unitPrice));
      // Validated stage ignores materials when recalculating totals
      final base = itemsBase;
      final subtotal = base;
      final taxAmount =
          (subtotal - s.discount).clamp(0, double.infinity) * s.taxRate;
      final total =
          (subtotal - s.discount).clamp(0, double.infinity) + taxAmount;

      final inv = _invoice!.copyWith(
        items: items,
        subtotal: subtotal,
        taxRate: s.taxRate,
        taxAmount: taxAmount,
        total: total,
        updatedAt: DateTime.now(),
      );

      final updated = await repo.updateInvoice(inv);
      if (!mounted) return true; // treat as ok if we're leaving the page
      setState(() {
        _invoice = updated;
        _savedItemsSnapshot = _mapInvoiceItems(updated.items);
        _hasUnsavedChanges = false;
      });
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice updated')),
        );
      }
      return true;
    } catch (e) {
      if (!mounted) return false;
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
      return false;
    }
  }

  // ----- Unsaved changes helpers -----
  void _initUnsavedSnapshot() {
    if (_invoice != null && _invoice!.status == InvoiceStatus.validated) {
      _savedItemsSnapshot = _mapInvoiceItems(_invoice!.items);
    } else {
      _savedItemsSnapshot = null;
    }
    _hasUnsavedChanges = false;
  }

  List<Map<String, dynamic>> _flattenFormItems(InvoiceFormState s) {
    final allLines = <InvoiceLineData>[
      ...s.independentLines,
      ...s.sections.expand((sec) => sec.items),
    ];
    return allLines
        .where((it) => it.label.trim().isNotEmpty)
        .map((it) => {
              'description': it.label.trim(),
              'quantity': it.quantity.round().clamp(1, 1000000),
              'unitPrice': it.unitPrice,
            })
        .toList();
  }

  List<Map<String, dynamic>> _mapInvoiceItems(List<InvoiceItem> items) {
    return items
        .map((it) => {
              'description': it.description,
              'quantity': it.quantity,
              'unitPrice': it.unitPrice,
            })
        .toList();
  }

  bool _sameItems(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (a.length != b.length) return false;
    bool sameDouble(double x, double y) => (x - y).abs() < 0.0001;
    for (var i = 0; i < a.length; i++) {
      final ai = a[i];
      final bi = b[i];
      if (ai['description'] != bi['description']) {
        return false;
      }
      if (ai['quantity'] != bi['quantity']) {
        return false;
      }
      if (!sameDouble((ai['unitPrice'] as num).toDouble(),
          (bi['unitPrice'] as num).toDouble())) {
        return false;
      }
    }
    return true;
  }

  Future<void> _saveDraft() async {
    try {
      final repo = GetIt.I<InvoiceRepository>();
      final cubit = _formCubit;
      final s = cubit.state;

      if (s.selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer first')),
        );
        return;
      }

      // Flatten all line items
      final allLines = <InvoiceLineData>[
        ...s.independentLines,
        ...s.sections.expand((sec) => sec.items),
      ];

      // Build domain invoice items
      final items = allLines
          .where((it) => it.label.trim().isNotEmpty)
          .map((it) => InvoiceItem(
                id: '',
                description: it.label.trim(),
                quantity: it.quantity.round().clamp(1, 1000000),
                unitPrice: it.unitPrice,
                amount: it.subtotal,
              ))
          .toList();

      // Compute totals (include materials in subtotal for draft)
      final itemsBase =
          allLines.fold<double>(0, (p, e) => p + (e.quantity * e.unitPrice));
      final materialsBase =
          s.materials.fold<double>(0, (p, m) => p + (m.quantity * m.unitPrice));
      final base = itemsBase + materialsBase;
      final subtotal = base;
      final taxAmount =
          (subtotal - s.discount).clamp(0, double.infinity) * s.taxRate;
      final total =
          (subtotal - s.discount).clamp(0, double.infinity) + taxAmount;

      // Build materials from form state (map to backend schema)
      final mats = s.materials
          .where((m) => m.description.trim().isNotEmpty)
          .map((m) => InvoiceMaterial(
                name: m.description.trim(),
                description: null,
                quantity: m.quantity,
                unit: 'pcs',
                unitCost: m.unitPrice,
              ))
          .toList();

      // Measurements (optional)
      final meas = s.measurements
          .where((m) => m.item.trim().isNotEmpty)
          .map((m) => InvoiceMeasurement(
                label: m.item.trim(),
                value: m.quantity,
                unit: (m.uom.isNotEmpty ? m.uom : 'unit'),
                notes: null,
              ))
          .toList();

      final inv = Invoice(
        id: '',
        invoiceNumber: 'DRAFT-${DateTime.now().millisecondsSinceEpoch}',
        clientName: s.selectedCustomer!.name,
        clientEmail: s.selectedCustomer!.email,
        customerId: s.selectedCustomer!.id,
        deliveryAddress: _deliveryAddressController.text.trim().isEmpty
            ? null
            : _deliveryAddressController.text.trim(),
        currency: _selectedCurrency,
        issueDate: _invoiceDate,
        dueDate: _dueDate,
        items: items,
        materials: mats,
        measurements: meas,
        subtotal: subtotal,
        taxRate: s.taxRate,
        taxAmount: taxAmount,
        total: total,
        status: InvoiceStatus.draft,
        notes: _termsController.text.trim().isEmpty
            ? null
            : _termsController.text.trim(),
        jobId: null,
        paidDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.createInvoice(inv);
      if (!mounted) return;
      setState(() {
        _invoice = saved;
        _mode = InvoiceMode.edit; // Draft state, keep editing allowed
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice saved as draft')),
      );
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && e.response?.statusCode == 403) {
        final detail = e.response?.data is Map
            ? ((e.response?.data)['detail']?.toString() ??
                'Invoice limit reached. Upgrade your plan to create more invoices.')
            : 'Invoice limit reached. Upgrade your plan to create more invoices.';
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Upgrade Required'),
            content: Text(detail),
            actions: [
              TextAppButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save draft: $e')),
        );
      }
    }
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
              AppSpacing.spaceXS,
              const Icon(Icons.help_outline, size: 16, color: Colors.grey),
            ],
          ),
          AppSpacing.spaceSM,
        ],
        TextFormField(
          controller: controller,
          readOnly: readOnly ?? _isFormReadOnly,
          decoration: InputDecoration(
            hintText: hint,
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

// (enum moved to top-level)

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
            AppSpacing.spaceXS,
            const Icon(Icons.help_outline, size: 16, color: Colors.grey),
          ],
        ),
        AppSpacing.spaceSM,
        GestureDetector(
          onTap: _isFormReadOnly ? null : () => _selectDate(context, label),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: AppRadius.radiusSM,
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

  // Obsolete placeholders removed; tabs and content are rendered by LinesTab,
  // MaterialsTab, and MeasurementTab widgets.

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
