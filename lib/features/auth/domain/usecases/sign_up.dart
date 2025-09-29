import '../../domain/entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<User?> call({required String identifier, required String password, String? name}) {
    return repository.signUp(identifier: identifier, password: password, name: name);
  }
}
