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

/// Single-page sign-up stepper wizard with redesigned UI to match sign in page.
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
      child: Row(
        children: List.generate(4, (i) {
          final active = i <= step;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppColors.orange : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    Widget? suffixIcon,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: prefixIcon != null 
                  ? Icon(prefixIcon, color: Colors.grey[400])
                  : null,
              suffixIcon: suffixIcon,
              counterText: '',
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  bool _isValidPhone(String phone) {
    final p = phone.replaceAll(' ', '');
    try {
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

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Create your artisan\naccount';
      case 1:
        return 'Secure your account\nwith a password';
      case 2:
        return 'Verify your phone\nnumber';
      case 3:
        return 'Set your withdrawal\nPIN';
      default:
        return 'Welcome to\nArtisans Circle';
    }
  }

  String _getStepSubtitle(int step) {
    switch (step) {
      case 0:
        return 'Join our community of skilled artisans and start growing your business';
      case 1:
        return 'Create a strong password to protect your account and earnings';
      case 2:
        return 'We need to verify your phone number for security and notifications';
      case 3:
        return 'Set up a 4-digit PIN to secure your withdrawals and transactions';
      default:
        return 'You\'re all set! Start showcasing your skills and finding clients';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<SignUpCubit>();
        
        if (state.step >= 4) {
          // Completed step - different layout
          return _buildCompletedStep(state, cubit);
        }
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brownHeader,
                  AppColors.darkBlue,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back arrow and step indicator
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (state.step == 0) {
                                    Navigator.of(context).pop();
                                  } else {
                                    cubit.prevStep();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        // Step indicator
                        _stepIndicator(state.step),
                        
                        const SizedBox(height: 24),
                        
                        // Title and subtitle
                        Text(
                          _getStepTitle(state.step),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          _getStepSubtitle(state.step),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildStepContent(state, cubit),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(SignUpState state, SignUpCubit cubit) {
    switch (state.step) {
      case 0:
        return _buildStep0(state, cubit);
      case 1:
        return _buildStep1(state, cubit);
      case 2:
        return _buildStep2(state, cubit);
      case 3:
        return _buildStep3(state, cubit);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep0(SignUpState state, SignUpCubit cubit) {
    return Form(
      key: _formKeyStep0,
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          _buildTextField(
            controller: _firstController,
            label: 'First Name',
            hint: 'Enter your first name',
            prefixIcon: Icons.person_outline,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter first name'
                : null,
          ),
          
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _lastController,
            label: 'Last Name',
            hint: 'Enter your last name',
            prefixIcon: Icons.person_outline,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter last name'
                : null,
          ),
          
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _identifierController,
            label: 'Email Address',
            hint: 'Enter your email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter email address'
                : null,
          ),
          
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _referralController,
            label: 'Referral Code (Optional)',
            hint: 'Enter referral code if you have one',
            prefixIcon: Icons.card_giftcard_outlined,
          ),
          
          const SizedBox(height: 20),
          
          // Terms and conditions
          Row(
            children: [
              Checkbox(
                value: state.termsAccepted,
                onChanged: (v) => cubit.toggleTerms(v ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: AppColors.orange,
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    children: [
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_formKeyStep0.currentState!.validate() && state.termsAccepted) {
                  cubit.updateName(
                    firstName: _firstController.text.trim(),
                    lastName: _lastController.text.trim(),
                  );
                  cubit.updateIdentifier(_identifierController.text.trim());
                  cubit.updateReferral(_referralController.text.trim());
                  cubit.nextStep();
                } else if (!state.termsAccepted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please accept terms and conditions')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Or register with
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or register with',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Social login buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton.icon(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(AuthSignInWithGoogleRequested()),
                    icon: Image.asset(
                      'assets/google_logo.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.g_mobiledata, size: 24),
                    ),
                    label: const Text(
                      'Google',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton.icon(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(AuthSignInWithAppleRequested()),
                    icon: const Icon(
                      Icons.apple,
                      size: 24,
                      color: Colors.black87,
                    ),
                    label: const Text(
                      'Apple',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(SignUpState state, SignUpCubit cubit) {
    return Form(
      key: _formKeyStep1,
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[400],
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) => (v == null || v.length < 6)
                ? 'Password must be at least 6 characters'
                : null,
          ),
          
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _confirmController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[400],
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            validator: (v) => (v != _passwordController.text)
                ? 'Passwords do not match'
                : null,
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_formKeyStep1.currentState!.validate()) {
                  cubit.setPassword(_passwordController.text);
                  cubit.nextStep();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(SignUpState state, SignUpCubit cubit) {
    return Column(
      children: [
        const SizedBox(height: 8),
        
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '+234 7039193613',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        
        const SizedBox(height: 24),
        
        if (!state.otpSent) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final phone = _phoneController.text.trim();
                final phoneOk = _isValidPhone(phone);
                if (!phoneOk) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid phone number')),
                  );
                  return;
                }
                await cubit.sendOtp(phone);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('OTP: ${cubit.state.generatedOtp}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Send Verification Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else ...[
          _buildTextField(
            controller: _otpController,
            label: 'Verification Code',
            hint: 'Enter 4-digit code',
            prefixIcon: Icons.security_outlined,
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                final code = _otpController.text.trim();
                if (cubit.verifyOtp(code)) {
                  cubit.nextStep();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Verify Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () => cubit.sendOtp(_phoneController.text.trim()),
            child: Text(
              'Resend Code',
              style: TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3(SignUpState state, SignUpCubit cubit) {
    return Column(
      children: [
        const SizedBox(height: 8),
        
        _buildTextField(
          controller: _pinController,
          label: 'Withdrawal PIN',
          hint: 'Enter 4-digit PIN',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
        ),
        
        const SizedBox(height: 32),
        
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              final pin = _pinController.text.trim();
              if (pin.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter 4-digit PIN')),
                );
                return;
              }
              cubit.setPin(pin);
              await cubit.finalizeSignUp();
              if (!mounted) return;
              if (cubit.state.createdUser != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account created successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedStep(SignUpState state, SignUpCubit cubit) {
    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Welcome to\nArtisans Circle!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brownHeader,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Your account has been created successfully. Start showcasing your skills and connecting with clients.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              
              const Spacer(),
              
              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => VerificationCubit(),
                          child: const IdentityVerificationPage(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verify Identity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AppShell()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brownHeader,
                    side: BorderSide(color: AppColors.brownHeader),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Skip for Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}