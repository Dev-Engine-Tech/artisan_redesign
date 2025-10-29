import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/auth/presentation/pages/identity_verification_page.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/verification_cubit.dart';
import 'package:artisans_circle/features/account/presentation/pages/account_page.dart';

class ProfileActionButtons extends StatelessWidget {
  final double profileProgress;
  final bool isVerified;

  const ProfileActionButtons({
    super.key,
    required this.profileProgress,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Complete profile banner
        if (profileProgress < 1.0)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: OutlinedAppButton(
              text: 'Complete your profile',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SupportAccountPage(),
                  ),
                );
              },
            ),
          ),

        // Verification banner
        if (!isVerified)
          Container(
            margin: EdgeInsets.fromLTRB(
              16,
              profileProgress < 1.0 ? 0 : 0,
              16,
              20,
            ),
            child: OutlinedAppButton(
              text: 'Verify your account',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => VerificationCubit(),
                      child: const IdentityVerificationPage(),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
