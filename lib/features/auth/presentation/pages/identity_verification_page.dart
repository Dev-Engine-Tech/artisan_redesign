// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/verification_cubit.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_event.dart';
import 'selfie_capture_page.dart';
import 'verification_submitted_page.dart';

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() => _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _country;
  String _docType = 'NIN';
  final _idController = TextEditingController();
  String? _uploadedDocumentPath;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Widget _docOption(String value, String label) {
    return GestureDetector(
      onTap: () => setState(() => _docType = value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: _docType == value ? AppColors.cardBackground : const Color(0xFFF2F2F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            // ignore: deprecated_member_use
            Radio<String>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: _docType,
              // ignore: deprecated_member_use
              onChanged: (v) => setState(() => _docType = v ?? _docType),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verificationCubit = context.read<VerificationCubit>();

    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.black87),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const Text('Identity Verification',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Provide a government issued ID and a clear selfie to verify your identity.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Issued country
                  Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Issued Country', style: TextStyle(color: Colors.black54))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _country,
                    items: const [
                      DropdownMenuItem(value: 'NG', child: Text('Nigeria')),
                      DropdownMenuItem(value: 'GH', child: Text('Ghana')),
                      DropdownMenuItem(value: 'KE', child: Text('Kenya')),
                    ],
                    onChanged: (v) => setState(() => _country = v),
                    decoration: InputDecoration(
                      hintText: 'select',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.subtleBorder)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Please select country' : null,
                  ),
                  const SizedBox(height: 12),

                  Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Document type:', style: TextStyle(color: Colors.black87))),
                  const SizedBox(height: 6),
                  _docOption('NIN', 'National Identification Number (NIN)'),
                  _docOption('PVC', "Permanent Voter's Card (PVC)"),
                  _docOption('PPT', 'International Passport'),
                  _docOption('DL', "Driver's License"),

                  const SizedBox(height: 12),
                  Align(
                      alignment: Alignment.centerLeft,
                      child:
                          const Text('Document number', style: TextStyle(color: Colors.black54))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      hintText: 'e.g A120000045',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.subtleBorder)),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Please enter document number' : null,
                  ),
                  const SizedBox(height: 16),

                  // Upload button (simulated)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // In this demo we simulate an upload and store a fake path.
                        final fakePath = 'local://id_${DateTime.now().millisecondsSinceEpoch}.jpg';
                        await verificationCubit.submitIdentity(idDocumentPath: fakePath);
                        setState(() {
                          _uploadedDocumentPath = fakePath;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Document uploaded (simulated)')));
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Document'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Selfie capture area
                  Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Take a clear selfie:',
                          style: TextStyle(color: Colors.black87))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFF0F0F0),
                        child: _uploadedDocumentPath == null
                            ? const Icon(Icons.camera_alt_outlined, color: Colors.brown)
                            : const Icon(Icons.check, color: Colors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Open selfie capture page. The selfie page will call the cubit to submit the selfie path.
                            final result = await Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => const SelfieCapturePage()));
                            if (result != null && result is String) {
                              // returned selfie path (the SelfieCapturePage already submitted to VerificationCubit)
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Selfie captured')));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3A59),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              child: Text('Open camera', style: TextStyle(fontSize: 16))),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  BlocConsumer<VerificationCubit, VerificationState>(
                    listener: (context, state) {
                      if (state.error != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(state.error!)));
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: state.submitting
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      if (!state.identitySubmitted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please upload your ID document'),
                                          ),
                                        );
                                        return;
                                      }
                                      if (!state.selfieCaptured) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please capture a selfie'),
                                          ),
                                        );
                                        return;
                                      }
                                      await context
                                          .read<VerificationCubit>()
                                          .finalizeVerification();
                                      if (!mounted) return;
                                      try {
                                        context.read<AuthBloc>().add(AuthMarkVerified());
                                      } catch (_) {}
                                      if (!mounted) return;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const VerificationSubmittedPage(),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E3A59),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.submitting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Verify Now', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
