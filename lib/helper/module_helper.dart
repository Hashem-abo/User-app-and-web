import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

class ModuleHelper {

  static ModuleModel? getModule() {
    return Get.isRegistered<SplashController>() ? Get.find<SplashController>().module : null;
  }

  static ModuleModel? getCacheModule() {
    return Get.isRegistered<SplashController>() ? Get.find<SplashController>().cacheModule : null;
  }

  static Module getModuleConfig(String? moduleType) {
    return Get.find<SplashController>().getModuleConfig(moduleType);
  }

  /// Dynamically resolves the module type from moduleId by searching SplashController.moduleList.
  static String? getModuleTypeById(int? moduleId) {
    if (moduleId == null) return null;
    if (Get.isRegistered<SplashController>()) {
      final splash = Get.find<SplashController>();
      final list = splash.moduleList;
      if (list != null) {
        for (final m in list) {
          if (m.id == moduleId) {
            return m.moduleType;
          }
        }
      }
      final curModule = splash.module ?? splash.cacheModule;
      if (curModule?.id == moduleId) {
        return curModule?.moduleType;
      }
    }
    return null;
  }

  /// Dynamically resolves the ModuleModel from moduleId.
  static ModuleModel? getModuleById(int? moduleId) {
    if (moduleId == null) return null;
    if (Get.isRegistered<SplashController>()) {
      final splash = Get.find<SplashController>();
      final list = splash.moduleList;
      if (list != null) {
        for (final m in list) {
          if (m.id == moduleId) {
            return m;
          }
        }
      }
      final curModule = splash.module ?? splash.cacheModule;
      if (curModule?.id == moduleId) {
        return curModule;
      }
    }
    return null;
  }

  /// Returns whether a module is grocery dynamically.
  static bool isGrocery({int? moduleId, String? moduleType, dynamic item}) {
    final String? type = moduleType ?? item?.moduleType ?? getModuleTypeById(moduleId ?? item?.moduleId) ?? getModule()?.moduleType ?? getCacheModule()?.moduleType;
    return type == AppConstants.grocery || type == 'grocery';
  }

  /// Returns whether unit should be displayed for an item.
  static bool isUnitVisible(dynamic item) {
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
    
    // Dynamically resolve module type
    String? type = moduleType;
    if (type == null && moduleId != null) {
      type = getModuleTypeById(moduleId);
    }
    type ??= getModule()?.moduleType ?? getCacheModule()?.moduleType;

    // Do NOT show unit in food or ecommerce module
    if (type == AppConstants.food || type == AppConstants.ecommerce || type == 'food' || type == 'ecommerce') {
      return false;
    }

    // Show unit for grocery
    if (type == AppConstants.grocery || type == 'grocery') {
      return true;
    }

    if (Get.isRegistered<SplashController>()) {
      final config = getModuleConfig(type);
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
  static String proMinSpendLabel({String? moduleType, required String fallbackKey}) {
    final String? type = moduleType ?? getModule()?.moduleType;
    if (type == AppConstants.parcel) {
      return 'minimum_parcel_amount'.tr;
    }
    return fallbackKey.tr;
  }

  /// Returns whether a module, item, or store corresponds to the Zad / Grocery module dynamically.
  static bool isZad({
    int? moduleId,
    String? moduleType,
    String? moduleName,
  }) {
    if (moduleType == 'zad' || moduleType == AppConstants.grocery || moduleType == 'grocery') {
      return true;
    }
    final resolvedType = getModuleTypeById(moduleId);
    if (resolvedType == AppConstants.grocery || resolvedType == 'grocery' || resolvedType == 'zad') {
      return true;
    }
    if (moduleName != null) {
      final name = moduleName.trim().toLowerCase();
      if (name.contains('zad') || name.contains('زاد') || name.contains('grocery')) {
        return true;
      }
    }
    if (Get.isRegistered<SplashController>()) {
      final module = getModule() ?? getCacheModule();
      if (module != null) {
        if (moduleId == null || moduleId == module.id) {
          if (module.moduleType == AppConstants.grocery || module.moduleType == 'grocery' || module.moduleType == 'zad') {
            return true;
          }
          final name = (module.moduleName ?? '').trim().toLowerCase();
          if (name.contains('zad') || name.contains('زاد') || name.contains('grocery')) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Returns whether a module, item, or store corresponds to Grocery (e.g. Zad) or Pharmacy dynamically.
  static bool isGroceryOrPharmacy({
    Item? item,
    int? moduleId,
    String? moduleType,
  }) {
    final String? directType = moduleType ?? item?.moduleType;
    if (directType == AppConstants.grocery || directType == AppConstants.pharmacy || directType == 'grocery' || directType == 'pharmacy') {
      return true;
    }

    final int? directId = moduleId ?? item?.moduleId;
    if (directId != null) {
      final resolvedType = getModuleTypeById(directId);
      if (resolvedType == AppConstants.grocery || resolvedType == AppConstants.pharmacy || resolvedType == 'grocery' || resolvedType == 'pharmacy') {
        return true;
      }
    }

    if (Get.isRegistered<SplashController>()) {
      final module = getModule() ?? getCacheModule();
      if (module != null) {
        if (module.moduleType == AppConstants.grocery || module.moduleType == AppConstants.pharmacy || module.moduleType == 'grocery' || module.moduleType == 'pharmacy') {
          return true;
        }
      }
    }

    return false;
  }

}