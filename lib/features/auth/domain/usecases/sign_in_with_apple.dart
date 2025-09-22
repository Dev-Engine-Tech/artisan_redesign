import '../../domain/entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithApple {
  final AuthRepository repository;

  SignInWithApple(this.repository);

  Future<User?> call() {
    return repository.signInWithApple();
  }
}
