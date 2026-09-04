import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';

class Dimensions {
  static double get _offset => Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontSizeOffset : 0.0;

  static double get fontSizeOverSmall => ((Get.context?.width ?? 1000) >= 1300 ? 10.0 : 8.0) - _offset;
  static double get fontSizeExtraSmall => ((Get.context?.width ?? 1000) >= 1300 ? 12.0 : 10.0) - _offset;
  static double get fontSizeSmall => ((Get.context?.width ?? 1000) >= 1300 ? 14.0 : 12.0) - _offset;
  static double get fontSizeDefault => ((Get.context?.width ?? 1000) >= 1300 ? 16.0 : 14.0) - _offset;
  static double get fontSizeLarge => ((Get.context?.width ?? 1000) >= 1300 ? 18.0 : 16.0) - _offset;
  static double get fontSizeExtraLarge => ((Get.context?.width ?? 1000) >= 1300 ? 20.0 : 18.0) - _offset;
  static double get fontSizeOverLarge => ((Get.context?.width ?? 1000) >= 1300 ? 26.0 : 24.0) - _offset;

  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeSmall = 10.0;
  static const double paddingSizeDefault = 15.0;
  static const double paddingSizeLarge = 20.0;
  static const double paddingSizeExtraLarge = 25.0;
  static const double paddingSizeExtremeLarge = 30.0;
  static const double paddingSizeExtraOverLarge = 35.0;

  static const double radiusSmall = 5.0;
  static const double radiusMedium = 8.0;
  static const double radiusDefault = 10.0;
  static const double radiusLarge = 15.0;
  static const double radiusExtraLarge = 20.0;

  static const double webMaxWidth = 1170;
  static const int messageInputLength = 1000;

  static const double pickMapIconSize = 100.0;
}
