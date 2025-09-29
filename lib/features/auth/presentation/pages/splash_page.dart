import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_event.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_state.dart';
import 'package:artisans_circle/features/auth/presentation/pages/sign_in_page.dart';
import 'package:artisans_circle/core/app_shell.dart';

/// Simple splash/loading screen that dispatches an auth check and then routes
/// based on the result. Designed to be visually appealing and brandable.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Trigger auth check after a short delay to allow splash animation.
    Timer(const Duration(milliseconds: 300), () {
      try {
        context.read<AuthBloc>().add(AuthCheckRequested());
      } catch (_) {
        // If no AuthBloc is available, ignore - host will handle navigation.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state and route accordingly.
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // If authenticated, go to app shell (home)
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
        } else if (state is AuthUnauthenticated) {
          // If not authenticated, show sign in page
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => const SignInPage()));
        } else if (state is AuthError) {
          // On error fallback to sign in page
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => const SignInPage()));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Placeholder logo
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                  child: Icon(Icons.handshake_outlined, size: 56, color: Color(0xFF2E3A59))),
            ),
            const SizedBox(height: 18),
            const Text('Artisans Circle',
                style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2E3A59))),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 72.0),
              child: Text(
                'Empowering artisans, connecting skills and projects.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ]),
        ),
      ),
    );
  }
}
