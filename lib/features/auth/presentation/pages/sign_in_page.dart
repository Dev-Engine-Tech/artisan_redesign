import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_event.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'package:artisans_circle/features/auth/presentation/pages/sign_up_page.dart';
import 'package:artisans_circle/core/app_shell.dart';
import 'package:artisans_circle/features/auth/presentation/pages/phone_verification_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _remember = false;
  bool _obscurePassword = true;
  int _selectedTab = 0; // 0 for Login, 1 for Register

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignInRequested(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Small delay to ensure AppShell BlocListener can detect fresh login
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AppShell()),
                (route) => false,
              );
            }
          });
        } else if (state is AuthError) {
          final msg = state.message;
          if (msg.toLowerCase().contains('inactive')) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PhoneVerificationPage(
                  initialPhone: _identifierController.text.trim()),
            ));
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          }
        } else if (state is AuthUnauthenticated) {
          // Show feedback when credentials are invalid or sign-in failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Invalid email/phone or password. Please try again.')),
          );
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
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: AppRadius.radiusLG,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Title and subtitle
                      const Text(
                        'Go ahead and set up\nyour account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),

                      AppSpacing.spaceSM,

                      Text(
                        'Sign in-up to enjoy the best managing experience',
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
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Tab selector
                            Container(
                              padding: AppSpacing.paddingXS,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: AppRadius.radiusLG,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedTab = 0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _selectedTab == 0
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius: AppRadius.radiusMD,
                                          boxShadow: _selectedTab == 0
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 4,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          'Login',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _selectedTab == 0
                                                ? AppColors.brownHeader
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignUpPage()),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _selectedTab == 1
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius: AppRadius.radiusMD,
                                        ),
                                        child: Text(
                                          'Register',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _selectedTab == 1
                                                ? AppColors.brownHeader
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            AppSpacing.spaceXXXL,

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Email field
                                  CustomTextFormField(
                                    label: 'Email Address',
                                    hint: 'micahmad@potarastudio.com',
                                    prefixIcon: Icons.email_outlined,
                                    controller: _identifierController,
                                    keyboardType: TextInputType.emailAddress,
                                    showLabel: true,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Please enter email or phone'
                                            : null,
                                  ),

                                  AppSpacing.spaceXL,

                                  // Password field
                                  CustomTextFormField(
                                    label: 'Password',
                                    hint: 'micahmad#',
                                    prefixIcon: Icons.lock_outline,
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    showLabel: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (v) => (v == null ||
                                            v.length < 6)
                                        ? 'Password must be at least 6 characters'
                                        : null,
                                  ),

                                  AppSpacing.spaceLG,

                                  // Remember me and Forgot password
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _remember,
                                        onChanged: (v) => setState(
                                            () => _remember = v ?? false),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppRadius.radiusSM,
                                        ),
                                        activeColor: AppColors.orange,
                                      ),
                                      Text(
                                        'Remember me',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextAppButton(
                                        text: 'Forgot Password?',
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),

                                  AppSpacing.spaceXXL,

                                  // Login button
                                  PrimaryButton(
                                    text: 'Login',
                                    onPressed: _submit,
                                  ),

                                  AppSpacing.spaceXXL,

                                  // Or login with
                                  Row(
                                    children: [
                                      Expanded(
                                          child:
                                              Divider(color: Colors.grey[300])),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          'Or login with',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child:
                                              Divider(color: Colors.grey[300])),
                                    ],
                                  ),

                                  AppSpacing.spaceXXL,

                                  // Social login buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextAppButton(
                                          text: 'Google',
                                          onPressed: () => context
                                              .read<AuthBloc>()
                                              .add(
                                                  AuthSignInWithGoogleRequested()),
                                        ),
                                      ),
                                      AppSpacing.spaceLG,
                                      Expanded(
                                        child: TextAppButton(
                                          text: 'Apple',
                                          onPressed: () => context
                                              .read<AuthBloc>()
                                              .add(
                                                  AuthSignInWithAppleRequested()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
