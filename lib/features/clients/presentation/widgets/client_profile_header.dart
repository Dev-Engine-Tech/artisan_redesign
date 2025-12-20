import 'package:flutter/material.dart';
import '../../domain/entities/client_profile.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../../../core/image_url.dart';

class ClientProfileHeader extends StatelessWidget {
  final ClientInfo client;

  const ClientProfileHeader({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = sanitizeImageUrl(client.profilePic);
    final hasAvatar = avatarUrl.startsWith('http');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.orange.withValues(alpha: 0.1),
          backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
          child: !hasAvatar
              ? const Icon(
                  Icons.person,
                  color: AppColors.orange,
                  size: 40,
                )
              : null,
        ),
        AppSpacing.spaceMD,

        // Name, occupation, location
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.fullName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (client.occupation != null && client.occupation!.isNotEmpty) ...[
                AppSpacing.spaceXS,
                Text(
                  client.occupation!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              if (client.location.isNotEmpty) ...[
                AppSpacing.spaceXS,
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        client.location,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
