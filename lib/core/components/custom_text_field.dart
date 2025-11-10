import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Custom text field component that enforces consistent styling across the app.
///
/// This component provides two variants:
/// 1. Filled style with background color and subtle border (default)
/// 2. Outlined style with transparent background and prominent border
///
/// Example usage:
/// ```dart
/// CustomTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   prefixIcon: Icons.email_outlined,
///   controller: emailController,
/// )
/// ```
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? initialValue;

  /// Visual style of the text field
  final CustomTextFieldStyle style;

  /// Whether to show the label above the field
  final bool showLabel;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.style = CustomTextFieldStyle.filled,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: _buildDecoration(context),
    );

    if (showLabel && label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.spaceSM,
          field,
        ],
      );
    }

    return field;
  }

  InputDecoration _buildDecoration(BuildContext context) {
    switch (style) {
      case CustomTextFieldStyle.filled:
        return InputDecoration(
          labelText: showLabel ? null : label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey[400])
              : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.orange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: AppSpacing.paddingLG,
        );

      case CustomTextFieldStyle.outlined:
        return InputDecoration(
          labelText: showLabel ? null : label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: prefixIcon != null
              ? Container(
                  margin: AppSpacing.paddingMD,
                  padding: AppSpacing.paddingSM,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: Icon(
                    prefixIcon,
                    size: 18,
                    color: AppColors.orange,
                  ),
                )
              : null,
          suffixIcon: suffixIcon,
          filled: false,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.orange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: AppSpacing.paddingLG,
        );
    }
  }
}

/// Form field variant with validation support
class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? initialValue;

  /// Validation function
  final String? Function(String?)? validator;

  /// Whether the field is required (adds automatic validation if validator is null)
  final bool required;

  /// Visual style of the text field
  final CustomTextFieldStyle style;

  /// Whether to show the label above the field
  final bool showLabel;

  const CustomTextFormField({
    super.key,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.validator,
    this.required = false,
    this.style = CustomTextFieldStyle.filled,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      initialValue: initialValue,
      validator: validator ?? (required ? _defaultValidator : null),
      decoration: _buildDecoration(context),
    );

    if (showLabel && label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.spaceSM,
          field,
        ],
      );
    }

    return field;
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  InputDecoration _buildDecoration(BuildContext context) {
    switch (style) {
      case CustomTextFieldStyle.filled:
        return InputDecoration(
          labelText: showLabel ? null : label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey[400])
              : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.orange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: AppSpacing.paddingLG,
        );

      case CustomTextFieldStyle.outlined:
        return InputDecoration(
          labelText: showLabel ? null : label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: prefixIcon != null
              ? Container(
                  margin: AppSpacing.paddingMD,
                  padding: AppSpacing.paddingSM,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: Icon(
                    prefixIcon,
                    size: 18,
                    color: AppColors.orange,
                  ),
                )
              : null,
          suffixIcon: suffixIcon,
          filled: false,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.orange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: AppSpacing.paddingLG,
        );
    }
  }
}

enum CustomTextFieldStyle {
  /// Filled background with subtle border
  filled,

  /// Outlined with transparent background
  outlined,
}
