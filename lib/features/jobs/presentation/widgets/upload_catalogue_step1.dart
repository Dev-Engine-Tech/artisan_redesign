import 'package:flutter/material.dart';
import 'dart:io' show File;
import '../../../../core/widgets/optimized_image.dart';
import 'package:artisans_circle/shared/widgets/image_preview_page.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';

/// Step 1 of upload catalogue: Basic info form
///
/// Collects:
/// - Project title
/// - Sub-category selection
/// - Project description
/// - Optional media upload
class UploadCatalogueStep1 extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedSubcategoryName;
  final List<String> media;
  final VoidCallback onNext;
  final VoidCallback onPickSubcategory;
  final VoidCallback onPickMedia;
  final VoidCallback onCaptureMedia;
  final ValueChanged<String> onRemoveMedia;

  const UploadCatalogueStep1({
    required this.titleController,
    required this.descriptionController,
    required this.selectedSubcategoryName,
    required this.media,
    required this.onNext,
    required this.onPickSubcategory,
    required this.onPickMedia,
    required this.onCaptureMedia,
    required this.onRemoveMedia,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        AppSpacing.spaceSM,
        const Text('Project Title',
            style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceSM,
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.cardBackgroundColor,
            hintText: 'what are you working on ?',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
        AppSpacing.spaceMD,
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.softBorderColor),
            color: context.cardBackgroundColor,
          ),
          child: const Text(
              'Title Samples\n• Modern 4-seater dinning table.\n• Eternal elegance wedding gown.\n• Metal staircases handrails.'),
        ),
        const SizedBox(height: 18),
        const Text('Sub-category',
            style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceSM,
        GestureDetector(
          onTap: onPickSubcategory,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(selectedSubcategoryName ??
                        'Select sub-category (tap to choose)')),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Project Description',
            style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceSM,
        TextField(
          controller: descriptionController,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.cardBackgroundColor,
            hintText: 'Describe what your project is',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        AppSpacing.spaceSM,
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: context.softBorderColor, style: BorderStyle.solid),
            color: context.cardBackgroundColor,
          ),
          child: const Text(
              'Descriptions should be specific to the product\n• Clear description of what your preferences and specifications are\n• Details about how you and your team likes to work'),
        ),
        const SizedBox(height: 18),
        const Text('Attached File (Optional)',
            style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceSM,
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
                color: context.softBorderColor,
                style: BorderStyle.solid,
                width: 1.5),
            color: context.colorScheme.surface,
          ),
          child: Column(
            children: [
              Expanded(
                child: media.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.perm_media_outlined,
                                color: context.primaryColor, size: 36),
                            AppSpacing.spaceSM,
                            const Text('Add images from your device or camera'),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: media.length,
                        itemBuilder: (context, index) {
                          final m = media[index];
                          final isNetwork = m.startsWith('http');
                          return GestureDetector(
                            onTap: () {
                              if (isNetwork) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ImagePreviewPage(
                                      imageUrl: m,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ImagePreviewPage(
                                      imageUrl: m,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: AppRadius.radiusMD,
                                  child: isNetwork
                                      ? OptimizedThumbnail(
                                          imageUrl: m,
                                          width: 80,
                                          height: 80,
                                        )
                                      : Image.file(
                                          File(m),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  right: -8,
                                  top: -8,
                                  child: GestureDetector(
                                    onTap: () => onRemoveMedia(m),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedAppButton(
                      text: 'Upload Media',
                      onPressed: onPickMedia,
                    ),
                    OutlinedAppButton(
                      text: 'Capture Photo',
                      onPressed: onCaptureMedia,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.spaceXL,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: PrimaryButton(
            text: 'Proceed',
            onPressed: onNext,
          ),
        ),
        AppSpacing.spaceXL,
      ],
    );
  }
}
