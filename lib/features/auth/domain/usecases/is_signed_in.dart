import '../repositories/auth_repository.dart';

class IsSignedIn {
  final AuthRepository repository;

  IsSignedIn(this.repository);

  Future<bool> call() {
    return repository.isSignedIn();
  }
}
