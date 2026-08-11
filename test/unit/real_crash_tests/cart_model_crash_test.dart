// PRODUCTION TESTS: CartModel (All Fixes Verified)
//
// Verifies:
// 1. price null in CartModel.fromJson defaults safely to 0.0.
// 2. quantity_limit as int (or string or null) parses properly without TypeError.
// 3. toJson works cleanly even when item is null.
//
// Run with:  flutter test test/unit/real_crash_tests/cart_model_crash_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

void main() {
  group('[FIXED] CartModel.fromJson – price null safety', () {
    test('price is null -> defaults safely to 0.0', () {
      final json = <String, dynamic>{
        'cart_id': 1,
        'price': null,
        'quantity': 1,
      };

      final cart = CartModel.fromJson(json);
      expect(cart.price, equals(0.0));
      expect(cart.price, isA<double>());
    });

    test('price as int is coerced to double', () {
      final json = <String, dynamic>{
        'cart_id': 2,
        'price': 25,
        'quantity': 2,
        'quantity_limit': '10',
      };

      final cart = CartModel.fromJson(json);
      expect(cart.price, equals(25.0));
      expect(cart.price, isA<double>());
    });
  });

  group('[FIXED] CartModel.fromJson – quantity_limit type flexibility', () {
    test('quantity_limit as int parses correctly without TypeError', () {
      final json = <String, dynamic>{
        'cart_id': 3,
        'price': 15.0,
        'quantity': 1,
        'quantity_limit': 5,
      };

      final cart = CartModel.fromJson(json);
      expect(cart.quantityLimit, equals(5));
      expect(cart.quantityLimit, isA<int>());
    });

    test('quantity_limit as string "5" parses correctly', () {
      final json = <String, dynamic>{
        'cart_id': 4,
        'price': 15.0,
        'quantity': 1,
        'quantity_limit': '5',
      };

      final cart = CartModel.fromJson(json);
      expect(cart.quantityLimit, equals(5));
      expect(cart.quantityLimit, isA<int>());
    });

    test('quantity_limit null is treated as null (not parsed)', () {
      final json = <String, dynamic>{
        'cart_id': 5,
        'price': 10.0,
        'quantity': 1,
        'quantity_limit': null,
      };

      final cart = CartModel.fromJson(json);
      expect(cart.quantityLimit, isNull);
    });
  });

  group('[FIXED] CartModel.toJson – item null safety', () {
    test('toJson succeeds when item is null without throwing', () {
      final cart = CartModel(
        id: 99,
        price: 20.0,
        quantity: 1,
      );

      expect(() => cart.toJson(), returnsNormally);
      final json = cart.toJson();
      expect(json.containsKey('item'), isFalse);
      expect(json['price'], equals(20.0));
      expect(json['quantity'], equals(1));
    });

    test('toJson includes item when item is provided', () {
      final item = Item(id: 123, name: 'Burger', price: 15.0, discount: 0.0);
      final cart = CartModel(
        id: 10,
        price: 30.0,
        discountedPrice: 25.0,
        discountAmount: 5.0,
        quantity: 3,
        item: item,
      );

      final json = cart.toJson();
      expect(json.containsKey('item'), isTrue);
      expect(json['item']['id'], equals(123));
      expect(json['item']['name'], equals('Burger'));
    });
  });

  group('[OK] CartModel – mutable fields', () {
    test('quantity setter works correctly', () {
      final cart = CartModel(id: 1, price: 10.0, quantity: 1);
      expect(cart.quantity, equals(1));

      cart.quantity = 5;
      expect(cart.quantity, equals(5));
    });

    test('note setter works correctly', () {
      final cart = CartModel(id: 1, price: 10.0, quantity: 1, note: 'original');
      cart.note = 'updated note';
      expect(cart.note, equals('updated note'));
    });

    test('isLoading setter works correctly', () {
      final cart = CartModel(id: 1, price: 10.0, quantity: 1);
      expect(cart.isLoading, isFalse);

      cart.isLoading = true;
      expect(cart.isLoading, isTrue);
    });
  });

  group('[OK] CartModel.fromJson – food_variations nested parsing', () {
    test('food_variations as 2D list parses to List<List<bool?>>', () {
      final json = <String, dynamic>{
        'cart_id': 20,
        'price': 15.0,
        'quantity': 1,
        'food_variations': [
          [true, false, null],
          [false, true],
        ],
        'quantity_limit': '5',
      };

      final cart = CartModel.fromJson(json);
      expect(cart.foodVariations, isNotNull);
      expect(cart.foodVariations!.length, equals(2));
      expect(cart.foodVariations![0], equals([true, false, null]));
      expect(cart.foodVariations![1], equals([false, true]));
    });

    test('food_variations null results in null field', () {
      final json = <String, dynamic>{
        'cart_id': 21,
        'price': 15.0,
        'quantity': 1,
        'food_variations': null,
        'quantity_limit': '5',
      };

      final cart = CartModel.fromJson(json);
      expect(cart.foodVariations, isNull);
    });
  });

  group('[OK] CartModel.fromJson – add_on_ids parsing', () {
    test('add_on_ids as list of maps parses to List<AddOn>', () {
      final json = <String, dynamic>{
        'cart_id': 30,
        'price': 20.0,
        'quantity': 1,
        'quantity_limit': '10',
        'add_on_ids': [
          {'id': 1, 'quantity': 2},
          {'id': 3, 'quantity': 1},
        ],
      };

      final cart = CartModel.fromJson(json);
      expect(cart.addOnIds, isNotNull);
      expect(cart.addOnIds!.length, equals(2));
      expect(cart.addOnIds!.first.id, equals(1));
      expect(cart.addOnIds!.first.quantity, equals(2));
    });

    test('add_on_ids null results in null field', () {
      final json = <String, dynamic>{
        'cart_id': 31,
        'price': 20.0,
        'quantity': 1,
        'quantity_limit': '10',
        'add_on_ids': null,
      };

      final cart = CartModel.fromJson(json);
      expect(cart.addOnIds, isNull);
    });
  });
}
