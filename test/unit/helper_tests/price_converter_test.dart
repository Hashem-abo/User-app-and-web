import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/helper/price_converter.dart';

void main() {
  group('PriceConverter - Standard Logic', () {
    test('power calculates integer exponentiation correctly', () {
      expect(PriceConverter.power(10, 0), equals(1));
      expect(PriceConverter.power(10, 2), equals(100));
      expect(PriceConverter.power(2, 5), equals(32));
    });

    test('calculation calculates fixed discount correctly', () {
      final discount = PriceConverter.calculation(100, 10, 'amount', 2);
      expect(discount, equals(20.0));
    });

    test('calculation calculates percentage discount correctly', () {
      final discount = PriceConverter.calculation(100, 15, 'percent', 2);
      expect(discount, equals(30.0)); // (15 / 100) * (100 * 2) = 30
    });

    test('convertWithDiscount calculates percentage discount', () {
      final result = PriceConverter.convertWithDiscount(100, 20, 'percent');
      expect(result, equals(80.0));
    });

    test('convertWithDiscount calculates fixed amount discount', () {
      final result = PriceConverter.convertWithDiscount(100, 15, 'amount');
      expect(result, equals(85.0));
    });
  });

  group('PriceConverter - Null Check & Exception Traps (Fixed)', () {
    test('convertWithDiscount with null price returns null safely', () {
      expect(() => PriceConverter.convertWithDiscount(null, 10, 'amount'), returnsNormally);
      expect(PriceConverter.convertWithDiscount(null, 10, 'amount'), isNull);
    });

    test('convertWithDiscount with null discount returns original price safely', () {
      expect(() => PriceConverter.convertWithDiscount(100, null, 'amount'), returnsNormally);
      expect(PriceConverter.convertWithDiscount(100, null, 'amount'), equals(100.0));
    });

    test('calculation with null discount returns 0.0 safely', () {
      expect(() => PriceConverter.calculation(100, null, 'amount', 1), returnsNormally);
      expect(PriceConverter.calculation(100, null, 'amount', 1), equals(0.0));
    });
  });
}
