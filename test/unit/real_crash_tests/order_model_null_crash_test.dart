// PRODUCTION TESTS: OrderModel & Sub-Models (All Fixes Verified)
//
// These tests verify that OrderModel, DeliveryMan, OfflinePayment,
// and OrderDetailsModel safely parse real-world incomplete or null API payloads
// without runtime exceptions, and correctly serialize data.
//
// Run with:  flutter test test/unit/real_crash_tests/order_model_null_crash_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart' as od;
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

void main() {
  // ---------------------------------------------------------------------------
  // OrderModel.fromJson – Null-Safety for numeric fields
  // ---------------------------------------------------------------------------
  group('[FIXED] OrderModel.fromJson – null numeric fields default safely without crashing', () {
    test('order_amount is null -> defaults to 0.0 safely', () {
      final json = <String, dynamic>{'order_amount': null};
      final order = OrderModel.fromJson(json);
      expect(order.orderAmount, equals(0.0));
      expect(order.orderAmount, isA<double>());
    });

    test('coupon_discount_amount is null -> defaults to 0.0 safely', () {
      final json = <String, dynamic>{'order_amount': 10.0, 'coupon_discount_amount': null};
      final order = OrderModel.fromJson(json);
      expect(order.couponDiscountAmount, equals(0.0));
    });

    test('total_tax_amount is null -> remains null (optional field)', () {
      final json = <String, dynamic>{
        'order_amount': 10.0,
        'coupon_discount_amount': 0.0,
        'total_tax_amount': null,
      };
      final order = OrderModel.fromJson(json);
      expect(order.totalTaxAmount, isNull);
    });

    test('delivery_charge is null -> defaults to 0.0 safely', () {
      final json = <String, dynamic>{
        'order_amount': 10.0,
        'delivery_charge': null,
      };
      final order = OrderModel.fromJson(json);
      expect(order.deliveryCharge, equals(0.0));
    });

    test('store_discount_amount is null -> defaults to 0.0 safely', () {
      final json = <String, dynamic>{
        'order_amount': 10.0,
        'store_discount_amount': null,
      };
      final order = OrderModel.fromJson(json);
      expect(order.storeDiscountAmount, equals(0.0));
    });

    test('dm_tips is null -> defaults to 0.0 safely', () {
      final json = <String, dynamic>{
        'order_amount': 10.0,
        'dm_tips': null,
      };
      final order = OrderModel.fromJson(json);
      expect(order.dmTips, equals(0.0));
    });

    test('full numeric payload parses correctly', () {
      final json = <String, dynamic>{
        'id': 101,
        'user_id': 5,
        'order_amount': 120.50,
        'coupon_discount_amount': 10.0,
        'total_tax_amount': 8.0,
        'delivery_charge': 5.0,
        'store_discount_amount': 0.0,
        'dm_tips': 2.0,
        'payment_status': 'paid',
        'order_status': 'delivered',
        'pro_customer': false,
      };

      final order = OrderModel.fromJson(json);
      expect(order.id, equals(101));
      expect(order.orderAmount, equals(120.50));
      expect(order.couponDiscountAmount, equals(10.0));
      expect(order.totalTaxAmount, equals(8.0));
      expect(order.deliveryCharge, equals(5.0));
      expect(order.dmTips, equals(2.0));
    });

    test('integer numeric values from backend coerce to double', () {
      final json = <String, dynamic>{
        'order_amount': 100,
        'coupon_discount_amount': 5,
        'total_tax_amount': 2,
        'delivery_charge': 3,
        'store_discount_amount': 0,
        'dm_tips': 1,
      };
      final order = OrderModel.fromJson(json);
      expect(order.orderAmount, equals(100.0));
      expect(order.orderAmount, isA<double>());
      expect(order.couponDiscountAmount, equals(5.0));
      expect(order.totalTaxAmount, equals(2.0));
      expect(order.deliveryCharge, equals(3.0));
      expect(order.storeDiscountAmount, equals(0.0));
      expect(order.dmTips, equals(1.0));
    });
  });

  // ---------------------------------------------------------------------------
  // OrderModel.toJson – Refund serialization fix
  // ---------------------------------------------------------------------------
  group('[FIXED] OrderModel.toJson – refund is properly included when deliveryAddress is null', () {
    test('toJson serializes refund correctly when deliveryAddress is null', () {
      final order = OrderModel(
        id: 200,
        deliveryAddress: null,
        refund: Refund(id: 99, orderId: 200),
      );

      final json = order.toJson();
      expect(json.containsKey('refund'), isTrue);
      expect(json['refund'], isNotNull);
      expect(json['refund']['id'], equals(99));
      expect(json['refund']['order_id'], equals(200));
    });

    test('toJson excludes refund when refund is null', () {
      final order = OrderModel(
        id: 201,
        deliveryAddress: null,
        refund: null,
      );

      final json = order.toJson();
      expect(json.containsKey('refund'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // DeliveryMan.fromJson – avgRating null safety
  // ---------------------------------------------------------------------------
  group('[FIXED] DeliveryMan.fromJson – avg_rating null safety', () {
    test('avg_rating is null -> defaults to 0.0 without crashing', () {
      final json = <String, dynamic>{
        'id': 10,
        'f_name': 'Ali',
        'l_name': 'Hassan',
        'phone': '+966500000000',
        'avg_rating': null,
        'rating_count': 0,
      };

      final dm = DeliveryMan.fromJson(json);
      expect(dm.avgRating, equals(0.0));
      expect(dm.avgRating, isA<double>());
    });

    test('avg_rating as double parses correctly', () {
      final json = <String, dynamic>{
        'id': 11,
        'f_name': 'Omar',
        'avg_rating': 4.5,
        'rating_count': 12,
      };

      final dm = DeliveryMan.fromJson(json);
      expect(dm.avgRating, equals(4.5));
    });

    test('avg_rating as int parses correctly', () {
      final json = <String, dynamic>{
        'id': 12,
        'f_name': 'Khalid',
        'avg_rating': 5,
        'rating_count': 3,
      };

      final dm = DeliveryMan.fromJson(json);
      expect(dm.avgRating, equals(5.0));
    });
  });

  // ---------------------------------------------------------------------------
  // Payments.fromJson
  // ---------------------------------------------------------------------------
  group('[OK] Payments.fromJson – safe with ?.toDouble()', () {
    test('amount null is handled safely', () {
      final json = <String, dynamic>{
        'id': 1,
        'order_id': 99,
        'amount': null,
        'payment_status': 'pending',
        'payment_method': 'cash',
      };

      final payment = Payments.fromJson(json);
      expect(payment.amount, isNull);
    });

    test('amount as int is coerced to double', () {
      final json = <String, dynamic>{
        'id': 2,
        'order_id': 100,
        'amount': 50,
        'payment_status': 'paid',
        'payment_method': 'online',
      };

      final payment = Payments.fromJson(json);
      expect(payment.amount, equals(50.0));
    });
  });

  // ---------------------------------------------------------------------------
  // OfflinePayment.toJson – methodFields serialization fix
  // ---------------------------------------------------------------------------
  group('[FIXED] OfflinePayment.toJson – methodFields correctly uses methodFields data', () {
    test('method_fields output contains methodFields data, not input data', () {
      final payment = OfflinePayment(
        input: [Input(userInput: 'account_number', userData: '123456')],
        methodFields: [MethodFields(inputName: 'bank_name', inputData: 'Al Rajhi')],
      );

      final json = payment.toJson();

      final List<dynamic> methodFieldsJson = json['method_fields'] as List<dynamic>;
      final firstEntry = methodFieldsJson.first as Map<String, dynamic>;

      expect(firstEntry.containsKey('input_name'), isTrue);
      expect(firstEntry['input_name'], equals('bank_name'));
      expect(firstEntry['input_data'], equals('Al Rajhi'));
      expect(firstEntry.containsKey('user_input'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // OrderDetailsModel.fromJson & AddOn.fromJson
  // ---------------------------------------------------------------------------
  group('[FIXED] OrderDetailsModel.fromJson & AddOn.fromJson – price null safety', () {
    test('price is null -> defaults to 0.0 without crashing', () {
      final json = <String, dynamic>{
        'id': 1,
        'item_id': 10,
        'order_id': 100,
        'price': null,
        'quantity': 2,
        'variation': [],
      };

      final detail = od.OrderDetailsModel.fromJson(json);
      expect(detail.price, equals(0.0));
      expect(detail.price, isA<double>());
    });

    test('standard detail line parses correctly', () {
      final json = <String, dynamic>{
        'id': 2,
        'item_id': 20,
        'order_id': 200,
        'price': 25.0,
        'quantity': 1,
        'variation': [],
        'discount_on_item': 5.0,
        'discount_type': 'amount',
        'tax_amount': 2.5,
        'total_add_on_price': 0.0,
      };

      final detail = od.OrderDetailsModel.fromJson(json);
      expect(detail.price, equals(25.0));
      expect(detail.quantity, equals(1));
    });

    test('AddOn price null -> defaults to 0.0 without crashing', () {
      final json = <String, dynamic>{
        'name': 'Extra Sauce',
        'price': null,
        'quantity': '1',
      };

      final addOn = od.AddOn.fromJson(json);
      expect(addOn.price, equals(0.0));
      expect(addOn.price, isA<double>());
    });
  });

  // ---------------------------------------------------------------------------
  // PaginatedOrderModel.fromJson – edge cases
  // ---------------------------------------------------------------------------
  group('[OK/EDGE] PaginatedOrderModel.fromJson – pagination field edge cases', () {
    test('standard response parses correctly', () {
      final json = <String, dynamic>{
        'total_size': 25,
        'limit': '10',
        'offset': '1',
        'orders': [],
      };

      final model = PaginatedOrderModel.fromJson(json);
      expect(model.totalSize, equals(25));
      expect(model.limit, equals('10'));
      expect(model.offset, equals(1));
      expect(model.orders, isEmpty);
    });

    test('integer offset and limit from backend', () {
      final json = <String, dynamic>{
        'total_size': 5,
        'limit': 5,
        'offset': 0,
        'orders': null,
      };

      final model = PaginatedOrderModel.fromJson(json);
      expect(model.limit, equals('5'));
      expect(model.offset, equals(0));
      expect(model.orders, isNull);
    });

    test('empty string offset treated as null', () {
      final json = <String, dynamic>{
        'total_size': 0,
        'limit': '10',
        'offset': '',
        'orders': null,
      };

      final model = PaginatedOrderModel.fromJson(json);
      expect(model.offset, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // proCustomer field – multi-type handling
  // ---------------------------------------------------------------------------
  group('[OK] OrderModel proCustomer – handles all backend type variations', () {
    Map<String, dynamic> baseJson(dynamic proCustomerValue) => <String, dynamic>{
      'id': 999,
      'order_amount': 50.0,
      'coupon_discount_amount': 0.0,
      'total_tax_amount': 0.0,
      'delivery_charge': 0.0,
      'store_discount_amount': 0.0,
      'dm_tips': 0.0,
      'pro_customer': proCustomerValue,
    };

    test('bool true maps to true', () => expect(OrderModel.fromJson(baseJson(true)).proCustomer, isTrue));
    test('int 1 maps to true', () => expect(OrderModel.fromJson(baseJson(1)).proCustomer, isTrue));
    test('string "1" maps to true', () => expect(OrderModel.fromJson(baseJson('1')).proCustomer, isTrue));
    test('string "true" maps to true', () => expect(OrderModel.fromJson(baseJson('true')).proCustomer, isTrue));
    test('bool false maps to false', () => expect(OrderModel.fromJson(baseJson(false)).proCustomer, isFalse));
    test('int 0 maps to false', () => expect(OrderModel.fromJson(baseJson(0)).proCustomer, isFalse));
    test('null maps to false', () => expect(OrderModel.fromJson(baseJson(null)).proCustomer, isFalse));
  });

  // ---------------------------------------------------------------------------
  // ParcelCancellation.fromJson – reason field type variance
  // ---------------------------------------------------------------------------
  group('[OK] ParcelCancellation.fromJson – reason field as List vs String', () {
    test('reason as JSON array', () {
      final json = <String, dynamic>{
        'id': 1,
        'order_id': 100,
        'reason': ['Wrong address', 'Customer unavailable'],
        'cancel_by': 'delivery_man',
        'return_fee': '5.00',
        'dm_penalty_fee': null,
      };

      final cancellation = ParcelCancellation.fromJson(json);
      expect(cancellation.reason, isNotNull);
      expect(cancellation.reason!.length, equals(2));
      expect(cancellation.reason, contains('Wrong address'));
    });

    test('reason as stringified array', () {
      final json = <String, dynamic>{
        'id': 2,
        'order_id': 101,
        'reason': '[Wrong address, Customer unavailable]',
        'cancel_by': 'admin',
      };

      final cancellation = ParcelCancellation.fromJson(json);
      expect(cancellation.reason, isNotNull);
      expect(cancellation.reason!.length, equals(2));
    });

    test('reason null is preserved', () {
      final json = <String, dynamic>{
        'id': 3,
        'order_id': 102,
        'reason': null,
        'cancel_by': 'customer',
      };

      expect(ParcelCancellation.fromJson(json).reason, isNull);
    });

    test('return_fee as decimal string parses to double', () {
      final json = <String, dynamic>{
        'id': 4,
        'order_id': 103,
        'reason': null,
        'return_fee': '12.50',
        'dm_penalty_fee': '3.00',
      };

      final c = ParcelCancellation.fromJson(json);
      expect(c.returnFee, closeTo(12.50, 0.001));
      expect(c.dmPenaltyFee, closeTo(3.00, 0.001));
    });
  });
}
