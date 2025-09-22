import 'package:flutter_test/flutter_test.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_up.dart';
import 'package:artisans_circle/features/auth/domain/repositories/auth_repository.dart';

void main() {
  setUpAll(() async {
    // ensure DI is configured with fakes
    await setupDependencies(useFake: true);
  });

  test('SignUp usecase creates a new user successfully', () async {
    final SignUp usecase = getIt<SignUp>();
    final AuthRepository repo = getIt<AuthRepository>();

    final identifier = 'newuser@example.com';
    final password = 'password123';
    final name = 'New User';

    final user = await usecase.call(
        identifier: identifier, password: password, name: name);
    expect(user, isNotNull);
    expect(user!.email, equals(identifier));
    expect(user.firstName, equals('New'));
    expect(user.lastName, equals('User'));
  });
}
