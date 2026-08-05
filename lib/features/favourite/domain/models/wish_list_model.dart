import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';

class WishListModel {
  String? id;
  String? name;
  List<CartModel>? items;
  DateTime? reminderDate;

  WishListModel({this.id, this.name, this.items, this.reminderDate});

  WishListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['items'] != null) {
      items = <CartModel>[];
      json['items'].forEach((v) {
        items!.add(CartModel.fromJson(v));
      });
    }
    reminderDate = json['reminder_date'] != null ? DateTime.parse(json['reminder_date']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['reminder_date'] = reminderDate?.toIso8601String();
    return data;
  }
}
