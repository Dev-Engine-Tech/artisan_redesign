import '../repositories/account_repository.dart';

class VerifyWithdrawalPin {
  final AccountRepository repository;
  VerifyWithdrawalPin(this.repository);

  Future<bool> call(String pin) => repository.verifyWithdrawalPin(pin);
}

