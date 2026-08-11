// PRODUCTION TESTS: AddressModel (Fixes Verified)
//
// Verifies that AddressModel.fromJson preserves true null values instead of
// corrupting them into the string "null", ensuring UI and GPS map rendering work properly.
//
// Run with:  flutter test test/unit/real_crash_tests/address_model_null_string_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';

void main() {
  group('[FIXED] AddressModel.fromJson – null fields stay null instead of string "null"', () {
    test('contact_person_number null stays null', () {
      final json = <String, dynamic>{
        'id': 1,
        'address_type': 'Home',
        'address': '123 Main St',
        'contact_person_number': null,
        'latitude': '24.8607',
        'longitude': '67.0011',
      };

      final address = AddressModel.fromJson(json);
      expect(address.contactPersonNumber, isNull);
    });

    test('latitude null stays null', () {
      final json = <String, dynamic>{
        'id': 2,
        'address_type': 'Work',
        'address': '456 Market St',
        'contact_person_number': '+1234567890',
        'latitude': null,
        'longitude': '67.0011',
      };

      final address = AddressModel.fromJson(json);
      expect(address.latitude, isNull);
    });

    test('longitude null stays null', () {
      final json = <String, dynamic>{
        'id': 3,
        'address_type': 'Other',
        'address': '789 Oak Ave',
        'contact_person_number': '+1234567890',
        'latitude': '24.8607',
        'longitude': null,
      };

      final address = AddressModel.fromJson(json);
      expect(address.longitude, isNull);
    });

    test('both lat and lng null stay null', () {
      final json = <String, dynamic>{
        'id': 4,
        'address_type': 'Home',
        'address': 'No GPS location saved',
        'contact_person_number': '+966501234567',
        'latitude': null,
        'longitude': null,
      };

      final address = AddressModel.fromJson(json);
      expect(address.latitude, isNull);
      expect(address.longitude, isNull);

      final isValidLocation = address.latitude != null && address.longitude != null;
      expect(isValidLocation, isFalse);
    });
  });

  group('[OK] AddressModel.fromJson – valid data parsing', () {
    test('complete address parses correctly', () {
      final json = <String, dynamic>{
        'id': 10,
        'address_type': 'Work',
        'contact_person_number': '+966501234567',
        'address': '742 Evergreen Terrace',
        'latitude': '37.7749',
        'longitude': '-122.4194',
        'zone_id': '5',
        'zone_ids': [1, 2, 5],
        'contact_person_name': 'Ahmed Ali',
        'road': 'King Fahd Road',
        'house': '10',
        'floor': '3',
      };

      final address = AddressModel.fromJson(json);
      expect(address.id, equals(10));
      expect(address.addressType, equals('Work'));
      expect(address.contactPersonNumber, equals('+966501234567'));
      expect(address.latitude, equals('37.7749'));
      expect(address.longitude, equals('-122.4194'));
      expect(address.zoneId, equals(5));
      expect(address.zoneIds, containsAll([1, 2, 5]));
      expect(address.contactPersonName, equals('Ahmed Ali'));
      expect(address.streetNumber, equals('King Fahd Road'));
      expect(address.house, equals('10'));
      expect(address.floor, equals('3'));
    });

    test('zone_id as string is parsed to int', () {
      final json = <String, dynamic>{
        'id': 11,
        'address_type': 'Home',
        'contact_person_number': '+966509876543',
        'address': 'Test',
        'latitude': '21.0000',
        'longitude': '39.0000',
        'zone_id': '7',
      };

      final address = AddressModel.fromJson(json);
      expect(address.zoneId, equals(7));
      expect(address.zoneId, isA<int>());
    });

    test('zone_id "null" string is treated as null', () {
      final json = <String, dynamic>{
        'id': 12,
        'address_type': 'Home',
        'contact_person_number': '+966501111111',
        'address': 'Test',
        'latitude': '21.0',
        'longitude': '39.0',
        'zone_id': 'null',
      };

      final address = AddressModel.fromJson(json);
      expect(address.zoneId, isNull);
    });

    test('toJson round-trips correctly', () {
      final address = AddressModel(
        id: 20,
        addressType: 'Home',
        address: '123 Main St',
        latitude: '10.0',
        longitude: '20.0',
        contactPersonNumber: '+966501234567',
        contactPersonName: 'Test User',
        streetNumber: 'Street 5',
        house: '2',
        floor: '1',
      );

      final json = address.toJson();
      expect(json['id'], equals(20));
      expect(json['address_type'], equals('Home'));
      expect(json['latitude'], equals('10.0'));
      expect(json['longitude'], equals('20.0'));
      expect(json['contact_person_number'], equals('+966501234567'));
      expect(json['contact_person_name'], equals('Test User'));
      expect(json['road'], equals('Street 5'));
    });

    test('contact_person_email in toJson only present when non-null', () {
      final withEmail = AddressModel(id: 30, email: 'test@test.com');
      final withoutEmail = AddressModel(id: 31);

      final jsonWith = withEmail.toJson();
      final jsonWithout = withoutEmail.toJson();

      expect(jsonWith.containsKey('contact_person_email'), isTrue);
      expect(jsonWith['contact_person_email'], equals('test@test.com'));
      expect(jsonWithout.containsKey('contact_person_email'), isFalse);
    });
  });

  group('[EDGE] AddressModel.fromJson – zone_ids and area_ids casting', () {
    test('zone_ids null stays null', () {
      final json = <String, dynamic>{
        'id': 40,
        'address_type': 'Home',
        'contact_person_number': '+1',
        'address': 'test',
        'latitude': '0.0',
        'longitude': '0.0',
        'zone_ids': null,
      };

      final address = AddressModel.fromJson(json);
      expect(address.zoneIds, isNull);
    });

    test('zone_ids as List<dynamic> casts to List<int>', () {
      final json = <String, dynamic>{
        'id': 41,
        'address_type': 'Home',
        'contact_person_number': '+1',
        'address': 'test',
        'latitude': '0.0',
        'longitude': '0.0',
        'zone_ids': [1, 3, 7],
      };

      final address = AddressModel.fromJson(json);
      expect(address.zoneIds, isNotNull);
      expect(address.zoneIds, isA<List<int>>());
      expect(address.zoneIds, equals([1, 3, 7]));
    });
  });
}
