import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Shared status badge widget following DRY principle
/// Use this instead of creating status badges repeatedly across the codebase
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final StatusBadgeType? type;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    required this.label,
    super.key,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.type,
    this.fontSize,
    this.padding,
  });

  /// Create a success badge (green)
  factory StatusBadge.success({
    required String label,
    IconData? icon,
  }) {
    return StatusBadge(
      label: label,
      type: StatusBadgeType.success,
      icon: icon ?? Icons.check_circle,
    );
  }

  /// Create an error badge (red)
  factory StatusBadge.error({
    required String label,
    IconData? icon,
  }) {
    return StatusBadge(
      label: label,
      type: StatusBadgeType.error,
      icon: icon ?? Icons.error,
    );
  }

  /// Create a warning badge (orange)
  factory StatusBadge.warning({
    required String label,
    IconData? icon,
  }) {
    return StatusBadge(
      label: label,
      type: StatusBadgeType.warning,
      icon: icon ?? Icons.warning,
    );
  }

  /// Create an info badge (blue)
  factory StatusBadge.info({
    required String label,
    IconData? icon,
  }) {
    return StatusBadge(
      label: label,
      type: StatusBadgeType.info,
      icon: icon ?? Icons.info,
    );
  }

  /// Create a pending badge (grey)
  factory StatusBadge.pending({
    required String label,
    IconData? icon,
  }) {
    return StatusBadge(
      label: label,
      type: StatusBadgeType.pending,
      icon: icon ?? Icons.schedule,
    );
  }

  /// Create a primary badge (app primary color)
  factory StatusBadge.primary({
    required String label,
    IconData? icon,
  }) {
    return StatusBadge(
      label: label,
      type: StatusBadgeType.primary,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on type
    Color bgColor = backgroundColor ?? _getBackgroundColor();
    Color txtColor = textColor ?? _getTextColor();

    return Container(
      padding: padding ?? AppSpacing.paddingSM,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusMD,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize ?? 14,
              color: txtColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: txtColor,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case StatusBadgeType.success:
        return Colors.green.shade100;
      case StatusBadgeType.error:
        return Colors.red.shade100;
      case StatusBadgeType.warning:
        return Colors.orange.shade100;
      case StatusBadgeType.info:
        return Colors.blue.shade100;
      case StatusBadgeType.pending:
        return Colors.grey.shade200;
      case StatusBadgeType.primary:
        return AppColors.badgeBackground;
      case null:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case StatusBadgeType.success:
        return Colors.green.shade800;
      case StatusBadgeType.error:
        return Colors.red.shade800;
      case StatusBadgeType.warning:
        return Colors.orange.shade800;
      case StatusBadgeType.info:
        return Colors.blue.shade800;
      case StatusBadgeType.pending:
        return Colors.grey.shade700;
      case StatusBadgeType.primary:
        return AppColors.orange;
      case null:
        return Colors.grey.shade700;
    }
  }
}

/// Status badge types for easy identification
enum StatusBadgeType {
  success,
  error,
  warning,
  info,
  pending,
  primary,
}

/// Extension to create status badges from job/order status strings
extension StatusBadgeExtension on String {
  /// Convert a status string to a StatusBadge
  StatusBadge toStatusBadge() {
    final status = toLowerCase();

    if (status.contains('complete') ||
        status.contains('success') ||
        status.contains('approve') ||
        status.contains('accept')) {
      return StatusBadge.success(label: this);
    } else if (status.contains('error') ||
        status.contains('fail') ||
        status.contains('reject') ||
        status.contains('cancel')) {
      return StatusBadge.error(label: this);
    } else if (status.contains('warn') || status.contains('review')) {
      return StatusBadge.warning(label: this);
    } else if (status.contains('pending') ||
        status.contains('wait') ||
        status.contains('progress')) {
      return StatusBadge.pending(label: this);
    } else {
      return StatusBadge.info(label: this);
    }
  }
}
