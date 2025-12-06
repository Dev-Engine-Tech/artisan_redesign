import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../../domain/usecases/delete_catalog.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/upload_catalogue_page.dart';
import '../../domain/entities/catalog_item.dart';
import '../../../../core/utils/responsive.dart';

class CatalogItemDetailsPage extends StatelessWidget {
  final CatalogItem item;
  const CatalogItemDetailsPage({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
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
            ClipRRect(
              borderRadius: AppRadius.radiusLG,
              child: (() {
                final imgUrl = sanitizeImageUrl(item.imageUrl ?? '');
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
                          child: const Center(child: Icon(Icons.image)),
                        ),
                      )
                    : Container(
                        height: 180,
                        color: context.softPinkColor,
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
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
                  border: Border.all(color: context.softBorderColor)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    if (item.ownerName != null && item.ownerName!.isNotEmpty)
                      Text(item.ownerName!,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.45))),
                    AppSpacing.spaceMD,
                    Text(item.description,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.54))),
                    AppSpacing.spaceMD,
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      if (item.priceMin != null)
                        _Badge(
                            label:
                                'Price: ₦${item.priceMin}${item.priceMax != null ? ' - ₦${item.priceMax}' : ''}'),
                      if (item.projectTimeline != null &&
                          item.projectTimeline!.isNotEmpty)
                        _Badge(label: 'Timeline: ${item.projectTimeline!}'),
                      if (item.brand != null && item.brand!.isNotEmpty)
                        _Badge(label: 'Brand: ${item.brand!}'),
                      if (item.condition != null && item.condition!.isNotEmpty)
                        _Badge(label: 'Condition: ${item.condition!}'),
                      if (item.salesCategory != null &&
                          item.salesCategory!.isNotEmpty)
                        _Badge(label: 'Category: ${item.salesCategory!}'),
                      if (item.instantSelling) _Badge(label: 'Instant selling'),
                      if (item.warranty) _Badge(label: 'Warranty'),
                      if (item.delivery) _Badge(label: 'Delivery'),
                      if (item.status != null && item.status!.isNotEmpty)
                        _Badge(label: 'Status: ${item.status!}'),
                      if (item.projectStatus != null &&
                          item.projectStatus!.isNotEmpty)
                        _Badge(label: 'Project: ${item.projectStatus!}'),
                    ]),
                  ]),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Edit',
              onPressed: () async {
                // Open edit flow
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                      builder: (_) => const UploadCataloguePage()),
                );
                if (changed == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catalogue updated')));
                }
              },
            ),
            AppSpacing.spaceMD,
            SecondaryButton(
              text: 'Delete Catalogue',
              onPressed: () async {
                final ok = await getIt<DeleteCatalog>().call(item.id);
                if (context.mounted) {
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Catalogue deleted')));
                    Navigator.of(context).pop(true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Failed to delete catalogue')));
                  }
                }
              },
            ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: context.softPeachColor, borderRadius: AppRadius.radiusMD),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: context.brownHeaderColor)),
    );
  }
}
