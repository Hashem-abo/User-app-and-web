import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_model.dart';

void main() {
  group('PRODUCTION MODEL SUITE: OrderModel & PaginatedOrderModel', () {
    test('PaginatedOrderModel.fromJson should parse valid pagination payload', () {
      final json = {
        'total_size': 50,
        'limit': '10',
        'offset': '1',
        'orders': [
          {
            'id': 101,
            'user_id': 1,
            'order_amount': 250.50,
            'coupon_discount_amount': 20.0,
            'total_tax_amount': 15.0,
            'delivery_charge': 10.0,
            'store_discount_amount': 5.0,
          }
        ]
      };

      final paginated = PaginatedOrderModel.fromJson(json);
      expect(paginated.totalSize, equals(50));
      expect(paginated.limit, equals('10'));
      expect(paginated.offset, equals(1));
      expect(paginated.orders, isNotNull);
      expect(paginated.orders!.length, equals(1));
      expect(paginated.orders!.first.id, equals(101));
    });

    test('OrderModel.fromJson should parse null financial fields safely in production payload', () {
      final json = {
        'id': 202,
        'order_amount': 100.0,
        'coupon_discount_amount': null, // Omitted discount
        'total_tax_amount': null, // Omitted tax
        'delivery_charge': 0.0,
        'store_discount_amount': 0.0,
      };

      final order = OrderModel.fromJson(json);
      expect(order.id, equals(202));
      expect(order.couponDiscountAmount, equals(0.0));
      expect(order.totalTaxAmount, isNull);
    });

    test('OrderModel.fromJson should handle string formatted numeric amounts', () {
      final json = {
        'id': 303,
        'order_amount': 120.75,
        'coupon_discount_amount': 0,
        'total_tax_amount': 5,
        'delivery_charge': 15,
        'store_discount_amount': 0,
      };

      final order = OrderModel.fromJson(json);
      expect(order.id, equals(303));
      expect(order.orderAmount, equals(120.75));
    });
  });

  group('PRODUCTION MODEL SUITE: AddressModel Null & Casting Resilience', () {
    test('AddressModel.fromJson should parse complete address correctly', () {
      final json = {
        'id': 10,
        'address_type': 'Work',
        'contact_person_number': '+1234567890',
        'address': '742 Evergreen Terrace',
        'latitude': '37.7749',
        'longitude': '-122.4194',
        'zone_id': '5',
        'zone_ids': [1, 2, 5],
      };

      final address = AddressModel.fromJson(json);
      expect(address.id, equals(10));
      expect(address.addressType, equals('Work'));
      expect(address.contactPersonNumber, equals('+1234567890'));
      expect(address.latitude, equals('37.7749'));
      expect(address.zoneId, equals(5));
      expect(address.zoneIds, contains(5));
    });

    test('AddressModel.fromJson should preserve null for omitted contact numbers and coordinates', () {
      final json = {
        'id': 11,
        'address_type': 'Home',
        'contact_person_number': null,
        'latitude': null,
        'longitude': null,
      };

      final address = AddressModel.fromJson(json);
      expect(address.contactPersonNumber, isNull);
      expect(address.latitude, isNull);
      expect(address.longitude, isNull);
    });

    test('AddressModel.toJson should output matching keys', () {
      final address = AddressModel(
        id: 12,
        addressType: 'Home',
        address: '123 Main St',
        latitude: '10.0',
        longitude: '20.0',
      );

      final json = address.toJson();
      expect(json['id'], equals(12));
      expect(json['address_type'], equals('Home'));
      expect(json['address'], equals('123 Main St'));
    });
  });

  group('PRODUCTION MODEL SUITE: CartModel & Variations', () {
    test('CartModel.fromJson should parse valid cart item', () {
      final json = {
        'cart_id': 99,
        'price': 45.0,
        'discounted_price': 40.0,
        'discount_amount': 5.0,
        'quantity': 2,
        'quantity_limit': 10,
        'is_campaign': false,
        'note': 'No onions',
      };

      final cart = CartModel.fromJson(json);
      expect(cart.id, equals(99));
      expect(cart.price, equals(45.0));
      expect(cart.discountedPrice, equals(40.0));
      expect(cart.quantity, equals(2));
      expect(cart.quantityLimit, equals(10));
      expect(cart.note, equals('No onions'));
    });

    test('CartModel.fromJson should handle string quantity_limit', () {
      final json = {
        'cart_id': 100,
        'price': 20.0,
        'quantity_limit': '5',
      };

      final cart = CartModel.fromJson(json);
      expect(cart.quantityLimit, equals(5));
    });
  });

  group('PRODUCTION MODEL SUITE: CouponModel & CategoryModel', () {
    test('CouponModel.fromJson should parse percentage coupon', () {
      final json = {
        'id': 1,
        'title': 'SUMMER20',
        'code': 'SUMMER20',
        'start_date': '2026-06-01',
        'expire_date': '2026-08-31',
        'min_purchase': 50.0,
        'max_discount': 20.0,
        'discount': 20.0,
        'discount_type': 'percent',
        'coupon_type': 'default',
      };

      final coupon = CouponModel.fromJson(json);
      expect(coupon.id, equals(1));
      expect(coupon.code, equals('SUMMER20'));
      expect(coupon.discountType, equals('percent'));
      expect(coupon.discount, equals(20.0));
    });

    test('CategoryModel.fromJson should parse hierarchy categories', () {
      final json = {
        'id': 15,
        'name': 'Electronics',
        'image_full_url': 'cat.jpg',
        'childes_count': 3,
      };

      final category = CategoryModel.fromJson(json);
      expect(category.id, equals(15));
      expect(category.name, equals('Electronics'));
      expect(category.childesCount, equals(3));
    });
  });

  group('PRODUCTION MODEL SUITE: ReviewModel & NotificationModel', () {
    test('ReviewModel.fromJson should parse item review with rating', () {
      final json = {
        'id': 88,
        'comment': 'Great product!',
        'rating': 5,
        'user_name': 'John Doe',
        'created_at': '2026-08-10 12:00:00',
      };

      final review = ReviewModel.fromJson(json);
      expect(review.id, equals(88));
      expect(review.comment, equals('Great product!'));
      expect(review.rating, equals(5));
    });

    test('NotificationModel.fromJson should parse push notification object', () {
      final json = {
        'id': 5,
        'data': {
          'title': 'Order Out for Delivery',
          'description': 'Your order #101 is on the way!',
          'type': 'order_status',
        },
        'created_at': '2026-08-11T10:00:00.000Z',
      };

      final notification = NotificationModel.fromJson(json);
      expect(notification.id, equals(5));
      expect(notification.data?.title, equals('Order Out for Delivery'));
      expect(notification.data?.description, equals('Your order #101 is on the way!'));
    });
  });
}
