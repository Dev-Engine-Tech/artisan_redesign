import '../entities/bank_account.dart';
import '../repositories/account_repository.dart';

class AddBankAccount {
  final AccountRepository repository;
  AddBankAccount(this.repository);

  Future<BankAccount> call({
    required String bankName,
    required String accountName,
    required String accountNumber,
    String? bankCode,
  }) =>
      repository.addBankAccount(
        bankName: bankName,
        bankCode: bankCode,
        accountName: accountName,
        accountNumber: accountNumber,
      );
}
