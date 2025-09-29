import '../repositories/account_repository.dart';

class ChangePassword {
  final AccountRepository repository;
  ChangePassword(this.repository);

  Future<void> call({required String oldPassword, required String newPassword}) =>
      repository.changePassword(oldPassword: oldPassword, newPassword: newPassword);
}
