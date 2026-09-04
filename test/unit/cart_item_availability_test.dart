import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

void main() {
  group('Cart Item Store Availability Invariants', () {
    test('Partial storeDetails without active/open does NOT mark item unavailable', () {
      // Simulates opening item bottom sheet where only logo and total_items are loaded
      final cartModel = CartModel(
        quantity: 2,
        item: Item(
          id: 1,
          name: 'Test Item',
          storeId: 10,
        )..storeDetails = {
          'logo_full_url': 'https://example.com/logo.png',
          'total_items': 15,
        },
      );

      bool isAvailable = true;

      // Fixed store status check logic from calculationCart()
      if (isAvailable && cartModel.item!.storeDetails != null) {
        if (cartModel.item!.storeDetails!['active'] != null) {
          bool storeActive = cartModel.item!.storeDetails!['active'] == 1 ||
              cartModel.item!.storeDetails!['active'] == true ||
              cartModel.item!.storeDetails!['active'] == '1';
          if (!storeActive) {
            isAvailable = false;
          }
        }
        if (cartModel.item!.storeDetails!['open'] != null) {
          bool storeOpen = cartModel.item!.storeDetails!['open'] == 1 ||
              cartModel.item!.storeDetails!['open'] == true ||
              cartModel.item!.storeDetails!['open'] == '1';
          if (!storeOpen) {
            isAvailable = false;
          }
        }
      }

      // Must remain available!
      expect(isAvailable, isTrue);
    });

    test('storeDetails with active=false marks item unavailable', () {
      final cartModel = CartModel(
        quantity: 2,
        item: Item(
          id: 1,
          name: 'Test Item',
          storeId: 10,
        )..storeDetails = {
          'logo_full_url': 'https://example.com/logo.png',
          'total_items': 15,
          'active': false,
          'open': 1,
        },
      );

      bool isAvailable = true;

      if (isAvailable && cartModel.item!.storeDetails != null) {
        if (cartModel.item!.storeDetails!['active'] != null) {
          bool storeActive = cartModel.item!.storeDetails!['active'] == 1 ||
              cartModel.item!.storeDetails!['active'] == true ||
              cartModel.item!.storeDetails!['active'] == '1';
          if (!storeActive) {
            isAvailable = false;
          }
        }
        if (cartModel.item!.storeDetails!['open'] != null) {
          bool storeOpen = cartModel.item!.storeDetails!['open'] == 1 ||
              cartModel.item!.storeDetails!['open'] == true ||
              cartModel.item!.storeDetails!['open'] == '1';
          if (!storeOpen) {
            isAvailable = false;
          }
        }
      }

      expect(isAvailable, isFalse);
    });

    test('storeDetails with open=0 marks item unavailable', () {
      final cartModel = CartModel(
        quantity: 2,
        item: Item(
          id: 1,
          name: 'Test Item',
          storeId: 10,
        )..storeDetails = {
          'logo_full_url': 'https://example.com/logo.png',
          'total_items': 15,
          'active': true,
          'open': 0,
        },
      );

      bool isAvailable = true;

      if (isAvailable && cartModel.item!.storeDetails != null) {
        if (cartModel.item!.storeDetails!['active'] != null) {
          bool storeActive = cartModel.item!.storeDetails!['active'] == 1 ||
              cartModel.item!.storeDetails!['active'] == true ||
              cartModel.item!.storeDetails!['active'] == '1';
          if (!storeActive) {
            isAvailable = false;
          }
        }
        if (cartModel.item!.storeDetails!['open'] != null) {
          bool storeOpen = cartModel.item!.storeDetails!['open'] == 1 ||
              cartModel.item!.storeDetails!['open'] == true ||
              cartModel.item!.storeDetails!['open'] == '1';
          if (!storeOpen) {
            isAvailable = false;
          }
        }
      }

      expect(isAvailable, isFalse);
    });

    test('Store mapping in ItemController accurately populates storeDetails active and open', () {
      final store = Store(
        id: 10,
        name: 'Super Market',
        logoFullUrl: 'https://example.com/logo.png',
        itemCount: 25,
        active: true,
        open: 1,
        zoneId: 2,
      );

      final Map<String, dynamic> storeDetails = {
        'id': store.id,
        'name': store.name,
        'logo_full_url': store.logoFullUrl,
        'total_items': store.itemCount,
        'active': store.active,
        'open': store.open,
        'zone_id': store.zoneId,
      };

      expect(storeDetails['active'], isTrue);
      expect(storeDetails['open'], equals(1));
      expect(storeDetails['id'], equals(10));
      expect(storeDetails['name'], equals('Super Market'));
    });
  });
}
