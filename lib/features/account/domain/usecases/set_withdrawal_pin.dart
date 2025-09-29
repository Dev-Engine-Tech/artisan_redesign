import '../repositories/account_repository.dart';

class SetWithdrawalPin {
  final AccountRepository repository;
  SetWithdrawalPin(this.repository);

  Future<bool> call(String pin) => repository.setWithdrawalPin(pin);
}
