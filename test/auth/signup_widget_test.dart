import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/auth/presentation/pages/sign_up_page.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/signup_cubit.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupDependencies(useFake: true);
  });

  testWidgets('Sign-up stepper widget test: full flow', (WidgetTester tester) async {
    // Prepare: get the AuthBloc instance and ensure SignUpCubit will be created by the page.
    final authBloc = getIt<AuthBloc>();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const SignUpPage(),
        ),
      ),
    );

    // Wait for initial frame
    await tester.pumpAndSettle();

    // Step 0: fill user info
    await tester.enterText(find.byType(TextFormField).at(0), 'John'); // first name
    await tester.enterText(find.byType(TextFormField).at(1), 'Doe'); // last name
    await tester.enterText(find.byType(TextFormField).at(2), 'john.doe@example.com'); // identifier
    await tester.tap(find.byType(Checkbox)); // accept terms
    await tester.pumpAndSettle();

    // Tap Continue
    expect(find.text('Continue'), findsWidgets);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue').first);
    await tester.pumpAndSettle();

    // Step 1: password
    expect(find.text('Create password'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'password123');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue').first);
    await tester.pumpAndSettle();

    // Step 2: phone verification - enter phone & get code
    expect(find.text('Phone Verification'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '+2347012345678');
    await tester.pumpAndSettle();

    // Tap Get Code
    await tester.tap(find.widgetWithText(ElevatedButton, 'Get Code'));
    // wait for cubit to generate OTP and show snackbar
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Read generated OTP from cubit so we can enter it
    final SignUpCubit cubit = getIt<SignUpCubit>();
    final generated = cubit.state.generatedOtp;
    expect(generated, isNotNull);

    // Enter OTP and verify
    await tester.enterText(find.byType(TextFormField).at(1), generated!);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Verify Phone Number'));
    await tester.pumpAndSettle();

    // Step 3: set PIN
    expect(find.text('Set withdrawal PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '1234');
    await tester.pumpAndSettle();

    // Tap Continue to finalize sign up (this will create user via fake repo)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue').first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Final step: Account Created should be visible
    expect(find.text('Account Created'), findsOneWidget);
  });
}
