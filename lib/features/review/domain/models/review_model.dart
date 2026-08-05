import 'dart:convert';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

class ReviewModel {
  int? id;
  String? comment;
  int? rating;
  String? itemName;
  String? itemImageFullUrl;
  String? customerName;
  String? createdAt;
  String? updatedAt;
  String? reply;
  String? storeName;
  Item? item;
  List<String>? attachment;
  int? itemId;
  String? moduleType;
  int? likeCount;
  bool? isLikedByUser;
  bool? isAnonymous;

  ReviewModel({
    this.id,
    this.comment,
    this.rating,
    this.itemName,
    this.itemImageFullUrl,
    this.customerName,
    this.createdAt,
    this.updatedAt,
    this.reply,
    this.item,
    this.attachment,
    this.itemId,
    this.moduleType,
    this.likeCount,
    this.isLikedByUser,
    this.isAnonymous,
  });

  ReviewModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.parse(json['id'].toString()) : null;
    comment = json['comment'];
    rating = json['rating'] != null ? double.parse(json['rating'].toString()).toInt() : 0;
    itemName = json['item_name'];
    itemImageFullUrl = json['item_image_full_url'];
    customerName = json['customer_name'];
    if(customerName == null && json['customer'] != null) {
      customerName = '${json['customer']['f_name']} ${json['customer']['l_name']}';
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    reply = json['reply'];
    storeName = json['store_name'];
    item = json['item'] != null ? Item.fromJson(json['item']) : null;
    itemId = json['item_id'] != null ? int.parse(json['item_id'].toString()) : null;
    moduleType = json['module_type'];
    if(json['attachment'] != null){
      attachment = [];
      if(json['attachment'] is String) {
        if(json['attachment'].toString().startsWith('[')) {
          jsonDecode(json['attachment']).forEach((v) {
            attachment!.add(v);
          });
        }
      } else {
        json['attachment'].forEach((v) {
          attachment!.add(v);
        });
      }
    }
    likeCount = json['likes_count'] != null ? int.parse(json['likes_count'].toString()) : 0;
    isLikedByUser = json['is_liked_by_user'];
    isAnonymous = json['is_anonymous'] == 1 || json['is_anonymous'] == true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['comment'] = comment;
    data['rating'] = rating;
    data['item_name'] = itemName;
    data['item_image_full_url'] = itemImageFullUrl;
    data['customer_name'] = customerName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['reply'] = reply;
    if (item != null) {
      data['item'] = item!.toJson();
    }
    data['attachment'] = attachment;
    data['item_id'] = itemId;
    data['module_type'] = moduleType;
    data['is_anonymous'] = isAnonymous;
    return data;
  }
}
