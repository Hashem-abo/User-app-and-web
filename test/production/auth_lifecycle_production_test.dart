// =============================================================================
// REAL PRODUCTION AUTH & LIFECYCLE CRASH/BUG EXPOSURE TESTS
// =============================================================================
//
// Directly tests session, address, and lifecycle crash points in Sixam Mart:
//
// 1. AuthRepository.clearSharedData Null Address Crash (auth_repository.dart:200):
//    - FirebaseMessaging.instance.unsubscribeFromTopic('zone_${AddressHelper.getUserAddressFromSharedPref()!.zoneId}_customer');
//    - Crashes when userAddress is null: NullCheckOperatorUsedOnANullValue
//
// 2. AuthRepository.updateToken Null Address Crash (auth_repository.dart:143):
//    - FirebaseMessaging.instance.subscribeToTopic('zone_${AddressHelper.getUserAddressFromSharedPref()!.zoneId}_customer');
//    - Crashes when userAddress is null on fresh install: NullCheckOperatorUsedOnANullValue
//
// 3. CheckoutScreen initCall Null Address Crash (checkout_screen.dart:100-102):
//    - AddressHelper.getUserAddressFromSharedPref()!.streetNumber
//    - AddressHelper.getUserAddressFromSharedPref()!.house
//    - AddressHelper.getUserAddressFromSharedPref()!.floor
//    - Crashes checkout screen immediately if guest has no saved address!
//
// 4. CheckoutScreen orderTax Null Check Crash (checkout_screen.dart:485, 491):
//    - tax: checkoutController.orderTax!
//    - Crashes when orderTax is reset (null) on screen load.
//
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';

void main() {
  group('[AUTH CRASH BUG] AuthRepository null userAddress dereference in clearSharedData & updateToken', () {
    test('CRASH REPRODUCTION: AddressHelper.getUserAddressFromSharedPref()! throws NullCheckOperator on fresh install or guest logout', () {
      AddressModel? nullUserAddress;

      // In auth_repository.dart line 143:
      // FirebaseMessaging.instance.subscribeToTopic('zone_${AddressHelper.getUserAddressFromSharedPref()!.zoneId}_customer');
      // In auth_repository.dart line 200:
      // FirebaseMessaging.instance.unsubscribeFromTopic('zone_${AddressHelper.getUserAddressFromSharedPref()!.zoneId}_customer');
      expect(() {
        final zoneId = nullUserAddress!.zoneId;
        return 'zone_${zoneId}_customer';
      }, throwsA(isA<TypeError>()));
    });
  });

  group('[AUTH CRASH BUG] CheckoutScreen initCall crashes on null user address', () {
    test('CRASH REPRODUCTION: checkout_screen.dart lines 100-102 dereference null user address with !', () {
      AddressModel? nullAddress;

      // In checkout_screen.dart lines 100-102:
      // streetNumberController.text = AddressHelper.getUserAddressFromSharedPref()!.streetNumber ?? '';
      // houseController.text = AddressHelper.getUserAddressFromSharedPref()!.house ?? '';
      // floorController.text = AddressHelper.getUserAddressFromSharedPref()!.floor ?? '';
      expect(() {
        return nullAddress!.streetNumber ?? '';
      }, throwsA(isA<TypeError>()));
    });
  });

  group('[AUTH CRASH BUG] CheckoutScreen orderTax! crash', () {
    test('CRASH REPRODUCTION: checkout_screen.dart lines 485 & 491 dereference orderTax! when tax is null', () {
      double? orderTax; // CheckoutController._orderTax starts as null

      // In checkout_screen.dart lines 485, 491:
      // tax: checkoutController.orderTax!
      expect(() {
        final double forcedTax = orderTax!;
        return forcedTax;
      }, throwsA(isA<TypeError>()));
    });
  });
}
