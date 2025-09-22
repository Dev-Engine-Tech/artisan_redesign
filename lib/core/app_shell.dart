import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/home/presentation/pages/home_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/discover_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/projects_page.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/messages/presentation/pages/messages_flow.dart';
import 'package:artisans_circle/features/messages/presentation/bloc/conversations_bloc.dart';
import 'package:artisans_circle/features/messages/domain/repositories/messages_repository.dart';
import 'package:artisans_circle/features/account/presentation/pages/account_page.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_bloc.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  JobBloc? _jobBloc;

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
        // Provide ConversationsBloc for MessagesListPage
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;
        final currentUserId = authState is AuthAuthenticated && authState.user.id != null ? authState.user.id! : 1;
        final messagesRepository = getIt<MessagesRepository>();
        
        return BlocProvider(
          create: (_) => ConversationsBloc(
            repository: messagesRepository,
            currentUserId: currentUserId,
          ),
          child: MessagesListPage(),
        );
      case 4:
        return const SupportAccountPage();
      default:
        return const HomePage();
    }
  }

  @override
  void initState() {
    super.initState();
    // debug log removed for production analyzer cleanliness
    _jobBloc = getIt<JobBloc>();
  }

  @override
  void dispose() {
    _jobBloc?.close();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobBloc = _jobBloc ??= getIt<JobBloc>();
    final authBloc = getIt<AuthBloc>();
    final accountBloc = getIt<AccountBloc>();
    // debug log removed for production analyzer cleanliness
    return Scaffold(
      // Provide AuthBloc, JobBloc, and AccountBloc to descendant pages.
      body: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<JobBloc>.value(value: jobBloc),
          BlocProvider<AccountBloc>.value(value: accountBloc),
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
                  icon: const Icon(Icons.chat_bubble_outline),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.softPink,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.chat_bubble_outline,
                        color: AppColors.orange),
                  ),
                  label: 'Message',
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
      ),
    );
  }
}
