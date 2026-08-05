import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';

import 'package:sixam_mart/common/controllers/theme_controller.dart';

TextStyle get robotoRegular => TextStyle(
  fontFamily: Get.find<ThemeController>().fontFamily,
  fontWeight: FontWeight.w400,
  fontSize: Get.find<ThemeController>().fontSize,
);

TextStyle get robotoMedium => TextStyle(
  fontFamily: Get.find<ThemeController>().fontFamily,
  fontWeight: FontWeight.w500,
  fontSize: Get.find<ThemeController>().fontSize,
);

TextStyle get robotoSemiBold => TextStyle(
  fontFamily: Get.find<ThemeController>().fontFamily,
  fontWeight: FontWeight.w600,
  fontSize: Get.find<ThemeController>().fontSize,
);

TextStyle get robotoBold => TextStyle(
  fontFamily: Get.find<ThemeController>().fontFamily,
  fontWeight: FontWeight.w700,
  fontSize: Get.find<ThemeController>().fontSize,
);

TextStyle get robotoBlack => TextStyle(
  fontFamily: Get.find<ThemeController>().fontFamily,
  fontWeight: FontWeight.w900,
  fontSize: Get.find<ThemeController>().fontSize,
);

final BoxDecoration riderContainerDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
  color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1), shape: BoxShape.rectangle,
);