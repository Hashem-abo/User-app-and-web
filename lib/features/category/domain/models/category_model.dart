class CategoryModel {
  int? id;
  String? name;
  String? imageFullUrl;
  int? childesCount;

  List<String>? bannersFullUrl;
  int? isTitleVisible;
  String? bannerAdFullUrl;
  int? bannerAdItemId;
  int? subCategoryHeight;
  int? subCategoryWidth;
  List<CategoryBanner>? bannersDetails;

  CategoryModel({this.id, this.name, this.imageFullUrl, this.childesCount, this.bannersFullUrl, this.isTitleVisible, this.bannerAdFullUrl, this.bannerAdItemId, this.subCategoryHeight, this.subCategoryWidth, this.bannersDetails});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
    childesCount = int.tryParse(json['childes_count'].toString());
    if(json['is_title_visible'] != null) {
      if(json['is_title_visible'] is bool) {
        isTitleVisible = json['is_title_visible'] ? 1 : 0;
      } else {
        isTitleVisible = int.tryParse(json['is_title_visible'].toString());
      }
    } else {
      isTitleVisible = 1;
    }
    if (json['banners_full_url'] != null) {
      bannersFullUrl = [];
      if (json['banners_full_url'] is List) {
        json['banners_full_url'].forEach((v) {
          bannersFullUrl!.add(v.toString());
        });
      }
    }
    bannerAdFullUrl = json['banner_ad_full_url'];
    bannerAdItemId = int.tryParse(json['banner_ad_item_id'].toString());
    subCategoryHeight = int.tryParse(json['sub_category_height'].toString());
    subCategoryWidth = int.tryParse(json['sub_category_width'].toString());
    if (json['banners_details'] != null) {
      bannersDetails = <CategoryBanner>[];
      json['banners_details'].forEach((v) {
        bannersDetails!.add(CategoryBanner.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    data['childes_count'] = childesCount;
    data['banners_full_url'] = bannersFullUrl;
    data['banners_full_url'] = bannersFullUrl;
    data['is_title_visible'] = isTitleVisible;
    data['banner_ad_full_url'] = bannerAdFullUrl;
    data['banner_ad_item_id'] = bannerAdItemId;
    data['sub_category_height'] = subCategoryHeight;
    data['sub_category_width'] = subCategoryWidth;
    if (bannersDetails != null) {
      data['banners_details'] = bannersDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryBanner {
  String? image;
  String? type;
  int? id;

  CategoryBanner({this.image, this.type, this.id});

  CategoryBanner.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    type = json['type'];
    id = int.tryParse(json['id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['type'] = type;
    data['id'] = id;
    return data;
  }
}
