import 'package:get/get.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class ItemHelper {
  static bool isItemEntirelyOutOfStock(Item? item) {
    if (item == null) return false;
    bool isFood = item.moduleType == 'food';
    bool moduleStock = Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false;
    if (isFood || !moduleStock) return false;

    if (item.variations != null && item.variations!.isNotEmpty) {
      bool hasAnyAvailableVariation = false;
      for (var v in item.variations!) {
        if (v.stock == null || v.stock! > 0) {
          hasAnyAvailableVariation = true;
          break;
        }
      }
      if (hasAnyAvailableVariation) return false;
      return true;
    }

    if (item.stock != null && item.stock! <= 0) {
      return true;
    }

    return false;
  }
}
