import '../entities/user_profile.dart' as ent;
import '../entities/user_profile.dart';
import '../repositories/account_repository.dart';

class AddEducation {
  final AccountRepository repository;
  AddEducation(this.repository);

  Future<UserProfile> call(ent.Education edu) => repository.addEducation(edu);
}
