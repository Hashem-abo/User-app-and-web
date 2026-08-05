import 'package:sixam_mart/features/item/domain/models/item_model.dart';

class TrendHashtagModel {
  String? tag;
  String? title;
  String? subtitle;
  String? coverImage;
  List<Item>? items;

  TrendHashtagModel({
    this.tag,
    this.title,
    this.subtitle,
    this.coverImage,
    this.items,
  });

  factory TrendHashtagModel.fromJson(Map<String, dynamic> json) {
    List<Item> itemsList = [];
    if (json['items'] != null) {
      json['items'].forEach((v) {
        itemsList.add(Item.fromJson(v));
      });
    }
    return TrendHashtagModel(
      tag: json['tag'],
      title: json['title'],
      subtitle: json['subtitle'],
      coverImage: json['cover_image'],
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tag'] = tag;
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['cover_image'] = coverImage;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TrendBrandModel {
  String? name;
  String? tagline;
  String? logo;
  String? banner;
  List<Item>? items;

  TrendBrandModel({
    this.name,
    this.tagline,
    this.logo,
    this.banner,
    this.items,
  });

  factory TrendBrandModel.fromJson(Map<String, dynamic> json) {
    List<Item> itemsList = [];
    if (json['items'] != null) {
      json['items'].forEach((v) {
        itemsList.add(Item.fromJson(v));
      });
    }
    return TrendBrandModel(
      name: json['name'],
      tagline: json['tagline'],
      logo: json['logo'],
      banner: json['banner'],
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['tagline'] = tagline;
    data['logo'] = logo;
    data['banner'] = banner;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
