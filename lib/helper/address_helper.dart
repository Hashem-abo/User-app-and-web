import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

import 'package:sixam_mart/features/location/controllers/location_controller.dart';

class AddressHelper {

  static String formatAddressWithZone(AddressModel? address) {
    if (address == null || address.address == null || address.address!.trim().isEmpty) {
      return 'select_location'.tr;
    }

    String rawAddress = address.address!.trim();

    String zoneName = '';
    if (address.zoneData != null && address.zoneData!.isNotEmpty && address.zoneData!.first.name != null) {
      zoneName = address.zoneData!.first.name!.trim();
    }

    if (zoneName.isEmpty && Get.isRegistered<LocationController>()) {
      LocationController locController = Get.find<LocationController>();
      if (locController.zoneList != null && locController.zoneList!.isNotEmpty) {
        for (var z in locController.zoneList!) {
          if (z.id == address.zoneId) {
            zoneName = z.name?.trim() ?? '';
            break;
          }
        }
      }
    }

    if (zoneName.isNotEmpty) {
      if (rawAddress.startsWith(zoneName)) {
        if (rawAddress == zoneName) {
          return zoneName;
        }
        if (rawAddress.startsWith('$zoneName - ')) {
          return rawAddress;
        }
        if (rawAddress.startsWith('$zoneName,') || rawAddress.startsWith('$zoneName ')) {
          String rest = rawAddress.substring(zoneName.length).replaceAll(RegExp(r'^[\s,\-]+'), '');
          return rest.isNotEmpty ? '$zoneName - $rest' : zoneName;
        }
        return rawAddress;
      } else {
        return '$zoneName - $rawAddress';
      }
    }

    return rawAddress;
  }

  static AddressModel? _cachedUserAddress;

  static Future<bool> saveUserAddressInSharedPref(AddressModel address) async {
    _cachedUserAddress = address;
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    List<int>? zoneIds = address.zoneIds;
    if ((zoneIds == null || zoneIds.isEmpty) && address.zoneId != null) {
      zoneIds = [address.zoneId!];
      address.zoneIds = zoneIds;
    }
    if (zoneIds == null || zoneIds.isEmpty) {
      zoneIds = [1];
      address.zoneId = 1;
      address.zoneIds = zoneIds;
    }

    if (address.address != null && address.address!.isNotEmpty) {
      address.address = formatAddressWithZone(address);
    }

    String userAddress = jsonEncode(address.toJson());
    Get.find<ApiClient>().updateHeader(
      sharedPreferences.getString(AppConstants.token),
      zoneIds,[],
      sharedPreferences.getString(AppConstants.languageCode),
      Get.find<SplashController>().module?.id,
      address.latitude,
      address.longitude,
    );
    return await sharedPreferences.setString(AppConstants.userAddress, userAddress);
  }

  static AddressModel? getUserAddressFromSharedPref([SharedPreferences? pref]) {
    if (_cachedUserAddress != null) {
      return _cachedUserAddress;
    }
    SharedPreferences? sharedPreferences = pref ?? (Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null);
    if (sharedPreferences == null) {
      return null;
    }
    AddressModel? addressModel;
    try {
      String? addressString = sharedPreferences.getString(AppConstants.userAddress);
      if (addressString != null && addressString.isNotEmpty) {
        addressModel = AddressModel.fromJson(jsonDecode(addressString));
        _cachedUserAddress = addressModel;
      }
    } catch(e) {
      if(!GetPlatform.isWeb) {
        debugPrint('Address Catch exception : $e');
      }
      try {
        sharedPreferences.remove(AppConstants.userAddress);
      } catch (_) {}
      _cachedUserAddress = null;
    }
    return addressModel;
  }

  static bool clearAddressFromSharedPref([SharedPreferences? pref]) {
    _cachedUserAddress = null;
    SharedPreferences? sharedPreferences = pref ?? (Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null);
    sharedPreferences?.remove(AppConstants.userAddress);
    return true;
  }

}