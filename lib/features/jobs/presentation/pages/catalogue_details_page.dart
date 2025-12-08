import 'package:flutter/material.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/image_url.dart';
import '../../../../core/utils/responsive.dart';

/// Catalogue details page — separate from JobDetailsPage so catalogue items
/// can have different layout/controls in the future.
class CatalogueDetailsPage extends StatefulWidget {
  final Job job;

  const CatalogueDetailsPage({required this.job, super.key});

  @override
  State<CatalogueDetailsPage> createState() => _CatalogueDetailsPageState();
}

class _CatalogueDetailsPageState extends State<CatalogueDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.0),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: context.softPinkColor,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text('Catalogue', style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: ListView(
          padding: context.responsivePadding,
          children: [
            // Image/banner + title block (compact)
            ClipRRect(
              borderRadius: AppRadius.radiusLG,
              child: (() {
                final imgUrl = sanitizeImageUrl(job.thumbnailUrl);
                final valid = imgUrl.startsWith('http');
                return valid
                    ? Image.network(
                        imgUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 180,
                          color: context.softPinkColor,
                          child: Center(child: Icon(Icons.image, color: colorScheme.onSurfaceVariant)),
                        ),
                      )
                    : Container(
                        height: 180,
                        color: context.softPinkColor,
                        child: Center(
                          child: Icon(
                            Icons.home_repair_service_outlined,
                            size: 56,
                            color: context.primaryColor,
                          ),
                        ),
                      );
              })(),
            ),
            AppSpacing.spaceMD,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.cardBackgroundColor,
                borderRadius: AppRadius.radiusLG,
                border: Border.all(color: context.softBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(job.category,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  AppSpacing.spaceMD,
                  Text(job.description,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  AppSpacing.spaceMD,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge(label: '₦${job.minBudget} - ₦${job.maxBudget}'),
                      _Badge(label: job.duration),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Edit Catalogue',
              onPressed: () {
                // placeholder edit
              },
            ),
            AppSpacing.spaceMD,
            SecondaryButton(
              text: 'Delete Catalogue',
              onPressed: () {
                // placeholder delete
              },
            ),
            const SizedBox(height: 18),
            // Additional details preserved
            Container(
              decoration: BoxDecoration(
                color: context.cardBackgroundColor,
                borderRadius: AppRadius.radiusLG,
                border: Border.all(color: context.softBorderColor),
              ),
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  AppSpacing.spaceSM,
                  Text(job.description,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.softPeachColor,
        borderRadius: AppRadius.radiusMD,
      ),
      child: Text(label,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: context.brownHeaderColor)),
    );
  }
}
