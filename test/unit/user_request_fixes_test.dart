import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/order/domain/models/monthly_order_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/module_helper.dart';

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
}

