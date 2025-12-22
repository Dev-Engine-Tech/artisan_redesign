/// Currency formatting utilities to keep NGN formatting consistent (DRY).
class Currency {
  static const String code = 'NGN';

  /// Format a number with thousands separators.
  /// Example: 1234567 -> "1,234,567"
  static String formatNumber(num amount, {int decimalDigits = 0}) {
    final fixed = amount.toStringAsFixed(decimalDigits);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    final formattedInt = intPart.replaceAllMapped(re, (m) => ',');

    return decPart == null || decPart.isEmpty
        ? formattedInt
        : '$formattedInt.$decPart';
  }

  /// Format as "NGN 1,234" (defaults to 0 decimals).
  static String formatNgn(num? amount, {int decimalDigits = 0}) {
    final a = (amount ?? 0);
    return '$code ${formatNumber(a, decimalDigits: decimalDigits)}';
  }

  /// Format a range like "NGN 1,000 - NGN 2,000". If equal, returns single value.
  static String formatNgnRange(num? min, num? max, {int decimalDigits = 0}) {
    final hasMin = min != null && min > 0;
    final hasMax = max != null && max > 0;
    if (hasMin && hasMax) {
      if (min == max) return formatNgn(max, decimalDigits: decimalDigits);
      return '${formatNgn(min, decimalDigits: decimalDigits)} - ${formatNgn(max, decimalDigits: decimalDigits)}';
    }
    if (hasMin) return formatNgn(min, decimalDigits: decimalDigits);
    if (hasMax) return formatNgn(max, decimalDigits: decimalDigits);
    return formatNgn(0);
  }

  /// Format using compact units: NGN 1.5k, NGN 2M, NGN 3B.
  static String formatNgnCompact(num? amount) {
    final a = (amount ?? 0).abs();
    String suffix = '';
    double v = a.toDouble();
    if (a >= 1000000000) {
      v = a / 1000000000;
      suffix = 'B';
    } else if (a >= 1000000) {
      v = a / 1000000;
      suffix = 'M';
    } else if (a >= 1000) {
      v = a / 1000;
      suffix = 'k';
    }

    if (suffix.isEmpty) return formatNgn(a);

    String s = v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
    return '$code $s$suffix';
  }
}
