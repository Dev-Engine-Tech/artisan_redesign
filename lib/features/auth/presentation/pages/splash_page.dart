import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_event.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'package:artisans_circle/features/auth/presentation/pages/sign_in_page.dart';
import 'package:artisans_circle/core/app_shell.dart';
import 'package:artisans_circle/core/theme.dart';

/// Splash screen with "Get Started" design that dispatches auth check
/// and routes based on result or shows login when "Get Started" is tapped
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showGetStarted = false;

  @override
  void initState() {
    super.initState();
    // Show splash animation first, then check auth
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showGetStarted = true);
      }
    });

    // Trigger auth check after a delay to allow splash animation
    Timer(const Duration(milliseconds: 800), () {
      try {
        context.read<AuthBloc>().add(AuthCheckRequested());
      } catch (_) {
        // If no AuthBloc is available, ignore - host will handle navigation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state and route accordingly
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // If authenticated, go to app shell (home)
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AppShell()));
        } else if (state is AuthUnauthenticated) {
          // Stay on splash page to show "Get Started" - user can tap to proceed
        } else if (state is AuthError) {
          // On error stay on splash page
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?auto=format&fit=crop&w=1471&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Dark overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Back arrow (top left)
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: AppRadius.radiusLG,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Modal-style content overlay
                    AnimatedOpacity(
                      opacity: _showGetStarted ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: AppSpacing.paddingXXXL,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: AppRadius.radiusXXXL,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // App title
                            const Text(
                              'Showcase Your Skills\nand Grow Your\nCraft Business',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),

                            AppSpacing.spaceLG,

                            // Subtitle
                            Text(
                              'Join a community of skilled artisans. Find new clients, showcase your portfolio, and build your reputation in the craft industry.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),

                            AppSpacing.spaceXXXL,

                            // Get Started button
                            PrimaryButton(
                              text: 'Join the Circle',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const SignInPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
