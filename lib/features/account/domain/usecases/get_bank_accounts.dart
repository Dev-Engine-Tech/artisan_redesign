import '../entities/bank_account.dart';
import '../repositories/account_repository.dart';

class GetBankAccounts {
  final AccountRepository repository;
  GetBankAccounts(this.repository);

  Future<List<BankAccount>> call() => repository.getBankAccounts();
}
