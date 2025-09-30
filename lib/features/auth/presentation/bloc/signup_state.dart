import '../../domain/entities/user.dart';

class SignUpState {
  final int
      step; // 0: user info, 1: password, 2: phone verify, 3: set pin, 4: complete
  final String firstName;
  final String lastName;
  final String identifier; // email or phone
  final String referralCode;
  final bool termsAccepted;

  final String password;
  final bool loading;
  final String? error;

  final String phoneNumber;
  final bool otpSent;
  final String? _generatedOtp; // internal, not serialized
  final bool phoneVerified;

  final String pin;

  final User? createdUser;

  const SignUpState({
    this.step = 0,
    this.firstName = '',
    this.lastName = '',
    this.identifier = '',
    this.referralCode = '',
    this.termsAccepted = false,
    this.password = '',
    this.loading = false,
    this.error,
    this.phoneNumber = '',
    this.otpSent = false,
    String? generatedOtp,
    this.phoneVerified = false,
    this.pin = '',
    this.createdUser,
  }) : _generatedOtp = generatedOtp;

  SignUpState copyWith({
    int? step,
    String? firstName,
    String? lastName,
    String? identifier,
    String? referralCode,
    bool? termsAccepted,
    String? password,
    bool? loading,
    String? error,
    String? phoneNumber,
    bool? otpSent,
    String? generatedOtp,
    bool? phoneVerified,
    String? pin,
    User? createdUser,
  }) {
    return SignUpState(
      step: step ?? this.step,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      identifier: identifier ?? this.identifier,
      referralCode: referralCode ?? this.referralCode,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      password: password ?? this.password,
      loading: loading ?? this.loading,
      error: error,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpSent: otpSent ?? this.otpSent,
      generatedOtp: generatedOtp ?? _generatedOtp,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      pin: pin ?? this.pin,
      createdUser: createdUser ?? this.createdUser,
    );
  }

  // Expose the generated OTP for testing/debug; in production this wouldn't be exposed.
  String? get generatedOtp => _generatedOtp;
}
