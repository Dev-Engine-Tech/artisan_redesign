import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_bloc.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_state.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';
import 'package:artisans_circle/features/catalog/presentation/pages/catalog_request_view_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/agreement_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/change_request_page.dart';
import 'package:artisans_circle/features/wallet/presentation/withdraw_flow.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_requests_bloc.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_request.dart';
import 'package:artisans_circle/features/account/presentation/pages/transactions_page.dart';
import 'package:artisans_circle/features/home/presentation/widgets/profile_action_buttons.dart';
import 'package:artisans_circle/features/home/utils/profile_utils.dart';
import 'package:artisans_circle/features/notifications/presentation/widgets/notification_icon.dart';
import 'package:artisans_circle/features/messages/presentation/widgets/message_icon.dart';
import 'package:artisans_circle/features/home/presentation/widgets/home_tab_section.dart';
import 'package:artisans_circle/features/home/presentation/widgets/unified_banner_carousel.dart';
import 'package:artisans_circle/core/models/banner_model.dart' as api;
import 'package:artisans_circle/core/performance/performance_monitor.dart';
import 'package:artisans_circle/features/home/utils/home_data_loader.dart';
import 'package:artisans_circle/core/utils/responsive.dart';
import 'package:artisans_circle/core/services/subscription_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PerformanceTrackingMixin {
  @override
  Widget buildWithTracking(BuildContext context) => _buildHome(context);
  int _selectedIndex = 0;
  final PageController _heroController = PageController(viewportFraction: 0.98);
  final ScrollController _scrollController = ScrollController();
  CatalogRequestsBloc? _ordersBloc;
  String? _ordersNext;
  bool _loadingMoreOrders = false;
  // Backing list for the Applications tab so we can update agreement state at runtime
  List<JobModel> _applications = [];
  SubscriptionPlan _currentPlan = SubscriptionPlan.unknown;

  // Performance optimization: centralized data loader
  final HomeDataLoader _dataLoader = HomeDataLoader();
  final List<Map<String, String>> _heroItems = [
    {
      'title': 'Discover Your Ideal\nJob match',
      'subtitle':
          'Find rewarding projects, connect with clients, and take your career to new heights.',
      'cta': 'Apply',
    },
    {
      'title': 'Artisan Tips & Best Practices',
      'subtitle': 'Improve your listings and win more orders with short tips.',
      'cta': 'Learn',
    },
    {
      'title': 'Featured Projects',
      'subtitle': 'Browse featured projects handpicked for you.',
      'cta': 'Explore',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-advance disabled to avoid animation-driven flakiness in widget tests.
    try {
      _ordersBloc = BlocProvider.of<CatalogRequestsBloc>(context);
    } catch (_) {
      // Fallback if provider not found (should not happen under AppShell)
      _ordersBloc = getIt<CatalogRequestsBloc>();
    }
    _scrollController.addListener(_onScroll);

    // ✅ PERFORMANCE OPTIMIZATION: Staggered data loading with request management
    // Load data after first frame to avoid blocking initial render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dataLoader.loadAllData(context);
        _loadSubscriptionPlan();
      }
    });
  }

  Future<void> _loadSubscriptionPlan() async {
    try {
      final subscriptionService = getIt<SubscriptionService>();
      final plan = await subscriptionService.getCurrentPlan();
      if (mounted) {
        setState(() {
          _currentPlan = plan;
        });
      }
    } catch (e) {
      debugPrint('Error loading subscription plan: $e');
    }
  }

  String _getPlanDisplayName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.bronze:
        return 'Bronze';
      case SubscriptionPlan.silver:
        return 'Silver';
      case SubscriptionPlan.gold:
        return 'Gold';
      case SubscriptionPlan.unknown:
        return '';
    }
  }

  Color _getPlanColor(SubscriptionPlan plan, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (plan) {
      case SubscriptionPlan.free:
        return colorScheme.onSurface.withValues(alpha: 0.6);
      case SubscriptionPlan.bronze:
        return const Color(0xFFCD7F32); // Bronze color
      case SubscriptionPlan.silver:
        return const Color(0xFFC0C0C0); // Silver color
      case SubscriptionPlan.gold:
        return const Color(0xFFFFD700); // Gold color
      case SubscriptionPlan.unknown:
        return colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _scrollController.dispose();
    // ✅ Cancel all pending API requests to prevent memory leaks
    _dataLoader.dispose();
    // Do not close _ordersBloc here; AppShell owns its lifecycle
    super.dispose();
  }

  void _onScroll() {
    if (_selectedIndex != 3) return;
    if (_ordersNext == null || _loadingMoreOrders) return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.extentAfter < 360) {
      _loadingMoreOrders = true;
      _ordersBloc?.add(LoadCatalogRequests(next: _ordersNext));
    }
  }

  List<JobModel> _sampleJobs() {
    return List.generate(
      6,
      (i) => JobModel(
        id: 'home_$i',
        title: i % 2 == 0 ? 'Electrical Home Wiring' : 'Cushion Chair',
        category: i % 2 == 0 ? 'Electrical Engineering' : 'Furniture',
        description:
            'Lorem ipsum dolor sit amet consectetur. Brief description used for demo purposes.',
        address: '15a, oladipo diya street, Lekki phase 1, Lagos state.',
        minBudget: 150000,
        maxBudget: 200000,
        duration: 'Less than a month',
        applied: i == 2,
      ),
    );
  }

  // Alternate sample lists used by the tabbed view
  List<JobModel> _sampleApplications() {
    // initialize once so we can update items (e.g., accept agreements)
    if (_applications.isEmpty) {
      _applications = List.generate(
        4,
        (i) => JobModel(
          id: 'app_$i',
          title: i % 2 == 0 ? 'Electrical Home Wiring' : 'Cushion Chair',
          category: i % 2 == 0 ? 'Electrical Engineering' : 'Furniture',
          description: 'Application - brief description for demo.',
          address: '15a, oladipo diya street, Lekki phase 1, Lagos state.',
          minBudget: 150000,
          maxBudget: 200000,
          duration: 'Less than a month',
          applied: true,
        ),
      );
    }
    return _applications;
  }

  List<JobModel> _sampleInvites() {
    return List.generate(
      3,
      (i) => JobModel(
        id: 'invite_$i',
        title: 'Invite: Electrical Home Wiring',
        category: 'Electrical Engineering',
        description: 'You have been invited to quote for this job.',
        address: 'Client location',
        minBudget: 200000,
        maxBudget: 300000,
        duration: 'Less than a month',
        applied: false,
      ),
    );
  }

  // Removed unused _sampleOrders() helper to satisfy analyzer

  List<JobModel> _getJobsForTab(int index, JobState jobState) {
    // Use different data sources for different tabs
    try {
      switch (index) {
        case 1:
          // Applications tab - use applied jobs data only
          if (jobState is JobStateAppliedSuccess) {
            return jobState.jobs
                .map((job) => JobModel(
                      id: job.id,
                      title: job.title,
                      category: job.category,
                      description: job.description,
                      address: job.address,
                      minBudget: job.minBudget,
                      maxBudget: job.maxBudget,
                      duration: job.duration,
                      applied: true, // These are from applied jobs endpoint
                      thumbnailUrl: job.thumbnailUrl,
                      status: job.status,
                      agreement: job.agreement,
                      changeRequest: job.changeRequest,
                      materials: job.materials,
                    ))
                .toList();
          }
          return [];
        case 2:
          // Job invites - for now use sample data
          return _sampleInvites();
        case 3:
          // Orders tab will handle catalog requests separately
          return [];
        case 0:
        default:
          // Jobs tab - use general jobs data only
          if (jobState is JobStateLoaded) {
            return jobState.jobs
                .map((job) => JobModel(
                      id: job.id,
                      title: job.title,
                      category: job.category,
                      description: job.description,
                      address: job.address,
                      minBudget: job.minBudget,
                      maxBudget: job.maxBudget,
                      duration: job.duration,
                      applied: false, // These are from general jobs endpoint
                      thumbnailUrl: job.thumbnailUrl,
                    ))
                .toList();
          }
          return [];
      }
    } catch (e) {
      // JobBloc not available, fall back to sample data
    }

    // Fallback to sample data
    switch (index) {
      case 1:
        return _sampleApplications();
      case 2:
        return _sampleInvites();
      case 3:
        // Orders tab will handle catalog requests separately
        return [];
      case 0:
      default:
        return _sampleJobs();
    }
  }

  // Convert CatalogRequest to JobModel for display consistency
  JobModel _catalogRequestToJob(CatalogRequest request) {
    // Use enhanced fields for better display
    final displayTitle = request.catalogTitle?.isNotEmpty == true
        ? request.catalogTitle!
        : request.title;

    // Priority for price: paymentBudget > priceMin/Max > material cost
    int minBudget = 0;
    int maxBudget = 0;

    if (request.paymentBudget != null) {
      final budget = double.tryParse(request.paymentBudget!) ?? 0;
      minBudget = budget.toInt();
      maxBudget = budget.toInt();
    } else if (request.priceMin != null || request.priceMax != null) {
      minBudget = double.tryParse(request.priceMin ?? '0')?.toInt() ?? 0;
      maxBudget = double.tryParse(request.priceMax ?? request.priceMin ?? '0')
              ?.toInt() ??
          0;
    } else {
      // Fallback to material cost calculation
      final totalCost = request.materials.fold<int>(
          0,
          (sum, material) =>
              sum + ((material.price ?? 0) * (material.quantity ?? 1)));
      minBudget = totalCost;
      maxBudget = totalCost;
    }

    return JobModel(
      id: request.id,
      title: displayTitle,
      category: 'Catalog Request',
      description: request.description,
      address: request.clientName != null
          ? 'Order from ${request.clientName}'
          : 'Client order',
      minBudget: minBudget,
      maxBudget: maxBudget,
      duration: request.projectStatus?.toUpperCase() ??
          request.status?.toUpperCase() ??
          'PENDING',
      applied: true,
      thumbnailUrl: request.catalogPictures.isNotEmpty
          ? request.catalogPictures.first
          : '',
    );
  }

  // Agreement / application helpers -------------------------------------------------
  Future<void> _openAgreementFlow(JobModel job) async {
    // Use the adaptive agreement presentation implemented in agreement_page.dart.
    final result = await showAgreementAdaptive<dynamic>(context, job);

    if (result == true) {
      // accepted - update local state first
      _acceptAgreement(job.id);

      // Wait briefly to allow the modal bottom sheet to finish its dismiss animation,
      // then show the success dialog above the root navigator so it isn't stacked inside the sheet.
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      showDialog(
        useRootNavigator: true,
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Success!'),
          content: const Text(
              'Agreement accepted. Payment requested and client notified. Proceed once deposit is made.'),
          actions: [
            TextAppButton(
              text: 'OK',
              onPressed: () => Navigator.of(c).pop(),
            ),
          ],
        ),
      );
    } else if (result == 'request_changes') {
      // Open the dedicated Change Request page so the user can provide details.
      // Provide the existing JobBloc instance to the pushed route (fall back to DI).
      JobBloc bloc;
      if (mounted) {
        try {
          bloc = BlocProvider.of<JobBloc>(context);
        } catch (_) {
          bloc = getIt<JobBloc>();
        }
      } else {
        bloc = getIt<JobBloc>();
      }

      // ignore: use_build_context_synchronously
      await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return BlocProvider.value(
          value: bloc,
          child: ChangeRequestPage(job: job.toEntity()),
        );
      }));

      // After returning from the change request flow, update local UI to reflect rejection.
      _rejectApplication(job.id);
    }
  }

  void _acceptAgreement(String jobId) {
    final idx = _applications.indexWhere((j) => j.id == jobId);
    if (idx == -1) return;
    final old = _applications[idx];
    setState(() {
      _applications[idx] = JobModel(
        id: old.id,
        title: old.title,
        category: old.category,
        description: old.description,
        address: old.address,
        minBudget: old.minBudget,
        maxBudget: old.maxBudget,
        duration: old.duration,
        applied: true,
        thumbnailUrl: old.thumbnailUrl,
      );
    });
  }

  void _rejectApplication(String jobId) {
    // simple placeholder: mark agreementSent = false and notify user
    final idx = _applications.indexWhere((j) => j.id == jobId);
    if (idx == -1) return;
    final old = _applications[idx];
    setState(() {
      _applications[idx] = JobModel(
        id: old.id,
        title: old.title,
        category: old.category,
        description: old.description,
        address: old.address,
        minBudget: old.minBudget,
        maxBudget: old.maxBudget,
        duration: old.duration,
        applied: true,
        thumbnailUrl: old.thumbnailUrl,
      );
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Requested changes. Client notified.')));
    }
  }

  // mapping for hero per tab
  static const List<String> _tabs = [
    'Jobs',
    'Applications',
    'Job Invite',
    'Orders'
  ];

  Widget _buildHero(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _heroController,
        itemCount: _heroItems.length,
        itemBuilder: (context, index) {
          final data = _heroItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(14)),
              padding: AppSpacing.paddingLG,
              child: Row(
                children: [
                  // Left text (no per-tab button — banner stands alone)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            data['title']!,
                            style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppSpacing.spaceSM,
                        Flexible(
                          child: Text(
                            data['subtitle']!,
                            style: TextStyle(
                                color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right image placeholder (slightly smaller to give space)
                  Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withValues(alpha: 0.24),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(AppRadius.lg)))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabChip(String label, {required int index}) {
    final selected = _selectedIndex == index;
    // Use a column so we can show an active underline when selected.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              padding: AppSpacing.horizontalSM,
              decoration: BoxDecoration(
                color: selected ? AppColors.softPink : AppColors.cardBackground,
                borderRadius: AppRadius.radiusXXXL,
              ),
              child: Row(
                children: [
                  Text(label,
                      style: TextStyle(
                          color: AppColors.brownHeader,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: selected ? 13 : 12)),
                  AppSpacing.spaceXS,
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: AppRadius.radiusLG),
                    child: const Text('56',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.brownHeader)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // active underline to match design
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: selected ? 3 : 0,
              width: selected ? 36 : 0,
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobStateAppliedSuccess) {
          // Convert domain Jobs to JobModel for local state storage
          final converted = state.jobs
              .map((j) => JobModel(
                    id: j.id,
                    title: j.title,
                    category: j.category,
                    description: j.description,
                    address: j.address,
                    minBudget: j.minBudget,
                    maxBudget: j.maxBudget,
                    duration: j.duration,
                    applied: j.applied,
                    thumbnailUrl: j.thumbnailUrl,
                    status: j.status,
                    agreement: j.agreement,
                    changeRequest: j.changeRequest,
                    materials: j.materials,
                  ))
              .toList();
          _updateApplications(converted);
        }
      },
      child: Performance.timeSync('HomePage_build', () {
            return _buildOptimizedHomePage(context);
          }) ??
          _buildOptimizedHomePage(context),
    );
  }

  Widget _buildOptimizedHomePage(BuildContext context) {
    // debug: applications length
    final double carouselHeight = context.isTablet ? 180 : 140;

    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: context.maxContentWidth,
            ),
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                RepaintBoundary(
                  child: _buildHeader(context),
                ),
                SizedBox(height: context.responsiveSpacing(18)),
                RepaintBoundary(
                  child: _buildProfileActions(context),
                ),
                RepaintBoundary(
                  child: UnifiedBannerCarousel.api(
                    category: api.BannerCategory.homepage,
                    height: carouselHeight,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsiveSpacing(8),
                    ),
                  ),
                ),
                AppSpacing.spaceSM,
                HomeTabSection(
                  onJobTap: _handleJobTap,
                  onRequestTap: _handleOrderTap,
                  applications: _applications,
                  onApplicationUpdate: _updateApplications,
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        color: AppColors.brownHeader,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AccountBloc, AccountState>(
              builder: (context, accountState) {
                String userName = 'Artisan';
                if (accountState is AccountProfileLoaded && accountState.profile.fullName.isNotEmpty) {
                  userName = accountState.profile.fullName;
                } else {
                  final authState = context.watch<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    final user = authState.user;
                    final full = (user.firstName + ' ' + user.lastName).trim();
                    if (full.isNotEmpty) {
                      userName = full;
                    } else if (user.firstName.isNotEmpty) {
                      userName = user.firstName;
                    } else if (user.lastName.isNotEmpty) {
                      userName = user.lastName;
                    } else if (user.phone.isNotEmpty) {
                      userName = user.phone;
                    }
                    debugPrint(
                        '🔐 Auth state: Authenticated, firstName: ${user.firstName}, lastName: ${user.lastName}, phone: ${user.phone}');
                  } else {
                    debugPrint('🔐 Auth state: ${authState.runtimeType}');
                  }
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorScheme.onPrimary.withValues(alpha: 0.24)),
                                  color: colorScheme.onPrimary.withValues(alpha: 0.24),
                                ),
                                child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.transparent,
                                    child: Icon(Icons.person,
                                        color: colorScheme.onPrimary)),
                              ),
                              // Subscription badge
                              if (_currentPlan != SubscriptionPlan.unknown &&
                                  _getPlanDisplayName(_currentPlan).isNotEmpty)
                                Positioned(
                                  right: -4,
                                  bottom: -2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getPlanColor(_currentPlan, context),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: colorScheme.onPrimary,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      _getPlanDisplayName(_currentPlan)[0],
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          AppSpacing.spaceMD,
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Hey, $userName',
                                    style: textTheme.titleLarge?.copyWith(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Row(
                                  children: [
                                    Text('Welcome back!',
                                        style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onPrimary.withValues(alpha: 0.7),
                                            fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    if (_currentPlan !=
                                            SubscriptionPlan.unknown &&
                                        _getPlanDisplayName(_currentPlan)
                                            .isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getPlanColor(_currentPlan, context),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _getPlanDisplayName(_currentPlan),
                                          style: TextStyle(
                                            color: colorScheme.onPrimary,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Row(
                      children: [
                        MessageIcon(),
                        AppSpacing.spaceMD,
                        NotificationIcon(unreadCount: 2),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.24), borderRadius: AppRadius.radiusXL),
              child: Text('Available Balance',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.7))),
            ),
            AppSpacing.spaceSM,
            BlocBuilder<AccountBloc, AccountState>(
              builder: (context, accountState) {
                String balanceText = '0';
                if (accountState is AccountEarningsLoaded) {
                  final available = accountState.earnings.available;
                  balanceText = available.toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                        (match) => '${match[1]},',
                      );
                } else if (accountState is AccountLoading) {
                  balanceText = '...';
                } else if (accountState is AccountError) {
                  balanceText = '0';
                } else {
                  balanceText = '...';
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('NGN',
                        style: textTheme.titleLarge
                            ?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: 20)),
                    AppSpacing.spaceSM,
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(balanceText,
                            style: textTheme.headlineLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                    AppSpacing.spaceMD,
                    Container(
                      decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withValues(alpha: 0.24),
                          borderRadius: AppRadius.radiusMD),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Icon(Icons.visibility,
                          color: colorScheme.onPrimary.withValues(alpha: 0.7), size: 18),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedAppButton(
                    text: 'Withdraw',
                    onPressed: () {
                      final accountBloc = BlocProvider.of<AccountBloc>(context);
                      final state = accountBloc.state;
                      double earnings = 300000;

                      if (state is AccountEarningsLoaded) {
                        earnings = state.earnings.available;
                      }

                      showWithdrawFlow(context, earnings: earnings);
                    },
                  ),
                ),
                AppSpacing.spaceMD,
                Expanded(
                  child: OutlinedAppButton(
                    text: 'History',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<AccountBloc>(context),
                            child: const TransactionsPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileActions(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          final profileProgress = ProfileUtils.calculateProfileProgress(user);
          final isVerified = user.isVerified;

          return ProfileActionButtons(
            profileProgress: profileProgress,
            isVerified: isVerified,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void _handleJobTap(Job job) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      JobBloc bloc;
      try {
        bloc = BlocProvider.of<JobBloc>(context);
      } catch (_) {
        bloc = getIt<JobBloc>();
      }
      return BlocProvider.value(
        value: bloc,
        child: JobDetailsPage(job: job),
      );
    }));
  }

  void _handleOrderTap(CatalogRequest request) {
    // Project Request details (Catalog Request) should use the dedicated page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogRequestViewPage(requestId: request.id),
      ),
    );
  }

  void _updateApplications(List<JobModel> applications) {
    setState(() {
      _applications = applications;
    });
  }
}
