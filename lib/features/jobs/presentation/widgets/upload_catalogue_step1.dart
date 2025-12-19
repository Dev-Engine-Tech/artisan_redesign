import 'package:flutter/material.dart';
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
  final ValueChanged<String> onRemoveMedia;

  const UploadCatalogueStep1({
    required this.titleController,
    required this.descriptionController,
    required this.selectedSubcategoryName,
    required this.media,
    required this.onNext,
    required this.onPickSubcategory,
    required this.onPickMedia,
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
        GestureDetector(
          onTap: onPickMedia,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusLG,
              border: Border.all(
                  color: context.softBorderColor,
                  style: BorderStyle.solid,
                  width: 1.5),
              color: context.colorScheme.surface,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.perm_media_outlined,
                      color: context.primaryColor, size: 36),
                  AppSpacing.spaceSM,
                  const Text(
                      'Copy and paste images, videos or any file from your device.'),
                  AppSpacing.spaceSM,
                  OutlinedAppButton(
                    text: 'Upload Media',
                    onPressed: onPickMedia,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (media.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              children: media.map((m) {
                String displayText =
                    m.startsWith('http') ? 'Existing Image' : m.split('/').last;
                return Chip(
                    label: Text(displayText),
                    onDeleted: () => onRemoveMedia(m));
              }).toList(),
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
