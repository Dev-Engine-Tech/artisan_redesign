import 'dart:math';

import 'package:bloc/bloc.dart';
import '../../domain/usecases/sign_up.dart';
import 'signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final SignUp signUpUsecase;

  SignUpCubit({required this.signUpUsecase}) : super(const SignUpState());

  void updateName({required String firstName, required String lastName}) {
    emit(state.copyWith(firstName: firstName, lastName: lastName));
  }

  void updateIdentifier(String identifier) {
    emit(state.copyWith(identifier: identifier));
  }

  void updateReferral(String code) {
    emit(state.copyWith(referralCode: code));
  }

  void toggleTerms(bool accepted) {
    emit(state.copyWith(termsAccepted: accepted));
  }

  void setPassword(String password) {
    emit(state.copyWith(password: password));
  }

  void nextStep() {
    emit(state.copyWith(step: state.step + 1, error: null));
  }

  void prevStep() {
    emit(state.copyWith(step: (state.step - 1).clamp(0, 4), error: null));
  }

  /// Simulate sending an OTP: generate a 4-digit code and set otpSent=true.
  Future<void> sendOtp(String phoneNumber) async {
    final rnd = Random();
    final code = (1000 + rnd.nextInt(9000)).toString();
    // store generated OTP in state for verification (exposed only for tests/debug)
    emit(state.copyWith(loading: true, phoneNumber: phoneNumber));
    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(loading: false, otpSent: true, generatedOtp: code));
  }

  /// Verify OTP entered by user. Returns true on success.
  bool verifyOtp(String code) {
    // Allow bypass for testing with code '0000' OR accept the generated OTP.
    if (code == '0000' ||
        (state.generatedOtp != null && state.generatedOtp == code)) {
      emit(state.copyWith(phoneVerified: true, error: null));
      return true;
    } else {
      emit(state.copyWith(error: 'Invalid code. Please try again.'));
      return false;
    }
  }

  void setPin(String pin) {
    emit(state.copyWith(pin: pin));
  }

  /// Finalize sign up: calls the SignUp usecase and stores created user in state.
  Future<void> finalizeSignUp() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final user = await signUpUsecase.call(
        identifier: state.identifier,
        password: state.password,
        name: '${state.firstName} ${state.lastName}'.trim(),
      );
      if (user != null) {
        emit(state.copyWith(loading: false, createdUser: user, step: 4));
      } else {
        emit(state.copyWith(loading: false, error: 'Failed to create account'));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
