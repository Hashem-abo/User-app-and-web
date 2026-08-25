import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sixam_mart/theme/light_theme.dart';
import 'package:sixam_mart/theme/dark_theme.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class ThemeController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  ThemeController({required this.sharedPreferences}) {
    _loadCurrentTheme();
  }

  bool _darkTheme = false;
  Color? _lightColor;
  Color? _darkColor;
  Color _primaryColor = const Color(0xFFFF7A21);
  Color _textColor = const Color(0xFF000000);


  bool get darkTheme => _darkTheme;
  Color? get darkColor => _darkColor;
  Color? get lightColor => _lightColor;
  Color get primaryColor => _primaryColor;
  Color get textColor => _textColor;


  Color _disabledColor = const Color(0xFF9F9F9F);
  Color get disabledColor => _disabledColor;

  Color _hintColor = const Color(0xFF9F9F9F);
  Color get hintColor => _hintColor;

  Color _cardColor = Colors.white;
  Color get cardColor => _cardColor;

  String _lightMap = '[]';
  String get lightMap => _lightMap;

  String _darkMap = '[]';
  String get darkMap => _darkMap;

  String _fontFamily = 'Tajawal';
  String get fontFamily {
    if (Get.isRegistered<SplashController>()) {
      final splashController = Get.find<SplashController>();
      if (splashController.module != null && splashController.module!.fontFamily != null && splashController.module!.fontFamily!.isNotEmpty) {
        return getFormattedFontFamily(splashController.module!.fontFamily!);
      }
    }
    return _fontFamily;
  }

  double get fontSizeOffset {
    if (Get.isRegistered<SplashController>()) {
      final splashController = Get.find<SplashController>();
      if (splashController.module != null && splashController.module!.fontSizeOffset != null) {
        return splashController.module!.fontSizeOffset!;
      }
    }
    return 0.0;
  }

  String getFormattedFontFamily(String font) {
    String lower = font.trim().toLowerCase();
    if (lower == 'tajawal') return 'Tajawal';
    if (lower == 'cairo') return 'Cairo';
    if (lower == 'roboto') return 'Roboto';
    if (lower == 'rubik') return 'Rubik';
    if (lower == 'dinnextltarabic' || lower == 'din next' || lower == 'din next lt arabic') return 'DINNextLTArabic';
    if (lower == 'neosansarabic' || lower == 'neo sans' || lower == 'neo sans arabic') return 'NeoSansArabic';
    if (lower == 'somarsans' || lower == 'somar sans' || lower == 'somar') return 'SomarSans';
    if (lower == 'kosans' || lower == 'ko sans') return 'KOSans';
    if (lower.isNotEmpty) {
      return lower[0].toUpperCase() + lower.substring(1);
    }
    return font;
  }

  String _lightMapTaxi = '[]';
  String get lightMapTaxi => _lightMapTaxi;

  void toggleTheme() {
    _darkTheme = !_darkTheme;
    sharedPreferences.setBool(AppConstants.theme, _darkTheme);
    Get.changeTheme(_darkTheme ? dark(color: _primaryColor, disabledColor: _disabledColor, hintColor: _hintColor) : light(color: _primaryColor, disabledColor: _disabledColor, hintColor: _hintColor, cardColor: _cardColor));
    update();
  }

  void changeTheme(Color lightColor, Color darkColor) {
    _lightColor = lightColor;
    _darkColor = darkColor;
    update();
  }

  void changePrimaryColor(Color color) {
    _primaryColor = color;
    sharedPreferences.setInt(AppConstants.themeColor, _primaryColor.value);
    Get.changeTheme(_darkTheme ? dark(color: color, disabledColor: _disabledColor, hintColor: _hintColor) : light(color: color, disabledColor: _disabledColor, hintColor: _hintColor, cardColor: _cardColor, textColor: _textColor));
    update();
  }

  void changeTextColor(Color color) {
    _textColor = color;
    sharedPreferences.setInt(AppConstants.themeTextColor, _textColor.value);
    Get.changeTheme(_darkTheme ? dark(color: _primaryColor, disabledColor: _disabledColor, hintColor: _hintColor) : light(color: _primaryColor, disabledColor: _disabledColor, hintColor: _hintColor, cardColor: _cardColor, textColor: _textColor));
    update();
  }

  void changeDisabledColor(Color color) {
    _disabledColor = color;
    sharedPreferences.setInt(AppConstants.themeDisabledColor, _disabledColor.value);
    Get.changeTheme(_darkTheme ? dark(color: _primaryColor, disabledColor: color, hintColor: _hintColor) : light(color: _primaryColor, disabledColor: color, hintColor: _hintColor, cardColor: _cardColor, textColor: _textColor));
    update();
  }

  void changeHintColor(Color color) {
    _hintColor = color;
    sharedPreferences.setInt(AppConstants.themeHintColor, _hintColor.value);
    Get.changeTheme(_darkTheme ? dark(color: _primaryColor, disabledColor: _disabledColor, hintColor: color) : light(color: _primaryColor, disabledColor: _disabledColor, hintColor: color, cardColor: _cardColor, textColor: _textColor));
    update();
  }

  void changeCardColor(Color color) {
    _cardColor = color;
    sharedPreferences.setInt(AppConstants.themeCardColor, _cardColor.value);
    Get.changeTheme(_darkTheme ? dark(color: _primaryColor, disabledColor: _disabledColor, hintColor: _hintColor) : light(color: _primaryColor, disabledColor: _disabledColor, hintColor: _hintColor, cardColor: color, textColor: _textColor));
    update();
  }

  double _fontSize = 14.0;
  double get fontSize => _fontSize;

  void changeFontSize(double size) {
    _fontSize = size;
    sharedPreferences.setDouble(AppConstants.fontSize, size);
    update();
  }

  void changeFont(String font) {
    _fontFamily = font;
    sharedPreferences.setString(AppConstants.fontFamily, font);
    Get.changeTheme(_darkTheme ? dark(color: _primaryColor, disabledColor: _disabledColor, hintColor: _hintColor) : light(color: _primaryColor, disabledColor: _disabledColor, hintColor: _hintColor, cardColor: _cardColor));
    update();
  }

  void _loadCurrentTheme() async {
    _lightMap = await rootBundle.loadString('assets/map/light_map.json');
    _darkMap = await rootBundle.loadString('assets/map/dark_map.json');
    _lightMapTaxi = await rootBundle.loadString('assets/map/light_taxi.json');
    _darkTheme = sharedPreferences.getBool(AppConstants.theme) ?? false;
    int? colorValue = sharedPreferences.getInt(AppConstants.themeColor);
    if(colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    int? textColorValue = sharedPreferences.getInt(AppConstants.themeTextColor);
    if(textColorValue != null) {
      _textColor = Color(textColorValue);
    }
    int? disabledColorValue = sharedPreferences.getInt(AppConstants.themeDisabledColor);
    if(disabledColorValue != null) {
      _disabledColor = Color(disabledColorValue);
    }
    int? hintColorValue = sharedPreferences.getInt(AppConstants.themeHintColor);
    if(hintColorValue != null) {
      _hintColor = Color(hintColorValue);
    }
    int? cardColorValue = sharedPreferences.getInt(AppConstants.themeCardColor);
    if(cardColorValue != null) {
      _cardColor = Color(cardColorValue);
    }
    _fontSize = sharedPreferences.getDouble(AppConstants.fontSize) ?? 14.0;
    _fontFamily = sharedPreferences.getString(AppConstants.fontFamily) ?? 'Tajawal';
    update();
  }
}
