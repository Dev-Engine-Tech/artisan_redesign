import '../entities/user_profile.dart' as ent;
import '../entities/user_profile.dart';
import '../repositories/account_repository.dart';

class UpdateEducation {
  final AccountRepository repository;
  UpdateEducation(this.repository);

  Future<UserProfile> call(ent.Education edu) =>
      repository.updateEducation(edu);
}
