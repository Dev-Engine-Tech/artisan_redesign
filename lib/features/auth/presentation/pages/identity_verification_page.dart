import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/verification_cubit.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_event.dart';
import 'selfie_capture_page.dart';
import 'verification_submitted_page.dart';
import '../../../../core/utils/responsive.dart';

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

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
    IconData? prefixIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpacing.spaceSM,
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: AppRadius.radiusLG,
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            dropdownColor: colorScheme.surface,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
              border: InputBorder.none,
              contentPadding: AppSpacing.paddingLG,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: colorScheme.onSurface.withValues(alpha: 0.4))
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _docOption(String value, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _docType = value),
      child: Container(
        margin: AppSpacing.verticalXS,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _docType == value
              ? AppColors.orange.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: AppRadius.radiusLG,
          border: Border.all(
            color: _docType == value ? AppColors.orange : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _docType == value
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _docType == value ? AppColors.orange : colorScheme.onSurface.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: _docType == value
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

                    AppSpacing.spaceSM,

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
                            Icons.badge_outlined,
                            size: 40,
                            color: AppColors.orange,
                          ),
                        ),

                        AppSpacing.spaceXXL,

                        Text(
                          'Government ID Required',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        AppSpacing.spaceSM,

                        Text(
                          'Upload a government-issued ID and take a selfie to complete your verification',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),

                        AppSpacing.spaceXXXL,

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
                                  DropdownMenuItem(
                                      value: 'NG', child: Text('Nigeria')),
                                  DropdownMenuItem(
                                      value: 'GH', child: Text('Ghana')),
                                  DropdownMenuItem(
                                      value: 'KE', child: Text('Kenya')),
                                ],
                                onChanged: (v) => setState(() => _country = v),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Please select country'
                                    : null,
                                prefixIcon: Icons.flag_outlined,
                              ),

                              AppSpacing.spaceXXL,

                              // Document type selection
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Document Type',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  AppSpacing.spaceMD,
                                  _docOption('NIN',
                                      'National Identification Number (NIN)'),
                                  _docOption(
                                      'PVC', "Permanent Voter's Card (PVC)"),
                                  _docOption('PPT', 'International Passport'),
                                  _docOption('DL', "Driver's License"),
                                ],
                              ),

                              AppSpacing.spaceXXL,

                              // Document number field
                              CustomTextFormField(
                                controller: _idController,
                                label: 'Document Number',
                                hint: 'e.g A120000045',
                                prefixIcon: Icons.numbers_outlined,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Please enter document number'
                                        : null,
                                showLabel: true,
                              ),

                              AppSpacing.spaceXXL,

                              // Upload document button
                              OutlinedAppButton(
                                text: _uploadedDocumentPath != null
                                    ? 'Document Uploaded'
                                    : 'Upload Document',
                                icon: _uploadedDocumentPath != null
                                    ? Icons.check_circle_outline
                                    : Icons.upload_file_outlined,
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
                                            content: Text(
                                                'Document uploaded successfully')));
                                  }
                                },
                              ),

                              AppSpacing.spaceXXL,

                              // Selfie capture section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Take a Selfie',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  AppSpacing.spaceMD,
                                  OutlinedAppButton(
                                    text: 'Take Selfie',
                                    icon: Icons.camera_alt_outlined,
                                    onPressed: () async {
                                      final result = await Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  const SelfieCapturePage()));
                                      if (result != null && result is String) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Selfie captured successfully')));
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),

                              AppSpacing.spaceXXXL,

                              // Submit button
                              BlocConsumer<VerificationCubit,
                                  VerificationState>(
                                listener: (context, state) {
                                  if (state.error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(state.error!)));
                                  }
                                },
                                builder: (context, state) {
                                  return PrimaryButton(
                                    text: 'Submit Verification',
                                    onPressed: state.submitting
                                        ? null
                                        : () async {
                                            if (!_formKey.currentState!
                                                .validate()) {
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
                                                  content: Text(
                                                      'Please capture a selfie'),
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
                                    isLoading: state.submitting,
                                  );
                                },
                              ),

                              AppSpacing.spaceXXXL,

                              // Info card
                              Container(
                                padding: context.responsivePadding,
                                decoration: BoxDecoration(
                                  color: AppColors.lightPeach,
                                  borderRadius: AppRadius.radiusLG,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.security_outlined,
                                      color: AppColors.orange,
                                      size: 20,
                                    ),
                                    AppSpacing.spaceMD,
                                    Expanded(
                                      child: Text(
                                        'Your identity verification helps build trust with clients and protects your account. All documents are encrypted and stored securely.',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withValues(alpha: 0.8),
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
