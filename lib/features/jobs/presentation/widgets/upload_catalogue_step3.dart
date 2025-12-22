import 'package:flutter/material.dart';
import 'dart:io' show File;
import '../../../../core/widgets/optimized_image.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../../../core/utils/responsive.dart';
import 'package:artisans_circle/shared/widgets/image_preview_page.dart';

/// Step 3 of upload catalogue: Review/preview screen
///
/// Displays:
/// - Media preview
/// - Project title
/// - Duration/timeline
/// - Description
/// - Selected skills
/// - Edit and Submit buttons
class UploadCatalogueStep3 extends StatelessWidget {
  final List<String> media;
  final String title;
  final String description;
  final String? timeline;
  final Set<String> selectedSkills;
  final VoidCallback onEdit;
  final VoidCallback onSubmit;

  const UploadCatalogueStep3({
    required this.media,
    required this.title,
    required this.description,
    required this.timeline,
    required this.selectedSkills,
    required this.onEdit,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        AppSpacing.spaceSM,
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 200,
            color: context.softPinkColor,
            child: media.isEmpty
                ? Center(
                    child: Icon(Icons.image_outlined,
                        size: 56, color: context.primaryColor),
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ImagePreviewPage(
                                imageUrl: m,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                      );
                    },
                  ),
          ),
        ),
        AppSpacing.spaceMD,
        Text(title.isEmpty ? 'Untitled project' : title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        AppSpacing.spaceMD,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.softBorder),
          ),
          child: Text('Duration: ${timeline ?? 'Not specified'}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.brownHeaderColor)),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(color: AppColors.softBorder),
          ),
          padding: context.responsivePadding,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.w700)),
            AppSpacing.spaceSM,
            Text(description.isEmpty ? 'No description provided.' : description,
                style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
          ]),
        ),
        const SizedBox(height: 14),
        const Text('Skills', style: TextStyle(fontWeight: FontWeight.w700)),
        AppSpacing.spaceSM,
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedSkills.isEmpty
                ? [const Text('No skills selected')]
                : selectedSkills.map((s) => Chip(label: Text(s))).toList()),
        const SizedBox(height: 18),
        SecondaryButton(
          text: 'Edit',
          onPressed: onEdit,
        ),
        AppSpacing.spaceMD,
        PrimaryButton(
          text: 'Submit',
          onPressed: onSubmit,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
