import 'package:flutter/material.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/image_url.dart';

/// Catalogue details page — separate from JobDetailsPage so catalogue items
/// can have different layout/controls in the future.
class CatalogueDetailsPage extends StatefulWidget {
  final Job job;

  const CatalogueDetailsPage({super.key, required this.job});

  @override
  State<CatalogueDetailsPage> createState() => _CatalogueDetailsPageState();
}

class _CatalogueDetailsPageState extends State<CatalogueDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration:
                BoxDecoration(color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
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
            // Image/banner + title block (compact)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: job.thumbnailUrl.isNotEmpty
                  ? Image.network(sanitizeImageUrl(job.thumbnailUrl),
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
                          child: Icon(Icons.home_repair_service_outlined,
                              size: 56, color: AppColors.orange)),
                    ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(job.category,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black45)),
                  const SizedBox(height: 12),
                  Text(job.description,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                  const SizedBox(height: 12),
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
            ElevatedButton(
              onPressed: () {
                // placeholder edit
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9A4B20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Edit Catalogue', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // placeholder delete
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Catalogue', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEB2D2D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 18),
            // Additional details preserved
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(job.description,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
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
  const _Badge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softPeach,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.brownHeader)),
    );
  }
}
