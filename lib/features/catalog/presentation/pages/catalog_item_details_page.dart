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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text('Catalogue', style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: ListView(
          padding: context.responsivePadding,
          children: [
            ClipRRect(
              borderRadius: AppRadius.radiusLG,
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(sanitizeImageUrl(item.imageUrl!),
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          height: 180,
                          color: AppColors.softPink,
                          child: const Center(child: Icon(Icons.image))))
                  : Container(
                      height: 180,
                      color: AppColors.softPink,
                      child: const Center(
                          child: Icon(Icons.image_outlined,
                              size: 56, color: AppColors.orange))),
            ),
            AppSpacing.spaceMD,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.radiusLG,
                  border: Border.all(color: AppColors.softBorder)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    if (item.ownerName != null && item.ownerName!.isNotEmpty)
                      Text(item.ownerName!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black45)),
                    AppSpacing.spaceMD,
                    Text(item.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black54)),
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
          color: AppColors.softPeach, borderRadius: AppRadius.radiusMD),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.brownHeader)),
    );
  }
}
