import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/profile/domain/models/userinfo_model.dart';

class ProductQuestionModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<ProductQuestion>? questions;

  ProductQuestionModel({this.totalSize, this.limit, this.offset, this.questions});

  ProductQuestionModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['questions'] != null) {
      questions = <ProductQuestion>[];
      json['questions'].forEach((v) {
        questions!.add(ProductQuestion.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (questions != null) {
      data['questions'] = questions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductQuestion {
  int? id;
  int? itemId;
  int? userId;
  String? question;
  String? reply;
  int? vendorId;
  int? status;
  String? createdAt;
  String? updatedAt;
  Item? item;
  UserInfoModel? user;
  // Vendor? vendor; // If needed, but usually we just show reply
  int? likeCount;
  bool? isLikedByUser;
  bool? isAnonymous;

  ProductQuestion({
    this.id,
    this.itemId,
    this.userId,
    this.question,
    this.reply,
    this.vendorId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.item,
    this.user,
    this.likeCount,
    this.isLikedByUser,
    this.isAnonymous,
  });

  ProductQuestion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemId = json['item_id'];
    userId = json['user_id'];
    question = json['question'];
    reply = json['reply'];
    vendorId = json['vendor_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    item = json['item'] != null ? Item.fromJson(json['item']) : null;
    user = json['user'] != null ? UserInfoModel.fromJson(json['user']) : null;
    likeCount = json['likes_count'];
    isLikedByUser = json['is_liked_by_user'];
    isAnonymous = json['is_anonymous'] == 1 || json['is_anonymous'] == true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_id'] = itemId;
    data['user_id'] = userId;
    data['question'] = question;
    data['reply'] = reply;
    data['vendor_id'] = vendorId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (item != null) {
      data['item'] = item!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['is_anonymous'] = isAnonymous;
    return data;
  }
}
