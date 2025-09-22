import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

class WorkExperiencePage extends StatelessWidget {
  final List<WorkExperience> items;
  const WorkExperiencePage({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work Experience')),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AccountError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final list = (state is AccountProfileLoaded) ? state.profile.workExperience : items;
          if (list.isEmpty) return const Center(child: Text('No work experience yet'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => _WorkTile(exp: list[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _WorkForm())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WorkTile extends StatelessWidget {
  final WorkExperience exp;
  const _WorkTile({required this.exp});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(exp.jobTitle),
        subtitle: Text(exp.companyName),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _WorkForm(existing: exp))),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => context.read<AccountBloc>().add(AccountDeleteWorkExperience(exp.id)),
        ),
      ),
    );
  }
}

class _WorkForm extends StatefulWidget {
  final WorkExperience? existing;
  const _WorkForm({this.existing});
  @override
  State<_WorkForm> createState() => _WorkFormState();
}

class _WorkFormState extends State<_WorkForm> {
  late final TextEditingController title;
  late final TextEditingController company;
  late final TextEditingController location;
  late final TextEditingController description;
  DateTime? startDate;
  DateTime? endDate;
  bool isCurrent = false;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.existing?.jobTitle ?? '');
    company = TextEditingController(text: widget.existing?.companyName ?? '');
    location = TextEditingController(text: widget.existing?.location ?? '');
    description = TextEditingController(text: widget.existing?.description ?? '');
    startDate = widget.existing?.startDate;
    endDate = widget.existing?.endDate;
    isCurrent = widget.existing?.isCurrent ?? false;
  }

  @override
  void dispose() {
    title.dispose();
    company.dispose();
    location.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final initial = (isStart ? startDate : endDate) ?? now;
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(1980), lastDate: DateTime(now.year + 5));
    if (picked != null) setState(() => isStart ? startDate = picked : endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add Work' : 'Edit Work')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Job Title')),
          const SizedBox(height: 12),
          TextField(controller: company, decoration: const InputDecoration(labelText: 'Company')),
          const SizedBox(height: 12),
          TextField(controller: location, decoration: const InputDecoration(labelText: 'Location')),
          const SizedBox(height: 12),
          TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => _pickDate(true), child: Text(startDate == null ? 'Start Date' : startDate!.toLocal().toString().split(' ').first))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => _pickDate(false), child: Text(endDate == null ? 'End Date' : endDate!.toLocal().toString().split(' ').first))),
            ],
          ),
          SwitchListTile(
            value: isCurrent,
            onChanged: (v) => setState(() => isCurrent = v),
            title: const Text("I'm currently working here"),
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
                  const SnackBar(
                      content: Text('End date cannot be before start date')),
                );
                return;
              }
              if (widget.existing == null) {
                context.read<AccountBloc>().add(AccountAddWorkExperience(
                      jobTitle: title.text.trim(),
                      companyName: company.text.trim(),
                      location: location.text.trim(),
                      description: description.text.trim(),
                      startDate: startDate!,
                      endDate: endDate,
                      isCurrent: isCurrent,
                    ));
              } else {
                context.read<AccountBloc>().add(AccountUpdateWorkExperience(
                      id: widget.existing!.id,
                      jobTitle: title.text.trim(),
                      companyName: company.text.trim(),
                      location: location.text.trim(),
                      description: description.text.trim(),
                      startDate: startDate ?? widget.existing!.startDate,
                      endDate: endDate,
                      isCurrent: isCurrent,
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
