import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_event.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/utils/responsive.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String? initialPhone;
  const PhoneVerificationPage({super.key, this.initialPhone});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) {
      _phoneController.text = widget.initialPhone!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          setState(() => _otpSent = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent. Please check your phone.')),
          );
        } else if (state is AuthRegistrationComplete ||
            state is AuthAuthenticated) {
          Navigator.of(context).pop(true);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
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
                      // Back arrow
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.radiusLG,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Title and subtitle
                      Text(
                        'Verify your account\nto continue',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),

                      AppSpacing.spaceSM,

                      Text(
                        'Your account is inactive. Verify your phone number to activate and start using all features.',
                        style: TextStyle(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
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
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Verification icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: AppColors.lightPeach,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              size: 40,
                              color: AppColors.orange,
                            ),
                          ),

                          AppSpacing.spaceXXL,

                          const Text(
                            'Phone Verification',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brownHeader,
                            ),
                          ),

                          AppSpacing.spaceSM,

                          Text(
                            _otpSent
                                ? 'Enter the verification code sent to your phone'
                                : 'We\'ll send a verification code to your phone number',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),

                          AppSpacing.spaceXXXL,

                          // Phone number field
                          CustomTextFormField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: '+234 703 919 3613',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            showLabel: true,
                          ),

                          AppSpacing.spaceXXL,

                          if (!_otpSent) ...[
                            // Send OTP button
                            PrimaryButton(
                              text: 'Send Verification Code',
                              onPressed: () {
                                final phone = _phoneController.text.trim();
                                if (phone.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please enter your phone number')),
                                  );
                                  return;
                                }
                                context
                                    .read<AuthBloc>()
                                    .add(AuthResendOtpRequested(phone: phone));
                              },
                            ),
                          ] else ...[
                            // OTP input field
                            CustomTextFormField(
                              controller: _codeController,
                              label: 'Verification Code',
                              hint: 'Enter 4-digit code',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.security_outlined,
                              maxLength: 4,
                              showLabel: true,
                            ),

                            AppSpacing.spaceXXL,

                            // Verify button
                            PrimaryButton(
                              text: 'Verify Account',
                              onPressed: () {
                                final code = _codeController.text.trim();
                                if (code.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Enter the verification code')));
                                  return;
                                }
                                context.read<AuthBloc>().add(
                                    AuthOtpVerificationRequested(otp: code));
                              },
                            ),

                            AppSpacing.spaceLG,

                            // Resend code button
                            TextAppButton(
                              text: 'Resend Code',
                              onPressed: () {
                                final phone = _phoneController.text.trim();
                                context.read<AuthBloc>().add(
                                    AuthResendOtpRequested(
                                        phone: phone.isEmpty ? null : phone));
                              },
                            ),
                          ],

                          AppSpacing.spaceXXXL,

                          // Info card
                          Container(
                            padding: context.responsivePadding,
                            decoration: BoxDecoration(
                              color: AppColors.lightPeach,
                              borderRadius: AppRadius.radiusLG,
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.orange,
                                  size: 20,
                                ),
                                AppSpacing.spaceMD,
                                Expanded(
                                  child: Text(
                                    'Verification helps secure your account and enables you to receive important notifications about jobs and payments.',
                                    style: TextStyle(
                                      color: AppColors.brownHeader,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
