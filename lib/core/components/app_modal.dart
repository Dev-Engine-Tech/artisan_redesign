import 'package:flutter/material.dart';
import '../theme.dart';

/// Shows a standardized bottom sheet modal
///
/// Example:
/// ```dart
/// AppBottomSheet.show(
///   context: context,
///   title: 'Select Customer',
///   child: CustomerList(),
/// );
/// ```
class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    EdgeInsetsGeometry? padding,
    bool showDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheetContent(
        title: title,
        height: height,
        padding: padding,
        showDragHandle: showDragHandle,
        child: child,
      ),
    );
  }
}

/// Bottom sheet content widget with consistent styling
class AppBottomSheetContent extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool showDragHandle;

  const AppBottomSheetContent({
    required this.child,
    super.key,
    this.title,
    this.height,
    this.padding,
    this.showDragHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max,
          children: [
            // Drag handle
            if (showDragHandle)
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

            // Title
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownHeader,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Flexible(
              child: Padding(
                padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-page modal wrapper (for complex modals like agreements, progress submissions, etc.)
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     fullscreenDialog: true,
///     builder: (context) => AppModal(
///       title: 'Agreement Details',
///       child: AgreementContent(),
///     ),
///   ),
/// );
/// ```
class AppModal extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? padding;

  const AppModal({
    required this.title,
    required this.child,
    super.key,
    this.actions,
    this.showCloseButton = true,
    this.onClose,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: showCloseButton
            ? IconButton(
                icon: Icon(Icons.close,
                    color: colorScheme.onSurface.withValues(alpha: 0.87)),
                onPressed: onClose ?? () => Navigator.pop(context),
              )
            : null,
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: padding ?? AppSpacing.paddingXXL,
              child: child,
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            Container(
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}

/// Simple modal bottom sheet for quick actions
///
/// Example:
/// ```dart
/// QuickActionSheet.show(
///   context: context,
///   title: 'Choose Action',
///   actions: [
///     QuickAction(
///       icon: Icons.edit,
///       label: 'Edit',
///       onTap: () => _handleEdit(),
///     ),
///     QuickAction(
///       icon: Icons.delete,
///       label: 'Delete',
///       onTap: () => _handleDelete(),
///       isDestructive: true,
///     ),
///   ],
/// );
/// ```
class QuickActionSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required List<QuickAction> actions,
    String? title,
    bool showCancelButton = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                // Actions
                ...actions.map((action) => _buildActionTile(context, action)),

                // Cancel button
                if (showCancelButton) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ],

                AppSpacing.spaceSM,
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildActionTile(BuildContext context, QuickAction action) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        action.icon,
        color: action.isDestructive ? colorScheme.error : colorScheme.primary,
      ),
      title: Text(
        action.label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: action.isDestructive
              ? colorScheme.error
              : colorScheme.onSurface.withValues(alpha: 0.87),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        action.onTap();
      },
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}
