import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/verification_cubit.dart';

void main() {
  group('VerificationCubit', () {
    test('initial state is correct', () {
      final cubit = VerificationCubit();
      expect(cubit.state.submitting, isFalse);
      expect(cubit.state.identitySubmitted, isFalse);
      expect(cubit.state.selfieCaptured, isFalse);
      expect(cubit.state.idDocumentPath, isNull);
      expect(cubit.state.selfiePath, isNull);
      cubit.close();
    });

    blocTest<VerificationCubit, VerificationState>(
      'submitIdentity sets identitySubmitted and idDocumentPath',
      build: () => VerificationCubit(),
      act: (c) => c.submitIdentity(idDocumentPath: 'local://id_1.jpg'),
      wait: const Duration(milliseconds: 500),
      verify: (c) {
        expect(c.state.identitySubmitted, isTrue);
        expect(c.state.idDocumentPath, isNotNull);
      },
    );

    blocTest<VerificationCubit, VerificationState>(
      'submitSelfie sets selfieCaptured and selfiePath',
      build: () => VerificationCubit(),
      act: (c) => c.submitSelfie(selfiePath: 'local://selfie_1.jpg'),
      wait: const Duration(milliseconds: 500),
      verify: (c) {
        expect(c.state.selfieCaptured, isTrue);
        expect(c.state.selfiePath, isNotNull);
      },
    );

    blocTest<VerificationCubit, VerificationState>(
      'finalizeVerification complains if missing parts',
      build: () => VerificationCubit(),
      act: (c) => c.finalizeVerification(),
      wait: const Duration(milliseconds: 800),
      verify: (c) {
        expect(c.state.error, isNotNull);
      },
    );

    blocTest<VerificationCubit, VerificationState>(
      'full flow: submitIdentity -> submitSelfie -> finalizeVerification',
      build: () => VerificationCubit(),
      act: (c) async {
        await c.submitIdentity(idDocumentPath: 'local://id_2.jpg');
        await c.submitSelfie(selfiePath: 'local://selfie_2.jpg');
        await c.finalizeVerification();
      },
      wait: const Duration(milliseconds: 1000),
      verify: (c) {
        expect(c.state.identitySubmitted, isTrue);
        expect(c.state.selfieCaptured, isTrue);
        expect(c.state.error, isNull);
      },
    );
  });
}
