import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/features/chat/domain/enum/chat_role_enum.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart' hide Store;
import 'package:sixam_mart/features/order/domain/models/order_model.dart';

class ChatMessage {
  final String text;
  final ChatRole role;
  final DateTime timestamp;
  final bool isError;
  final XFile? image;
  final List<Item>? items;
  final List<Store>? stores;
  final bool showCartButton;
  final List<CouponModel>? coupons;
  final List<OrderModel>? chatOrders;

  ChatMessage({
    required this.text,
    required this.role,
    DateTime? timestamp,
    this.isError = false,
    this.image,
    this.items,
    this.stores,
    this.showCartButton = false,
    this.coupons,
    this.chatOrders,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'role': role.toString(), 
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
      'items': items?.map((i) => i.toJson()).toList(),
      'stores': stores?.map((s) => s.toJson()).toList(),
      'showCartButton': showCartButton,
      'coupons': coupons?.map((c) => c.toJson()).toList(),
      'chatOrders': chatOrders?.map((o) => o.toJson()).toList(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      role: ChatRole.values.firstWhere((e) => e.toString() == json['role']),
      timestamp: DateTime.parse(json['timestamp']),
      isError: json['isError'] ?? false,
      items: json['items'] != null ? (json['items'] as List).map((i) => Item.fromJson(i)).toList() : null,
      stores: json['stores'] != null ? (json['stores'] as List).map((s) => Store.fromJson(s)).toList() : null,
      showCartButton: json['showCartButton'] ?? false,
      coupons: json['coupons'] != null ? (json['coupons'] as List).map((c) => CouponModel.fromJson(c)).toList() : null,
      chatOrders: json['chatOrders'] != null ? (json['chatOrders'] as List).map((o) => OrderModel.fromJson(o)).toList() : null,
    );
  }
}
