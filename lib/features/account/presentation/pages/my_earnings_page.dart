import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di.dart';
import '../../../../core/components/components.dart';
import '../../domain/entities/earnings.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

class MyEarningsPage extends StatefulWidget {
  const MyEarningsPage({super.key});

  @override
  State<MyEarningsPage> createState() => _MyEarningsPageState();
}

class _MyEarningsPageState extends State<MyEarningsPage> {
  late final AccountBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<AccountBloc>();

    // ✅ PERFORMANCE FIX: Check state before loading to avoid redundant API calls
    final currentState = _bloc.state;

    // Only load earnings if not already loaded
    if (currentState is! AccountEarningsLoaded) {
      _bloc.add(AccountLoadEarnings());
    }

    // ✅ PERFORMANCE FIX: Defer transactions load to avoid concurrent API calls
    // Load transactions after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _bloc.state is! AccountTransactionsLoaded) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _bloc.add(const AccountLoadTransactions());
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('My Earnings')),
        body: BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountActionSuccess) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              if (state.message.toLowerCase().contains('withdrawal')) {
                // refresh earnings + transactions after withdrawal
                context.read<AccountBloc>().add(AccountLoadEarnings());
                context
                    .read<AccountBloc>()
                    .add(const AccountLoadTransactions());
              }
            } else if (state is AccountError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<AccountBloc, AccountState>(
                  buildWhen: (prev, curr) =>
                      curr is AccountEarningsLoaded ||
                      curr is AccountTransactionsLoaded ||
                      curr is AccountLoading ||
                      curr is AccountError,
                  builder: (context, state) {
                    return _EarningsBody(state: state);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  text: 'Request Withdrawal',
                  onPressed: () => _showWithdrawDialog(context),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showWithdrawDialog(BuildContext context) async {
    // Verify or set withdrawal PIN first
    final verified = await _promptVerifyOrSetPin(context);
    if (!verified) return;
    final ctr = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Amount'),
        content: TextField(
          controller: ctr,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Amount'),
        ),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(ctx),
          ),
          PrimaryButton(
            text: 'Submit',
            onPressed: () {
              final amount = double.tryParse(ctr.text.trim());
              if (amount != null && amount > 0) {
                Navigator.pop(ctx);
                context
                    .read<AccountBloc>()
                    .add(AccountRequestWithdrawal(amount));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _EarningsBody extends StatelessWidget {
  final AccountState state;
  const _EarningsBody({required this.state});

  @override
  Widget build(BuildContext context) {
    Earnings? earnings;
    List<TransactionItem> tx = const [];
    if (state is AccountEarningsLoaded) {
      earnings = (state as AccountEarningsLoaded).earnings;
    }
    if (state is AccountTransactionsLoaded) {
      tx = (state as AccountTransactionsLoaded).transactions;
    }

    if (state is AccountLoading && earnings == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AccountError) {
      final err = state as AccountError;
      return Center(child: Text(err.message));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (earnings != null) ...[
          Row(
            children: [
              _StatCard(title: 'Total', value: earnings.total),
              const SizedBox(width: 12),
              _StatCard(title: 'Available', value: earnings.available),
              const SizedBox(width: 12),
              _StatCard(title: 'Pending', value: earnings.pending),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Text('Transaction History',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...tx.map((t) => Card(
              child: ListTile(
                title: Text('${t.currency} ${t.amount.toStringAsFixed(2)}'),
                subtitle: Text(t.description ?? t.status),
                trailing: Text(
                    '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}'),
              ),
            )),
      ],
    );
  }
}

extension on _MyEarningsPageState {
  Future<bool> _promptVerifyOrSetPin(BuildContext context) async {
    final pinCtr = TextEditingController();
    bool ok = false;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Withdrawal PIN'),
        content: TextField(
          controller: pinCtr,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '4-digit PIN'),
        ),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(ctx),
          ),
          TextAppButton(
            text: 'Verify',
            onPressed: () async {
              final pin = pinCtr.text.trim();
              if (pin.length != 4) return;
              context.read<AccountBloc>().add(AccountVerifyWithdrawalPin(pin));
              Navigator.pop(ctx);
              ok = true; // proceed; bloc will show error if invalid
            },
          ),
          TextAppButton(
            text: 'Set PIN',
            onPressed: () async {
              Navigator.pop(ctx);
              await _promptSetPin(context);
            },
          ),
        ],
      ),
    );
    return ok;
  }

  Future<void> _promptSetPin(BuildContext context) async {
    final a = TextEditingController();
    final b = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Withdrawal PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: a,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'PIN')),
            TextField(
                controller: b,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Confirm PIN')),
          ],
        ),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(ctx),
          ),
          TextAppButton(
            text: 'Save',
            onPressed: () {
              if (a.text.trim().length != 4 || a.text.trim() != b.text.trim())
                return;
              context
                  .read<AccountBloc>()
                  .add(AccountSetWithdrawalPin(a.text.trim()));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
