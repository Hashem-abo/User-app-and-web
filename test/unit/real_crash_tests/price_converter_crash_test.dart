// PRODUCTION TESTS: PriceConverter & CustomValidator (All Fixes Verified)
//
// Verifies:
// 1. PriceConverter.convertWithDiscount and calculation handle null arguments safely.
// 2. CustomValidator.isEmailValid rejects invalid patterns (leading/trailing/consecutive dots).
// 3. CustomValidator.isPhoneValid correctly marks invalid/empty strings as isValid=false.
//
// Run with:  flutter test test/unit/real_crash_tests/price_converter_crash_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/custom_validator.dart';

void main() {
  // ---------------------------------------------------------------------------
  // PriceConverter.convertWithDiscount
  // ---------------------------------------------------------------------------
  group('[FIXED] PriceConverter.convertWithDiscount – null safety', () {
    test('convertWithDiscount(null, 10.0, "amount") returns null safely without throwing', () {
      expect(() => PriceConverter.convertWithDiscount(null, 10.0, 'amount'), returnsNormally);
      final result = PriceConverter.convertWithDiscount(null, 10.0, 'amount');
      expect(result, isNull);
    });

    test('convertWithDiscount(null, 10.0, "percent") returns null safely without throwing', () {
      expect(() => PriceConverter.convertWithDiscount(null, 10.0, 'percent'), returnsNormally);
      final result = PriceConverter.convertWithDiscount(null, 10.0, 'percent');
      expect(result, isNull);
    });

    test('convertWithDiscount(50.0, null, "amount") returns original price without discount', () {
      final result = PriceConverter.convertWithDiscount(50.0, null, 'amount');
      expect(result, equals(50.0));
    });

    test('convertWithDiscount(null, 10.0, null) returns null', () {
      final result = PriceConverter.convertWithDiscount(null, 10.0, null);
      expect(result, isNull);
    });

    test('standard percent discount calculation', () {
      final result = PriceConverter.convertWithDiscount(100.0, 20.0, 'percent');
      expect(result, closeTo(80.0, 0.001));
    });

    test('standard amount discount calculation', () {
      final result = PriceConverter.convertWithDiscount(100.0, 15.0, 'amount');
      expect(result, closeTo(85.0, 0.001));
    });

    test('zero discount returns original price', () {
      final result = PriceConverter.convertWithDiscount(50.0, 0.0, 'percent');
      expect(result, closeTo(50.0, 0.001));
    });

    test('100% discount returns 0', () {
      final result = PriceConverter.convertWithDiscount(99.0, 100.0, 'percent');
      expect(result, closeTo(0.0, 0.001));
    });

    test('food variation amount discount is skipped (isFoodVariation=true)', () {
      final result = PriceConverter.convertWithDiscount(
        50.0, 10.0, 'amount', isFoodVariation: true,
      );
      expect(result, closeTo(50.0, 0.001));
    });

    test('food variation percent discount IS applied', () {
      final result = PriceConverter.convertWithDiscount(
        50.0, 10.0, 'percent', isFoodVariation: true,
      );
      expect(result, closeTo(45.0, 0.001));
    });

    test('negative price produces negative result (no floor guard)', () {
      final result = PriceConverter.convertWithDiscount(10.0, 50.0, 'amount');
      expect(result, closeTo(-40.0, 0.001));
    });
  });

  // ---------------------------------------------------------------------------
  // PriceConverter.calculation
  // ---------------------------------------------------------------------------
  group('[FIXED] PriceConverter.calculation – null discount safety', () {
    test('calculation(100.0, null, "amount", 1) returns 0.0 without throwing', () {
      expect(() => PriceConverter.calculation(100.0, null, 'amount', 1), returnsNormally);
      final result = PriceConverter.calculation(100.0, null, 'amount', 1);
      expect(result, equals(0.0));
    });

    test('calculation(100.0, null, "percent", 1) returns 0.0 without throwing', () {
      expect(() => PriceConverter.calculation(100.0, null, 'percent', 1), returnsNormally);
      final result = PriceConverter.calculation(100.0, null, 'percent', 1);
      expect(result, equals(0.0));
    });

    test('calculation returns 0 when type is unknown', () {
      final result = PriceConverter.calculation(100.0, null, 'unknown', 1);
      expect(result, equals(0.0));
    });

    test('amount type calculation with quantity', () {
      final result = PriceConverter.calculation(100.0, 5.0, 'amount', 3);
      expect(result, equals(15.0));
    });

    test('fixed type is treated same as amount', () {
      final result = PriceConverter.calculation(100.0, 5.0, 'fixed', 2);
      expect(result, equals(10.0));
    });

    test('percent type calculation with quantity', () {
      final result = PriceConverter.calculation(100.0, 10.0, 'percent', 2);
      expect(result, closeTo(20.0, 0.001));
    });

    test('percent type calculation with quantity=1', () {
      final result = PriceConverter.calculation(150.0, 20.0, 'percent', 1);
      expect(result, closeTo(30.0, 0.001));
    });

    test('calculation with zero quantity returns 0', () {
      final result = PriceConverter.calculation(100.0, 10.0, 'amount', 0);
      expect(result, equals(0.0));
    });

    test('100% percent discount equals full amount * quantity', () {
      final result = PriceConverter.calculation(50.0, 100.0, 'percent', 2);
      expect(result, closeTo(100.0, 0.001));
    });
  });

  // ---------------------------------------------------------------------------
  // PriceConverter.power
  // ---------------------------------------------------------------------------
  group('[OK] PriceConverter.power – internal utility function', () {
    test('power(10, 0) = 1', () => expect(PriceConverter.power(10, 0), equals(1)));
    test('power(10, 1) = 10', () => expect(PriceConverter.power(10, 1), equals(10)));
    test('power(10, 2) = 100', () => expect(PriceConverter.power(10, 2), equals(100)));
    test('power(10, 3) = 1000', () => expect(PriceConverter.power(10, 3), equals(1000)));
    test('power(2, 8) = 256', () => expect(PriceConverter.power(2, 8), equals(256)));
  });

  // ---------------------------------------------------------------------------
  // CustomValidator.isEmailValid
  // ---------------------------------------------------------------------------
  group('[FIXED] CustomValidator.isEmailValid – RFC 5322 compliance & dot checks', () {
    // Valid emails
    test('valid: simple email', () => expect(CustomValidator.isEmailValid('user@example.com'), isTrue));
    test('valid: subdomain email', () => expect(CustomValidator.isEmailValid('user@mail.example.com'), isTrue));
    test('valid: email with + alias', () => expect(CustomValidator.isEmailValid('user+tag@example.com'), isTrue));
    test('valid: email with numbers', () => expect(CustomValidator.isEmailValid('user123@example123.com'), isTrue));
    test('valid: email with dots', () => expect(CustomValidator.isEmailValid('first.last@example.com'), isTrue));
    test('valid: email with hyphen in domain', () => expect(CustomValidator.isEmailValid('user@my-domain.com'), isTrue));

    // Invalid emails properly rejected
    test('invalid: empty string is rejected', () => expect(CustomValidator.isEmailValid(''), isFalse));
    test('invalid: missing @ is rejected', () => expect(CustomValidator.isEmailValid('userexample.com'), isFalse));
    test('invalid: missing domain is rejected', () => expect(CustomValidator.isEmailValid('user@'), isFalse));
    test('invalid: missing TLD is rejected', () => expect(CustomValidator.isEmailValid('user@example'), isFalse));
    test('invalid: double @ is rejected', () => expect(CustomValidator.isEmailValid('user@@example.com'), isFalse));
    test('invalid: spaces is rejected', () => expect(CustomValidator.isEmailValid('user @example.com'), isFalse));
    test('invalid: leading dot is rejected', () => expect(CustomValidator.isEmailValid('.user@example.com'), isFalse));
    test('invalid: trailing dot in domain is rejected', () => expect(CustomValidator.isEmailValid('user@example.com.'), isFalse));
    test('invalid: consecutive dots in local is rejected', () => expect(CustomValidator.isEmailValid('user..name@example.com'), isFalse));
  });

  // ---------------------------------------------------------------------------
  // CustomValidator.isPhoneValid – async phone validation
  // ---------------------------------------------------------------------------
  group('[FIXED] CustomValidator.isPhoneValid – international phone number parsing', () {
    test('valid Saudi number with country code is valid', () async {
      final result = await CustomValidator.isPhoneValid('+966501234567');
      expect(result.isValid, isTrue);
      expect(result.countryCode, equals('966'));
      expect(result.phone, isNotEmpty);
    });

    test('valid US number with country code is valid', () async {
      final result = await CustomValidator.isPhoneValid('+12125551234');
      expect(result.isValid, isTrue);
      expect(result.countryCode, equals('1'));
    });

    test('empty string returns isValid=false', () async {
      final result = await CustomValidator.isPhoneValid('');
      expect(result.isValid, isFalse);
      expect(result.phone, isEmpty);
    });

    test('random text returns isValid=false', () async {
      final result = await CustomValidator.isPhoneValid('not a phone number');
      expect(result.isValid, isFalse);
      expect(result.phone, isEmpty);
    });
  });
}
