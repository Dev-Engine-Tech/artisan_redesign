import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image_cropper/image_cropper.dart';
export 'package:image_picker/image_picker.dart' show ImageSource, XFile;

/// Shared service for image picking functionality
///
/// Centralizes image picking logic that was duplicated across:
/// - messages_flow.dart
/// - my_profile_page.dart
/// - account_page.dart
/// - upload_catalogue_page.dart
///
/// Usage:
/// ```dart
/// final service = ImagePickerService();
/// final path = await service.pickImage(source: ImageSource.gallery);
/// if (path != null) {
///   // Use the image path
/// }
/// ```
class ImagePickerService {
  /// Pick an image from the specified source
  ///
  /// Returns the file path of the selected image, or null if cancelled
  ///
  /// NOTE: Uses `image_picker` under the hood.
  Future<String?> pickImage({
    required picker.ImageSource source,
    int? maxWidth,
    int? imageQuality,
  }) async {
    final _picker = picker.ImagePicker();
    final picker.XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: (maxWidth ?? 2048).toDouble(),
      imageQuality: imageQuality ?? 92,
    );
    return file?.path;
  }

  /// Pick an image from gallery
  Future<String?> pickFromGallery({
    int? maxWidth,
    int? imageQuality,
  }) async {
    return pickImage(
      source: picker.ImageSource.gallery,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
  }

  /// Pick an image from camera
  Future<String?> pickFromCamera({
    int? maxWidth,
    int? imageQuality,
  }) async {
    return pickImage(
      source: picker.ImageSource.camera,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
  }

  /// Pick multiple images from gallery
  ///
  /// Returns list of file paths, or empty list if cancelled
  Future<List<String>> pickMultipleImages({
    int? imageQuality,
  }) async {
    final _picker = picker.ImagePicker();
    final List<picker.XFile> files = await _picker.pickMultiImage(
      imageQuality: imageQuality ?? 92,
    );
    return files.map((f) => f.path).toList();
  }

  /// Crop an image at the given path
  ///
  /// Returns the path to the cropped image, or null if cancelled
  ///
  /// NOTE: Image cropping is not enabled by default; integrate image_cropper
  /// if/when needed.
  Future<String?> cropImage({
    required String sourcePath,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color(0xFFE65300),
          toolbarWidgetColor: const Color(0xFFFFFFFF),
          hideBottomControls: false,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );
    return cropped?.path;
  }

  /// Pick and crop an image in one operation
  ///
  /// Convenience method that combines picking and cropping
  Future<String?> pickAndCropImage({
    required picker.ImageSource source,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    final path = await pickImage(
      source: source,
      imageQuality: imageQuality,
    );

    if (path == null) return null;

    return cropImage(
      sourcePath: path,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}
