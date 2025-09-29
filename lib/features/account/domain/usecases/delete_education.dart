import '../entities/user_profile.dart';
import '../repositories/account_repository.dart';

class DeleteEducation {
  final AccountRepository repository;
  DeleteEducation(this.repository);

  Future<UserProfile> call(String id) => repository.deleteEducation(id);
}
