import 'package:flutter/material.dart';
import '../../domain/entities/client_profile.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';

class ClientInfoCard extends StatelessWidget {
  final ClientInfo client;

  const ClientInfoCard({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio section
          if (client.bio != null && client.bio!.isNotEmpty) ...[
            Text(
              'About',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AppSpacing.spaceXS,
            Text(
              client.bio!,
              style: const TextStyle(
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            AppSpacing.spaceMD,
          ],

          // Contact information
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.spaceXS,

          if (client.email.isNotEmpty)
            _buildInfoRow(Icons.email_outlined, client.email),

          if (client.phone != null && client.phone!.isNotEmpty)
            _buildInfoRow(Icons.phone_outlined, client.phone!),

          if (client.location.isNotEmpty)
            _buildInfoRow(Icons.location_on_outlined, client.location),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
