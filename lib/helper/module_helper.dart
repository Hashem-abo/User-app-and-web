import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

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