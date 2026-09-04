import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/vendor_type_badge_widget.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/vendor_type_helper.dart';

void main() {
  group('VendorTypeHelper & VendorTypeBadgeWidget Comprehensive Tests', () {
    test('VendorTypeHelper correctly identifies retailer strings', () {
      expect(VendorTypeHelper.isRetailer('retail'), isTrue);
      expect(VendorTypeHelper.isRetailer('Retail'), isTrue);
      expect(VendorTypeHelper.isRetailer('retailer'), isTrue);
      expect(VendorTypeHelper.isRetailer('Retailer'), isTrue);
      expect(VendorTypeHelper.isRetailer('retails'), isTrue);
      expect(VendorTypeHelper.isRetailer('تجزئة'), isTrue);
      expect(VendorTypeHelper.isRetailer('قطاعي'), isTrue);
      expect(VendorTypeHelper.isRetailer('مفرق'), isTrue);
      expect(VendorTypeHelper.isRetailer('تاجر تجزئة'), isTrue);

      // Non-retail
      expect(VendorTypeHelper.isRetailer('wholesale'), isFalse);
      expect(VendorTypeHelper.isRetailer('factory'), isFalse);
      expect(VendorTypeHelper.isRetailer(''), isFalse);
      expect(VendorTypeHelper.isRetailer(null), isFalse);
    });

    test('VendorTypeHelper correctly identifies wholesaler strings', () {
      expect(VendorTypeHelper.isWholesaler('wholesale'), isTrue);
      expect(VendorTypeHelper.isWholesaler('Wholesale'), isTrue);
      expect(VendorTypeHelper.isWholesaler('wholesaler'), isTrue);
      expect(VendorTypeHelper.isWholesaler('wholesalers'), isTrue);
      expect(VendorTypeHelper.isWholesaler('جملة'), isTrue);
      expect(VendorTypeHelper.isWholesaler('تاجر جملة'), isTrue);

      expect(VendorTypeHelper.isWholesaler('retail'), isFalse);
      expect(VendorTypeHelper.isWholesaler('factory'), isFalse);
    });

    test('VendorTypeHelper correctly identifies factory strings', () {
      expect(VendorTypeHelper.isFactory('factory'), isTrue);
      expect(VendorTypeHelper.isFactory('Factory'), isTrue);
      expect(VendorTypeHelper.isFactory('factories'), isTrue);
      expect(VendorTypeHelper.isFactory('manufacturer'), isTrue);
      expect(VendorTypeHelper.isFactory('manufacturers'), isTrue);
      expect(VendorTypeHelper.isFactory('مصنع'), isTrue);
      expect(VendorTypeHelper.isFactory('معمل'), isTrue);

      expect(VendorTypeHelper.isFactory('retail'), isFalse);
      expect(VendorTypeHelper.isFactory('wholesale'), isFalse);
    });

    test('VendorTypeHelper correctly identifies empty and null-like strings', () {
      expect(VendorTypeHelper.isEmpty(null), isTrue);
      expect(VendorTypeHelper.isEmpty(''), isTrue);
      expect(VendorTypeHelper.isEmpty('   '), isTrue);
      expect(VendorTypeHelper.isEmpty('null'), isTrue);
      expect(VendorTypeHelper.isEmpty('Null'), isTrue);
      expect(VendorTypeHelper.isEmpty('none'), isTrue);
      expect(VendorTypeHelper.isEmpty('undefined'), isTrue);

      expect(VendorTypeHelper.isEmpty('wholesale'), isFalse);
      expect(VendorTypeHelper.isEmpty('retail'), isFalse);
      expect(VendorTypeHelper.isEmpty('factory'), isFalse);
    });

    test('resolveVendorType hides retailer and empty, returns empty string', () {
      expect(VendorTypeHelper.resolveVendorType('retail'), equals(''));
      expect(VendorTypeHelper.resolveVendorType('retailer'), equals(''));
      expect(VendorTypeHelper.resolveVendorType('تجزئة'), equals(''));
      expect(VendorTypeHelper.resolveVendorType(null), equals(''));
      expect(VendorTypeHelper.resolveVendorType(''), equals(''));
      expect(VendorTypeHelper.resolveVendorType('   '), equals(''));
      expect(VendorTypeHelper.resolveVendorType('null'), equals(''));
      expect(VendorTypeHelper.resolveVendorType('none'), equals(''));
    });

    test('resolveVendorType produces Arabic words when locale is Arabic (ar)', () {
      Get.locale = const Locale('ar', 'YE');

      expect(VendorTypeHelper.resolveVendorType('wholesale'), equals('جملة'));
      expect(VendorTypeHelper.resolveVendorType('wholesaler'), equals('جملة'));
      expect(VendorTypeHelper.resolveVendorType('جملة'), equals('جملة'));

      expect(VendorTypeHelper.resolveVendorType('factory'), equals('مصنع'));
      expect(VendorTypeHelper.resolveVendorType('manufacturer'), equals('مصنع'));
      expect(VendorTypeHelper.resolveVendorType('مصنع'), equals('مصنع'));

      // Retailer is still hidden even in Arabic
      expect(VendorTypeHelper.resolveVendorType('retail'), equals(''));
      expect(VendorTypeHelper.resolveVendorType('تجزئة'), equals(''));
    });

    test('resolveVendorType produces English words when locale is English (en)', () {
      Get.locale = const Locale('en', 'US');

      expect(VendorTypeHelper.resolveVendorType('wholesale'), anyOf(equals('Wholesale'), equals('wholesale')));
      expect(VendorTypeHelper.resolveVendorType('factory'), anyOf(equals('Factory'), equals('factory')));

      // Retailer is still hidden in English
      expect(VendorTypeHelper.resolveVendorType('retail'), equals(''));
      expect(VendorTypeHelper.resolveVendorType('retailer'), equals(''));
    });

    test('Store model vendorType returns empty string for retailer stores', () {
      final retailStore = Store.fromJson({
        'id': 1,
        'name': 'Retail Supermarket',
        'module_id': 1,
        'vendor_type': 'retail',
      });
      expect(retailStore.vendorType, equals(''));
      expect(retailStore.vendorType.isEmpty, isTrue);

      final retailerStore = Store.fromJson({
        'id': 2,
        'name': 'Retailer Store',
        'module_id': 1,
        'vendor_type': 'retailer',
      });
      expect(retailerStore.vendorType, equals(''));

      final arabicRetailStore = Store.fromJson({
        'id': 3,
        'name': 'متجر تجزئة',
        'module_id': 1,
        'vendor_type': 'تجزئة',
      });
      expect(arabicRetailStore.vendorType, equals(''));
    });

    test('Store model vendorType keeps wholesale and factory stores', () {
      Get.locale = const Locale('ar', 'YE');

      final wholesaleStore = Store.fromJson({
        'id': 4,
        'name': 'Wholesale Mart',
        'module_id': 1,
        'vendor_type': 'wholesale',
      });
      expect(wholesaleStore.vendorType, equals('جملة'));

      final factoryStore = Store.fromJson({
        'id': 5,
        'name': 'Food Factory',
        'module_id': 1,
        'vendor_type': 'factory',
      });
      expect(factoryStore.vendorType, equals('مصنع'));
    });

    testWidgets('VendorTypeBadgeWidget renders nothing for retailer or empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                VendorTypeBadgeWidget(vendorType: 'retail'),
                VendorTypeBadgeWidget(vendorType: 'retailer'),
                VendorTypeBadgeWidget(vendorType: 'تجزئة'),
                VendorTypeBadgeWidget(vendorType: ''),
                VendorTypeBadgeWidget(vendorType: 'null'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsNothing);
      expect(find.text('retail'), findsNothing);
      expect(find.text('Retail'), findsNothing);
      expect(find.text('تجزئة'), findsNothing);
    });

    testWidgets('VendorTypeBadgeWidget renders badge for wholesale and factory with correct Arabic text and icons', (tester) async {
      Get.locale = const Locale('ar', 'YE');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const VendorTypeBadgeWidget(vendorType: 'wholesale'),
                const VendorTypeBadgeWidget(vendorType: 'factory'),
              ],
            ),
          ),
        ),
      );

      // Verify Arabic labels
      expect(find.text('جملة'), findsOneWidget);
      expect(find.text('مصنع'), findsOneWidget);

      // Verify icons
      expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
      expect(find.byIcon(Icons.precision_manufacturing_outlined), findsOneWidget);
    });
  });
}
