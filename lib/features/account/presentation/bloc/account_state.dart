import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/entities/bank_account.dart';

abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountProfileLoaded extends AccountState {
  final UserProfile profile;
  const AccountProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class AccountEarningsLoaded extends AccountState {
  final Earnings earnings;
  const AccountEarningsLoaded(this.earnings);
  @override
  List<Object?> get props => [earnings];
}

class AccountTransactionsLoaded extends AccountState {
  final List<TransactionItem> transactions;
  final bool hasMore;
  const AccountTransactionsLoaded(this.transactions, {this.hasMore = false});
  @override
  List<Object?> get props => [transactions, hasMore];
}

class AccountBankAccountsLoaded extends AccountState {
  final List<BankAccount> accounts;
  const AccountBankAccountsLoaded(this.accounts);
  @override
  List<Object?> get props => [accounts];
}

class AccountBankListLoaded extends AccountState {
  final List<BankInfo> banks;
  const AccountBankListLoaded(this.banks);
  @override
  List<Object?> get props => [banks];
}

class AccountBankListLoading extends AccountState {
  const AccountBankListLoading();
}

class AccountBankListError extends AccountState {
  final String message;
  const AccountBankListError(this.message);
  @override
  List<Object?> get props => [message];
}

class AccountBankVerified extends AccountState {
  final String accountName;
  const AccountBankVerified(this.accountName);
  @override
  List<Object?> get props => [accountName];
}

class AccountBankVerifyLoading extends AccountState {
  const AccountBankVerifyLoading();
}

class AccountBankVerifyError extends AccountState {
  final String message;
  const AccountBankVerifyError(this.message);
  @override
  List<Object?> get props => [message];
}

class AccountBankMutationLoading extends AccountState {
  const AccountBankMutationLoading();
}

class AccountWithdrawalPinVerified extends AccountState {
  const AccountWithdrawalPinVerified();
}

class AccountWithdrawalPinSet extends AccountState {
  const AccountWithdrawalPinSet();
}

class AccountActionSuccess extends AccountState {
  final String message;
  const AccountActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);
  @override
  List<Object?> get props => [message];
}
