import '../repositories/account_repository.dart';

class DeleteBankAccount {
  final AccountRepository repository;
  DeleteBankAccount(this.repository);

  Future<void> call(String id) => repository.deleteBankAccount(id);
}
