import '../repositories/account_repository.dart';

class VerifyBankAccount {
  final AccountRepository repository;
  VerifyBankAccount(this.repository);

  Future<String> call({required String bankCode, required String accountNumber}) =>
      repository.verifyBankAccount(bankCode: bankCode, accountNumber: accountNumber);
}

