import 'package:flutter_test/flutter_test.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/signup_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await setupDependencies(useFake: true);
  });

  test('SignUpCubit flow: send OTP, verify, finalize sign up', () async {
    final SignUpCubit cubit = getIt<SignUpCubit>();

    // initial step
    expect(cubit.state.step, equals(0));

    // update name & identifier, accept terms
    cubit.updateName(firstName: 'John', lastName: 'Doe');
    cubit.updateIdentifier('john.doe@example.com');
    cubit.toggleTerms(true);

    // proceed to password step
    cubit.nextStep();
    expect(cubit.state.step, equals(1));

    // set password and proceed
    cubit.setPassword('password123');
    cubit.nextStep();
    expect(cubit.state.step, equals(2));

    // send OTP for phone verification
    await cubit.sendOtp('+2347012345678');
    expect(cubit.state.otpSent, isTrue);
    final generated = cubit.state.generatedOtp;
    expect(generated, isNotNull);

    // verify OTP
    final verified = cubit.verifyOtp(generated!);
    expect(verified, isTrue);
    expect(cubit.state.phoneVerified, isTrue);

    // proceed to PIN step
    cubit.nextStep();
    expect(cubit.state.step, equals(3));

    // set pin and finalize (this will create the user via fake repo)
    cubit.setPin('1234');
    await cubit.finalizeSignUp();

    // createdUser should be present and step advanced to 4
    expect(cubit.state.createdUser, isNotNull);
    expect(cubit.state.step, equals(4));
  });
}
