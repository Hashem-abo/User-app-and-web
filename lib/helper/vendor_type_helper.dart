import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';

class VendorTypeHelper {
  /// Checks if the vendor type string is empty, null, or a null-like placeholder.
  static bool isEmpty(String? type) {
    if (type == null) return true;
    final clean = type.trim().toLowerCase();
    return clean.isEmpty || clean == 'null' || clean == 'none' || clean == 'undefined';
  }

  /// Checks if the type represents a retailer (which MUST be hidden).
  static bool isRetailer(String? type) {
    if (isEmpty(type)) return false;
    final clean = type!.trim().toLowerCase();
    return clean == 'retail' ||
        clean == 'retailer' ||
        clean == 'retails' ||
        clean == 'retailers' ||
        clean == 'تجزئة' ||
        clean == 'قطاعي' ||
        clean == 'مفرق' ||
        clean == 'تاجر تجزئة';
  }

  /// Checks if the type represents a wholesaler (which MUST be kept).
  static bool isWholesaler(String? type) {
    if (isEmpty(type)) return false;
    final clean = type!.trim().toLowerCase();
    return clean == 'wholesale' ||
        clean == 'wholesaler' ||
        clean == 'wholesalers' ||
        clean == 'جملة' ||
        clean == 'تاجر جملة';
  }

  /// Checks if the type represents a factory (which MUST be kept).
  static bool isFactory(String? type) {
    if (isEmpty(type)) return false;
    final clean = type!.trim().toLowerCase();
    return clean == 'factory' ||
        clean == 'factories' ||
        clean == 'manufacturer' ||
        clean == 'manufacturers' ||
        clean == 'مصنع' ||
        clean == 'معمل';
  }

  /// Determines if the current app language is Arabic.
  static bool isArabic() {
    if (Get.isRegistered<LocalizationController>()) {
      final loc = Get.find<LocalizationController>().locale;
      if (loc.languageCode.toLowerCase() == 'ar') return true;
    }
    final localeCode = Get.locale?.languageCode;
    if (localeCode != null && localeCode.toLowerCase() == 'ar') {
      return true;
    }
    return false;
  }

  /// Resolves the vendor type display text based on current app language.
  /// - Retailer: returns empty string (hidden)
  /// - Empty / null: returns empty string (hidden)
  /// - Wholesaler: returns "جملة" in Arabic, "Wholesale" in English/other
  /// - Factory: returns "مصنع" in Arabic, "Factory" in English/other
  static String resolveVendorType(String? type) {
    if (isEmpty(type)) return '';
    if (isRetailer(type)) return '';

    final arabic = isArabic();

    if (isRetailer(type)) {
      return '';
    }

    if (isWholesaler(type)) {
      if (arabic) return 'جملة';
      final trVal = 'wholesale'.tr;
      return (trVal.isNotEmpty && trVal != 'wholesale') ? trVal : 'Wholesale';
    }

    if (isFactory(type)) {
      if (arabic) return 'مصنع';
      final trVal = 'factory'.tr;
      return (trVal.isNotEmpty && trVal != 'factory') ? trVal : 'Factory';
    }

    // Custom non-empty vendor types (e.g. 'مخبز')
    final trimmed = type!.trim();
    final trVal = trimmed.tr;
    return trVal.isNotEmpty ? trVal : trimmed;
  }
}
