import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';

void main() {
  group('PRODUCTION CRITICAL ISSUE 1: OrderModel Crashes on Null Optional Financial Fields', () {
    test('OrderModel.fromJson should parse valid order when coupon_discount_amount is null', () {
      final jsonResponse = {
        'id': 101,
        'user_id': 55,
        'order_amount': 150.0,
        'coupon_discount_amount': null, // Common backend response when no coupon applied
        'total_tax_amount': 12.5,
        'delivery_charge': 5.0,
        'store_discount_amount': 0.0,
        'payment_status': 'paid',
        'order_status': 'delivered',
      };

      // REAL EXPECTATION: Should parse cleanly without crashing the app
      final order = OrderModel.fromJson(jsonResponse);
      expect(order.id, equals(101));
      expect(order.couponDiscountAmount, equals(0.0));
    });

    test('OrderModel.fromJson should parse valid order when total_tax_amount is null', () {
      final jsonResponse = {
        'id': 102,
        'user_id': 55,
        'order_amount': 99.99,
        'coupon_discount_amount': 0.0,
        'total_tax_amount': null, // Missing/null tax field
        'delivery_charge': 0.0,
        'store_discount_amount': 0.0,
      };

      final order = OrderModel.fromJson(jsonResponse);
      expect(order.id, equals(102));
      expect(order.totalTaxAmount, isNull);
    });
  });

  group('PRODUCTION CRITICAL ISSUE 2: AddressModel Corrupts Null Fields to "null" Strings', () {
    test('AddressModel.fromJson should preserve null for contactPersonNumber when omitted', () {
      final jsonResponse = {
        'id': 1,
        'address_type': 'Home',
        'address': '123 Main St',
        'contact_person_number': null, // Omitted contact number
        'latitude': '24.8607',
        'longitude': '67.0011',
      };

      final address = AddressModel.fromJson(jsonResponse);
      // REAL EXPECTATION: contactPersonNumber should be null, NOT the literal String "null"
      expect(address.contactPersonNumber, isNull);
    });

    test('AddressModel.fromJson should preserve null for latitude/longitude when omitted', () {
      final jsonResponse = {
        'id': 2,
        'address': '456 Market St',
        'latitude': null,
        'longitude': null,
      };

      final address = AddressModel.fromJson(jsonResponse);
      expect(address.latitude, isNull);
      expect(address.longitude, isNull);
    });
  });

  group('PRODUCTION CRITICAL ISSUE 3: ItemModel Deserialization Hardcoded UI Singleton Dependency', () {
    test('ItemModel.fromJson should parse items payload in background or cache without UI controller', () {
      final jsonResponse = {
        'total_size': 1,
        'limit': '10',
        'offset': 1,
        'items': [
          {
            'id': 500,
            'name': 'Fresh Milk',
            'price': 4.5,
            'module_type': 'grocery',
          }
        ],
      };

      // REAL EXPECTATION: Pure data models MUST be deserializable without Flutter UI bindings or SplashController loaded in memory
      final model = ItemModel.fromJson(jsonResponse);
      expect(model.items, isNotEmpty);
      expect(model.items!.first.id, equals(500));
    });
  });

  group('PRODUCTION CRITICAL ISSUE 4: PriceConverter Null Pointer Exceptions', () {
    test('PriceConverter.convertWithDiscount should return null or 0 when price is null', () {
      final result = PriceConverter.convertWithDiscount(null, 10.0, 'amount');
      // REAL EXPECTATION: Helper should safely return null or 0 without crashing with Null check operator error
      expect(result, isNull);
    });

    test('PriceConverter.calculation should return 0.0 when discount is null', () {
      final result = PriceConverter.calculation(100.0, null, 'percent', 1);
      // REAL EXPECTATION: Should return 0.0 discount instead of crashing app
      expect(result, equals(0.0));
    });
  });

  group('PRODUCTION CRITICAL ISSUE 5: DateConverter Range & Timestamp Parsing Crashes', () {
    test('DateConverter.containTAndZToUTCFormat should parse ISO date strings safely', () {
      const shortIso = '2026-08-11';
      // REAL EXPECTATION: Should format date safely without throwing RangeError (end) out of bounds
      final formatted = DateConverter.containTAndZToUTCFormat(shortIso);
      expect(formatted, contains('2026'));
    });

    test('DateConverter.dateTimeStringToUTCTime should parse standard ISO timestamps without millis', () {
      const standardIso = '2026-08-11T14:30:00';
      // REAL EXPECTATION: Should format standard ISO string cleanly
      final formatted = DateConverter.dateTimeStringToUTCTime(standardIso);
      expect(formatted, contains('11 Aug 2026'));
    });
  });

  group('PRODUCTION CRITICAL ISSUE 6: ResponsiveHelper Unsafe Null Context Access', () {
    test('ResponsiveHelper.isMobile should return false or true safely when context is null', () {
      // REAL EXPECTATION: Signature accepts `BuildContext? context`. If null is passed, it should handle it safely
      final isMob = ResponsiveHelper.isMobile(null);
      expect(isMob, isA<bool>());
    });
  });
}
