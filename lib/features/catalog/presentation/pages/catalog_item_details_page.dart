import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/image_url.dart';
import '../../domain/usecases/delete_catalog.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/upload_catalogue_page.dart';
import '../../domain/entities/catalog_item.dart';

class CatalogItemDetailsPage extends StatelessWidget {
  final CatalogItem item;
  const CatalogItemDetailsPage({super.key, required this.item});

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 12),
                    Text(item.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black54)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, children: [
                      if (item.priceMin != null)
                        _Badge(
                            label:
                                '₦${item.priceMin}${item.priceMax != null ? ' - ₦${item.priceMax}' : ''}'),
                      if (item.projectTimeline != null)
                        _Badge(label: item.projectTimeline!),
                    ]),
                  ]),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () async {
                // Open edit flow
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                      builder: (_) => UploadCataloguePage(item: item)),
                );
                if (changed == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catalogue updated')));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9A4B20)),
              child: const Text('Edit Catalogue'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
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
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Catalogue'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB2D2D)),
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
          color: AppColors.softPeach, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.brownHeader)),
    );
  }
}
