import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/components/components.dart';
import '../../../../core/theme.dart';
import '../../../../core/di.dart';
import '../../domain/repositories/client_repository.dart';
import '../bloc/client_profile_bloc.dart';
import '../bloc/client_profile_event.dart';
import '../bloc/client_profile_state.dart';
import '../widgets/client_profile_header.dart';
import '../widgets/client_info_card.dart';
import '../widgets/client_rating_stats.dart';
import '../widgets/client_review_item.dart';
import '../widgets/client_jobs_section.dart';

class ClientProfilePage extends StatelessWidget {
  final int clientId;

  const ClientProfilePage({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClientProfileBloc(
        repository: getIt<ClientRepository>(),
      )..add(LoadClientProfile(clientId: clientId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Client Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<ClientProfileBloc, ClientProfileState>(
          builder: (context, state) {
            if (state is ClientProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ClientProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
                        AppSpacing.spaceSM,
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.spaceLG,
                        PrimaryButton(
                          text: 'Retry',
                          onPressed: () {
                            context.read<ClientProfileBloc>().add(
                              LoadClientProfile(clientId: clientId),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is ClientProfileLoaded) {
              final profile = state.profile;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ClientProfileBloc>().add(
                    LoadClientProfile(clientId: clientId),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header with avatar, name, occupation, rating
                    ClientProfileHeader(client: profile.client),
                    AppSpacing.spaceLG,

                    // Client info card (bio, location, contact)
                    if (profile.client.bio != null ||
                        profile.client.location.isNotEmpty ||
                        profile.client.email.isNotEmpty)
                      ClientInfoCard(client: profile.client),

                    if (profile.client.bio != null ||
                        profile.client.location.isNotEmpty ||
                        profile.client.email.isNotEmpty)
                      AppSpacing.spaceLG,

                    // Rating stats
                    ClientRatingStats(ratingStats: profile.ratingStats),
                    AppSpacing.spaceLG,

                    // Recent reviews section
                    if (profile.recentReviews.isNotEmpty) ...[
                      Text(
                        'Recent Reviews',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.spaceSM,
                      ...profile.recentReviews.map((review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ClientReviewItem(review: review),
                      )),
                      AppSpacing.spaceLG,
                    ],

                    // Jobs section
                    ClientJobsSection(jobs: profile.jobs),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
