import '../repositories/account_repository.dart';

class RequestWithdrawal {
  final AccountRepository repository;
  RequestWithdrawal(this.repository);

  Future<void> call(double amount) => repository.requestWithdrawal(amount);
}
