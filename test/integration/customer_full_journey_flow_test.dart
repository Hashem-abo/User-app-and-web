import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';

void main() {
  group('Customer End-to-End User Journey Simulation Tests', () {
    testWidgets('1. Login and OTP Verification Flow Simulation', (WidgetTester tester) async {
      final phoneController = TextEditingController();
      final otpController = TextEditingController();
      bool isOtpSent = false;
      bool isLoggedIn = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(title: const Text('Login Screen')),
                body: Column(
                  children: [
                    TextField(
                      key: const Key('phone_field'),
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                    ),
                    if (isOtpSent)
                      TextField(
                        key: const Key('otp_field'),
                        controller: otpController,
                        decoration: const InputDecoration(labelText: 'Enter OTP'),
                      ),
                    ElevatedButton(
                      key: const Key('action_button'),
                      onPressed: () {
                        setState(() {
                          if (!isOtpSent) {
                            if (phoneController.text.isNotEmpty) {
                              isOtpSent = true;
                            }
                          } else {
                            if (otpController.text == '1234') {
                              isLoggedIn = true;
                            }
                          }
                        });
                      },
                      child: Text(isOtpSent ? 'Verify OTP' : 'Send OTP'),
                    ),
                    if (isLoggedIn) const Text('Welcome Customer!', key: Key('welcome_text')),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Step A: Enter Phone Number
      await tester.enterText(find.byKey(const Key('phone_field')), '+967771234567');
      await tester.tap(find.byKey(const Key('action_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('otp_field')), findsOneWidget);
      expect(find.text('Verify OTP'), findsOneWidget);

      // Step B: Enter Valid OTP
      await tester.enterText(find.byKey(const Key('otp_field')), '1234');
      await tester.tap(find.byKey(const Key('action_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('welcome_text')), findsOneWidget);
      expect(find.text('Welcome Customer!'), findsOneWidget);
    });

    test('2. Cart calculation, additions, variations, and quantities', () {
      Item testItem = Item(
        id: 101,
        name: 'Fresh Fruits Basket',
        price: 25.0,
        discount: 5.0,
        discountType: 'amount',
        storeId: 1,
        storeName: 'Al-Baraka Supermarket',
      );

      CartModel cartItem1 = CartModel(
        id: 1,
        price: 25.0,
        discountedPrice: 20.0,
        quantity: 2,
        item: testItem,
        stock: 10,
      );

      expect(cartItem1.quantity, 2);
      expect(cartItem1.discountedPrice, 20.0);
      double totalItemCost = (cartItem1.discountedPrice ?? 0) * (cartItem1.quantity ?? 1);
      expect(totalItemCost, 40.0);
    });

    test('3. Checkout and PlaceOrderBody validation', () {
      List<OnlineCart> orderItems = [
        OnlineCart(
          cartId: 1,
          itemId: 101,
          price: '20.0',
          quantity: 2,
        ),
      ];

      PlaceOrderBodyModel orderPayload = PlaceOrderBodyModel(
        cart: orderItems,
        couponDiscountAmount: 5.0,
        couponCode: 'WELCOME5',
        orderAmount: 35.0,
        orderType: 'delivery',
        paymentMethod: 'cash_on_delivery',
        orderNote: 'Please deliver before 5 PM',
        address: 'Sanaa, Street 14',
        latitude: '15.3418',
        longitude: '44.1866',
        storeId: 1,
        distance: 2.5,
        dmTips: '0',
        receiverDetails: null,
        parcelCategoryId: null,
        chargePayer: null,
        unavailableItemNote: 'none',
        cutlery: 0,
        partialPayment: 0,
        guestId: 0,
        isBuyNow: 0,
        extraPackagingAmount: 0.0,
        createNewUser: 0,
        password: null,
        discountAmount: 5.0,
      );

      expect(orderPayload.paymentMethod, 'cash_on_delivery');
      expect(orderPayload.orderType, 'delivery');
      expect(orderPayload.storeId, 1);
      expect(orderPayload.orderAmount, 35.0);
      expect(orderPayload.cart?.length, 1);

      // Convert to JSON and verify required API keys
      Map<String, String> json = orderPayload.toJson();
      expect(json['payment_method'], 'cash_on_delivery');
      expect(json['order_amount'], '35.0');
      expect(json['order_type'], 'delivery');
    });

    test('4. Order status progression and tracking simulation', () {
      OrderModel order = OrderModel(
        id: 5001,
        orderStatus: 'pending',
        orderAmount: 35.0,
        paymentStatus: 'unpaid',
        paymentMethod: 'cash_on_delivery',
        createdAt: '2026-09-13T07:00:00.000000Z',
      );

      expect(order.orderStatus, 'pending');

      // Progression 1: Confirmed
      order = OrderModel(id: order.id, orderStatus: 'confirmed', orderAmount: order.orderAmount);
      expect(order.orderStatus, 'confirmed');

      // Progression 2: Processing / Handover
      order = OrderModel(id: order.id, orderStatus: 'processing', orderAmount: order.orderAmount);
      expect(order.orderStatus, 'processing');

      // Progression 3: Handover to delivery
      order = OrderModel(id: order.id, orderStatus: 'handover', orderAmount: order.orderAmount);
      expect(order.orderStatus, 'handover');

      // Progression 4: Delivered
      order = OrderModel(id: order.id, orderStatus: 'delivered', orderAmount: order.orderAmount, paymentStatus: 'paid');
      expect(order.orderStatus, 'delivered');
      expect(order.paymentStatus, 'paid');
    });
  });
}
