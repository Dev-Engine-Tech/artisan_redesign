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
import 'package:artisans_circle/features/account/presentation/bloc/account_bloc.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_requests_bloc.dart';
import 'package:artisans_circle/core/performance/performance_monitor.dart';
// import 'package:artisans_circle/core/analytics/firebase_analytics_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final JobBloc _jobBloc;
  late final AuthBloc _authBloc;
  late final AccountBloc _accountBloc;
  late final CatalogRequestsBloc _catalogRequestsBloc;

  // Pages will be created dynamically to provide proper context
  Widget _getPage(int index, BuildContext context) {
    print('DEBUG: AppShell - _getPage called with index: $index');
    switch (index) {
      case 0:
        print('DEBUG: AppShell - Returning HomePage');
        return const HomePage();
      case 1:
        print('DEBUG: AppShell - Returning DiscoverPage');
        return const DiscoverPage();
      case 2:
        print('DEBUG: AppShell - Returning CatalogPage');
        return const CatalogPage();
      case 3:
        print('DEBUG: AppShell - Returning InvoiceMenuPage');
        // Modern Invoice Menu Page
        return const InvoiceMenuPage();
      case 4:
        print('DEBUG: AppShell - Returning SupportAccountPage');
        return const SupportAccountPage();
      default:
        print('DEBUG: AppShell - Returning default HomePage');
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
    _authBloc = getIt<AuthBloc>();
    _accountBloc = getIt<AccountBloc>();
    _catalogRequestsBloc = getIt<CatalogRequestsBloc>();

    // Track app launch analytics
    // try {
    //   final analyticsService = getIt<AnalyticsService>();
    //   analyticsService.logEvent('app_launched', {
    //     'platform': 'mobile',
    //     'timestamp': DateTime.now().toIso8601String(),
    //   });
    // } catch (e) {
    //   // Analytics failure shouldn't crash the app
    // }
  }

  @override
  void dispose() {
    _jobBloc.close();
    _authBloc.close();
    _accountBloc.close();
    _catalogRequestsBloc.close();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Performance.trackRebuild('AppShell');

    return Scaffold(
      // Provide AuthBloc, JobBloc, and AccountBloc to descendant pages.
      body: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<JobBloc>.value(value: _jobBloc),
          BlocProvider<AccountBloc>.value(value: _accountBloc),
          BlocProvider<CatalogRequestsBloc>.value(value: _catalogRequestsBloc),
        ],
        child: Builder(
          builder: (context) => IndexedStack(
            index: _selectedIndex,
            children: List.generate(5, (index) => _getPage(index, context)),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              showUnselectedLabels: true,
              iconSize: 26,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.home_outlined, color: AppColors.orange),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.explore_outlined),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.explore_outlined, color: AppColors.orange),
                  ),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.grid_view_outlined),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.grid_view_outlined, color: AppColors.orange),
                  ),
                  label: 'Catalogue',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.receipt_long_outlined),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.receipt_long_outlined, color: AppColors.orange),
                  ),
                  label: 'Invoice',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person_outline, color: AppColors.orange),
                  ),
                  label: 'Support',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
