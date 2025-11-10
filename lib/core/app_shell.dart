import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/home/presentation/pages/home_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/discover_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/projects_page.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/account/presentation/pages/account_page.dart';
import 'package:artisans_circle/features/invoices/presentation/pages/invoice_menu_page.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_bloc.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_requests_bloc.dart';
import 'package:artisans_circle/core/performance/performance_monitor.dart';
import 'package:artisans_circle/core/services/login_state_service.dart';
import 'package:artisans_circle/core/widgets/youtube_video_popup.dart';
import 'package:artisans_circle/core/analytics/firebase_analytics_service.dart';
import 'package:artisans_circle/features/auth/presentation/pages/sign_in_page.dart';
import 'package:artisans_circle/core/services/push_registration_service.dart';
import 'package:artisans_circle/core/utils/responsive.dart';
// import 'package:artisans_circle/core/analytics/firebase_analytics_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final JobBloc _jobBloc;
  late final AccountBloc _accountBloc;
  late final CatalogRequestsBloc _catalogRequestsBloc;
  bool _videoCheckScheduled = false;

  // Pages will be created dynamically to provide proper context
  Widget _getPage(int index, BuildContext context) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const DiscoverPage();
      case 2:
        return const CatalogPage();
      case 3:
        // Modern Invoice Menu Page
        return const InvoiceMenuPage();
      case 4:
        return const SupportAccountPage();
      default:
        return const HomePage();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize performance monitoring
    Performance.enable();

    // Initialize BLoCs once in initState for better performance
    _jobBloc = getIt<JobBloc>();
    _accountBloc = getIt<AccountBloc>();
    _catalogRequestsBloc = getIt<CatalogRequestsBloc>();

    // Attempt push registration early; safe to call multiple times
    try {
      getIt<PushRegistrationService>().registerIfPossible();
    } catch (_) {}

    // After first frame, check if we should show the instructional video.
    // This covers the fresh-login case where AppShell is pushed after auth succeeds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _triggerVideoCheckIfNeeded();
      }
    });

    // Track app launch analytics
    try {
      final analyticsService = getIt<AnalyticsService>();
      analyticsService.logEvent('app_launched', {
        'platform': 'mobile',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _jobBloc.close();
    _accountBloc.close();
    _catalogRequestsBloc.close();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Log tab screen view manually since tabs don't change routes
    try {
      final analytics = getIt<AnalyticsService>();
      final names = ['Home', 'Discover', 'Catalogue', 'Invoice', 'Support'];
      analytics.logScreenView('tab_${names[index].toLowerCase()}', 'BottomTab');
    } catch (_) {}
  }

  /// Check if instructional video should be shown and display it
  Future<void> _showInstructionalVideoIfNeeded(BuildContext context) async {
    try {
      debugPrint(
          '🔍 AppShell: Checking if instructional video should be shown...');
      final loginStateService = getIt<LoginStateService>();
      final shouldShow = await loginStateService.shouldShowInstructionalVideo();

      debugPrint('🎯 AppShell: Should show video? $shouldShow');

      if (shouldShow && context.mounted) {
        debugPrint('⏳ AppShell: Waiting 1 second for UI to load...');
        // Small delay to ensure the UI is fully loaded
        await Future.delayed(const Duration(milliseconds: 1000));

        if (context.mounted) {
          debugPrint('🎬 AppShell: Showing YouTube video popup now!');
          showYouTubeVideoPopup(
            context,
            videoUrl: 'https://youtube.com/shorts/UbXpeqAfLkE',
            title: 'Welcome to Artisans Circle!',
            onClose: () async {
              debugPrint('✅ AppShell: User closed video, marking as seen');
              // Mark that user has seen the video
              await loginStateService.markInstructionalVideoSeen();
            },
            barrierDismissible: true,
          );
        }
      } else {
        debugPrint(
            '❌ AppShell: Not showing video - shouldShow: $shouldShow, mounted: ${context.mounted}');
      }
    } catch (e) {
      // Silently handle errors - video popup is optional
      debugPrint('❗ Error showing instructional video: $e');
    }
  }

  void _triggerVideoCheckIfNeeded() {
    if (_videoCheckScheduled) return;
    _videoCheckScheduled = true;
    _showInstructionalVideoIfNeeded(context);
  }

  @override
  Widget build(BuildContext context) {
    Performance.trackRebuild('AppShell');

    return Scaffold(
      // Provide AuthBloc, JobBloc, and AccountBloc to descendant pages.
      body: MultiBlocProvider(
        providers: [
          // AuthBloc is already provided at the app root. Reuse that instance.
          BlocProvider<JobBloc>.value(value: _jobBloc),
          BlocProvider<AccountBloc>.value(value: _accountBloc),
          BlocProvider<CatalogRequestsBloc>.value(value: _catalogRequestsBloc),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Check if this is a fresh login and show instructional video
            if (state is AuthAuthenticated && state.isFreshLogin) {
              debugPrint(
                  '🎥 AppShell: Fresh login detected, showing instructional video...');
              _triggerVideoCheckIfNeeded();
              // Register push token after fresh login
              try {
                getIt<PushRegistrationService>().registerIfPossible();
              } catch (_) {}
            } else if (state is AuthAuthenticated && !state.isFreshLogin) {
              debugPrint(
                  '🔄 AppShell: Automatic login detected, skipping video');
              // Ensure token is registered on auto-login as well
              try {
                getIt<PushRegistrationService>().registerIfPossible();
              } catch (_) {}
            }
            // Handle logout - navigate back to sign in page
            else if (state is AuthUnauthenticated) {
              debugPrint('🚪 AppShell: User logged out, navigating to sign in');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignInPage()),
                (route) => false,
              );
            }
          },
          child: Builder(
            builder: (context) => Row(
              children: [
                // Show navigation rail on tablet/desktop
                if (context.isTabletOrDesktop)
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onItemTapped,
                    backgroundColor: Colors.white,
                    selectedIconTheme: const IconThemeData(
                      color: AppColors.orange,
                      size: 28,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: Colors.grey[500],
                      size: 26,
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    labelType: context.isLargeTablet || context.isDesktop
                        ? NavigationRailLabelType.all
                        : NavigationRailLabelType.selected,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore),
                        label: Text('Discover'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.grid_view_outlined),
                        selectedIcon: Icon(Icons.grid_view),
                        label: Text('Catalogue'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.receipt_long_outlined),
                        selectedIcon: Icon(Icons.receipt_long),
                        label: Text('Invoice'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Support'),
                      ),
                    ],
                  ),

                // Vertical divider
                if (context.isTabletOrDesktop)
                  const VerticalDivider(thickness: 1, width: 1),

                // Main content
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children:
                        List.generate(5, (index) => _getPage(index, context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Only show bottom nav on mobile
      bottomNavigationBar: context.isMobile
          ? SafeArea(
              top: false,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xxl)),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 8),
                  child: BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    selectedItemColor: AppColors.orange,
                    unselectedItemColor: Colors.grey[500],
                    selectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.w600),
                    showUnselectedLabels: true,
                    iconSize: 26,
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.home_outlined),
                        activeIcon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: AppColors.softPink,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.home_outlined,
                              color: AppColors.orange),
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.explore_outlined),
                        activeIcon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: AppColors.softPink,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.explore_outlined,
                              color: AppColors.orange),
                        ),
                        label: 'Discover',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.grid_view_outlined),
                        activeIcon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: AppColors.softPink,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.grid_view_outlined,
                              color: AppColors.orange),
                        ),
                        label: 'Catalogue',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.receipt_long_outlined),
                        activeIcon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: AppColors.softPink,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.receipt_long_outlined,
                              color: AppColors.orange),
                        ),
                        label: 'Invoice',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.person_outline),
                        activeIcon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: AppColors.softPink,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.person_outline,
                              color: AppColors.orange),
                        ),
                        label: 'Support',
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
