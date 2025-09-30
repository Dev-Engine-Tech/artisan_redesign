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
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    String? Function(String?)? validator,
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
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: prefixIcon != null 
                  ? Icon(prefixIcon, color: Colors.grey[400])
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
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
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: prefixIcon != null 
                  ? Icon(prefixIcon, color: Colors.grey[400])
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _docOption(String value, String label) {
    return GestureDetector(
      onTap: () => setState(() => _docType = value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _docType == value
              ? AppColors.orange.withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _docType == value 
                ? AppColors.orange 
                : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _docType == value 
                      ? AppColors.brownHeader
                      : Colors.grey[700],
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _docType == value 
                      ? AppColors.orange 
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: _docType == value
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.orange,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verificationCubit = context.read<VerificationCubit>();

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
                    // Back arrow
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
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title and subtitle
                    const Text(
                      'Identity Verification',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Verify your identity to access all features and build trust with potential clients.',
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
                    child: Column(
                      children: [
                        // Verification icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.lightPeach,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.badge_outlined,
                            size: 40,
                            color: AppColors.orange,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Government ID Required',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brownHeader,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Upload a government-issued ID and take a selfie to complete your verification',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Country dropdown
                              _buildDropdownField(
                                label: 'Issued Country',
                                hint: 'Select your country',
                                value: _country,
                                items: const [
                                  DropdownMenuItem(value: 'NG', child: Text('Nigeria')),
                                  DropdownMenuItem(value: 'GH', child: Text('Ghana')),
                                  DropdownMenuItem(value: 'KE', child: Text('Kenya')),
                                ],
                                onChanged: (v) => setState(() => _country = v),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Please select country'
                                    : null,
                                prefixIcon: Icons.flag_outlined,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Document type selection
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Document Type',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _docOption('NIN', 'National Identification Number (NIN)'),
                                  _docOption('PVC', "Permanent Voter's Card (PVC)"),
                                  _docOption('PPT', 'International Passport'),
                                  _docOption('DL', "Driver's License"),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Document number field
                              _buildTextField(
                                controller: _idController,
                                label: 'Document Number',
                                hint: 'e.g A120000045',
                                prefixIcon: Icons.numbers_outlined,
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Please enter document number'
                                    : null,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Upload document button
                              Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final fakePath =
                                        'local://id_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                    await verificationCubit.submitIdentity(
                                        idDocumentPath: fakePath);
                                    setState(() {
                                      _uploadedDocumentPath = fakePath;
                                    });
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Document uploaded successfully')));
                                    }
                                  },
                                  icon: Icon(
                                    _uploadedDocumentPath != null 
                                        ? Icons.check_circle_outline
                                        : Icons.upload_file_outlined,
                                    color: _uploadedDocumentPath != null 
                                        ? Colors.green
                                        : AppColors.orange,
                                  ),
                                  label: Text(
                                    _uploadedDocumentPath != null 
                                        ? 'Document Uploaded'
                                        : 'Upload Document',
                                    style: TextStyle(
                                      color: _uploadedDocumentPath != null 
                                          ? Colors.green
                                          : AppColors.brownHeader,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Selfie capture section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Take a Selfie',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) => const SelfieCapturePage()));
                                        if (result != null && result is String) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Selfie captured successfully')));
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        Icons.camera_alt_outlined,
                                        color: AppColors.orange,
                                      ),
                                      label: Text(
                                        'Take Selfie',
                                        style: TextStyle(
                                          color: AppColors.brownHeader,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Submit button
                              BlocConsumer<VerificationCubit, VerificationState>(
                                listener: (context, state) {
                                  if (state.error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(state.error!)));
                                  }
                                },
                                builder: (context, state) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: state.submitting
                                          ? null
                                          : () async {
                                              if (!_formKey.currentState!.validate()) {
                                                return;
                                              }
                                              if (!state.identitySubmitted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Please upload your ID document'),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (!state.selfieCaptured) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content:
                                                        Text('Please capture a selfie'),
                                                  ),
                                                );
                                                return;
                                              }
                                              await context
                                                  .read<VerificationCubit>()
                                                  .finalizeVerification();
                                              if (!mounted) return;
                                              try {
                                                context
                                                    .read<AuthBloc>()
                                                    .add(AuthMarkVerified());
                                              } catch (_) {}
                                              if (!mounted) return;
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const VerificationSubmittedPage(),
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
                                      child: state.submitting
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : const Text(
                                              'Submit Verification',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Info card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.lightPeach,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.security_outlined,
                                      color: AppColors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Your identity verification helps build trust with clients and protects your account. All documents are encrypted and stored securely.',
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
                      ],
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
