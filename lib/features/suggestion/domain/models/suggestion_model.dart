import 'package:suliman/features/profile/domain/models/userinfo_model.dart';

class CustomerSuggestionModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<CustomerSuggestion>? suggestions;

  CustomerSuggestionModel({this.totalSize, this.limit, this.offset, this.suggestions});

  CustomerSuggestionModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit']?.toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty)
        ? int.parse(json['offset'].toString())
        : null;
    if (json['suggestions'] != null) {
      suggestions = <CustomerSuggestion>[];
      json['suggestions'].forEach((v) {
        suggestions!.add(CustomerSuggestion.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (suggestions != null) {
      data['suggestions'] = suggestions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerSuggestion {
  int? id;
  int? userId;
  String? title;
  String? description;
  String? category;
  List<String>? attachment;
  int? status; // 0: Pending, 1: Under Review, 2: Applied, 3: Rejected
  String? reply;
  String? repliedAt;
  bool? isAnonymous;
  String? createdAt;
  String? updatedAt;
  UserInfoModel? user;

  CustomerSuggestion({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.category,
    this.attachment,
    this.status,
    this.reply,
    this.repliedAt,
    this.isAnonymous,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  CustomerSuggestion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    category = json['category'];
    if (json['attachment'] != null) {
      attachment = [];
      if (json['attachment'] is List) {
        for (var v in (json['attachment'] as List)) {
          attachment!.add(v.toString());
        }
      }
    }
    status = json['status'];
    reply = json['reply'];
    repliedAt = json['replied_at'];
    isAnonymous = json['is_anonymous'] == 1 || json['is_anonymous'] == true;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? UserInfoModel.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['title'] = title;
    data['description'] = description;
    data['category'] = category;
    data['attachment'] = attachment;
    data['status'] = status;
    data['reply'] = reply;
    data['replied_at'] = repliedAt;
    data['is_anonymous'] = isAnonymous;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
