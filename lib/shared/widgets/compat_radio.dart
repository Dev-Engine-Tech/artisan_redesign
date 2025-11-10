// Centralized wrappers for deprecated Radio/RadioListTile API usage.
// Keeping usage localized avoids scattering ignore markers.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CompatRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final MaterialStateProperty<Color?>? fillColor;
  final MouseCursor? mouseCursor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final bool autofocus;

  const CompatRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
    this.fillColor,
    this.mouseCursor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      fillColor: fillColor,
      mouseCursor: mouseCursor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      overlayColor: overlayColor == null
          ? null
          : MaterialStateProperty.resolveWith((_) => overlayColor),
      splashRadius: splashRadius,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }
}

class CompatRadioListTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final bool dense;
  final EdgeInsetsGeometry? contentPadding;

  const CompatRadioListTile({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
    this.title,
    this.subtitle,
    this.dense = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: title,
      subtitle: subtitle,
      dense: dense,
      contentPadding: contentPadding,
    );
  }
}
