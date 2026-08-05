import 'package:flutter/material.dart';

class ModuleIconHelper {
  static IconData getIcon(String? name, IconData defaultIcon) {
    if (name == null) return defaultIcon;
    switch (name) {
      case 'add': return Icons.add;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'add_circle': return Icons.add_circle;
      case 'add_shopping_cart': return Icons.add_shopping_cart;
      case 'plus_one': return Icons.plus_one;
      
      case 'star': return Icons.star;
      case 'thumb_up': return Icons.thumb_up;
      case 'favorite': return Icons.favorite;
      case 'verified': return Icons.verified;
      
      case 'store': return Icons.store;
      case 'storefront': return Icons.storefront;
      case 'home': return Icons.home;
      case 'business': return Icons.business;
      
      default: return defaultIcon;
    }
  }
}
