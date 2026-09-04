import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';

import 'package:sixam_mart/common/controllers/theme_controller.dart';

TextStyle get robotoRegular => TextStyle(
  fontFamily: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontFamily : 'Roboto',
  fontWeight: FontWeight.w400,
  fontSize: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontSize : Dimensions.fontSizeDefault,
);

TextStyle get robotoMedium => TextStyle(
  fontFamily: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontFamily : 'Roboto',
  fontWeight: FontWeight.w500,
  fontSize: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontSize : Dimensions.fontSizeDefault,
);

TextStyle get robotoSemiBold => TextStyle(
  fontFamily: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontFamily : 'Roboto',
  fontWeight: FontWeight.w600,
  fontSize: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontSize : Dimensions.fontSizeDefault,
);

TextStyle get robotoBold => TextStyle(
  fontFamily: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontFamily : 'Roboto',
  fontWeight: FontWeight.w700,
  fontSize: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontSize : Dimensions.fontSizeDefault,
);

TextStyle get robotoBlack => TextStyle(
  fontFamily: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontFamily : 'Roboto',
  fontWeight: FontWeight.w900,
  fontSize: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().fontSize : Dimensions.fontSizeDefault,
);

final BoxDecoration riderContainerDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
  color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1), shape: BoxShape.rectangle,
);