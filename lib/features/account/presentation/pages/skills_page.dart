import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

class SkillsPage extends StatefulWidget {
  final List<String> initial;
  const SkillsPage({super.key, this.initial = const []});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final TextEditingController ctr = TextEditingController();
  List<String> skills = [];

  @override
  void initState() {
    super.initState();
    skills = [...widget.initial];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skills')),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountProfileLoaded)
            setState(() => skills = state.profile.skills);
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((s) => Chip(
                            label: Text(s),
                            onDeleted: () => context
                                .read<AccountBloc>()
                                .add(AccountRemoveSkill(s)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctr,
                        decoration:
                            const InputDecoration(hintText: 'Add a skill'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final val = ctr.text.trim();
                        if (val.isNotEmpty) {
                          context.read<AccountBloc>().add(AccountAddSkill(val));
                          ctr.clear();
                        }
                      },
                      child: const Text('Add'),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
