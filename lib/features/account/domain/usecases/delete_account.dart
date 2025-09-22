import '../repositories/account_repository.dart';

class DeleteAccount {
  final AccountRepository repository;
  DeleteAccount(this.repository);

  Future<void> call({String? otp}) => repository.deleteAccount(otp: otp);
}
