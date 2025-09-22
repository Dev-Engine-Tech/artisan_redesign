import '../entities/user_profile.dart';
import '../repositories/account_repository.dart';

class GetUserProfile {
  final AccountRepository repository;
  GetUserProfile(this.repository);

  Future<UserProfile> call() => repository.getUserProfile();
}
