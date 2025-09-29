import '../entities/user_profile.dart';
import '../repositories/account_repository.dart';

class AddSkill {
  final AccountRepository repository;
  AddSkill(this.repository);

  Future<UserProfile> call(String skill) => repository.addSkill(skill);
}
