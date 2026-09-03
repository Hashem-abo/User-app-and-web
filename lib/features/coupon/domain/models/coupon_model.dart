import 'package:just_the_tooltip/just_the_tooltip.dart';

class CouponModel {
  int? id;
  String? title;
  String? code;
  String? startDate;
  String? expireDate;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  String? couponType;
  int? limit;
  String? data;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  Store? store;
  JustTheController? toolTip;

  CouponModel({
    this.id,
    this.title,
    this.code,
    this.startDate,
    this.expireDate,
    this.minPurchase,
    this.maxDiscount,
    this.discount,
    this.discountType,
    this.couponType,
    this.limit,
    this.data,
    this.storeId,
    this.createdAt,
    this.updatedAt,
    this.store,
    this.toolTip,
  });

  CouponModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    startDate = json['start_date'];
    expireDate = json['expire_date'];
    minPurchase = json['min_purchase'] != null ? double.tryParse(json['min_purchase'].toString()) : null;
    maxDiscount = json['max_discount'] != null ? double.tryParse(json['max_discount'].toString()) : null;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
    discountType = json['discount_type'];
    couponType = json['coupon_type'];
    limit = json['limit'] != null ? int.tryParse(json['limit'].toString()) : null;
    data = json['data'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['store'] != null) {
      store = Store.fromJson(json['store']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['code'] = code;
    data['start_date'] = startDate;
    data['expire_date'] = expireDate;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['coupon_type'] = couponType;
    data['limit'] = limit;
    data['data'] = this.data;
    data['store_id'] = storeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Store {
  int? id;
  String? name;

  Store({this.id, this.name});

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
