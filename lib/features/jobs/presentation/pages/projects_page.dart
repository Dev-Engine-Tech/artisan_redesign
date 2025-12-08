import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/catalog/presentation/pages/catalog_item_details_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/upload_catalogue_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/ongoing_jobs_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/completed_jobs_page.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_item.dart';
import 'package:artisans_circle/core/utils/responsive.dart';

/// Projects page (catalogue) with tabbed interface:
/// - Catalog: Upload and manage catalog items
/// - Ongoing Jobs: Track active projects and submit progress
/// - Completed Jobs: View completed projects, payments, and reviews
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with TickerProviderStateMixin {
  late final CatalogBloc bloc;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    bloc = getIt<CatalogBloc>();
    // ✅ PERFORMANCE FIX: Check state before loading
    final currentState = bloc.state;
    if (currentState is! CatalogLoaded) {
      bloc.add(LoadMyCatalog());
    }
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    bloc.close();
    super.dispose();
  }

  Widget _uploadPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.softBorderColor),
        ),
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Artisans with catalog projects receive more orders than those without.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            AppSpacing.spaceMD,
            OutlinedAppButton(
              text: 'Upload Catalogue',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const UploadCataloguePage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(color: context.subtleBorderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            AppSpacing.spaceSM,
            Expanded(
              child: Text('Search products, services and artisans',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
            ),
            AppSpacing.spaceSM,
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                  color: context.softPinkColor, borderRadius: AppRadius.radiusMD),
              child: IconButton(
                icon:
                    Icon(Icons.filter_list, color: context.brownHeaderColor),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
            color: context.primaryColor, borderRadius: BorderRadius.circular(14)),
        padding: AppSpacing.paddingLG,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Discover Your Ideal\nJob match',
                      style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700)),
                  AppSpacing.spaceSM,
                  Text(
                      'Find rewarding projects, connect with clients, and take your career to new heights.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8))),
                ],
              ),
            ),
            // placeholder illustration area
            Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius:
                        const BorderRadius.all(Radius.circular(AppRadius.lg)))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocProvider<CatalogBloc>.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: context.lightPeachColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colorScheme.surface.withValues(alpha: 0.0),
          automaticallyImplyLeading: false,
          title: Text('Projects',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: context.responsiveFontSize(20),
                  fontWeight: FontWeight.w600)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: context.maxContentWidth,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: context.responsiveSpacing(16),
                ),
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  borderRadius: AppRadius.radiusLG,
                  border: Border.all(color: context.softBorderColor),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: colorScheme.onPrimary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: context.responsiveFontSize(14),
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: context.responsiveFontSize(14),
                  ),
                  tabs: const [
                    Tab(text: 'Catalogue'),
                    Tab(text: 'Ongoing'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: context.maxContentWidth,
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCatalogTab(),
                  const OngoingJobsPage(),
                  const CompletedJobsPage(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogTab() {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        final header = <Widget>[
          AppSpacing.spaceSM,
          _searchBar(context),
          const SizedBox(height: 14),
          _hero(context),
          const SizedBox(height: 14),
          _uploadPanel(context),
          AppSpacing.spaceLG,
        ];

        if (state is CatalogLoading || state is CatalogInitial) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              ...header,
              const SizedBox(height: 40),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 200),
            ],
          );
        }

        if (state is CatalogError) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              ...header,
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text('Error: ${state.message}'))),
            ],
          );
        }

        if (state is CatalogLoaded) {
          final items = state.items;
          if (items.isEmpty) {
            return RefreshIndicator(
              // ✅ PERFORMANCE FIX: Force refresh on pull-to-refresh is intentional
              onRefresh: () async =>
                  context.read<CatalogBloc>().add(RefreshMyCatalog()),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...header,
                  const SizedBox(height: 40),
                  const Center(child: Text('No projects found')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            // ✅ PERFORMANCE FIX: Force refresh on pull-to-refresh is intentional
            onRefresh: () async =>
                context.read<CatalogBloc>().add(RefreshMyCatalog()),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: header.length + items.length,
              itemBuilder: (context, index) {
                if (index < header.length) return header[index];
                final item = items[index - header.length];
                return _catalogTile(item);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _catalogTile(CatalogItem item) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: context.responsiveSpacing(16),
            vertical: context.responsiveSpacing(8),
          ),
          child: Card(
            elevation: Responsive.cardElevation(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                context.responsiveBorderRadius(12),
              ),
            ),
            color: context.cardBackgroundColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                context.responsiveBorderRadius(12),
              ),
              onTap: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                      builder: (_) => CatalogItemDetailsPage(item: item)),
                );
                // ✅ PERFORMANCE FIX: Reload after item edit is intentional
                if (changed == true && mounted) {
                  context.read<CatalogBloc>().add(RefreshMyCatalog());
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large image banner
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(context.responsiveBorderRadius(12)),
                    ),
                    child: Container(
                      height: context.isTablet ? 240 : 180,
                      width: double.infinity,
                      decoration: (() {
                        final imgUrl = sanitizeImageUrl(item.imageUrl ?? '');
                        final valid = imgUrl.startsWith('http');
                        return BoxDecoration(
                          color: context.cardBackgroundColor,
                          image: valid
                              ? DecorationImage(
                                  image: NetworkImage(imgUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        );
                      })(),
                      child: item.imageUrl == null || item.imageUrl!.isEmpty
                          ? Center(
                              child: Icon(Icons.image_outlined,
                                  size: context.responsiveIconSize(48),
                                  color: colorScheme.onSurfaceVariant),
                            )
                          : null,
                    ),
                  ),

                  // Content section
                  Padding(
                    padding: context.responsivePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and vendor
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: context.responsiveFontSize(16),
                          ),
                        ),

                        // Sub-category badge
                        if (item.subCategoryName != null && item.subCategoryName!.isNotEmpty) ...[
                          AppSpacing.spaceXS,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: context.primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              item.subCategoryName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        if (item.ownerName != null) ...[
                          AppSpacing.spaceXS,
                          Text(
                            item.ownerName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],

                        AppSpacing.spaceMD,

                        // Description excerpt
                        if (item.description.isNotEmpty) ...[
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                            ),
                          ),
                          AppSpacing.spaceMD,
                        ],

                        // Feature badges (hot sale, condition, warranty, delivery)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (item.hotSale == true)
                              _buildFeatureBadge(context, '🔥 Hot Sale', Colors.red),
                            if (item.condition != null && item.condition!.isNotEmpty)
                              _buildFeatureBadge(
                                context,
                                item.condition!.toUpperCase(),
                                item.condition?.toLowerCase() == 'new' ? Colors.green : Colors.orange,
                              ),
                            if (item.warranty == true)
                              _buildFeatureBadge(context, '✓ Warranty', Colors.blue),
                            if (item.delivery == true)
                              _buildFeatureBadge(context, '🚚 Delivery', Colors.teal),
                            if (item.discountPercent != null && item.discountPercent! > 0)
                              _buildFeatureBadge(context, '${item.discountPercent}% OFF', Colors.red),
                          ],
                        ),
                        if ((item.hotSale == true) ||
                            (item.condition != null && item.condition!.isNotEmpty) ||
                            (item.warranty == true) ||
                            (item.delivery == true) ||
                            (item.discountPercent != null && item.discountPercent! > 0))
                          AppSpacing.spaceMD,

                        // Price and timeline row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price range
                            if (item.priceMin != null || item.priceMax != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.softPeachColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.priceMin != null && item.priceMax != null
                                      ? '₦${_formatPrice(item.priceMin!)} - ₦${_formatPrice(item.priceMax!)}'
                                      : '₦${_formatPrice(item.priceMin ?? item.priceMax ?? 0)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                            // Status indicator
                            _buildStatusBadge(context, item.projectStatus ?? item.status),
                          ],
                        ),

                        if (item.projectTimeline != null) ...[
                          AppSpacing.spaceSM,
                          Row(
                            children: [
                              Icon(Icons.schedule,
                                  size: 16, color: colorScheme.onSurface),
                              AppSpacing.spaceXS,
                              Text(
                                'Duration: ${item.projectTimeline}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    if (status == null) return const SizedBox.shrink();

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    Color badgeColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'ongoing':
      case 'started':
        badgeColor = isDark ? Colors.blue.withValues(alpha: 0.3) : Colors.blue.shade100;
        textColor = isDark ? Colors.blue.shade200 : Colors.blue.shade800;
        displayText = 'Started';
        break;
      case 'completed':
        badgeColor = isDark ? Colors.green.withValues(alpha: 0.3) : Colors.green.shade100;
        textColor = isDark ? Colors.green.shade200 : Colors.green.shade800;
        displayText = 'Completed';
        break;
      case 'paused':
      case 'pending':
        badgeColor = isDark ? Colors.orange.withValues(alpha: 0.3) : Colors.orange.shade100;
        textColor = isDark ? Colors.orange.shade200 : Colors.orange.shade800;
        displayText = 'Paused';
        break;
      case 'rejected':
      case 'cancelled':
        badgeColor = isDark ? Colors.red.withValues(alpha: 0.3) : Colors.red.shade100;
        textColor = isDark ? Colors.red.shade200 : Colors.red.shade800;
        displayText = 'Cancelled';
        break;
      default:
        badgeColor = isDark ? Colors.grey.withValues(alpha: 0.3) : Colors.grey.shade100;
        textColor = isDark ? Colors.grey.shade200 : Colors.grey.shade800;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Helper method to build feature badges (hot sale, warranty, delivery, etc.)
  Widget _buildFeatureBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Formats price with thousand separators (e.g., 700000 -> 700,000)
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
