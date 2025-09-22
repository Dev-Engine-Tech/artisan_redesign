import '../entities/user_profile.dart';
import '../repositories/account_repository.dart';

class UpdateUserProfile {
  final AccountRepository repository;
  UpdateUserProfile(this.repository);

  Future<UserProfile> call({
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? bio,
    String? location,
    String? phone,
    int? yearsOfExperience,
  }) {
    return repository.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      jobTitle: jobTitle,
      bio: bio,
      location: location,
      phone: phone,
      yearsOfExperience: yearsOfExperience,
    );
  }
}
