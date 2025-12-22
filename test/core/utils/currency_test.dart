import 'package:flutter_test/flutter_test.dart';
import 'package:artisans_circle/core/utils/currency.dart';

void main() {
  group('Currency.formatNumber', () {
    test('adds thousands separators', () {
      expect(Currency.formatNumber(0), '0');
      expect(Currency.formatNumber(12), '12');
      expect(Currency.formatNumber(1234), '1,234');
      expect(Currency.formatNumber(1234567), '1,234,567');
    });

    test('respects decimal digits', () {
      expect(Currency.formatNumber(12.3, decimalDigits: 2), '12.30');
      expect(Currency.formatNumber(1234.567, decimalDigits: 1), '1,234.6');
    });
  });

  group('Currency.formatNgn', () {
    test('prefixes NGN and formats number', () {
      expect(Currency.formatNgn(0), 'NGN 0');
      expect(Currency.formatNgn(1234), 'NGN 1,234');
    });

    test('supports decimals when requested', () {
      expect(Currency.formatNgn(12.3, decimalDigits: 2), 'NGN 12.30');
    });
  });

  group('Currency.formatNgnRange', () {
    test('single value when equal', () {
      expect(Currency.formatNgnRange(1000, 1000), 'NGN 1,000');
    });
    test('min-max when different', () {
      expect(Currency.formatNgnRange(1000, 2500), 'NGN 1,000 - NGN 2,500');
    });
    test('handles null min or max', () {
      expect(Currency.formatNgnRange(null, 1500), 'NGN 1,500');
      expect(Currency.formatNgnRange(1500, null), 'NGN 1,500');
      expect(Currency.formatNgnRange(null, null), 'NGN 0');
    });
  });

  group('Currency.formatNgnCompact', () {
    test('formats in k/M/B units', () {
      expect(Currency.formatNgnCompact(999), 'NGN 999');
      expect(Currency.formatNgnCompact(1000), 'NGN 1k');
      expect(Currency.formatNgnCompact(1500), 'NGN 1.5k');
      expect(Currency.formatNgnCompact(1000000), 'NGN 1M');
      expect(Currency.formatNgnCompact(1250000), 'NGN 1.3M');
      expect(Currency.formatNgnCompact(1000000000), 'NGN 1B');
    });
  });
}

