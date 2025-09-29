import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class AboutMePage extends StatefulWidget {
  final UserProfile? initial;
  const AboutMePage({super.key, this.initial});

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  late final TextEditingController bio;
  late final TextEditingController jobTitle;
  late final TextEditingController location;
  late final TextEditingController phone;

  @override
  void initState() {
    super.initState();
    bio = TextEditingController(text: widget.initial?.bio ?? '');
    jobTitle = TextEditingController(text: widget.initial?.jobTitle ?? '');
    location = TextEditingController(text: widget.initial?.location ?? '');
    phone = TextEditingController(text: widget.initial?.phone ?? '');
  }

  @override
  void dispose() {
    bio.dispose();
    jobTitle.dispose();
    location.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Me')),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is AccountError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: jobTitle,
              decoration: const InputDecoration(labelText: 'Job Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: location,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bio,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final p = phone.text.trim();
                  if (p.isNotEmpty) {
                    bool ok = true;
                    try {
                      PhoneNumber.parse(p);
                    } catch (_) {
                      try {
                        PhoneNumber.parse(p, callerCountry: IsoCode.NG);
                      } catch (_) {
                        ok = false;
                      }
                    }
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid phone number'),
                        ),
                      );
                      return;
                    }
                  }
                  context.read<AccountBloc>().add(AccountUpdateProfile(
                        bio: bio.text.trim(),
                        jobTitle: jobTitle.text.trim(),
                        location: location.text.trim(),
                        phone: p,
                      ));
                },
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
