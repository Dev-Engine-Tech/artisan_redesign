import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/signup_cubit.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/signup_state.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_event.dart';
import 'package:artisans_circle/core/app_shell.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/verification_cubit.dart';
import 'package:artisans_circle/features/auth/presentation/pages/identity_verification_page.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Single-page sign-up stepper wizard.
/// Steps:
/// 0 - User info
/// 1 - Password
/// 2 - Phone verification (send OTP, enter code)
/// 3 - Set 4-digit PIN
/// 4 - Completed
class SignUpPage extends StatelessWidget {
  final SignUpCubit? cubit;

  const SignUpPage({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<SignUpCubit>.value(
        value: cubit!,
        child: const _SignUpView(),
      );
    }

    return BlocProvider<SignUpCubit>(
      create: (_) => getIt<SignUpCubit>(),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKeyStep0 = GlobalKey<FormState>();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _identifierController = TextEditingController();
  final _referralController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _identifierController.dispose();
    _referralController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Widget _stepIndicator(int step) {
    // 4 segments (0..3). If step >= 3 all segments filled.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
      child: Row(
        children: List.generate(4, (i) {
          final active = i <= step;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              height: 6,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF6B4CD6) : Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, String? label}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.subtleBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B4CD6))),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6B4CD6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    );
  }

  bool _isValidPhone(String phone) {
    final p = phone.replaceAll(' ', '');
    try {
      // Try parse as international. If no leading +, default to NG region.
      PhoneNumber.parse(p);
      return true;
    } catch (_) {
      try {
        PhoneNumber.parse(p, callerCountry: IsoCode.NG);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final authBloc = context.read<AuthBloc>();
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<SignUpCubit>();
        return Scaffold(
          backgroundColor: AppColors.lightPeach,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.softPink,
                    borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  onPressed: () {
                    if (state.step == 0) {
                      Navigator.of(context).pop();
                    } else {
                      cubit.prevStep();
                    }
                  },
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                _stepIndicator(state.step),
                const SizedBox(height: 6),
                if (state.step == 0) ...[
                  const Text('Create an account',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E3A59))),
                  const SizedBox(height: 8),
                  const Text('Sign up now to get started with an account',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKeyStep0,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstController,
                          decoration: _inputDecoration(
                              hint: 'Enter your first name',
                              label: 'First name'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter first name'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _lastController,
                          decoration: _inputDecoration(
                              hint: 'Enter your last name / surname',
                              label: 'Last name'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter last name'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _identifierController,
                          decoration: _inputDecoration(
                              hint: 'Enter your email or phone',
                              label: 'Email / Phone'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter email or phone'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _referralController,
                          decoration: _inputDecoration(
                              hint: 'Enter your referral code here',
                              label: 'Referral Code (optional)'),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Checkbox(
                              value: state.termsAccepted,
                              onChanged: (v) => cubit.toggleTerms(v ?? false),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              activeColor: const Color(0xFF6B4CD6),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'I agree with the ',
                                  children: [
                                    TextSpan(
                                        text: 'terms and conditions',
                                        style:
                                            TextStyle(color: AppColors.orange)),
                                    const TextSpan(text: ' of ArtisanBridge'),
                                  ],
                                ),
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKeyStep0.currentState!.validate() &&
                                  state.termsAccepted) {
                                cubit.updateName(
                                    firstName: _firstController.text.trim(),
                                    lastName: _lastController.text.trim());
                                cubit.updateIdentifier(
                                    _identifierController.text.trim());
                                cubit.updateReferral(
                                    _referralController.text.trim());
                                cubit.nextStep();
                              } else if (!state.termsAccepted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please accept terms')));
                              }
                            },
                            style: _primaryButtonStyle(),
                            child: const Text('Continue',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Row(children: const [
                    Expanded(child: Divider()),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('OR')),
                    Expanded(child: Divider())
                  ]),
                  const SizedBox(height: 12),
                  // Social buttons (sign up) — show both with safe asset fallback
                  Column(
                    children: [
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => context
                              .read<AuthBloc>()
                              .add(AuthSignInWithGoogleRequested()),
                          icon: Image.asset(
                            'assets/google_logo.png',
                            width: 22,
                            height: 22,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.g_mobiledata, size: 22),
                          ),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFFE6E6E6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => context
                              .read<AuthBloc>()
                              .add(AuthSignInWithAppleRequested()),
                          icon: const Icon(Icons.apple, size: 22),
                          label: const Text('Continue with Apple'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFFE6E6E6)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ] else if (state.step == 1) ...[
                  const Text('Create password',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E3A59))),
                  const SizedBox(height: 8),
                  const Text('Create password to protect your account',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 18),
                  Form(
                    key: _formKeyStep1,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _inputDecoration(
                              hint: 'Enter your password', label: 'Password'),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Enter at least 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          decoration: _inputDecoration(
                              hint: 'Confirm your password',
                              label: 'Confirm password'),
                          validator: (v) => (v != _passwordController.text)
                              ? 'Passwords do not match'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKeyStep1.currentState!.validate()) {
                                cubit.setPassword(_passwordController.text);
                                cubit.nextStep();
                              }
                            },
                            style: _primaryButtonStyle(),
                            child: const Text('Continue',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (state.step == 2) ...[
                  const Text('Phone Verification',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E3A59))),
                  const SizedBox(height: 8),
                  const Text(
                      'We need to register your phone number before getting started',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration(
                        hint: '+234 7039193613', label: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  if (!state.otpSent)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          final phone = _phoneController.text.trim();
                          final phoneOk = _isValidPhone(phone);
                          if (!phoneOk) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Enter a valid phone number')));
                            return;
                          }
                          await cubit.sendOtp(phone);
                          // For demo/testing show generated OTP (in real app don't show)
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('OTP: ${cubit.state.generatedOtp}')));
                        },
                        style: _primaryButtonStyle(),
                        child: const Text('Get Code',
                            style: TextStyle(fontSize: 18)),
                      ),
                    )
                  else ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _otpController,
                      decoration: _inputDecoration(
                          hint: '4-digit code', label: 'Enter code'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          final code = _otpController.text.trim();
                          if (cubit.verifyOtp(code)) {
                            cubit.nextStep();
                          } else {
                            // cubit listener will show error
                          }
                        },
                        style: _primaryButtonStyle(),
                        child: const Text('Verify Phone Number',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                        onPressed: () =>
                            cubit.sendOtp(_phoneController.text.trim()),
                        child: const Text('Resend Code')),
                  ]
                ] else if (state.step == 3) ...[
                  const Text('Set withdrawal PIN',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E3A59))),
                  const SizedBox(height: 8),
                  const Text('Setup a 4 digit withdrawal pin for your account',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _pinController,
                    decoration: _inputDecoration(
                        hint: 'Enter 4 digit pin', label: 'PIN'),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        final pin = _pinController.text.trim();
                        if (pin.length != 4) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Enter 4 digit PIN')));
                          return;
                        }
                        cubit.setPin(pin);
                        await cubit.finalizeSignUp();
                        if (!mounted) return;
                        // Leave the user on the "Account Created" screen.
                        // The actual sign-in and navigation to the home shell will be performed
                        // when the user taps "Continue" on the completed screen.
                        if (cubit.state.createdUser != null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Account created. You may continue to the app or verify your identity.')));
                        }
                      },
                      style: _primaryButtonStyle(),
                      child: const Text('Continue',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ] else ...[
                  // Completed — improved layout with logo, status tiles and action buttons
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 18),
                        // App logo (fallback to icon if asset missing)
                        Image.asset(
                          'assets/logo.png',
                          width: 180,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 180,
                            height: 80,
                            alignment: Alignment.center,
                            child: const Icon(Icons.handshake_outlined,
                                size: 56, color: Color(0xFF2E3A59)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Account Created',
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              'Verify your identification to continue using this app.',
                              style: TextStyle(color: Colors.black54)),
                        ),
                        const SizedBox(height: 18),
                        // Status tiles
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 12, top: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF8F6F4),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF2DE0B8),
                                    borderRadius: BorderRadius.circular(22)),
                                child: const Icon(Icons.check,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Create Account',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 4),
                                    Text('You have completed the registration',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF8F6F4),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFE14D4D),
                                    borderRadius: BorderRadius.circular(22)),
                                child: const Icon(Icons.close,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Account Verification',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 4),
                                    Text('Verify your account to continue',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              // Open the identity verification flow
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                        create: (_) => VerificationCubit(),
                                        child: const IdentityVerificationPage(),
                                      )));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E3A59),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Verify Now',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => const AppShell()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEDEFF1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Continue',
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xFF2E3A59))),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
