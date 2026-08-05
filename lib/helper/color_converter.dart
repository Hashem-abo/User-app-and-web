import 'package:flutter/material.dart';

class ColorConverter{
  static Color stringToColor(String? color){
    int value = 0xFFEF7822;
    if(color != null) {
      if (color.startsWith('#')) {
        value = int.parse(color.replaceAll('#', '0xFF'));
      }
    }
    return Color(value);
  }

  static Color? getColorFromOption(String option) {
    String cleanOption = option.trim().replaceAll(' ', '').toLowerCase();
    
    // Check for Hex
    if (cleanOption.startsWith('#')) {
      return stringToColor(cleanOption);
    }
    
    // Map Common Colors (English & Arabic)
    Map<String, Color> colorMap = {
      'red': Colors.red, 'احمر': Colors.red, 'أحمر': Colors.red,
      'blue': Colors.blue, 'ازرق': Colors.blue, 'أزرق': Colors.blue,
      'green': Colors.green, 'اخضر': Colors.green, 'أخضر': Colors.green,
      'yellow': Colors.yellow, 'اصفر': Colors.yellow, 'أصفر': Colors.yellow,
      'black': Colors.black, 'اسود': Colors.black, 'أسود': Colors.black,
      'white': Colors.white, 'ابيض': Colors.white, 'أبيض': Colors.white,
      'orange': Colors.orange.shade700, 'برتقالي': Colors.orange.shade700,
      'purple': Colors.purple, 'بنفسجي': Colors.purple, 'ارجواني': Colors.purple,
      'pink': Colors.pink, 'وردي': Colors.pink, 'زهري': Colors.pink,
      'brown': Colors.brown, 'بني': Colors.brown,
      'grey': Colors.grey, 'gray': Colors.grey, 'رمادي': Colors.grey, 'رصاصي': Colors.grey,
      'cyan': Colors.cyan, 'سماوي': Colors.cyan,
      'silver': const Color(0xFFC0C0C0), 'فضي': const Color(0xFFC0C0C0), 'فضة': const Color(0xFFC0C0C0),
    };
    
    // Check mapped keys
    for (var entry in colorMap.entries) {
      if (cleanOption.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null; // Fallback
  }
}