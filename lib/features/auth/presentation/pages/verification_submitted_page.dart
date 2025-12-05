import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/core/app_shell.dart';

class VerificationSubmittedPage extends StatelessWidget {
  const VerificationSubmittedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: context.lightPeachColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 48),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [colorScheme.tertiary, colorScheme.tertiary.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                ),
                child: Center(
                  child: Icon(Icons.check, size: 72, color: colorScheme.onPrimary),
                ),
              ),
              const SizedBox(height: 28),
              Text('Congratulations!',
                  style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28)),
              AppSpacing.spaceMD,
              Text(
                'Your documents are under review. You will be notified about the status within the next 24 hours.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  // Navigate to app home and remove previous routes so the flow doesn't flash back.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AppShell()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
