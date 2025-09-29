import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

class EducationPage extends StatelessWidget {
  final List<Education> items;
  const EducationPage({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Education/Certification')),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AccountError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final list = (state is AccountProfileLoaded) ? state.profile.education : items;
          if (list.isEmpty) return const Center(child: Text('No education yet'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => _EduTile(edu: list[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _EduForm())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EduTile extends StatelessWidget {
  final Education edu;
  const _EduTile({required this.edu});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(edu.schoolName),
        subtitle: Text(edu.fieldOfStudy),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => _EduForm(existing: edu))),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => context.read<AccountBloc>().add(AccountDeleteEducation(edu.id)),
        ),
      ),
    );
  }
}

class _EduForm extends StatefulWidget {
  final Education? existing;
  const _EduForm({this.existing});
  @override
  State<_EduForm> createState() => _EduFormState();
}

class _EduFormState extends State<_EduForm> {
  late final TextEditingController school;
  late final TextEditingController field;
  late final TextEditingController degree;
  late final TextEditingController description;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    school = TextEditingController(text: widget.existing?.schoolName ?? '');
    field = TextEditingController(text: widget.existing?.fieldOfStudy ?? '');
    degree = TextEditingController(text: widget.existing?.degree ?? '');
    description = TextEditingController(text: widget.existing?.description ?? '');
    startDate = widget.existing?.startDate;
    endDate = widget.existing?.endDate;
  }

  @override
  void dispose() {
    school.dispose();
    field.dispose();
    degree.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final initial = (isStart ? startDate : endDate) ?? now;
    final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1980),
        lastDate: DateTime(now.year + 5));
    if (picked != null) setState(() => isStart ? startDate = picked : endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add Education' : 'Edit Education')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: school, decoration: const InputDecoration(labelText: 'School')),
          const SizedBox(height: 12),
          TextField(
              controller: field, decoration: const InputDecoration(labelText: 'Field of Study')),
          const SizedBox(height: 12),
          TextField(
              controller: degree,
              decoration: const InputDecoration(labelText: 'Degree (optional)')),
          const SizedBox(height: 12),
          TextField(
              controller: description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description (optional)')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => _pickDate(true),
                      child: Text(startDate == null
                          ? 'Start Date'
                          : startDate!.toLocal().toString().split(' ').first))),
              const SizedBox(width: 8),
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => _pickDate(false),
                      child: Text(endDate == null
                          ? 'End Date'
                          : endDate!.toLocal().toString().split(' ').first))),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (startDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select start date')),
                );
                return;
              }
              if (endDate != null && endDate!.isBefore(startDate!)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('End date cannot be before start date')),
                );
                return;
              }
              if (widget.existing == null) {
                context.read<AccountBloc>().add(AccountAddEducation(
                      schoolName: school.text.trim(),
                      fieldOfStudy: field.text.trim(),
                      degree: degree.text.trim().isEmpty ? null : degree.text.trim(),
                      startDate: startDate!,
                      endDate: endDate,
                      description: description.text.trim().isEmpty ? null : description.text.trim(),
                    ));
              } else {
                context.read<AccountBloc>().add(AccountUpdateEducation(
                      id: widget.existing!.id,
                      schoolName: school.text.trim(),
                      fieldOfStudy: field.text.trim(),
                      degree: degree.text.trim().isEmpty ? null : degree.text.trim(),
                      startDate: startDate ?? widget.existing!.startDate,
                      endDate: endDate,
                      description: description.text.trim().isEmpty ? null : description.text.trim(),
                    ));
              }
              Navigator.pop(context);
            },
            child: Text(widget.existing == null ? 'Add' : 'Save'),
          )
        ],
      ),
    );
  }
}
