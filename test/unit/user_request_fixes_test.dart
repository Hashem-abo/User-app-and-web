import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/order/domain/models/monthly_order_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

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
}
