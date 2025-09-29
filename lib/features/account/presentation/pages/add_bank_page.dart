import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../../../core/di.dart';
import '../../domain/entities/bank_account.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

class AddBankPage extends StatefulWidget {
  const AddBankPage({super.key});

  @override
  State<AddBankPage> createState() => _AddBankPageState();
}

class _AddBankPageState extends State<AddBankPage> {
  late final AccountBloc _bloc;
  List<BankInfo> _banks = const [];
  bool _banksLoading = false;
  List<BankAccount> _accountsCache = const [];

  @override
  void initState() {
    super.initState();
    _bloc = getIt<AccountBloc>();
    _bloc.add(AccountLoadBankAccounts());
    _bloc.add(AccountLoadProfile());
    _bloc.add(AccountLoadBankList());
    _banksLoading = true;
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
        appBar: AppBar(title: const Text('Bank Accounts')),
        body: BlocConsumer<AccountBloc, AccountState>(
          listenWhen: (prev, curr) =>
              curr is AccountBankListLoaded ||
              curr is AccountBankListLoading ||
              curr is AccountError ||
              curr is AccountBankAccountsLoaded,
          listener: (context, state) {
            if (state is AccountBankListLoaded) {
              _banks = state.banks;
              _banksLoading = false;
            } else if (state is AccountBankListLoading) {
              _banksLoading = true;
            } else if (state is AccountError) {
              // Show add/delete failures as global snackbar; verify/list use dialog-only errors
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is AccountBankAccountsLoaded) {
              _accountsCache = state.accounts;
            }
          },
          buildWhen: (prev, curr) =>
              curr is AccountLoading ||
              curr is AccountBankAccountsLoaded ||
              curr is AccountProfileLoaded ||
              curr is AccountBankMutationLoading,
          builder: (context, state) {
            final overlayBusy = state is AccountBankMutationLoading;
            if (state is AccountLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            bool isVerified = true;
            if (state is AccountProfileLoaded) {
              isVerified = state.profile.isVerified;
            }
            if (state is AccountBankAccountsLoaded || state is AccountBankMutationLoading) {
              final accounts = state is AccountBankAccountsLoaded ? state.accounts : _accountsCache;
              Widget content;
              if (accounts.isEmpty) {
                content = _EmptyState(
                  onAdd: () => _showAddDialog(context, requireVerified: !isVerified),
                  verified: isVerified,
                );
              } else {
                content = Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: accounts.length,
                        itemBuilder: (_, i) => _BankTile(
                          account: accounts[i],
                          onDelete: () => context
                              .read<AccountBloc>()
                              .add(AccountDeleteBankAccount(accounts[i].id)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: isVerified ? () => _showAddDialog(context) : null,
                          child: Text(isVerified
                              ? 'Add another bank account'
                              : 'Verify your identity to add bank'),
                        ),
                      ),
                    )
                  ],
                );
              }
              return Stack(
                children: [
                  Positioned.fill(child: content),
                  if (overlayBusy)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.08),
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<AccountBloc, AccountState>(
          buildWhen: (p, c) =>
              c is AccountProfileLoaded || c is AccountLoading || c is AccountError,
          builder: (context, st) {
            bool verified = true;
            if (st is AccountProfileLoaded) verified = st.profile.isVerified;
            return FloatingActionButton(
              onPressed: verified
                  ? () => _showAddDialog(context, requireVerified: false)
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Complete KYC to add bank account')),
                      ),
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, {bool requireVerified = false}) async {
    if (requireVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete KYC to add a bank account')),
      );
      return;
    }
    BankInfo? selected;
    String? verifiedName;
    final nameCtr = TextEditingController();
    final numberCtr = TextEditingController();
    bool verifying = false;

    // Refresh bank list when opening
    _bloc.add(AccountLoadBankList());
    _banksLoading = true;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (ctx) {
        Timer? debounce;
        String? numberError;
        String? dropdownError;
        bool banksError = false;
        String? banksErrorMessage;
        bool showChangeHint = false;
        return StatefulBuilder(builder: (context, setStateDialog) {
          return BlocProvider<AccountBloc>.value(
            value: _bloc,
            child: AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Bank Account'),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh banks',
                    onPressed: () {
                      banksError = false;
                      banksErrorMessage = null;
                      _bloc.add(const AccountLoadBankList(forceRefresh: true));
                      _banksLoading = true;
                      setStateDialog(() {});
                    },
                  ),
                ],
              ),
              content: BlocListener<AccountBloc, AccountState>(
                listenWhen: (prev, curr) =>
                    curr is AccountBankListLoaded ||
                    curr is AccountBankListLoading ||
                    curr is AccountBankListError ||
                    curr is AccountBankVerified ||
                    curr is AccountBankVerifyLoading ||
                    curr is AccountBankVerifyError,
                listener: (context, state) {
                  if (state is AccountBankListLoaded) {
                    _banks = state.banks;
                    _banksLoading = false;
                    banksError = false;
                    banksErrorMessage = null;
                    setStateDialog(() {});
                  } else if (state is AccountBankListLoading) {
                    _banksLoading = true;
                    banksError = false;
                    banksErrorMessage = null;
                    setStateDialog(() {});
                  } else if (state is AccountBankListError) {
                    _banksLoading = false;
                    banksError = true;
                    banksErrorMessage = 'Unable to load banks. Please retry.';
                    setStateDialog(() {});
                  } else if (state is AccountBankVerifyLoading) {
                    verifying = true;
                    numberError = null;
                    setStateDialog(() {});
                  } else if (state is AccountBankVerified) {
                    verifying = false;
                    verifiedName = state.accountName;
                    nameCtr.text = verifiedName ?? '';
                    numberError = null;
                    setStateDialog(() {});
                  } else if (state is AccountBankVerifyError) {
                    verifying = false;
                    numberError = 'Verification failed. Please check details and try again.';
                    setStateDialog(() {});
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_banksLoading) const LinearProgressIndicator(minHeight: 2),
                    if (!_banksLoading && banksError)
                      Row(
                        children: [
                          Expanded(
                            child: Text(banksErrorMessage ?? 'Unable to load banks.',
                                style: const TextStyle(color: Colors.red)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              banksError = false;
                              _bloc.add(AccountLoadBankList());
                              _banksLoading = true;
                              setStateDialog(() {});
                            },
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    if (!_banksLoading && !banksError)
                      DropdownButtonFormField<BankInfo>(
                        initialValue: selected,
                        items: _banks
                            .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                            .toList(),
                        onChanged: (b) {
                          selected = b;
                          verifiedName = null;
                          nameCtr.text = '';
                          dropdownError = null;
                          if (numberCtr.text.isNotEmpty) {
                            showChangeHint = true;
                          }
                          setStateDialog(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Bank',
                          errorText: dropdownError,
                        ),
                      ),
                    if (showChangeHint)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline, size: 14, color: Colors.orange),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Bank changed. Please re-verify account number.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Account Number (10 digits)',
                        errorText: numberError,
                      ),
                      controller: numberCtr,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      keyboardType: TextInputType.number,
                      onChanged: (v) async {
                        verifiedName = null;
                        nameCtr.text = '';
                        numberError = null;
                        verifying = false;
                        showChangeHint = false;
                        setStateDialog(() {});
                        debounce?.cancel();
                        final value = v.trim();
                        if (selected == null) {
                          dropdownError = 'Please select a bank';
                          setStateDialog(() {});
                          return;
                        }
                        if (value.isEmpty || value.length < 10) {
                          numberError =
                              value.isEmpty ? null : 'Enter a valid 10-digit account number';
                          setStateDialog(() {});
                          return;
                        }
                        if (value.length == 10 && selected != null) {
                          debounce = Timer(const Duration(milliseconds: 500), () {
                            verifying = true;
                            setStateDialog(() {});
                            context.read<AccountBloc>().add(
                                AccountVerifyBank(bankCode: selected!.code, accountNumber: value));
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Account Name (auto)'),
                      controller: nameCtr,
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    if (verifying)
                      Row(
                        children: const [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Verifying...'),
                        ],
                      ),
                    if (verifiedName != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Verified: $verifiedName',
                            style: const TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (selected != null &&
                          numberCtr.text.trim().length == 10 &&
                          (verifiedName != null && verifiedName!.isNotEmpty))
                      ? () {
                          final name = nameCtr.text.trim();
                          final number = numberCtr.text.trim();
                          Navigator.pop(ctx);
                          context.read<AccountBloc>().add(AccountAddBankAccount(
                                bankName: selected!.name,
                                bankCode: selected!.code,
                                accountName: name,
                                accountNumber: number,
                              ));
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _BankTile extends StatelessWidget {
  final BankAccount account;
  final VoidCallback onDelete;
  const _BankTile({required this.account, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.account_balance_outlined)),
        title: Text(account.bankName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acct No: ${account.accountNumber}'),
            Text('Account Name: ${account.accountName}'),
          ],
        ),
        trailing:
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final bool verified;
  const _EmptyState({required this.onAdd, this.verified = true});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              verified ? 'No bank accounts yet' : 'Verify your identity to add bank accounts',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: onAdd, child: Text(verified ? 'Add bank account' : 'Verify identity'))
          ],
        ),
      ),
    );
  }
}
