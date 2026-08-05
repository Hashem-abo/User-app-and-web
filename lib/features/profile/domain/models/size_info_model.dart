import 'dart:convert';

class SizeInfo {
  final String id;
  final String label;
  final double weight;
  final double bust;
  final double waist;
  final double hips;
  final String fitPreference;
  final double footLength;
  final String shoeSize;

  SizeInfo({
    required this.id,
    required this.label,
    required this.weight,
    required this.bust,
    required this.waist,
    required this.hips,
    required this.fitPreference,
    required this.footLength,
    required this.shoeSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'weight': weight,
      'bust': bust,
      'waist': waist,
      'hips': hips,
      'fitPreference': fitPreference,
      'footLength': footLength,
      'shoeSize': shoeSize,
    };
  }

  factory SizeInfo.fromJson(Map<String, dynamic> json) {
    return SizeInfo(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 60.0,
      bust: (json['bust'] as num?)?.toDouble() ?? 90.0,
      waist: (json['waist'] as num?)?.toDouble() ?? 80.0,
      hips: (json['hips'] as num?)?.toDouble() ?? 90.0,
      fitPreference: json['fitPreference'] ?? 'Average',
      footLength: (json['footLength'] as num?)?.toDouble() ?? 25.0,
      shoeSize: json['shoeSize'] ?? '',
    );
  }
}

class ShoppingPreference {
  final List<String> favoriteCategories;
  final List<String> targetAudience;
  final List<String> favoriteStyles;
  final bool isCompleted;

  ShoppingPreference({
    required this.favoriteCategories,
    required this.targetAudience,
    required this.favoriteStyles,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'favoriteCategories': favoriteCategories,
      'targetAudience': targetAudience,
      'favoriteStyles': favoriteStyles,
      'isCompleted': isCompleted,
    };
  }

  factory ShoppingPreference.fromJson(Map<String, dynamic> json) {
    return ShoppingPreference(
      favoriteCategories: List<String>.from(json['favoriteCategories'] ?? []),
      targetAudience: List<String>.from(json['targetAudience'] ?? []),
      favoriteStyles: List<String>.from(json['favoriteStyles'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  factory ShoppingPreference.empty() {
    return ShoppingPreference(
      favoriteCategories: [],
      targetAudience: [],
      favoriteStyles: [],
      isCompleted: false,
    );
  }
}
