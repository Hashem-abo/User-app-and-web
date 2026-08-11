// FIXED BEHAVIOR TESTS: DeliveryMan, OrderDetailsModel, AddOn
//
// These were previously CRASH tests that expected NoSuchMethodError.
// After the fix (null-safe .toDouble()), they now verify correct behavior.
//
// Run with:  flutter test test/unit/real_crash_tests/order_model_null_crash_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart' as od;

void main() {
  // ---------------------------------------------------------------------------
  // DeliveryMan.fromJson
  // ---------------------------------------------------------------------------
  group('[FIXED] DeliveryMan.fromJson – avg_rating null now defaults to 0', () {
    test('FIXED: avg_rating null -> 0.0 (no crash)', () {
      final json = <String, dynamic>{'avg_rating': null};
      final dm = DeliveryMan.fromJson(json);
      expect(dm.avgRating, equals(0.0));
      expect(dm.avgRating, isA<double>());
    });

    test('OK: avg_rating as double parses correctly', () {
      final json = <String, dynamic>{'avg_rating': 4.75};
      final dm = DeliveryMan.fromJson(json);
      expect(dm.avgRating, closeTo(4.75, 0.001));
    });

    test('OK: avg_rating as int coerces to double', () {
      final json = <String, dynamic>{'avg_rating': 5};
      final dm = DeliveryMan.fromJson(json);
      expect(dm.avgRating, equals(5.0));
      expect(dm.avgRating, isA<double>());
    });

    test('OK: avg_rating 0.0 stays 0.0', () {
      final json = <String, dynamic>{'avg_rating': 0.0};
      final dm = DeliveryMan.fromJson(json);
      expect(dm.avgRating, equals(0.0));
    });

    test('OK: full DeliveryMan parses correctly', () {
      final json = <String, dynamic>{
        'id': 42,
        'f_name': 'Ahmed',
        'l_name': 'Ali',
        'phone': '+966501234567',
        'email': 'ahmed@example.com',
        'zone_id': 3,
        'active': 1,
        'available': 1,
        'avg_rating': 4.5,
        'rating_count': 120,
        'lat': '24.8607',
        'lng': '67.0011',
      };

      final dm = DeliveryMan.fromJson(json);
      expect(dm.id, equals(42));
      expect(dm.fName, equals('Ahmed'));
      expect(dm.lName, equals('Ali'));
      expect(dm.avgRating, equals(4.5));
      expect(dm.ratingCount, equals(120));
    });
  });

  // ---------------------------------------------------------------------------
  // OrderDetailsModel.fromJson
  // ---------------------------------------------------------------------------
  group('[FIXED] OrderDetailsModel.fromJson – price null now defaults to 0', () {
    test('FIXED: price null -> 0.0 (no crash)', () {
      final json = <String, dynamic>{'price': null};
      final detail = od.OrderDetailsModel.fromJson(json);
      expect(detail.price, equals(0.0));
      expect(detail.price, isA<double>());
    });

    test('OK: price as int coerces to double', () {
      final json = <String, dynamic>{'price': 15};
      final detail = od.OrderDetailsModel.fromJson(json);
      expect(detail.price, equals(15.0));
    });

    test('OK: price as double parses correctly', () {
      final json = <String, dynamic>{'price': 29.99};
      final detail = od.OrderDetailsModel.fromJson(json);
      expect(detail.price, closeTo(29.99, 0.001));
    });

    test('OK: full order detail parses correctly', () {
      final json = <String, dynamic>{
        'id': 1,
        'item_id': 10,
        'order_id': 200,
        'price': 45.0,
        'quantity': '2',
        'tax_amount': 3.5,
        'discount_on_item': 5.0,
        'discount_type': 'amount',
      };
      final detail = od.OrderDetailsModel.fromJson(json);
      expect(detail.id, equals(1));
      expect(detail.price, equals(45.0));
      expect(detail.quantity, equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // AddOn.fromJson
  // ---------------------------------------------------------------------------
  group('[FIXED] AddOn.fromJson – price null now defaults to 0', () {
    test('FIXED: AddOn price null -> 0.0 (no crash)', () {
      final json = <String, dynamic>{'name': 'Extra Sauce', 'price': null, 'quantity': 1};
      final addOn = od.AddOn.fromJson(json);
      expect(addOn.price, equals(0.0));
    });

    test('OK: AddOn with full data', () {
      final json = <String, dynamic>{
        'name': 'Extra Cheese',
        'price': 2.5,
        'quantity': 2,
      };
      final addOn = od.AddOn.fromJson(json);
      expect(addOn.name, equals('Extra Cheese'));
      expect(addOn.price, equals(2.5));
      expect(addOn.quantity, equals(2));
    });
  });
}
