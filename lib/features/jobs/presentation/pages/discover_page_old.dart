import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/discover_job_card.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/filter_page.dart';
import 'package:artisans_circle/core/di.dart';

class DiscoverPage extends StatefulWidget {
  final bool showHeader;
  const DiscoverPage({super.key, this.showHeader = true});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late final JobBloc bloc;
  // Removed unused flag to satisfy analyzer

  @override
  void initState() {
    super.initState();
    // Use GetIt to create a fresh bloc (registered as factory)
    bloc = getIt<JobBloc>();
    // Load jobs when page becomes visible to avoid race condition with HomePage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        bloc.add(LoadJobs());
      }
    });
  }

  @override
  void dispose() {
    // Blocs created by factory should be closed when page is disposed.
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JobBloc>.value(
      value: bloc,
      child: Scaffold(
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
                icon: const Icon(Icons.chevron_left, color: Colors.black54),
                onPressed: () {
                  // In shell the back may not pop; keep as placeholder
                },
              ),
            ),
          ),
          title: const Text('Discover',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
          centerTitle: false,
          actions: [],
        ),
        body: SafeArea(
          child: BlocBuilder<JobBloc, JobState>(
            builder: (context, state) {
              // Header built to match design (search bar, hero banner, tabs)
              final headerWidgets = <Widget>[];
              // Allow tests to disable the header to avoid tight layout constraints in test environment.
              if (widget.showHeader) {
                headerWidgets.addAll([
                  const SizedBox(height: 8),

                  // Search bar (single control with embedded filter)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.subtleBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black26),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                                'Search products, services and artisans',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.black38)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                                color: AppColors.softPink,
                                borderRadius: BorderRadius.circular(10)),
                            child: IconButton(
                              icon: const Icon(Icons.filter_list,
                                  color: AppColors.brownHeader),
                              onPressed: () async {
                                // Open the Filter page as a draggable bottom sheet.
                                final filters =
                                    await showModalBottomSheet<dynamic>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (c) => DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.92,
                                    minChildSize: 0.5,
                                    maxChildSize: 0.95,
                                    builder: (_, controller) => Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16)),
                                      ),
                                      child: const FilterPage(),
                                    ),
                                  ),
                                );
                                if (filters != null) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Filters applied')));
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Hero card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Flexible(
                            child: FittedBox(
                              alignment: Alignment.topLeft,
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Discover Your Ideal\nJob match',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Find rewarding projects, connect with clients, and take your career to new heights.',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.brownHeader,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Apply',
                                          style: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // image placeholder
                          Container(
                              width: 86,
                              height: 86,
                              decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)))),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tabs row (design sized chips)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      height: 46,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildTabChip('Jobs', selected: true),
                          _buildTabChip('Applications'),
                          _buildTabChip('Job Invite'),
                          _buildTabChip('Cata Request'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ]);
              }

              // Render content based on state
              if (state is JobStateLoading || state is JobStateInitial) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...headerWidgets,
                    const SizedBox(height: 40),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 200),
                  ],
                );
              }

              if (state is JobStateError) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...headerWidgets,
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text('Error: ${state.message}')),
                    ),
                  ],
                );
              }

              if (state is JobStateLoaded || state is JobStateAppliedSuccess) {
                final jobs = state is JobStateLoaded
                    ? state.jobs
                    : (state as JobStateAppliedSuccess).jobs;
                if (jobs.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<JobBloc>().add(RefreshJobs());
                    },
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ...headerWidgets,
                        const SizedBox(height: 40),
                        const Center(child: Text('No jobs found')),
                      ],
                    ),
                  );
                }

                // Single ListView with header widgets followed by discover-styled job cards.
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<JobBloc>().add(RefreshJobs());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: headerWidgets.length + jobs.length,
                    itemBuilder: (context, index) {
                      if (index < headerWidgets.length) {
                        return headerWidgets[index];
                      }
                      final job = jobs[index - headerWidgets.length];
                      return DiscoverJobCard(
                        job: job,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: bloc,
                              child: JobDetailsPage(job: job),
                            ),
                          ));
                        },
                      );
                    },
                  ),
                );
              }

              if (state is JobStateApplying) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...headerWidgets,
                    const SizedBox(height: 40),
                    const Center(child: CircularProgressIndicator()),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.softPink : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: AppColors.brownHeader,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text('56',
                  style: TextStyle(fontSize: 12, color: AppColors.brownHeader)),
            ),
          ],
        ),
      ),
    );
  }
}
