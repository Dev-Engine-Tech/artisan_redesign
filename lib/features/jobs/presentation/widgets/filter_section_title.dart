import 'package:flutter/material.dart';

/// Section title widget for filter page
class FilterSectionTitle extends StatelessWidget {
  final String text;

  const FilterSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
