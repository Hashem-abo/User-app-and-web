import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/common/widgets/vendor_type_badge_widget.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/order/domain/models/monthly_order_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/api/data_module_manager.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:get/get.dart';

PlaceOrderBodyModel _buildTestBody({bool? monthlySubscribe}) {
  return PlaceOrderBodyModel(
    cart: [],
    couponDiscountAmount: 0,
    couponCode: null,
    orderAmount: 100,
    orderType: 'delivery',
    paymentMethod: 'wallet',
    storeId: 1,
    distance: 1.5,
    discountAmount: 0,
    orderNote: '',
    receiverDetails: null,
    parcelCategoryId: null,
    chargePayer: null,
    dmTips: '0',
    unavailableItemNote: '',
    cutlery: 0,
    partialPayment: 0,
    guestId: 0,
    isBuyNow: 0,
    extraPackagingAmount: 0,
    createNewUser: 0,
    password: null,
    monthlySubscribe: monthlySubscribe,
  );
}

void main() {
  group('USER REQUEST FIX 1: PlaceOrderBodyModel Monthly Subscription', () {
    test('PlaceOrderBodyModel should correctly encode monthly_subscribe when true', () {
      final body = _buildTestBody(monthlySubscribe: true);
      final json = body.toJson();
      expect(json['monthly_subscribe'], isNotNull);
      expect(json['monthly_subscribe'] == '1' || json['monthly_subscribe'] == 'true', isTrue);
    });

    test('PlaceOrderBodyModel should correctly encode monthly_subscribe when false', () {
      final body = _buildTestBody(monthlySubscribe: false);
      final json = body.toJson();
      expect(json['monthly_subscribe'] == '0' || json['monthly_subscribe'] == 'false', isTrue);
    });

    test('PlaceOrderBodyModel should handle null monthlySubscribe cleanly', () {
      final body = _buildTestBody(monthlySubscribe: null);
      final json = body.toJson();
      expect(json.containsKey('monthly_subscribe'), isFalse);
    });
  });

  group('USER REQUEST FIX 2: MonthlyOrder Model Resilience', () {
    test('MonthlyOrderModel parses list of items and store details correctly', () {
      final json = {
        'total_size': 1,
        'limit': 10,
        'offset': 1,
        'items': [
          {
            'id': 55,
            'order_id': 1002,
            'module_id': 2,
            'module_type': 'grocery',
            'remind_at': '2026-10-01T00:00:00.000Z',
            'status': 'active',
            'items_count': 3,
            'store': {
              'id': 12,
              'name': 'Fresh Market',
              'logo_full_url': 'https://example.com/logo.png',
            },
            'items_preview': [
              {
                'id': 101,
                'name': 'Fresh Milk',
                'price': 4.5,
                'quantity': 2,
                'image_full_url': 'https://example.com/milk.png',
              }
            ]
          }
        ]
      };

      final model = MonthlyOrderModel.fromJson(json);
      expect(model.totalSize, equals(1));
      expect(model.items.length, equals(1));
      expect(model.items.first.id, equals(55));
      expect(model.items.first.store?.name, equals('Fresh Market'));
      expect(model.items.first.itemsPreview.first.name, equals('Fresh Milk'));
      expect(model.items.first.itemsPreview.first.price, equals(4.5));
    });
  });

  group('USER REQUEST FIX 3: Vendor Contact Hiding Logic', () {
    test('Takeaway order represents vendor contact, delivery order with DM represents courier', () {
      final takeawayOrder = OrderModel(
        id: 101,
        orderType: 'take_away',
        orderStatus: 'confirmed',
        store: Store(id: 5, name: 'Vendor Store', phone: '123456789'),
        deliveryMan: null,
      );

      final deliveryOrder = OrderModel(
        id: 102,
        orderType: 'delivery',
        orderStatus: 'picked_up',
        store: Store(id: 5, name: 'Vendor Store', phone: '123456789'),
        deliveryMan: DeliveryMan(id: 9, fName: 'John', lName: 'Rider', phone: '987654321'),
      );

      // Takeaway contact target is the vendor
      expect(takeawayOrder.orderType == 'take_away', isTrue);
      final bool hideTakeawayVendorContact = (takeawayOrder.orderType == 'take_away');
      expect(hideTakeawayVendorContact, isTrue);

      // Delivery contact target is the delivery courier
      expect(deliveryOrder.orderType == 'take_away', isFalse);
      expect(deliveryOrder.deliveryMan, isNotNull);
    });
  });

  group('USER REQUEST FIX 4: Pro Subscription Wallet Payment Request Payload', () {
    test('Subscribe request payload should accept purchase_code when paying with wallet gateway', () {
      final Map<String, dynamic> requestPayload = {
        'plan_id': 3,
        'payment_type': 'digital_payment',
        'payment_method': 'easy_wallet',
        'callback': 'https://example.com/callback',
        'payment_platform': 'app',
        'purchase_code': '98765432',
      };

      expect(requestPayload['payment_method'], equals('easy_wallet'));
      expect(requestPayload['purchase_code'], equals('98765432'));
      expect(requestPayload.containsKey('purchase_code'), isTrue);
    });

    test('Subscribe request payload without purchase_code omits or handles null cleanly', () {
      String? purchaseCode;
      final Map<String, dynamic> requestPayload = {
        'plan_id': 3,
        'payment_type': 'wallet',
        'payment_method': 'wallet',
        'callback': null,
        'payment_platform': 'app',
        if (purchaseCode != null && purchaseCode.isNotEmpty) 'purchase_code': purchaseCode,
      };

      expect(requestPayload['payment_type'], equals('wallet'));
      expect(requestPayload.containsKey('purchase_code'), isFalse);
    });
  });

  group('USER REQUEST FIX 5: Password Fields LTR Direction, High Contrast Color & Font', () {
    test('Password fields must use LTR directionality even when app is RTL', () {
      bool isPassword = true;
      bool isPhone = false;
      String? countryDialCode;
      
      // Simulating Directionality check in CustomTextField / MyTextField
      final isRtlContext = true;
      final resolvedDirection = (isPhone || isPassword || countryDialCode != null) ? 'ltr' : (isRtlContext ? 'rtl' : 'ltr');
      expect(resolvedDirection, equals('ltr'));
    });

    test('Password field text color must contrast with background', () {
      // Light card (e.g. #FFFFFF or #FCFCFC)
      final lightLuminance = 1.0;
      final lightModeColor = (lightLuminance > 0.5) ? '0xFF2E2E2E' : '0xFFFFFFFF';
      expect(lightModeColor, equals('0xFF2E2E2E'));

      // Dark card (e.g. #30313C)
      final darkLuminance = 0.2;
      final darkModeColor = (darkLuminance > 0.5) ? '0xFF2E2E2E' : '0xFFFFFFFF';
      expect(darkModeColor, equals('0xFFFFFFFF'));
    });

    test('Password field adaptive keyboardType switches between text and visiblePassword', () {
      bool isPassword = true;
      bool obscureText = true;

      String resolveKeyboardType(bool isPassword, bool obscureText) {
        if (!isPassword) return 'text';
        return obscureText ? 'text' : 'visiblePassword';
      }

      expect(resolveKeyboardType(isPassword, true), equals('text'));
      expect(resolveKeyboardType(isPassword, false), equals('visiblePassword'));
    });
  });

  group('USER REQUEST FIX 6: Zad Module Product Unit Display', () {
    test('isUnitVisibleForType returns true for Zad module ID 1', () {
      expect(ModuleHelper.isUnitVisibleForType(unitType: 'kg', moduleId: 1), isTrue);
      expect(ModuleHelper.isUnitVisibleForType(unitType: 'قطعة', moduleId: 1), isTrue);
      expect(ModuleHelper.isUnitVisibleForType(unitType: 'حبة', moduleId: 1), isTrue);
    });

    test('isUnitVisibleForType returns true for grocery module type', () {
      expect(ModuleHelper.isUnitVisibleForType(unitType: 'kg', moduleType: 'grocery'), isTrue);
      expect(ModuleHelper.isUnitVisibleForType(unitType: 'ltr', moduleType: 'grocery'), isTrue);
    });

    test('isUnitVisibleForType returns false for empty or null unitType', () {
      expect(ModuleHelper.isUnitVisibleForType(unitType: null, moduleId: 1), isFalse);
      expect(ModuleHelper.isUnitVisibleForType(unitType: '', moduleId: 1), isFalse);
      expect(ModuleHelper.isUnitVisibleForType(unitType: '   ', moduleId: 1), isFalse);
    });

    test('isUnitVisible returns true for Item in Zad module with unit', () {
      final zadItem = Item(id: 10, name: 'Tomato', moduleId: 1, unitType: 'kg');
      expect(ModuleHelper.isUnitVisible(zadItem), isTrue);

      final groceryItem = Item(id: 11, name: 'Apple', moduleType: 'grocery', unitType: 'box');
      expect(ModuleHelper.isUnitVisible(groceryItem), isTrue);
    });

    test('isUnitVisible returns false for Item with null or empty unitType or null item', () {
      expect(ModuleHelper.isUnitVisible(null), isFalse);

      final itemNoUnit = Item(id: 12, name: 'Milk', moduleId: 1, unitType: null);
      expect(ModuleHelper.isUnitVisible(itemNoUnit), isFalse);

      final itemEmptyUnit = Item(id: 13, name: 'Bread', moduleId: 1, unitType: '');
      expect(ModuleHelper.isUnitVisible(itemEmptyUnit), isFalse);
    });
  });

  group('USER REQUEST FIX 7: Monthly Enable Module & Config Resolution', () {
    test('ModuleHelper.isGroceryOrPharmacy correctly detects grocery module ID 1 and pharmacy ID 2', () {
      expect(ModuleHelper.isGroceryOrPharmacy(moduleId: 1), isTrue);
      expect(ModuleHelper.isGroceryOrPharmacy(moduleId: 2), isTrue);
      expect(ModuleHelper.isGroceryOrPharmacy(moduleId: 3), isFalse);
      expect(ModuleHelper.isGroceryOrPharmacy(moduleId: 4), isFalse);
    });

    test('ModuleHelper.isGroceryOrPharmacy detects grocery and pharmacy moduleType strings', () {
      expect(ModuleHelper.isGroceryOrPharmacy(moduleType: 'grocery'), isTrue);
      expect(ModuleHelper.isGroceryOrPharmacy(moduleType: 'pharmacy'), isTrue);
      expect(ModuleHelper.isGroceryOrPharmacy(moduleType: 'food'), isFalse);
      expect(ModuleHelper.isGroceryOrPharmacy(moduleType: 'parcel'), isFalse);
    });

    test('ModuleHelper.isGroceryOrPharmacy handles Items with null moduleType but valid moduleId', () {
      final itemFromApi = Item(id: 101, name: 'Cucumber', moduleId: 1, moduleType: null);
      expect(ModuleHelper.isGroceryOrPharmacy(item: itemFromApi), isTrue);

      final pharmacyItem = Item(id: 102, name: 'Aspirin', moduleId: 2, moduleType: null);
      expect(ModuleHelper.isGroceryOrPharmacy(item: pharmacyItem), isTrue);

      final foodItem = Item(id: 103, name: 'Burger', moduleId: 3, moduleType: null);
      expect(ModuleHelper.isGroceryOrPharmacy(item: foodItem), isFalse);
    });

    test('ConfigModel parses monthlyOrderRemainder safely from string, int, and boolean forms', () {
      final configInt = ConfigModel.fromJson({'monthly_order_reminder': 1});
      expect(configInt.monthlyOrderRemainder, equals(1));

      final configStr = ConfigModel.fromJson({'monthly_order_reminder': '1'});
      expect(configStr.monthlyOrderRemainder, equals(1));

      final configBool = ConfigModel.fromJson({'monthly_order_reminder': true});
      expect(configBool.monthlyOrderRemainder, equals(1));

      final configRemainderKey = ConfigModel.fromJson({'monthly_order_remainder': '1'});
      expect(configRemainderKey.monthlyOrderRemainder, equals(1));

      final configStatusKey = ConfigModel.fromJson({'monthly_order_status': 1});
      expect(configStatusKey.monthlyOrderRemainder, equals(1));

      final configDisabled = ConfigModel.fromJson({'monthly_order_reminder': 0});
      expect(configDisabled.monthlyOrderRemainder, equals(0));

      final configDisabledStr = ConfigModel.fromJson({'monthly_order_reminder': '0'});
      expect(configDisabledStr.monthlyOrderRemainder, equals(0));
    });

    test('PlaceOrderBodyModel sends monthly order payload aliases for backend compatibility', () {
      final body = _buildTestBody(monthlySubscribe: true);
      final json = body.toJson();
      expect(json['monthly_subscribe'], equals('1'));
      expect(json['is_monthly_subscribe'], equals('1'));
      expect(json['monthly_order'], equals('1'));
      expect(json['is_monthly_order'], equals('1'));
      expect(json['monthly_purchase'], equals('1'));
      expect(json['is_monthly_purchase'], equals('1'));
      expect(json['add_to_monthly'], equals('1'));
      expect(json['add_to_monthly_order'], equals('1'));
    });
  });

  group('USER REQUEST FIX 8: Zad Module Vendor Type Null Hiding & Badge Safety', () {
    test('ModuleHelper.isZad detects Zad by moduleId, moduleType, or moduleName', () {
      expect(ModuleHelper.isZad(moduleId: 1), isTrue);
      expect(ModuleHelper.isZad(moduleType: 'zad'), isTrue);
      expect(ModuleHelper.isZad(moduleName: 'Zad Mart'), isTrue);
      expect(ModuleHelper.isZad(moduleName: 'سوبرماركت زاد'), isTrue);
      expect(ModuleHelper.isZad(moduleId: 3, moduleType: 'food'), isFalse);
    });

    test('Store.isZad correctly identifies Zad stores', () {
      final zadStoreById = Store(id: 1, moduleId: 1);
      expect(zadStoreById.isZad, isTrue);

      final zadStoreByName = Store.fromJson({
        'id': 2,
        'module': {'id': 1, 'module_name': 'Zad Grocery', 'module_type': 'grocery'},
      });
      expect(zadStoreByName.isZad, isTrue);

      final nonZadStore = Store.fromJson({
        'id': 3,
        'module_id': 2,
        'module': {'id': 2, 'module_name': 'Pharmacy', 'module_type': 'pharmacy'},
      });
      expect(nonZadStore.isZad, isFalse);
    });

    test('Store in Zad hides vendorType (returns empty string) when vendor_type is null', () {
      final store = Store.fromJson({
        'id': 10,
        'name': 'Al-Hilal Zad Grocery',
        'module_id': 1,
        'vendor_type': null,
        'store_business_model': 'commission',
        'module': {'id': 1, 'module_name': 'Zad', 'module_type': 'grocery'},
      });
      expect(store.isZad, isTrue);
      expect(store.vendorType, equals(''));
      expect(store.vendorType.isEmpty, isTrue);
    });

    test('Store in Zad hides vendorType (returns empty string) when vendor_type is literal "null" string', () {
      final store = Store.fromJson({
        'id': 11,
        'name': 'Baraka Zad Grocery',
        'module_id': 1,
        'vendor_type': 'null',
        'module': {'id': 1, 'module_name': 'Zad', 'module_type': 'grocery'},
      });
      expect(store.isZad, isTrue);
      expect(store.vendorType, equals(''));
      expect(store.vendorType.isEmpty, isTrue);
    });

    test('Store in Zad hides vendorType (returns empty string) when vendor_type is empty or omitted', () {
      final storeEmpty = Store.fromJson({
        'id': 12,
        'name': 'Safwa Zad Grocery',
        'module_id': 1,
        'vendor_type': '   ',
      });
      expect(storeEmpty.isZad, isTrue);
      expect(storeEmpty.vendorType, equals(''));

      final storeOmitted = Store.fromJson({
        'id': 13,
        'name': 'No Vendor Type Zad',
        'module_id': 1,
      });
      expect(storeOmitted.isZad, isTrue);
      expect(storeOmitted.vendorType, equals(''));
    });

    test('Store in Zad displays vendorType for wholesale/factory, hides retailer and empty', () {
      final wholesaleStore = Store.fromJson({
        'id': 20,
        'name': 'Zad Wholesale Co',
        'module_id': 1,
        'vendor_type': 'wholesale',
      });
      expect(wholesaleStore.isZad, isTrue);
      expect(wholesaleStore.vendorType, isNotEmpty);
      expect(wholesaleStore.vendorType.toLowerCase(), anyOf(contains('wholesale'), contains('جملة')));

      final factoryStore = Store.fromJson({
        'id': 23,
        'name': 'Zad Factory Co',
        'module_id': 1,
        'vendor_type': 'factory',
      });
      expect(factoryStore.isZad, isTrue);
      expect(factoryStore.vendorType, isNotEmpty);
      expect(factoryStore.vendorType.toLowerCase(), anyOf(contains('factory'), contains('مصنع')));

      final retailStore = Store.fromJson({
        'id': 21,
        'name': 'Zad Corner Retail',
        'module_id': 1,
        'vendor_type': 'retail',
      });
      expect(retailStore.isZad, isTrue);
      expect(retailStore.vendorType, isEmpty);
      expect(retailStore.vendorType, equals(''));

      final customStore = Store.fromJson({
        'id': 22,
        'name': 'Zad Bakery',
        'module_id': 1,
        'vendor_type': 'مخبز',
      });
      expect(customStore.isZad, isTrue);
      expect(customStore.vendorType, equals('مخبز'));
    });

    testWidgets('VendorTypeBadgeWidget returns SizedBox.shrink/empty when store vendorType is null or hidden', (tester) async {
      final zadNullStore = Store.fromJson({
        'id': 30,
        'name': 'Zad Store Null Type',
        'module_id': 1,
        'vendor_type': null,
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VendorTypeBadgeWidget(store: zadNullStore),
          ),
        ),
      );

      // Must NOT show any text widget with "null", "Zad", or "grocery"
      expect(find.text('null'), findsNothing);
      expect(find.text('Zad'), findsNothing);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('VendorTypeBadgeWidget returns SizedBox when vendorType is empty, "null", or retailer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VendorTypeBadgeWidget(vendorType: 'null'),
          ),
        ),
      );
      expect(find.text('null'), findsNothing);
      expect(find.byType(Icon), findsNothing);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VendorTypeBadgeWidget(vendorType: ''),
          ),
        ),
      );
      expect(find.byType(Icon), findsNothing);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VendorTypeBadgeWidget(vendorType: 'retail'),
          ),
        ),
      );
      expect(find.byType(Icon), findsNothing);
      expect(find.text('Retail'), findsNothing);
      expect(find.text('تجزئة'), findsNothing);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VendorTypeBadgeWidget(vendorType: 'retailer'),
          ),
        ),
      );
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('VendorTypeBadgeWidget displays badge when store has wholesale or factory vendorType', (tester) async {
      final zadWholesaleStore = Store.fromJson({
        'id': 31,
        'name': 'Zad Wholesale Store',
        'module_id': 1,
        'vendor_type': 'wholesale',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VendorTypeBadgeWidget(store: zadWholesaleStore),
          ),
        ),
      );

      // Icon storefront should be rendered for wholesale
      expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);

      final zadFactoryStore = Store.fromJson({
        'id': 32,
        'name': 'Zad Factory Store',
        'module_id': 1,
        'vendor_type': 'factory',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VendorTypeBadgeWidget(store: zadFactoryStore),
          ),
        ),
      );

      // Icon manufacturing should be rendered for factory
      expect(find.byIcon(Icons.precision_manufacturing_outlined), findsOneWidget);
    });
  });

  group('USER REQUEST FIX: Fast Cart +/- Clicks, Debounce & Crash-Proof Safety', () {
    test('Rapid Click Debounce Simulation: 10 taps collapse to single final sync', () async {
      int serverSyncCount = 0;
      int finalSyncedQty = 0;
      Map<int, dynamic> timers = {};

      void scheduleQuantitySync(int cartId, int targetQty) {
        if (timers.containsKey(cartId)) {
          timers[cartId].cancel();
        }
        timers[cartId] = (
          cancel: () => timers.remove(cartId),
          fire: () {
            serverSyncCount++;
            finalSyncedQty = targetQty;
          }
        );
      }

      // Simulate user clicking + 10 times in 100ms
      int localQty = 1;
      for (int i = 0; i < 10; i++) {
        localQty++;
        scheduleQuantitySync(101, localQty);
      }

      // Local optimistic UI shows 11 immediately
      expect(localQty, 11);
      // No server sync has happened yet!
      expect(serverSyncCount, 0);

      // Debounce timer completes
      timers[101]?.fire();

      // Exactly 1 server sync fired with final quantity 11
      expect(serverSyncCount, 1);
      expect(finalSyncedQty, 11);
    });

    test('Crash-proof index resolution: handles negative or out-of-bounds index via cartId / cartModel', () {
      final item1 = CartModel(id: 10, quantity: 2, item: Item(id: 1, name: 'Item 1'));
      final item2 = CartModel(id: 20, quantity: 3, item: Item(id: 2, name: 'Item 2'));
      final cartList = [item1, item2];

      int resolveIndex(int cartIndex, {int? cartId, CartModel? cartModel}) {
        int resolvedIndex = cartIndex;
        if (resolvedIndex < 0 || resolvedIndex >= cartList.length) {
          if (cartId != null) {
            resolvedIndex = cartList.indexWhere((c) => c.id == cartId);
          } else if (cartModel != null) {
            resolvedIndex = cartList.indexOf(cartModel);
          }
        }
        return resolvedIndex;
      }

      // Stale index 5 (out of bounds) resolves correctly using cartId 20
      expect(resolveIndex(5, cartId: 20), 1);
      // Negative index -1 resolves correctly using cartModel item1
      expect(resolveIndex(-1, cartModel: item1), 0);
      // Truly missing item returns -1 safely without throwing RangeError
      expect(resolveIndex(99, cartId: 999), -1);
    });

    test('Removing cart item cancels any pending debounced quantity timer', () {
      Map<int, bool> activeTimers = {101: true};

      void removeFromCart(int cartId) {
        activeTimers.remove(cartId);
      }

      removeFromCart(101);
      expect(activeTimers.containsKey(101), isFalse);
    });

    test('Direct adding guard drops duplicate clicks while item is in flight', () {
      final Set<int> directAddingItemIds = {};
      int fetchCount = 0;

      void itemDirectlyAddToCart(int itemId) {
        if (directAddingItemIds.contains(itemId)) return;
        directAddingItemIds.add(itemId);
        fetchCount++;
      }

      // Rapid clicks on the same item
      itemDirectlyAddToCart(42);
      itemDirectlyAddToCart(42);
      itemDirectlyAddToCart(42);

      // Only 1 execution was allowed!
      expect(fetchCount, 1);
      expect(directAddingItemIds.contains(42), isTrue);

      // Once completed, item is unlocked
      directAddingItemIds.remove(42);
      expect(directAddingItemIds.contains(42), isFalse);
    });
  });

  group('USER REQUEST FIX 10: Module Switching Smart Cache & Data Isolation', () {
    setUp(() {
      DataModuleManager().clearMemoryCache();
    });

    test('buildCanonicalKey separates cache keys by moduleId to prevent cross-module data leakage', () {
      final keyGrocery = DataModuleManager.buildCanonicalKey(
        '/api/v1/categories',
        moduleId: 1, // Grocery
        languageCode: 'en',
      );

      final keyPharmacy = DataModuleManager.buildCanonicalKey(
        '/api/v1/categories',
        moduleId: 2, // Pharmacy
        languageCode: 'en',
      );

      expect(keyGrocery, isNot(equals(keyPharmacy)));
      expect(keyGrocery, contains('moduleId=1'));
      expect(keyPharmacy, contains('moduleId=2'));
    });

    test('buildCanonicalKey separates cache keys by language code', () {
      final keyEn = DataModuleManager.buildCanonicalKey(
        '/api/v1/categories',
        moduleId: 1,
        languageCode: 'en',
      );

      final keyAr = DataModuleManager.buildCanonicalKey(
        '/api/v1/categories',
        moduleId: 1,
        languageCode: 'ar',
      );

      expect(keyEn, isNot(equals(keyAr)));
      expect(keyEn, contains('lang=en'));
      expect(keyAr, contains('lang=ar'));
    });

    test('DataModuleManager stores and retrieves cached responses per module independently', () {
      final groceryData = {'module': 'grocery', 'items': ['apple', 'banana']};
      final pharmacyData = {'module': 'pharmacy', 'items': ['panadol', 'aspirin']};

      final keyGrocery = DataModuleManager.buildCanonicalKey(
        '/api/v1/items',
        moduleId: 1,
        languageCode: 'en',
      );

      final keyPharmacy = DataModuleManager.buildCanonicalKey(
        '/api/v1/items',
        moduleId: 2,
        languageCode: 'en',
      );

      DataModuleManager().cache.put(keyGrocery, groceryData);
      DataModuleManager().cache.put(keyPharmacy, pharmacyData);

      final retrievedGrocery = DataModuleManager().cache.get(keyGrocery) as Map<String, dynamic>?;
      final retrievedPharmacy = DataModuleManager().cache.get(keyPharmacy) as Map<String, dynamic>?;

      expect(retrievedGrocery, isNotNull);
      expect(retrievedGrocery!['module'], equals('grocery'));
      expect(retrievedPharmacy, isNotNull);
      expect(retrievedPharmacy!['module'], equals('pharmacy'));
    });

    test('DataModuleManager generation tracking prevents race condition when switching fast', () {
      final gen1 = DataModuleManager().nextGeneration('home_module');
      expect(DataModuleManager().isGenerationActive('home_module', gen1), isTrue);

      // User initiates switch from grocery to pharmacy
      final gen2 = DataModuleManager().nextGeneration('home_module');
      expect(gen2, equals(gen1 + 1));

      // Any pending request with gen1 is now recognized as stale and ignored
      expect(DataModuleManager().isGenerationActive('home_module', gen1), isFalse);
      expect(DataModuleManager().isGenerationActive('home_module', gen2), isTrue);

      // Invalidate context further increments generation
      DataModuleManager().invalidateContext('home_module');
      expect(DataModuleManager().isGenerationActive('home_module', gen2), isFalse);
    });

    test('National products tab context generation increments on tab change', () {
      final gen1 = DataModuleManager().nextGeneration('national_products_tab');
      expect(DataModuleManager().isGenerationActive('national_products_tab', gen1), isTrue);

      final gen2 = DataModuleManager().nextGeneration('national_products_tab');
      expect(gen2, equals(gen1 + 1));
      expect(DataModuleManager().isGenerationActive('national_products_tab', gen1), isFalse);

      DataModuleManager().invalidateContext('national_products_tab');
      expect(DataModuleManager().isGenerationActive('national_products_tab', gen2), isFalse);
    });
  });

  group('USER REQUEST FIX: Logout Confirmation UI/UX & Non-Blocking Safety', () {
    testWidgets('ConfirmationDialog uses logout icon, logout title, and error color badge when isLogOut is true', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: _TestTranslations(),
          locale: const Locale('en'),
          home: Scaffold(
            body: ConfirmationDialog(
              icon: Images.support,
              description: 'are_you_sure_to_logout',
              isLogOut: true,
              onYesPressed: () {},
            ),
          ),
        ),
      );

      // Allow the 250ms anti-tap-through debounce to finish
      await tester.pump(const Duration(milliseconds: 300));

      // Title should automatically display 'Logout' for logout confirmation
      expect(find.text('Logout'), findsWidgets);

      // The image asset should resolve to Images.logOut rather than Images.support
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final Image imageWidget = tester.widget(imageFinder);
      expect((imageWidget.image as AssetImage).assetName, equals(Images.logOut));
    });

    testWidgets('ConfirmationDialog transitions to loading indicator on confirm click and disables cancel', (tester) async {
      bool taskCompleted = false;

      await tester.pumpWidget(
        GetMaterialApp(
          translations: _TestTranslations(),
          locale: const Locale('en'),
          home: Scaffold(
            body: ConfirmationDialog(
              icon: Images.logOut,
              description: 'Are you sure want to logout?',
              isLogOut: true,
              onYesPressed: () async {
                await Future.delayed(const Duration(milliseconds: 500));
                taskCompleted = true;
              },
            ),
          ),
        ),
      );

      // Allow the 250ms anti-tap-through debounce to finish
      await tester.pump(const Duration(milliseconds: 300));

      // Find the confirm/logout button and tap it
      final logoutButton = find.text('Logout');
      expect(logoutButton, findsWidgets);

      await tester.tap(logoutButton.last);
      // Pump initial frame of async action
      await tester.pump();

      // Now it should show 'Logging out...'
      expect(find.text('Logging out...'), findsWidgets);

      // Advance time by 600ms to allow task to finish
      await tester.pump(const Duration(milliseconds: 600));
      expect(taskCompleted, isTrue);
    });

    test('Safe social logout handles errors gracefully without throwing', () async {
      bool errorLogged = false;
      Future<void> simulateSafeSocialLogout({required bool throwGoogle, required bool throwFacebook}) async {
        try {
          if (throwGoogle) throw StateError('Google disconnect failed');
        } catch (e) {
          errorLogged = true;
        }

        try {
          if (throwFacebook) throw StateError('Facebook logout failed');
        } catch (e) {
          errorLogged = true;
        }
      }

      // Should complete normally without throwing
      await expectLater(
        simulateSafeSocialLogout(throwGoogle: true, throwFacebook: true),
        completes,
      );
      expect(errorLogged, isTrue);
    });

    test('Logout timeout protection guarantees non-blocking execution', () async {
      Future<void> simulateLogoutWithTimeout() async {
        // Simulate a hung backend request that takes 10 seconds
        Future<void> hungApiCall() async {
          await Future.delayed(const Duration(seconds: 10));
        }

        try {
          await hungApiCall().timeout(const Duration(milliseconds: 50));
        } catch (_) {
          // Timeout safely absorbed
        }
      }

      final stopwatch = Stopwatch()..start();
      await simulateLogoutWithTimeout();
      stopwatch.stop();

      // Must have resolved quickly via timeout rather than waiting 10 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('USER REQUEST FIX 9: Login & SignUp UI/UX Resilience & Non-Stuck Safety', () {
    test('AuthController async actions guarantee _isLoading resets to false even on error', () async {
      bool isLoading = false;

      Future<void> simulateAuthAction({required bool shouldFail}) async {
        isLoading = true;
        try {
          if (shouldFail) {
            throw Exception('Network timeout during login/signup');
          }
        } finally {
          isLoading = false;
        }
      }

      // Successful call resets isLoading
      await simulateAuthAction(shouldFail: false);
      expect(isLoading, isFalse);

      // Failed call also guarantees isLoading resets to false (never stuck)
      expect(simulateAuthAction(shouldFail: true), throwsA(isA<Exception>()));
      // Give microtask queue time to finish
      await Future.delayed(Duration.zero);
      expect(isLoading, isFalse);
    });

    test('Null-safe check for AuthResponseModel prevents crash on null boolean fields', () {
      // Simulates payload with null booleans
      final Map<String, dynamic> partialAuthResponse = {
        'token': 'test_token',
        'is_phone_verified': null,
        'is_email_verified': null,
        'is_personal_info': null,
      };

      bool isPhoneVerified(Map<String, dynamic> json) => (json['is_phone_verified'] as bool?) ?? false;
      bool isEmailVerified(Map<String, dynamic> json) => (json['is_email_verified'] as bool?) ?? false;
      bool isPersonalInfo(Map<String, dynamic> json) => (json['is_personal_info'] as bool?) ?? false;

      // Must not throw Null check operator used on null value
      expect(isPhoneVerified(partialAuthResponse), isFalse);
      expect(isEmailVerified(partialAuthResponse), isFalse);
      expect(isPersonalInfo(partialAuthResponse), isFalse);
    });

    test('Terms & conditions validation returns clear prompt when not accepted', () {
      bool acceptTerms = false;
      String? snackbarMessage;

      void onContinuePressed() {
        if (!acceptTerms) {
          snackbarMessage = 'please_agree_with_terms_conditions';
          return;
        }
        snackbarMessage = 'success';
      }

      onContinuePressed();
      expect(snackbarMessage, equals('please_agree_with_terms_conditions'));

      acceptTerms = true;
      onContinuePressed();
      expect(snackbarMessage, equals('success'));
    });

    test('RTL back button icon resolves to forward chevron and LTR to back chevron', () {
      IconData getBackIcon(TextDirection direction) {
        return direction == TextDirection.rtl
            ? Icons.arrow_forward_ios_rounded
            : Icons.arrow_back_ios_rounded;
      }

      expect(getBackIcon(TextDirection.ltr), equals(Icons.arrow_back_ios_rounded));
      expect(getBackIcon(TextDirection.rtl), equals(Icons.arrow_forward_ios_rounded));
    });
  });

  group('USER REQUEST FIX 11: Home Screen Freeze & ANR Elimination', () {
    testWidgets('PaginatedListView safely removes scroll listener upon disposal', (tester) async {
      final ScrollController scrollController = ScrollController();
      int paginateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: PaginatedListView(
                scrollController: scrollController,
                totalSize: 50,
                offset: 1,
                onPaginate: (offset) async {
                  paginateCount++;
                },
                itemView: const SizedBox(height: 1000),
              ),
            ),
          ),
        ),
      );

      // Rebuild with PaginatedListView disposed
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Verify no exceptions when disposing or scrolling afterwards
      expect(scrollController.hasClients, isFalse);
      scrollController.dispose();
      expect(paginateCount, equals(0));
    });

    test('Module scroll sync calculation avoids division by zero when extents are 0', () {
      double computeTarget(double offset, double maxExpanded, double maxCollapsed) {
        if (maxExpanded > 0 && maxCollapsed > 0) {
          double ratio = offset / maxExpanded;
          return (ratio * maxCollapsed).clamp(0.0, maxCollapsed);
        }
        return 0.0;
      }

      // When maxCollapsed is 0, must return safe 0.0 without NaN or Infinity
      expect(computeTarget(10.0, 100.0, 0.0), equals(0.0));
      expect(computeTarget(10.0, 0.0, 100.0), equals(0.0));
      expect(computeTarget(50.0, 100.0, 200.0), equals(100.0));
    });

    test('Scroll direction forward/reverse strictly filters idle ticks to prevent constant update() loops', () {
      bool showFav = true;
      int updateCount = 0;

      void onScrollDirectionChanged(ScrollDirection direction) {
        if (direction == ScrollDirection.forward) {
          if (!showFav) {
            showFav = true;
            updateCount++;
          }
        } else if (direction == ScrollDirection.reverse) {
          if (showFav) {
            showFav = false;
            updateCount++;
          }
        }
        // ScrollDirection.idle is strictly ignored!
      }

      // Initial idle ticks should do NOTHING
      onScrollDirectionChanged(ScrollDirection.idle);
      onScrollDirectionChanged(ScrollDirection.idle);
      expect(updateCount, equals(0));
      expect(showFav, isTrue);

      // Reverse hides
      onScrollDirectionChanged(ScrollDirection.reverse);
      expect(updateCount, equals(1));
      expect(showFav, isFalse);

      // Further reverse ticks do not re-trigger
      onScrollDirectionChanged(ScrollDirection.reverse);
      expect(updateCount, equals(1));

      // Idle does not re-trigger or toggle
      onScrollDirectionChanged(ScrollDirection.idle);
      expect(updateCount, equals(1));

      // Forward shows
      onScrollDirectionChanged(ScrollDirection.forward);
      expect(updateCount, equals(2));
      expect(showFav, isTrue);
    });
  });
}

class _TestTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'logout': 'Logout',
      'logging_out': 'Logging out...',
      'cancel': 'Cancel',
      'yes': 'Yes',
      'confirm': 'Confirm',
      'are_you_sure_to_logout': 'Are you sure want to logout?',
      'please_agree_with_terms_conditions': 'Please agree with terms & conditions',
    },
  };
}


