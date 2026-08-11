import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';

void main() {
  group('PRODUCTION HELPER SUITE: PriceConverter Edge Cases', () {
    test('power should compute exponents correctly', () {
      expect(PriceConverter.power(10, 0), equals(1));
      expect(PriceConverter.power(10, 2), equals(100));
      expect(PriceConverter.power(2, 4), equals(16));
    });

    test('calculation should calculate fixed amount discounts', () {
      final amount = PriceConverter.calculation(100.0, 10.0, 'amount', 2);
      expect(amount, equals(20.0));
    });

    test('calculation should calculate percent discounts', () {
      final amount = PriceConverter.calculation(100.0, 20.0, 'percent', 2);
      expect(amount, equals(40.0)); // (20 / 100) * (100 * 2) = 40
    });

    test('convertWithDiscount should discount percentage correctly', () {
      final result = PriceConverter.convertWithDiscount(200.0, 25.0, 'percent');
      expect(result, equals(150.0));
    });

    test('convertWithDiscount should discount amount correctly', () {
      final result = PriceConverter.convertWithDiscount(200.0, 30.0, 'amount');
      expect(result, equals(170.0));
    });
  });

  group('PRODUCTION HELPER SUITE: DateConverter Formats & Timestamps', () {
    test('formatDate should format DateTime to standard timestamp', () {
      final dt = DateTime(2026, 8, 11, 15, 45, 0);
      final formatted = DateConverter.formatDate(dt);
      expect(formatted, contains('2026-08-11'));
    });

    test('dateToDate should format yyyy-MM-dd', () {
      final dt = DateTime(2026, 12, 31);
      expect(DateConverter.dateToDate(dt), equals('2026-12-31'));
    });

    test('dateToReadableDate should format dd MMM, yyy', () {
      final dt = DateTime(2026, 1, 1);
      expect(DateConverter.dateToReadableDate(dt), equals('01 Jan, 2026'));
    });

    test('localDateToIsoString should format ISO 8601 string', () {
      final dt = DateTime(2026, 8, 11, 9, 30, 0, 100);
      final iso = DateConverter.localDateToIsoString(dt);
      expect(iso, equals('2026-08-11T09:30:00.100'));
    });

    test('convertFromMinute should format min/hour/day/week/month/year ranges', () {
      expect(DateConverter.convertFromMinute(15, 30), contains('15-30'));
      expect(DateConverter.convertFromMinute(120, 240), contains('2-4'));
      expect(DateConverter.convertFromMinute(2880, 5760), contains('2-4'));
    });

    test('isBeforeTime should check past dates correctly', () {
      const pastDate = '2020-01-01 12:00:00';
      expect(DateConverter.isBeforeTime(pastDate), isTrue);
    });
  });

  group('PRODUCTION HELPER SUITE: ResponsiveHelper Environment Checks', () {
    test('isWeb should return false in Dart VM unit test environment', () {
      expect(ResponsiveHelper.isWeb(), isFalse);
    });

    test('isMobilePhone should return true in VM environment', () {
      expect(ResponsiveHelper.isMobilePhone(), isTrue);
    });
  });
}
