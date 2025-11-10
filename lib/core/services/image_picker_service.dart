import 'package:flutter/material.dart';

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
  /// NOTE: ImagePicker is currently disabled in the project.
  /// This service provides a centralized place to re-enable it later.
  Future<String?> pickImage({
    required ImageSource source,
    int? maxWidth,
    int? imageQuality,
  }) async {
    // TODO: Re-enable when ImagePicker is added back to the project
    // final picker = ImagePicker();
    // final XFile? file = await picker.pickImage(
    //   source: source,
    //   maxWidth: maxWidth ?? 2048,
    //   imageQuality: imageQuality ?? 92,
    // );
    // return file?.path;

    debugPrint('ImagePicker is currently disabled');
    return null;
  }

  /// Pick an image from gallery
  Future<String?> pickFromGallery({
    int? maxWidth,
    int? imageQuality,
  }) async {
    return pickImage(
      source: ImageSource.gallery,
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
      source: ImageSource.camera,
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
    // TODO: Re-enable when ImagePicker is added back
    // final picker = ImagePicker();
    // final List<XFile> files = await picker.pickMultiImage(
    //   imageQuality: imageQuality ?? 92,
    // );
    // return files.map((f) => f.path).toList();

    debugPrint('ImagePicker is currently disabled');
    return [];
  }

  /// Crop an image at the given path
  ///
  /// Returns the path to the cropped image, or null if cancelled
  ///
  /// NOTE: ImageCropper is currently disabled in the project.
  Future<String?> cropImage({
    required String sourcePath,
    int? maxWidth,
    int? maxHeight,
  }) async {
    // TODO: Re-enable when ImageCropper is added back
    // final cropped = await ImageCropper().cropImage(
    //   sourcePath: sourcePath,
    //   maxWidth: maxWidth,
    //   maxHeight: maxHeight,
    //   compressFormat: ImageCompressFormat.jpg,
    //   compressQuality: 90,
    // );
    // return cropped?.path;

    debugPrint('ImageCropper is currently disabled');
    return null;
  }

  /// Pick and crop an image in one operation
  ///
  /// Convenience method that combines picking and cropping
  Future<String?> pickAndCropImage({
    required ImageSource source,
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

/// Image source enum placeholder
/// Replace with actual ImagePicker enum when re-enabled
enum ImageSource {
  gallery,
  camera,
}
