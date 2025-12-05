import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/core/analytics/firebase_analytics_service.dart';

/// Simple withdraw flow used by the Home page Withdraw button.
/// This is a self-contained UI demonstration of the flow shown in the screenshots:
/// 1) Amount screen
/// 2) Select account modal
/// 3) Confirm withdraw modal (shows account + amount)
/// 4) PIN input keypad modal
/// 5) Success screen
///
/// Replace the mocked account list / submission logic with real services as needed.
Future<void> showWithdrawFlow(BuildContext context, {double earnings = 70000}) {
  return Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => _WithdrawAmountPage(initialEarnings: earnings),
    fullscreenDialog: true,
  ));
}

class _WithdrawAmountPage extends StatefulWidget {
  final double initialEarnings;
  const _WithdrawAmountPage({required this.initialEarnings});

  @override
  State<_WithdrawAmountPage> createState() => _WithdrawAmountPageState();
}

class _WithdrawAmountPageState extends State<_WithdrawAmountPage> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showSelectAccountSheet() async {
    final selected = await showModalBottomSheet<_Account>(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (c) {
        final accounts = [
          _Account(
              bank: 'Zenith Bank Plc',
              masked: '2*****3139',
              name: 'Adeyeni Praise'),
          _Account(
              bank: 'Access Bank Plc',
              masked: '3*****6789',
              name: 'Cecillia Uwak'),
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Text('Select a withdrawal account',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              const Divider(height: 1),
              ...accounts.map((a) {
                return ListTile(
                  leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: c.cardBackgroundColor,
                          borderRadius: AppRadius.radiusMD),
                      child: Center(
                          child: Icon(Icons.account_balance,
                              color: c.primaryColor))),
                  title: Text(a.bank),
                  subtitle: Text(a.masked),
                  trailing: Icon(Icons.check, color: c.primaryColor),
                  onTap: () => Navigator.of(context).pop(a),
                );
              }),
              AppSpacing.spaceMD,
            ],
          ),
        );
      },
    );

    if (selected != null) {
      _showConfirmWithdraw(selected);
    }
  }

  void _showConfirmWithdraw(_Account account) {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.48,
        minChildSize: 0.32,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
              color: c.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: Text('Withdraw',
                            style: Theme.of(context).textTheme.titleLarge)),
                    IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Acct Name:'),
                trailing: Text(account.name,
                    style: Theme.of(c).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ),
              ListTile(
                title: const Text('Amount'),
                trailing: Text('₦${amount.toStringAsFixed(0)}',
                    style: Theme.of(c).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Expanded(child: Container()),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
                child: PrimaryButton(
                  text: 'Next',
                  onPressed: () {
                    Navigator.of(context).pop(); // close confirm sheet
                    _showPinModal(amount, account);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinModal(double amount, _Account account) async {
    final pin = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => _PinEntrySheet(amount: amount),
    );

    if (pin != null && pin.length == 4) {
      // simulate success
      try {
        final analytics = getIt<AnalyticsService>();
        await analytics.logWithdrawal(amount, 'bank_transfer');
      } catch (_) {}
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) =>
              _WithdrawSuccessPage(amount: amount, account: account)));
    } else {
      // cancelled or invalid — do nothing (user can try again)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.lightPeachColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: context.softPinkColor,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text('Withdraw Money',
            style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          children: [
            Container(
              decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(10)),
              padding: AppSpacing.paddingMD,
              child: Row(
                children: [
                  Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: context.cardBackgroundColor,
                          borderRadius: AppRadius.radiusMD),
                      child: Icon(Icons.account_balance,
                          color: context.primaryColor)),
                  AppSpacing.spaceMD,
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Zenith Bank Plc',
                              style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                          AppSpacing.spaceXS,
                          Text('Acct No: ******3139',
                              style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('Bank Name: Adeyeni Praise',
                              style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                        ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount:',
                    style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text('Earnings: ₦${widget.initialEarnings.toStringAsFixed(0)}',
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
              ],
            ),
            AppSpacing.spaceSM,
            Container(
              padding: AppSpacing.horizontalMD,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.subtleBorderColor)),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: '0'),
                style:
                    context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: 'Next',
              onPressed: () {
                // open select-account sheet
                _showSelectAccountSheet();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Account {
  final String bank;
  final String masked;
  final String name;
  _Account({required this.bank, required this.masked, required this.name});
}

class _PinEntrySheet extends StatefulWidget {
  final double amount;
  const _PinEntrySheet({required this.amount});

  @override
  State<_PinEntrySheet> createState() => _PinEntrySheetState();
}

class _PinEntrySheetState extends State<_PinEntrySheet> {
  String _entered = '';

  void _addDigit(String d) {
    if (_entered.length >= 4) return;
    setState(() => _entered += d);
    if (_entered.length == 4) {
      // return pin to caller after small delay so UI updates
      Future.delayed(const Duration(milliseconds: 250),
          () => Navigator.of(context).pop(_entered));
    }
  }

  void _removeDigit() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            AppSpacing.spaceSM,
            Text('Input PIN to withdraw',
                style: Theme.of(context).textTheme.titleLarge),
            AppSpacing.spaceMD,
            Text('₦${widget.amount.toStringAsFixed(0)}',
                style:
                    context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _entered.length;
                  return Container(
                    margin: AppSpacing.horizontalSM,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        border: Border.all(color: context.subtleBorderColor),
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                        child: filled
                            ? Icon(Icons.circle,
                                size: 12, color: context.colorScheme.onSurface)
                            : const SizedBox.shrink()),
                  );
                })),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                children: [
                  for (var i = 1; i <= 9; i++)
                    ElevatedButton(
                      onPressed: () => _addDigit(i.toString()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: context.colorScheme.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusLG)),
                      child: Text('$i',
                          style: context.textTheme.titleMedium?.copyWith(
                              color: context.colorScheme.onSurface)),
                    ),
                  const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: () => _addDigit('0'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: context.colorScheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusLG)),
                    child: Text('0',
                        style: context.textTheme.titleMedium?.copyWith(
                            color: context.colorScheme.onSurface)),
                  ),
                  ElevatedButton(
                    onPressed: _removeDigit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: context.colorScheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusLG)),
                    child: Icon(Icons.backspace_outlined,
                        color: context.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawSuccessPage extends StatelessWidget {
  final double amount;
  final _Account account;
  const _WithdrawSuccessPage({required this.amount, required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(Icons.check_circle_outline,
                  size: 140, color: context.colorScheme.tertiary),
            ),
            AppSpacing.spaceXL,
            Text('Withdraw Successful!',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            AppSpacing.spaceMD,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Text(
                'You successfully withdrew NGN${amount.toStringAsFixed(0)} to ${account.masked} - ${account.bank} - ${account.name}.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: PrimaryButton(
                text: 'Continue',
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
