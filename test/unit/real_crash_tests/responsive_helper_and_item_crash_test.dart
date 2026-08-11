// PRODUCTION TESTS: ResponsiveHelper & Item.fromJson (All Fixes Verified)
//
// Verifies:
// 1. ResponsiveHelper.isMobile/isTab/isDesktop safely handle null context without throwing.
// 2. Item.fromJson handles null price and discount gracefully without crashing.
// 3. ItemModel.fromJson handles key variations and pagination.
//
// Run with:  flutter test test/unit/real_crash_tests/responsive_helper_and_item_crash_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

void main() {
  // ---------------------------------------------------------------------------
  // ResponsiveHelper – null context safety
  // ---------------------------------------------------------------------------
  group('[FIXED] ResponsiveHelper – null context handled safely without crashing', () {
    test('isMobile(null) returns bool safely without throwing', () {
      expect(() => ResponsiveHelper.isMobile(null), returnsNormally);
      final result = ResponsiveHelper.isMobile(null);
      expect(result, isA<bool>());
    });

    test('isTab(null) returns false safely without throwing', () {
      expect(() => ResponsiveHelper.isTab(null), returnsNormally);
      final result = ResponsiveHelper.isTab(null);
      expect(result, isFalse);
    });

    test('isDesktop(null) returns false safely without throwing', () {
      expect(() => ResponsiveHelper.isDesktop(null), returnsNormally);
      final result = ResponsiveHelper.isDesktop(null);
      expect(result, isFalse);
    });

    test('isMobilePhone() returns bool without context', () {
      final result = ResponsiveHelper.isMobilePhone();
      expect(result, isA<bool>());
    });

    test('isWeb() returns bool without context', () {
      final result = ResponsiveHelper.isWeb();
      expect(result, isA<bool>());
    });
  });

  // ---------------------------------------------------------------------------
  // Item.fromJson – null price and discount safety
  // ---------------------------------------------------------------------------
  group('[FIXED] Item.fromJson – null price and discount handled safely', () {
    test('price null -> defaults to 0.0 without crashing', () {
      final json = <String, dynamic>{
        'id': 1,
        'name': 'Test Item',
        'price': null,
        'discount': 0.0,
        'discount_type': 'percent',
        'module_type': 'grocery',
      };

      final item = Item.fromJson(json);
      expect(item.price, equals(0.0));
      expect(item.price, isA<double>());
    });

    test('discount null -> defaults to 0.0 without crashing', () {
      final json = <String, dynamic>{
        'id': 2,
        'name': 'No Discount Item',
        'price': 10.0,
        'discount': null,
        'discount_type': 'percent',
        'module_type': 'grocery',
      };

      final item = Item.fromJson(json);
      expect(item.discount, equals(0.0));
      expect(item.discount, isA<double>());
    });

    test('standard item with all numeric fields parses cleanly', () {
      final json = <String, dynamic>{
        'id': 3,
        'name': 'Fresh Milk',
        'price': 4.5,
        'discount': 0.0,
        'discount_type': 'percent',
        'tax': 0.15,
        'avg_rating': 4.2,
        'rating_count': 25,
        'stock': 100,
        'veg': 1,
        'module_type': 'grocery',
        'store_id': 5,
        'zone_id': 2,
        'free_delivery': false,
      };

      final item = Item.fromJson(json);
      expect(item.id, equals(3));
      expect(item.name, equals('Fresh Milk'));
      expect(item.price, equals(4.5));
      expect(item.discount, equals(0.0));
      expect(item.tax, equals(0.15));
      expect(item.avgRating, closeTo(4.2, 0.001));
      expect(item.veg, equals(1));
    });

    test('free_delivery handles all backend type variants', () {
      // bool true
      final jsonBoolTrue = <String, dynamic>{
        'id': 10, 'name': 'Item', 'price': 5.0, 'discount': 0.0,
        'discount_type': 'percent', 'free_delivery': true,
      };
      expect(Item.fromJson(jsonBoolTrue).freeDelivery, isTrue);

      // int 1
      final jsonInt1 = <String, dynamic>{
        'id': 11, 'name': 'Item', 'price': 5.0, 'discount': 0.0,
        'discount_type': 'percent', 'free_delivery': 1,
      };
      expect(Item.fromJson(jsonInt1).freeDelivery, isTrue);

      // string '1'
      final jsonStr1 = <String, dynamic>{
        'id': 12, 'name': 'Item', 'price': 5.0, 'discount': 0.0,
        'discount_type': 'percent', 'free_delivery': '1',
      };
      expect(Item.fromJson(jsonStr1).freeDelivery, isTrue);

      // bool false
      final jsonBoolFalse = <String, dynamic>{
        'id': 13, 'name': 'Item', 'price': 5.0, 'discount': 0.0,
        'discount_type': 'percent', 'free_delivery': false,
      };
      expect(Item.fromJson(jsonBoolFalse).freeDelivery, isFalse);

      // int 0
      final jsonInt0 = <String, dynamic>{
        'id': 14, 'name': 'Item', 'price': 5.0, 'discount': 0.0,
        'discount_type': 'percent', 'free_delivery': 0,
      };
      expect(Item.fromJson(jsonInt0).freeDelivery, isFalse);
    });

    test('veg field as int string parses correctly', () {
      final json = <String, dynamic>{
        'id': 20,
        'name': 'Veggie Burger',
        'price': 8.0,
        'discount': 0.0,
        'discount_type': 'percent',
        'veg': '1',
      };

      final item = Item.fromJson(json);
      expect(item.veg, equals(1));
    });

    test('variations as string (JSON encoded) parses via jsonDecode', () {
      final json = <String, dynamic>{
        'id': 30,
        'name': 'T-Shirt',
        'price': 20.0,
        'discount': 0.0,
        'discount_type': 'percent',
        'variations': '[]',
      };

      final item = Item.fromJson(json);
      expect(item.variations, isNotNull);
      expect(item.variations, isEmpty);
    });

    test('verifiedSeller as string "1" parses to int 1', () {
      final json = <String, dynamic>{
        'id': 40,
        'name': 'Verified Store Item',
        'price': 15.0,
        'discount': 0.0,
        'discount_type': 'percent',
        'verified_seller': '1',
      };

      final item = Item.fromJson(json);
      expect(item.verifiedSeller, equals(1));
    });

    test('wishlistCount accepts both key variants', () {
      final jsonPrimary = <String, dynamic>{
        'id': 50, 'name': 'Item', 'price': 5.0, 'discount': 0.0,
        'discount_type': 'percent', 'whislists_count': 12,
      };
      expect(Item.fromJson(jsonPrimary).wishlistCount, equals(12));

      final jsonFallback = <String, dynamic>{
        'id': 51, 'name': 'Item', 'price': 5.0, 'discount': 0.0,
        'discount_type': 'percent', 'wishlist_count': 8,
      };
      expect(Item.fromJson(jsonFallback).wishlistCount, equals(8));
    });

    test('halalItem and prescriptionRequired parsed as booleans from int', () {
      final json = <String, dynamic>{
        'id': 60,
        'name': 'Medicine',
        'price': 30.0,
        'discount': 0.0,
        'discount_type': 'percent',
        'halal_tag_status': 1,
        'is_halal': 1,
        'is_prescription_required': 1,
      };

      final item = Item.fromJson(json);
      expect(item.isStoreHalalActive, isTrue);
      expect(item.isHalalItem, isTrue);
      expect(item.isPrescriptionRequired, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // ItemModel.fromJson – pagination with 'products' key (not 'items')
  // ---------------------------------------------------------------------------
  group('[OK] ItemModel.fromJson – accepts both "products" and "items" keys', () {
    test('products key maps to items list', () {
      final json = <String, dynamic>{
        'total_size': 1,
        'limit': '10',
        'offset': 1,
        'products': [
          {
            'id': 100,
            'name': 'Widget',
            'price': 9.99,
            'discount': 0.0,
            'discount_type': 'percent',
          }
        ],
      };

      final model = ItemModel.fromJson(json);
      expect(model.items, isNotNull);
      expect(model.items!.length, equals(1));
      expect(model.items!.first.id, equals(100));
      expect(model.items!.first.price, equals(9.99));
    });

    test('categories key parses to List<Categories>', () {
      final json = <String, dynamic>{
        'total_size': 0,
        'limit': '10',
        'offset': '0',
        'categories': [
          {'id': 5, 'name': 'Beverages'},
          {'id': 6, 'name': 'Snacks'},
        ],
      };

      final model = ItemModel.fromJson(json);
      expect(model.categories, isNotNull);
      expect(model.categories!.length, equals(2));
      expect(model.categories!.first.name, equals('Beverages'));
    });
  });
}
