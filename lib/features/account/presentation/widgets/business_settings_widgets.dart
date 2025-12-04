import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme.dart';
import '../../domain/entities/business_settings.dart';

/// Color picker dialog for selecting hex colors
class ColorPickerDialog extends StatefulWidget {
  final String? initialColor;
  final String title;

  const ColorPickerDialog({
    super.key,
    required this.title,
    this.initialColor,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialColor?.replaceFirst('#', '') ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidHex(String value) {
    if (value.isEmpty) return true;
    final hex = value.replaceFirst('#', '');
    return RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hex);
  }

  Color? _getPreviewColor() {
    final hex = _controller.text.replaceFirst('#', '');
    if (_isValidHex(hex) && hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Hex Color',
              hintText: 'e.g., FF5722 or #FF5722',
              prefixText: '#',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f#]')),
              LengthLimitingTextInputFormatter(7),
            ],
            onChanged: (value) {
              setState(() {
                _error = _isValidHex(value)
                    ? null
                    : 'Invalid hex color (use 6 characters)';
              });
            },
          ),
          const SizedBox(height: 16),
          if (_getPreviewColor() != null) ...[
            const Text('Preview:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: _getPreviewColor(),
                borderRadius: AppRadius.radiusMD,
                border: Border.all(color: AppColors.softBorder),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _error == null
              ? () {
                  final hex = _controller.text.replaceFirst('#', '');
                  Navigator.of(context).pop(hex.isEmpty ? null : '#$hex');
                }
              : null,
          child: const Text('Select'),
        ),
      ],
    );
  }
}

/// Invoice style preview card
class InvoiceStyleCard extends StatelessWidget {
  final InvoiceStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const InvoiceStyleCard({
    super.key,
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  String _getStyleName(InvoiceStyle style) {
    return style.name[0].toUpperCase() + style.name.substring(1);
  }

  IconData _getStyleIcon(InvoiceStyle style) {
    switch (style) {
      case InvoiceStyle.classic:
        return Icons.description_outlined;
      case InvoiceStyle.modern:
        return Icons.auto_awesome_outlined;
      case InvoiceStyle.minimal:
        return Icons.minimize_outlined;
      case InvoiceStyle.professional:
        return Icons.business_center_outlined;
      case InvoiceStyle.creative:
        return Icons.brush_outlined;
      case InvoiceStyle.elegant:
        return Icons.diamond_outlined;
      case InvoiceStyle.bold:
        return Icons.format_bold;
      case InvoiceStyle.corporate:
        return Icons.corporate_fare_outlined;
      case InvoiceStyle.artistic:
        return Icons.palette_outlined;
      case InvoiceStyle.traditional:
        return Icons.history_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: BorderSide(
          color: isSelected ? AppColors.orange : AppColors.softBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLG,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getStyleIcon(style),
                size: 40,
                color: isSelected ? AppColors.orange : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                _getStyleName(style),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.orange : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: AppColors.orange,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Image upload section with preview
class ImageUploadSection extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onUpload;
  final VoidCallback? onRemove;
  final String label;
  final bool isLoading;

  const ImageUploadSection({
    super.key,
    required this.onUpload,
    required this.label,
    this.imageUrl,
    this.onRemove,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (imageUrl != null) ...[
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(color: AppColors.softBorder),
                  image: (imageUrl != null && imageUrl!.trim().startsWith('http'))
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!.trim()),
                          fit: BoxFit.contain,
                        )
                      : null,
                ),
              ),
              if (onRemove != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.close, color: AppColors.cardBackground),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                    onPressed: onRemove,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: isLoading ? null : onUpload,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: Text(imageUrl == null ? 'Upload Logo' : 'Change Logo'),
        ),
      ],
    );
  }
}

/// Color selection card
class ColorSelectionCard extends StatelessWidget {
  final String label;
  final String? hexColor;
  final VoidCallback onTap;

  const ColorSelectionCard({
    super.key,
    required this.label,
    required this.onTap,
    this.hexColor,
  });

  Color? _getColor() {
    if (hexColor == null) return null;
    final hex = hexColor!.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMD,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.softBorder),
          borderRadius: AppRadius.radiusMD,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color ?? AppColors.cardBackground,
                borderRadius: AppRadius.radiusSM,
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: color == null
                  ? Icon(Icons.add, color: AppColors.textSecondary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hexColor ?? 'Not selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Section card wrapper for consistent styling
class SettingsSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: BorderSide(color: AppColors.subtleBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.brownHeader,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
