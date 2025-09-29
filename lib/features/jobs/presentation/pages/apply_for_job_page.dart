// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_material_management_widget.dart';
import 'package:artisans_circle/core/di.dart';

enum PaymentMethod { byProject, byMilestone }

class ApplyForJobPage extends StatefulWidget {
  final Job job;

  const ApplyForJobPage({super.key, required this.job});

  @override
  State<ApplyForJobPage> createState() => _ApplyForJobPageState();
}

class _ApplyForJobPageState extends State<ApplyForJobPage> {
  final _proposalController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.byProject;
  bool _requiresInspection = false;
  final _inspectionFeeController = TextEditingController();
  String? _selectedDuration;
  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, "0")}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}';

  // Simple milestone model for the form (editable)
  final List<_Milestone> _milestones = [];

  // Desired pay for 'By Project' method
  final _desiredPayController = TextEditingController();

  // Material list editable by user
  final List<_MaterialItem> _materials = [];

  // Attachments (simple string list for demo)
  final List<String> _attachments = [];

  @override
  void dispose() {
    _proposalController.dispose();
    _inspectionFeeController.dispose();
    _desiredPayController.dispose();
    for (final m in _materials) {
      m.dispose();
    }
    for (final ms in _milestones) {
      ms.dispose();
    }
    super.dispose();
  }

  void _addMilestone() {
    setState(() {
      _milestones.add(_Milestone(
          descriptionController: TextEditingController(),
          amountController: TextEditingController(),
          date: null));
    });
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestones[index].dispose();
      _milestones.removeAt(index);
    });
  }

  Future<void> _pickMilestoneDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _milestones[index].date = picked;
      });
    }
  }

  void _addMaterial() {
    setState(() {
      _materials.add(_MaterialItem(
        descriptionController: TextEditingController(),
        quantityController: TextEditingController(text: '1'),
        costController: TextEditingController(),
      ));
    });
  }

  void _removeMaterial(int index) {
    setState(() {
      _materials[index].dispose();
      _materials.removeAt(index);
    });
  }

  // Removed unused _addAttachment helper to satisfy analyzer

  void _submitApplication() {
    // Validation remains local
    if (_proposalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please add a project proposal')));
      return;
    }
    if (_paymentMethod == PaymentMethod.byMilestone && _milestones.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please add at least one milestone')));
      return;
    }
    // Materials are required by API
    if (_materials.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please add at least one material item')));
      return;
    }

    // Build application payload mirroring the working GetX app
    final jobIdInt = int.tryParse(widget.job.id) ??
        int.tryParse(widget.job.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
    if (jobIdInt <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid job ID for application')));
      return;
    }
    final paymentTypeStr = _paymentMethod == PaymentMethod.byProject ? 'project' : 'milestone';

    final materials = _materials
        .where((m) => m.descriptionController.text.trim().isNotEmpty)
        .map((m) => JobMaterial(
              description: m.descriptionController.text.trim(),
              quantity: (int.tryParse(m.quantityController.text.trim()) ?? 1).clamp(1, 1000000),
              price: (double.tryParse(m.costController.text.trim()) ?? 0).toInt(),
            ))
        .where((m) => m.price > 0)
        .toList();
    if (materials.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add at least one material with a cost > 0')));
      return;
    }
    final milestones = _milestones
        .where((ms) => ms.date != null)
        .map((ms) => JobMilestone(
              description: ms.descriptionController.text.trim(),
              dueDate: ms.date!,
              amount: int.tryParse(ms.amountController.text.trim()) ?? 0,
            ))
        .toList();

    final application = JobApplication(
      job: jobIdInt,
      duration: _selectedDuration?.trim().isNotEmpty == true
          ? _selectedDuration!.trim()
          : (widget.job.duration.trim().isNotEmpty ? widget.job.duration : 'Less than 1 month'),
      proposal: _proposalController.text.trim(),
      paymentType: paymentTypeStr,
      desiredPay: (int.tryParse(_desiredPayController.text.trim()) ?? widget.job.minBudget)
          .clamp(0, 100000000),
      milestones: milestones,
      materials: materials,
      attachments: _attachments,
      inspection: _requiresInspection && _inspectionFeeController.text.trim().isNotEmpty
          ? JobInspectionFee(amount: _inspectionFeeController.text.trim())
          : null,
    );

    // Dispatch via JobBloc; listener will handle success/error.
    context.read<JobBloc>().add(ApplyToJobEvent(application: application));
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    // Create the inner widget (the one that depends on JobBloc).
    // We'll try to use an existing JobBloc from context; if none exists we will
    // create a provider here so the inner widget always has a JobBloc available.
    Widget inner() {
      return BlocListener<JobBloc, JobState>(
        listener: (context, state) {
          if (state is JobStateAppliedSuccess && state.jobId == widget.job.id) {
            // Close the apply sheet/page and show confirmation
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application submitted — payment requested')));
          } else if (state is JobStateError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightPeach,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            title: const Text('Apply for Job', style: TextStyle(color: Colors.black87)),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Job details box (readonly summary)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.softBorder),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Job Details', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(job.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(job.category,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.softPeach, borderRadius: BorderRadius.circular(8)),
                          child: Text('Budget: NGN${job.minBudget}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.brownHeader)),
                        ),
                        Text('• ${job.duration}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(job.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis),
                  ]),
                ),

                const SizedBox(height: 16),

                // Project proposal input
                const Text('Project proposal', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.softBorder)),
                  child: TextField(
                    controller: _proposalController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration.collapsed(
                        hintText:
                            'Describe what you will do for this project and why the client should hire you.'),
                  ),
                ),

                const SizedBox(height: 16),

                // Payment method
                const Text('How do you want to be paid?',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                // ignore: deprecated_member_use
                RadioListTile<PaymentMethod>(
                  value: PaymentMethod.byProject,
                  // ignore: deprecated_member_use
                  groupValue: _paymentMethod,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                  title: const Text('By Project'),
                  subtitle: const Text(
                      'Get your entire payment at the end when all work has been delivered'),
                ),
                // ignore: deprecated_member_use
                RadioListTile<PaymentMethod>(
                  value: PaymentMethod.byMilestone,
                  // ignore: deprecated_member_use
                  groupValue: _paymentMethod,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                  title: const Text('By Milestone'),
                  subtitle:
                      const Text('Divide the project into smaller segments called milestones.'),
                ),

                if (_paymentMethod == PaymentMethod.byMilestone) ...[
                  const SizedBox(height: 8),
                  const Text('Milestones', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (var i = 0; i < _milestones.length; i++)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Milestone ${i + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _removeMilestone(i)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _milestones[i].descriptionController,
                            decoration: const InputDecoration(labelText: 'Description'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickMilestoneDate(i),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                        color: AppColors.cardBackground,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.softBorder)),
                                    child: Text(_milestones[i].date == null
                                        ? 'Select due date'
                                        : _formatDate(_milestones[i].date!)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _milestones[i].amountController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Amount (NGN)'),
                                ),
                              ),
                            ],
                          )
                        ]),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: _addMilestone,
                    icon: const Icon(Icons.add),
                    label: const Text('Add milestone'),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  const Text('Desired pay', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _desiredPayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: 'NGN ',
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Note: This is the total amount you will be paid for the project.',
                      style: TextStyle(color: Colors.black54)),
                ],

                const SizedBox(height: 12),

                // Inspection fee
                CheckboxListTile(
                  value: _requiresInspection,
                  onChanged: (v) => setState(() => _requiresInspection = v ?? false),
                  title: const Text('I require an inspection fee'),
                ),
                if (_requiresInspection)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppColors.orange, borderRadius: BorderRadius.circular(8)),
                          child: const Text('₦', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _inspectionFeeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'Inspection fee amount'),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Duration dropdown
                const Text('How long will this project take you?',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDuration,
                  items: const [
                    DropdownMenuItem(value: 'Less than 1 month', child: Text('Less than 1 month')),
                    DropdownMenuItem(value: '1-3 months', child: Text('1-3 months')),
                    DropdownMenuItem(value: '3+ months', child: Text('3+ months')),
                  ],
                  onChanged: (v) => setState(() => _selectedDuration = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),

                const SizedBox(height: 16),

                // Materials (editable)
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Material List (required)',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    ElevatedButton(
                      onPressed: _addMaterial,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
                      child: const Text('Add Materials'),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                if (_materials.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        for (var i = 0; i < _materials.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextField(
                                    controller: _materials[i].descriptionController,
                                    decoration:
                                        const InputDecoration(labelText: 'Material Description'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _materials[i].quantityController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Quantity'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: _materials[i].costController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Cost (NGN)'),
                                  ),
                                ),
                                IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _removeMaterial(i)),
                              ],
                            ),
                          ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                                'NGN ${_materials.fold<double>(0.0, (prev, m) => prev + m.total).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        )
                      ]),
                    ),
                  ),

                const SizedBox(height: 16),

                // Attachments placeholder
                const Text('Attachments', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Attach files (placeholder)')));
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.subtleBorder),
                    ),
                    child: const Center(child: Text('Attach files')),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF213447),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      const Text('Apply Now', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    }

    // If a JobBloc already exists above this context, use it. Otherwise create a provider here.
    try {
      BlocProvider.of<JobBloc>(context);
      return inner();
    } catch (_) {
      return BlocProvider<JobBloc>(
        create: (_) => getIt<JobBloc>(),
        child: inner(),
      );
    }
  }
}

class _Milestone {
  TextEditingController descriptionController;
  TextEditingController amountController;
  DateTime? date;

  _Milestone({required this.descriptionController, required this.amountController, this.date});

  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
  }
}

class _MaterialItem {
  TextEditingController descriptionController;
  TextEditingController quantityController;
  TextEditingController costController;

  _MaterialItem({
    required this.descriptionController,
    required this.quantityController,
    required this.costController,
  });

  double get total {
    final cost = double.tryParse(costController.text) ?? 0.0;
    final qty = double.tryParse(quantityController.text) ?? 1.0;
    return cost * qty;
  }

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    costController.dispose();
  }
}
