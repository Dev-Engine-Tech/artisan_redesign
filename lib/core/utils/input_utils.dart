import 'package:flutter/services.dart';

class InputUtils {
  static final digitsOnly = FilteringTextInputFormatter.digitsOnly;

  static int parseInt(String? v, {int fallback = 0}) {
    if (v == null) return fallback;
    final cleaned = v.replaceAll(RegExp(r'[^0-9\-]'), '');
    final i = int.tryParse(cleaned);
    if (i != null) return i;
    final d = double.tryParse(cleaned);
    return d?.round() ?? fallback;
  }

  static double parseDouble(String? v, {double fallback = 0}) {
    if (v == null) return fallback;
    final cleaned = v.replaceAll(RegExp(r'[^0-9\.-]'), '');
    return double.tryParse(cleaned) ?? fallback;
  }
}
