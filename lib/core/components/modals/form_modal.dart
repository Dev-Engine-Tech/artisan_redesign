import 'package:flutter/material.dart';

/// Reusable form modal for collecting user input
///
/// Usage:
/// ```dart
/// final result = await showFormModal(
///   context: context,
///   title: 'Add Comment',
///   fields: [
///     FormField(
///       label: 'Comment',
///       hint: 'Enter your comment',
///       maxLines: 3,
///     ),
///   ],
///   submitText: 'Submit',
///   onSubmit: (values) {
///     print('Comment: ${values['Comment']}');
///     return true; // Return true to close modal
///   },
/// );
/// ```
Future<Map<String, String>?> showFormModal({
  required BuildContext context,
  required String title,
  required List<FormFieldConfig> fields,
  String submitText = 'Submit',
  String cancelText = 'Cancel',
  required Future<bool> Function(Map<String, String>) onSubmit,
}) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (ctx) => FormModal(
      title: title,
      fields: fields,
      submitText: submitText,
      cancelText: cancelText,
      onSubmit: onSubmit,
    ),
  );
}

class FormModal extends StatefulWidget {
  const FormModal({
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.submitText = 'Submit',
    this.cancelText = 'Cancel',
    super.key,
  });

  final String title;
  final List<FormFieldConfig> fields;
  final String submitText;
  final String cancelText;
  final Future<bool> Function(Map<String, String>) onSubmit;

  @override
  State<FormModal> createState() => _FormModalState();
}

class _FormModalState extends State<FormModal> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _controllers[field.label] = TextEditingController(text: field.initialValue);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final values = <String, String>{};
    for (final entry in _controllers.entries) {
      values[entry.key] = entry.value.text;
    }

    try {
      final shouldClose = await widget.onSubmit(values);
      if (shouldClose && mounted) {
        Navigator.of(context).pop(values);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _controllers[field.label],
                  decoration: InputDecoration(
                    labelText: field.label,
                    hintText: field.hint,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: field.maxLines,
                  keyboardType: field.keyboardType,
                  validator: field.validator,
                  enabled: !_isSubmitting,
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(widget.cancelText),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.submitText),
        ),
      ],
    );
  }
}

/// Configuration for a form field in the modal
class FormFieldConfig {
  const FormFieldConfig({
    required this.label,
    this.hint,
    this.initialValue,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final String? hint;
  final String? initialValue;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
}
