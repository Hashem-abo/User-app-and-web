import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

import 'package:sixam_mart/features/item/domain/models/item_model.dart';

class ModuleHelper {

  static ModuleModel? getModule() {
    return Get.find<SplashController>().module;
  }

  static ModuleModel? getCacheModule() {
    return Get.find<SplashController>().cacheModule;
  }

  static Module getModuleConfig(String? moduleType) {
    return Get.find<SplashController>().getModuleConfig(moduleType);
  }

  /// Returns whether unit should be displayed for an item, especially in the Zad module (grocery / module 1).
  static bool isUnitVisible(Item? item) {
    return isUnitVisibleForType(
      unitType: item?.unitType,
      moduleId: item?.moduleId,
      moduleType: item?.moduleType,
    );
  }

  /// Returns whether unit should be displayed based on unit string, module id, and module type.
  static bool isUnitVisibleForType({String? unitType, int? moduleId, String? moduleType}) {
    if (unitType == null || unitType.trim().isEmpty) {
      return false;
    }
    if (moduleId == 1 || moduleType == AppConstants.grocery) {
      return true;
    }
    final module = getModule() ?? getCacheModule();
    if (module?.id == 1 || module?.moduleType == AppConstants.grocery) {
      return true;
    }
    if (Get.isRegistered<SplashController>()) {
      final config = getModuleConfig(moduleType ?? module?.moduleType);
      if (config.unit == true) {
        return true;
      }
      if (Get.find<SplashController>().configModel?.moduleConfig?.module?.unit == true) {
        return true;
      }
    }
    return false;
  }

  /// Returns a localized label for the pro benefit minimum-order field.
  /// [moduleType] is optional; when null the active module is used.
  /// [fallbackKey] is the translation key to use when no module-specific
  /// override is needed.
  static String proMinSpendLabel({String? moduleType, required String fallbackKey}) {
    final String? type = moduleType ?? getModule()?.moduleType;
    if (type == AppConstants.parcel) {
      return 'minimum_parcel_amount'.tr;
    }
    return fallbackKey.tr;
  }

}