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

  /// Returns whether a module, item, or store corresponds to Grocery (e.g. Zad) or Pharmacy.
  static bool isGroceryOrPharmacy({
    Item? item,
    int? moduleId,
    String? moduleType,
  }) {
    final String? directType = moduleType ?? item?.moduleType;
    if (directType == AppConstants.grocery || directType == AppConstants.pharmacy) {
      return true;
    }

    final int? directId = moduleId ?? item?.moduleId;
    if (directId == 1 || directId == 2) {
      return true;
    }

    if (directId != null && Get.isRegistered<SplashController>()) {
      final splash = Get.find<SplashController>();
      final List<ModuleModel>? list = splash.moduleList;
      if (list != null) {
        for (final m in list) {
          if (m.id == directId) {
            if (m.moduleType == AppConstants.grocery || m.moduleType == AppConstants.pharmacy) {
              return true;
            }
            break;
          }
        }
      }
    }

    if (Get.isRegistered<SplashController>()) {
      final module = getModule() ?? getCacheModule();
      if (module != null) {
        if (module.moduleType == AppConstants.grocery || module.moduleType == AppConstants.pharmacy) {
          return true;
        }
        if (module.id == 1 || module.id == 2) {
          return true;
        }
      }
    }

    return false;
  }

}