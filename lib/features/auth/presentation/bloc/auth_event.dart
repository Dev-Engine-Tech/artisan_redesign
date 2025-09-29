import 'package:meta/meta.dart';

@immutable
abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthSignedOut extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String identifier;
  final String password;

  AuthSignInRequested({required this.identifier, required this.password});
}

class AuthSignUpRequested extends AuthEvent {
  final String identifier;
  final String password;
  final String? name;

  AuthSignUpRequested({required this.identifier, required this.password, this.name});
}

class AuthSignInWithGoogleRequested extends AuthEvent {}

class AuthSignInWithAppleRequested extends AuthEvent {}

/// Marks the currently authenticated user as verified (local/demo only).
/// In a real app this would be triggered after a successful server-side verification.
class AuthMarkVerified extends AuthEvent {}

class AuthOtpVerificationRequested extends AuthEvent {
  final String otp;
  final String? pinId;

  AuthOtpVerificationRequested({required this.otp, this.pinId});
}

class AuthResendOtpRequested extends AuthEvent {
  final String? phone;

  AuthResendOtpRequested({this.phone});
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  AuthForgotPasswordRequested({required this.email});
}

class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  AuthResetPasswordRequested({required this.token, required this.newPassword});
}
