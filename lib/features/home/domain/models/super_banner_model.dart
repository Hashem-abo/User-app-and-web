class SuperBanner {
  int? id;
  String? name;
  String? type;
  int? moduleId;
  bool? status;
  bool? featured;
  List<SuperBannerItem>? items;

  SuperBanner(
      {this.id,
      this.name,
      this.type,
      this.moduleId,
      this.status,
      this.featured,
      this.items});

  SuperBanner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    moduleId = json['module_id'];
    status = (json['status'] is int ? json['status'] == 1 : json['status']);
    featured = (json['featured'] is int ? json['featured'] == 1 : json['featured']);
    if (json['items'] != null) {
      items = <SuperBannerItem>[];
      json['items'].forEach((v) {
        items!.add(SuperBannerItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['module_id'] = moduleId;
    data['status'] = status;
    data['featured'] = featured;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SuperBannerItem {
  int? id;
  int? superBannerId;
  String? image;
  String? url;
  String? type;
  int? linkId;
  bool? status;
  String? imageFullUrl;

  SuperBannerItem(
      {this.id,
      this.superBannerId,
      this.image,
      this.url,
      this.type,
      this.linkId,
      this.status,
      this.imageFullUrl});

  SuperBannerItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    superBannerId = json['super_banner_id'];
    image = json['image'];
    url = json['url'];
    type = json['type'];
    linkId = json['link_id'];
    status = (json['status'] is int ? json['status'] == 1 : json['status']);
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['super_banner_id'] = superBannerId;
    data['image'] = image;
    data['url'] = url;
    data['type'] = type;
    data['link_id'] = linkId;
    data['status'] = status;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}
