import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class HeaderHelper {
  static Map<String, String> featuredHeader() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    AddressModel? addressModel = AddressHelper.getUserAddressFromSharedPref();
    int? moduleID;
    if(GetPlatform.isWeb && sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        moduleID = ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!)).id;
      }catch(_) {}
    }
    List<int>? zoneIds = addressModel?.zoneIds;
    if ((zoneIds == null || zoneIds.isEmpty) && addressModel?.zoneId != null) {
      zoneIds = [addressModel!.zoneId!];
    }
    if (zoneIds == null || zoneIds.isEmpty) {
      zoneIds = [1];
    }

    String sanitizeCoord(String? input, String fallback) {
      if (input == null || input.isEmpty || input == '0' || input == 'null') return fallback;
      String clean = input.replaceAll('"', '').replaceAll("'", '').trim();
      double? val = double.tryParse(clean);
      return (val == null || val == 0) ? fallback : clean;
    }

    String validLat = sanitizeCoord(addressModel?.latitude, '15.369445');
    String validLng = sanitizeCoord(addressModel?.longitude, '44.191006');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.zoneId: jsonEncode(zoneIds),
      if (moduleID != null) AppConstants.moduleId: '$moduleID',
      AppConstants.localizationKey: sharedPreferences.getString(AppConstants.languageCode) ?? AppConstants.languages[0].languageCode!,
      AppConstants.latitude: validLat,
      AppConstants.longitude: validLng,
    };
  }
}