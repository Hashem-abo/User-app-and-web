import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AddressHelper.clearAddressFromSharedPref();
  });

  group('AddressModel & AddressHelper StackOverflow Resilience Tests', () {
    test('AddressModel.toJson produces lightweight zone_data without formated_coordinates', () {
      final address = AddressModel(
        id: 1,
        address: "Sana'a, Yemen",
        latitude: '15.3545381',
        longitude: '44.2064003',
        addressType: 'others',
        zoneId: 1,
        zoneIds: [1],
      );

      final json = address.toJson();
      expect(json['address'], "Sana'a, Yemen");
      expect(json['zone_id'], 1);
      expect(json['zone_ids'], [1]);
    });

    test('AddressModel.fromJson parses safe and malformed zone arrays without throwing', () {
      final rawJson = {
        'id': 123,
        'address': 'Test Address',
        'latitude': '15.35',
        'longitude': '44.20',
        'address_type': 'others',
        'zone_id': '1',
        'zone_ids': ['1', 2, '3'],
        'zone_data': [
          {'id': 1, 'name': 'Zone 1', 'status': 1},
          'invalid_entry_should_not_crash',
        ],
      };

      final model = AddressModel.fromJson(rawJson);
      expect(model.id, 123);
      expect(model.zoneId, 1);
      expect(model.zoneIds, [1, 2, 3]);
      expect(model.zoneData?.length, 1);
      expect(model.zoneData?.first.name, 'Zone 1');
    });

    test('AddressHelper auto-recovers from corrupted/overflowing string in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.userAddress: '{corrupted_malformed_json...{[[[',
      });
      final pref = await SharedPreferences.getInstance();

      final recoveredAddress = AddressHelper.getUserAddressFromSharedPref(pref);
      // When json fails to parse, it cleans SharedPreferences and returns null
      expect(recoveredAddress, isNull);
      // Corrupted key should have been cleared from SharedPreferences
      expect(pref.getString(AppConstants.userAddress), isNull);
    });

    test('AddressHelper caches valid address and serves without disk overhead', () async {
      final address = AddressModel(
        id: 99,
        address: 'Al-Zubairi St, Sana\'a',
        latitude: '15.35',
        longitude: '44.20',
        addressType: 'others',
        zoneId: 1,
        zoneIds: [1],
      );

      SharedPreferences.setMockInitialValues({
        AppConstants.userAddress: jsonEncode(address.toJson()),
      });
      final pref = await SharedPreferences.getInstance();

      final firstCall = AddressHelper.getUserAddressFromSharedPref(pref);
      expect(firstCall?.id, 99);
      expect(firstCall?.address, 'Al-Zubairi St, Sana\'a');

      // Subsequent calls return in-memory cached instance
      final secondCall = AddressHelper.getUserAddressFromSharedPref(pref);
      expect(identical(firstCall, secondCall), isTrue);
    });
  });
}
