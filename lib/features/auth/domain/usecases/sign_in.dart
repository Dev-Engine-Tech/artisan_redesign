import '../../domain/entities/user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<User?> call({required String identifier, required String password}) {
    return repository.signIn(identifier: identifier, password: password);
  }
}
