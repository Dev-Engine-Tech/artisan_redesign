import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/catalog/presentation/pages/catalog_item_details_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/upload_catalogue_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/ongoing_jobs_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/completed_jobs_page.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_item.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.softBorder),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Artisans with catalog projects receive more orders than those without.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const UploadCataloguePage()));
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(color: AppColors.orange, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Upload Catalogue',
                  style: TextStyle(
                      color: AppColors.orange, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.black26),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Search products, services and artisans',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black38)),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon:
                    const Icon(Icons.filter_list, color: AppColors.brownHeader),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
            color: AppColors.orange, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Discover Your Ideal\nJob match',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20)),
                  SizedBox(height: 8),
                  Text(
                      'Find rewarding projects, connect with clients, and take your career to new heights.',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            // placeholder illustration area
            Container(
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.all(Radius.circular(12)))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CatalogBloc>.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: AppColors.lightPeach,
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
                icon: const Icon(Icons.chevron_left, color: Colors.black54),
                onPressed: () {},
              ),
            ),
          ),
          title: const Text('Projects',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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
        body: SafeArea(
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
    );
  }

  Widget _buildCatalogTab() {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        final header = <Widget>[
          const SizedBox(height: 8),
          _searchBar(context),
          const SizedBox(height: 14),
          _hero(context),
          const SizedBox(height: 14),
          _uploadPanel(context),
          const SizedBox(height: 16),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? DecorationImage(
                            image:
                                NetworkImage(sanitizeImageUrl(item.imageUrl!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.imageUrl == null || item.imageUrl!.isEmpty
                      ? const Center(
                          child: Icon(Icons.image_outlined,
                              size: 48, color: Colors.grey),
                        )
                      : null,
                ),
              ),

              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and vendor
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    if (item.ownerName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.ownerName!,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

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
                              color: AppColors.softPeach,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.priceMin != null && item.priceMax != null
                                  ? '₦${item.priceMin} - ₦${item.priceMax}'
                                  : '₦${item.priceMin ?? item.priceMax}',
                              style: TextStyle(
                                color: AppColors.brownHeader,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        // Status indicator
                        _buildStatusBadge(item.projectStatus ?? item.status),
                      ],
                    ),

                    if (item.projectTimeline != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            'Duration: ${item.projectTimeline}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
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
  }

  Widget _buildStatusBadge(String? status) {
    if (status == null) return const SizedBox.shrink();

    Color badgeColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'ongoing':
      case 'started':
        badgeColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        displayText = 'Started';
        break;
      case 'completed':
        badgeColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        displayText = 'Completed';
        break;
      case 'paused':
      case 'pending':
        badgeColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        displayText = 'Paused';
        break;
      case 'rejected':
      case 'cancelled':
        badgeColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        displayText = 'Cancelled';
        break;
      default:
        badgeColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
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
}
