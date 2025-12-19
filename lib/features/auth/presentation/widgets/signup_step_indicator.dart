import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Step indicator widget for signup page
class SignupStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SignupStepIndicator({
    required this.currentStep,
    this.totalSteps = 4,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final active = i <= currentStep;
          return Expanded(
            child: Container(
              margin: AppSpacing.horizontalXS,
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? context.primaryColor
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
