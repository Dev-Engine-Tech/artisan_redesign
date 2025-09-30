import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_event.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String? initialPhone;
  const PhoneVerificationPage({super.key, this.initialPhone});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          title: const Text('Verify Phone',
              style: TextStyle(color: Colors.black87)),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              const SizedBox(height: 6),
              const Text('Account Inactive',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E3A59))),
              const SizedBox(height: 8),
              const Text('Verify your phone number to activate your account',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 18),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration(
                    hint: '+234 703...', label: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final phone = _phoneController.text.trim();
                    context.read<AuthBloc>().add(AuthResendOtpRequested(
                        phone: phone.isEmpty ? null : phone));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4CD6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Send Code'),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _codeController,
                decoration:
                    _inputDecoration(hint: '4-digit code', label: 'Enter Code'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final code = _codeController.text.trim();
                    if (code.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter the code')));
                      return;
                    }
                    context
                        .read<AuthBloc>()
                        .add(AuthOtpVerificationRequested(otp: code));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3A59),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
