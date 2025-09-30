import '../entities/user_profile.dart';
import '../entities/user_profile.dart' as ent;
import '../repositories/account_repository.dart';

class AddWorkExperience {
  final AccountRepository repository;
  AddWorkExperience(this.repository);

  Future<UserProfile> call(ent.WorkExperience work) =>
      repository.addWorkExperience(work);
}
