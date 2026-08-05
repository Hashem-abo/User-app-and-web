import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';

ThemeData light({Color color = const Color(0xFFFF7A21), Color disabledColor = const Color(0xFF9F9F9F), Color hintColor = const Color(0xFF9F9F9F), Color cardColor = Colors.white, Color textColor = const Color(0xFF000000), String? fontFamily}) => ThemeData(
  fontFamily: fontFamily ?? Get.find<ThemeController>().fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color(0xFF005CAA),
  disabledColor: disabledColor,
  brightness: Brightness.light,
  hintColor: hintColor,
  cardColor: cardColor,
  textTheme: Typography.blackMountainView.apply(bodyColor: textColor, displayColor: textColor),

  //titlesColor:const Color(0xFF1ED7AA),
  shadowColor: Colors.black.withValues(alpha: 0.03),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
  colorScheme: ColorScheme.light(primary: color, secondary: color).copyWith(
      surface: const Color(0xFFFCFCFC)).copyWith(error: const Color(0xFFE84D4F)),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.white, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(thickness: 0.2, color: Color(0xFFA0A4A8)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);