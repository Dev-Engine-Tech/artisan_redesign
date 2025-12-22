import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/di.dart';

class SubscriptionBankTransferPage extends StatefulWidget {
  final String planName;
  final double amount;
  final String paymentReference;
  final String uploadUrl;

  const SubscriptionBankTransferPage({
    super.key,
    required this.planName,
    required this.amount,
    required this.paymentReference,
    required this.uploadUrl,
  });

  @override
  State<SubscriptionBankTransferPage> createState() =>
      _SubscriptionBankTransferPageState();
}

class _SubscriptionBankTransferPageState
    extends State<SubscriptionBankTransferPage> {
  File? _receiptFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Select Receipt Source',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.brownHeader,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.orange),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.orange),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await _pickReceipt(source);
    }
  }

  Future<void> _pickReceipt(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024, // Reduce image width to decrease file size
        imageQuality: 60, // Lower quality to ensure file stays under 1 MB
      );

      if (image != null) {
        final file = File(image.path);

        // Check file size
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        debugPrint(
            '📸 Selected image size: ${fileSizeMB.toStringAsFixed(2)} MB');

        if (fileSizeMB > 1.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Image is too large (${fileSizeMB.toStringAsFixed(2)} MB). Please select a smaller image or take a new photo.',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        setState(() {
          _receiptFile = file;
        });
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitTransfer() async {
    if (_receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload payment receipt'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final dio = getIt<Dio>();

      // Create multipart request
      final formData = FormData.fromMap({
        'amount': widget.amount,
        'reference': widget.paymentReference,
        'plan': widget.planName,
        'receipt': await MultipartFile.fromFile(
          _receiptFile!.path,
          filename: 'receipt_${widget.paymentReference}.jpg',
        ),
      });

      debugPrint('💳 Uploading bank transfer receipt...');
      debugPrint('💳 Upload URL: ${widget.uploadUrl}');
      debugPrint('💳 Reference: ${widget.paymentReference}');

      final response = await dio.post(
        widget.uploadUrl,
        data: formData,
      );

      debugPrint('💳 Upload response: ${response.data}');

      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      // Show success message
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Receipt Uploaded Successfully',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brownHeader,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your payment receipt has been submitted.\nOur team will verify and activate your subscription within 24 hours.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Reference: ${widget.paymentReference}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bank transfer page
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } on DioException catch (e) {
      debugPrint('❌ Error uploading receipt: $e');
      debugPrint('❌ Response data: ${e.response?.data}');

      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      String errorMessage = 'Failed to upload receipt';
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        errorMessage = data['detail']?.toString() ??
            data['message']?.toString() ??
            errorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');

      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyAccountNumber() {
    Clipboard.setData(const ClipboardData(text: '6764160487'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account number copied to clipboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      appBar: AppBar(
        title: const Text('Bank Transfer'),
        backgroundColor: AppColors.brownHeader,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: context.responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.spaceMD,
            // Payment details
            Container(
              padding: context.responsivePadding,
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusXL,
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownHeader,
                    ),
                  ),
                  AppSpacing.spaceSM,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Plan:',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        widget.planName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.spaceXS,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount:',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'NGN ${widget.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.spaceXS,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reference:',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        widget.paymentReference,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.spaceLG,
            // Instructions
            const Text(
              'Transfer Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brownHeader,
              ),
            ),
            AppSpacing.spaceSM,
            const Text(
              'Transfer the amount above to the account details below and upload your payment receipt.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            AppSpacing.spaceLG,
            // Account details
            InkWell(
              onTap: _copyAccountNumber,
              borderRadius: AppRadius.radiusXL,
              child: Container(
                padding: context.responsivePadding,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.radiusXL,
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Moniepoint MFB',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          AppSpacing.spaceXS,
                          const Text(
                            'Acct no: 6764160487',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.orange,
                            ),
                          ),
                          AppSpacing.spaceXS,
                          Text(
                            'Acct name: Artisan Bridge LTD',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.copy,
                      color: AppColors.orange,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.spaceXL,
            // Upload receipt
            const Text(
              'Upload Payment Receipt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brownHeader,
              ),
            ),
            AppSpacing.spaceSM,
            InkWell(
              onTap: _isUploading ? null : _showImageSourceDialog,
              borderRadius: AppRadius.radiusXL,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.radiusXL,
                  border: Border.all(
                    color: _receiptFile != null
                        ? AppColors.orange
                        : Colors.grey[300]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    if (_receiptFile == null) ...[
                      const Icon(
                        Icons.cloud_upload,
                        size: 64,
                        color: AppColors.orange,
                      ),
                      AppSpacing.spaceSM,
                      const Text(
                        'Tap to select receipt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownHeader,
                        ),
                      ),
                      AppSpacing.spaceXS,
                      Text(
                        'JPG, JPEG, or PNG (max 1 MB)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Images will be automatically compressed',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.green[600],
                      ),
                      AppSpacing.spaceSM,
                      const Text(
                        'Receipt selected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownHeader,
                        ),
                      ),
                      AppSpacing.spaceXS,
                      Text(
                        _receiptFile!.path.split('/').last,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AppSpacing.spaceXL,
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading || _receiptFile == null
                    ? null
                    : _submitTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            AppSpacing.spaceXL,
          ],
        ),
      ),
    );
  }
}
