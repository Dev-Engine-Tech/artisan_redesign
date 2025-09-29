import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_bloc.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_event.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_state.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_card.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_invite_details_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/order_details_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/agreement_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/change_request_page.dart';
import 'package:artisans_circle/features/messages/domain/entities/conversation.dart' as domain;
import 'package:artisans_circle/features/messages/presentation/manager/chat_manager.dart';
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
import 'package:artisans_circle/features/home/presentation/widgets/banner_carousel.dart';
import 'package:artisans_circle/features/home/presentation/widgets/enhanced_banner_carousel.dart';
import 'package:artisans_circle/core/models/banner_model.dart' as api;
import 'package:artisans_circle/core/performance/performance_monitor.dart';

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
    _ordersBloc = getIt<CatalogRequestsBloc>();
    _ordersBloc!.add(LoadCatalogRequests());
    _scrollController.addListener(_onScroll);
    
    // Load real data from APIs
    _loadJobsData();
    _loadAccountData();
  }

  void _loadJobsData() {
    try {
      final jobBloc = BlocProvider.of<JobBloc>(context);
      // Load applications first (for Applications tab)
      // Jobs will be loaded when user switches to Jobs tab to avoid race condition
      jobBloc.add(LoadApplications(page: 1, limit: 10));
    } catch (e) {
      // JobBloc not available in context, will use sample data
    }
  }

  void _loadAccountData() {
    try {
      final accountBloc = BlocProvider.of<AccountBloc>(context);
      // Load earnings data
      accountBloc.add(AccountLoadEarnings());
      accountBloc.add(AccountLoadTransactions(page: 1, limit: 10));
    } catch (e) {
      // AccountBloc not available, will use fallback data
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _scrollController.dispose();
    _ordersBloc?.close();
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
            return jobState.jobs.map((job) => JobModel(
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
            )).toList();
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
            return jobState.jobs.map((job) => JobModel(
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
            )).toList();
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
              TextButton(
                  onPressed: () => Navigator.of(c).pop(),
                  child: const Text('OK')),
            ],
          ),
        );
      }
    else if (result == 'request_changes') {
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
              padding: const EdgeInsets.all(16),
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
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            data['subtitle']!,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
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
                      decoration: const BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.softPink : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Text(label,
                      style: TextStyle(
                          color: AppColors.brownHeader,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: selected ? 13 : 12)),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('56',
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
        print('DEBUG: HomePage - BlocListener received state: ${state.runtimeType}');
        if (state is JobStateAppliedSuccess) {
          print('DEBUG: HomePage - Updating _applications with ${state.jobs.length} applications');
          // Convert domain Jobs to JobModel for local state storage
          final converted = state.jobs.map((j) => JobModel(
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
      }) ?? _buildOptimizedHomePage(context),
    );
  }
  
  Widget _buildOptimizedHomePage(BuildContext context) {
    print('DEBUG: HomePage - _buildOptimizedHomePage called, _applications.length: ${_applications.length}');
    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context),
            const SizedBox(height: 18),
            _buildProfileActions(context),
            EnhancedBannerCarousel(
              category: api.BannerCategory.homepage,
              height: 140,
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            const SizedBox(height: 8),
            () {
              print('DEBUG: HomePage - About to create HomeTabSection with ${_applications.length} applications');
              return HomeTabSection(
                onJobTap: _handleJobTap,
                onRequestTap: _handleOrderTap,
                applications: _applications,
                onApplicationUpdate: _updateApplications,
              );
            }(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        color: AppColors.brownHeader,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                        color: Colors.white24,
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.person, color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Hey, Uwak Daniel',
                            style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('Welcome back!',
                            style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
                const Row(
                  children: [
                    MessageIcon(),
                    SizedBox(width: 12),
                    NotificationIcon(unreadCount: 2),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16)),
              child: Text('Available Balance',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70)),
            ),
            const SizedBox(height: 8),
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
                        style: textTheme.titleLarge?.copyWith(
                            color: Colors.white70, fontSize: 20)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(balanceText,
                            style: textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: const Icon(Icons.visibility,
                          color: Colors.white70, size: 18),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final accountBloc = BlocProvider.of<AccountBloc>(context);
                      final state = accountBloc.state;
                      double earnings = 300000;
                      
                      if (state is AccountEarningsLoaded) {
                        earnings = state.earnings.available;
                      }
                      
                      showWithdrawFlow(context, earnings: earnings);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Withdraw', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Transactions', style: TextStyle(color: Colors.white)),
                      ],
                    ),
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
    final job = _catalogRequestToJob(request).toEntity();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OrderDetailsPage(job: job),
    ));
  }
  
  void _updateApplications(List<JobModel> applications) {
    setState(() {
      _applications = applications;
    });
  }
}
