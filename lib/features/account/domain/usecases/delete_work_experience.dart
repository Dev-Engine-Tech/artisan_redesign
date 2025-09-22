import '../entities/user_profile.dart';
import '../repositories/account_repository.dart';

class DeleteWorkExperience {
  final AccountRepository repository;
  DeleteWorkExperience(this.repository);

  Future<UserProfile> call(String id) => repository.deleteWorkExperience(id);
}

