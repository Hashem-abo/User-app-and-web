class ForumPostModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<ForumPost>? posts;

  ForumPostModel({this.totalSize, this.limit, this.offset, this.posts});

  ForumPostModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit']?.toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty)
        ? int.parse(json['offset'].toString())
        : null;
    if (json['posts'] != null) {
      posts = <ForumPost>[];
      json['posts'].forEach((v) {
        posts!.add(ForumPost.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (posts != null) {
      data['posts'] = posts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ForumPost {
  int? id;
  String? title;
  String? description;
  String? image;
  String? imageFullUrl;
  String? category;
  int? status;
  int? views;
  String? createdAt;
  String? updatedAt;

  ForumPost({
    this.id,
    this.title,
    this.description,
    this.image,
    this.imageFullUrl,
    this.category,
    this.status,
    this.views,
    this.createdAt,
    this.updatedAt,
  });

  ForumPost.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.parse(json['id'].toString()) : null;
    title = json['title'];
    description = json['description'];
    image = json['image'];
    imageFullUrl = json['image_full_url'];
    category = json['category'];
    status = json['status'] != null ? int.parse(json['status'].toString()) : 1;
    views = json['views'] != null ? int.parse(json['views'].toString()) : 0;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['image_full_url'] = imageFullUrl;
    data['category'] = category;
    data['status'] = status;
    data['views'] = views;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
