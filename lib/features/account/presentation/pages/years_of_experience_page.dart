import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

class YearsOfExperiencePage extends StatefulWidget {
  final int? initial;
  const YearsOfExperiencePage({super.key, this.initial});

  @override
  State<YearsOfExperiencePage> createState() => _YearsOfExperiencePageState();
}

class _YearsOfExperiencePageState extends State<YearsOfExperiencePage> {
  late final TextEditingController yearsCtr;

  @override
  void initState() {
    super.initState();
    yearsCtr = TextEditingController(text: widget.initial?.toString() ?? '');
  }

  @override
  void dispose() {
    yearsCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Years of experience')),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How many years of professional experience do you have?'),
              const SizedBox(height: 12),
              TextField(
                controller: yearsCtr,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g., 3'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final n = int.tryParse(yearsCtr.text.trim());
                    if (n == null || n < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid number')),
                      );
                      return;
                    }
                    context.read<AccountBloc>().add(AccountUpdateProfile(
                          yearsOfExperience: n,
                        ));
                  },
                  child: const Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
