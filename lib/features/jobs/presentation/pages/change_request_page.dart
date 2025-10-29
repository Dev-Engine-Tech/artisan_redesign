// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';

class ChangeRequestPage extends StatefulWidget {
  final Job job;

  const ChangeRequestPage({super.key, required this.job});

  @override
  State<ChangeRequestPage> createState() => _ChangeRequestPageState();
}

class _ChangeRequestPageState extends State<ChangeRequestPage> {
  final _formKey = GlobalKey<FormState>();
  String? _proposedChange;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTime? _selectedDate;

  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for delivery date
    if (_proposedChange == 'delivery' && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a proposed delivery date')));
      return;
    }

    // Build the reason including proposed change details
    final baseReason = _reasonController.text.trim();
    String reason = baseReason;

    if (_proposedChange != null) {
      if (_proposedChange == 'price') {
        final priceText = _priceController.text.trim();
        reason =
            'Change price to NGN $priceText. ${baseReason.isNotEmpty ? baseReason : ''}';
      } else if (_proposedChange == 'delivery') {
        final dateText = _selectedDate != null
            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
            : '';
        reason =
            'Change delivery date to $dateText. ${baseReason.isNotEmpty ? baseReason : ''}';
      } else if (_proposedChange == 'scope') {
        reason = 'Change scope. ${baseReason.isNotEmpty ? baseReason : ''}';
      } else if (_proposedChange == 'other') {
        reason = 'Other changes. ${baseReason.isNotEmpty ? baseReason : ''}';
      }
    }

    // Dispatch bloc event
    context
        .read<JobBloc>()
        .add(RequestChangeEvent(jobId: widget.job.id, reason: reason.trim()));

    setState(() {
      _submitting = true;
    });
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // icon
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline,
                    size: 72, color: Color(0xFF6B4CD6)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Request Sent',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your change request has been sent successfully and the client has been notified.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                text: 'OK',
                onPressed: () {
                  Navigator.of(ctx).pop(); // close dialog
                  Navigator.of(context).pop(); // close change request page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobStateChangeRequested && state.jobId == job.id) {
          setState(() {
            _submitting = false;
          });
          _showSuccessDialog();
        } else if (state is JobStateError) {
          setState(() {
            _submitting = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is JobStateApplying) {
          setState(() {
            _submitting = true;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(10)),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          title: const Text('Change Request',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
          centerTitle: true,
        ),
        backgroundColor: AppColors.lightPeach,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Agreement summary card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Agreed Payment',
                            style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 6),
                        Text('NGN ${job.minBudget}',
                            style: const TextStyle(
                                color: Color(0xFF9A4B20),
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        const Text('Agreed Delivery Date',
                            style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 6),
                        const Text('30/04/2024',
                            style: TextStyle(color: Colors.black87)),
                        const SizedBox(height: 12),
                        const Text('Comment',
                            style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 6),
                        Text(job.description,
                            style: const TextStyle(color: Colors.black87)),
                      ]),
                ),
                const SizedBox(height: 20),

                const Text('Proposed Changes',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _proposedChange,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.subtleBorder)),
                  ),
                  hint: const Text('Select'),
                  items: const [
                    DropdownMenuItem(
                        value: 'price', child: Text('Change price')),
                    DropdownMenuItem(
                        value: 'delivery', child: Text('Change delivery date')),
                    DropdownMenuItem(
                        value: 'scope', child: Text('Change scope')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() {
                    _proposedChange = v;
                    if (v != 'price') _priceController.clear();
                    if (v != 'delivery') _selectedDate = null;
                  }),
                ),
                const SizedBox(height: 16),

                // Dynamic fields based on selected proposed change
                if (_proposedChange == 'price') ...[
                  const Text('Proposed Price',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.subtleBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter new price (NGN)',
                        border: InputBorder.none,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter a price';
                        }
                        final parsed = int.tryParse(v.replaceAll(',', ''));
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (_proposedChange == 'delivery') ...[
                  const Text('Proposed Delivery Date',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.subtleBorder),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: const TextStyle(color: Colors.black87)),
                          const Icon(Icons.calendar_today,
                              color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const Text('Explain reasons for the proposed changes',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFF6B4CD6).withValues(alpha: 0.7)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: TextFormField(
                    controller: _reasonController,
                    maxLines: 10,
                    minLines: 6,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Select',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 10) {
                        return 'Please provide more details (min 10 chars)';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: PrimaryButton(
            text: 'Submit Request',
            onPressed: _submitting ? null : _submit,
            isLoading: _submitting,
          ),
        ),
      ),
    );
  }
}
