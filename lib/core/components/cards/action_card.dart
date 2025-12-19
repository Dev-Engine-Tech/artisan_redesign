import 'package:flutter/material.dart';
import 'package:artisans_circle/core/components/cards/app_card.dart';

/// Action card for displaying content with action buttons
///
/// Commonly used for items that require user actions (approve/reject, accept/decline, etc.)
///
/// Usage:
/// ```dart
/// ActionCard(
///   title: 'Job Invitation',
///   content: Text('Description here'),
///   primaryAction: ActionButton(
///     label: 'Accept',
///     onPressed: () => print('Accepted'),
///   ),
///   secondaryAction: ActionButton(
///     label: 'Decline',
///     onPressed: () => print('Declined'),
///     isDestructive: true,
///   ),
/// )
/// ```
class ActionCard extends StatelessWidget {
  const ActionCard({
    required this.content,
    this.title,
    this.primaryAction,
    this.secondaryAction,
    this.onTap,
    this.leading,
    super.key,
  });

  /// Optional title at the top
  final String? title;

  /// Main content of the card
  final Widget content;

  /// Optional leading widget (e.g., image, icon)
  final Widget? leading;

  /// Primary action button
  final ActionButton? primaryAction;

  /// Secondary action button
  final ActionButton? secondaryAction;

  /// Callback when card body is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (title != null) const SizedBox(height: 12),
          if (leading != null) ...[
            leading!,
            const SizedBox(height: 12),
          ],
          content,
          if (primaryAction != null || secondaryAction != null) ...[
            const SizedBox(height: 16),
            _buildActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final hasBothActions = primaryAction != null && secondaryAction != null;

    return Row(
      children: [
        if (secondaryAction != null)
          Expanded(
            child: _buildActionButton(
              context,
              secondaryAction!,
              isSecondary: true,
            ),
          ),
        if (hasBothActions) const SizedBox(width: 12),
        if (primaryAction != null)
          Expanded(
            child: _buildActionButton(context, primaryAction!),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ActionButton action, {
    bool isSecondary = false,
  }) {
    final theme = Theme.of(context);
    final backgroundColor = action.isDestructive
        ? theme.colorScheme.error
        : isSecondary
            ? Colors.transparent
            : theme.colorScheme.primary;

    final foregroundColor = action.isDestructive
        ? theme.colorScheme.onError
        : isSecondary
            ? theme.colorScheme.primary
            : theme.colorScheme.onPrimary;

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: action.isLoading ? null : action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: isSecondary ? 0 : 2,
          side: isSecondary
              ? BorderSide(color: theme.colorScheme.primary)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: action.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Text(action.label),
      ),
    );
  }
}

/// Configuration for an action button
class ActionButton {
  const ActionButton({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isLoading;
}
