import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/verification_cubit.dart';
import 'package:artisans_circle/core/theme.dart';

/// Selfie capture page that attempts to use the device front camera.
/// Falls back to a simulated capture if cameras are not available (e.g. in tests).
class SelfieCapturePage extends StatefulWidget {
  const SelfieCapturePage({super.key});

  @override
  State<SelfieCapturePage> createState() => _SelfieCapturePageState();
}

class _SelfieCapturePageState extends State<SelfieCapturePage> {
  CameraController? _controller;
  CameraDescription? _frontCamera;
  bool _initializing = true;
  bool _cameraAvailable = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      // Prefer a front-facing camera if available
      _frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.isNotEmpty
            ? cameras.first
            : throw Exception('No cameras found'),
      );

      _controller = CameraController(_frontCamera!, ResolutionPreset.medium,
          enableAudio: false);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _cameraAvailable = true;
        _initializing = false;
      });
    } catch (e) {
      // Not available (emulator/test) — fall back to simulated capture
      setState(() {
        _cameraAvailable = false;
        _initializing = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final verificationCubit = context.read<VerificationCubit>();

    if (_cameraAvailable &&
        _controller != null &&
        _controller!.value.isInitialized) {
      try {
        final file = await _controller!.takePicture();
        // Submit selfie to cubit (in real app you'd upload)
        await verificationCubit.submitSelfie(selfiePath: file.path);
        if (mounted) Navigator.of(context).pop(file.path);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Capture failed: $e')));
        }
      }
    } else {
      // Simulate capture by returning a fake local path
      final fakePath =
          'local://selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await verificationCubit.submitSelfie(selfiePath: fakePath);
      if (mounted) Navigator.of(context).pop(fakePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text('Take a selfie',
            style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: _initializing
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: AppSpacing.paddingXL,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: _cameraAvailable &&
                                _controller != null &&
                                _controller!.value.isInitialized
                            ? ClipRRect(
                                borderRadius: AppRadius.radiusLG,
                                child: AspectRatio(
                                  aspectRatio: _controller!.value.aspectRatio,
                                  child: CameraPreview(_controller!),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(110),
                                    ),
                                    child: const Icon(Icons.person,
                                        size: 64, color: Colors.brown),
                                  ),
                                  AppSpacing.spaceLG,
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Text(
                                      'Camera not available. Use simulated capture for tests/emulator.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                  if (_error != null) ...[
                                    AppSpacing.spaceSM,
                                    Text(_error!,
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 12)),
                                  ],
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      text: 'Capture',
                      onPressed: _capture,
                    ),
                    AppSpacing.spaceMD,
                    OutlinedAppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
