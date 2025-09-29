import '../entities/user_profile.dart' as ent;
import '../entities/user_profile.dart';
import '../repositories/account_repository.dart';

class UpdateWorkExperience {
  final AccountRepository repository;
  UpdateWorkExperience(this.repository);

  Future<UserProfile> call(ent.WorkExperience work) => repository.updateWorkExperience(work);
}
