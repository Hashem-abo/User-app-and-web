import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

class StoreCornerModel {
  int? id;
  int? storeId;
  int? priority;
  String? backgroundColor;
  String? backgroundType;
  String? backgroundColor2;
  String? viewMoreButtonColor;
  String? viewMoreButtonText;
  String? viewMoreButtonWidth;
  String? coverImageFullUrl;
  double? itemWidth;
  Store? store;
  List<Item>? items;

  StoreCornerModel({
    this.id,
    this.storeId,
    this.priority,
    this.backgroundColor,
    this.backgroundType,
    this.backgroundColor2,
    this.viewMoreButtonColor,
    this.viewMoreButtonText,
    this.viewMoreButtonWidth,
    this.coverImageFullUrl,
    this.store,
    this.items,
  });

  StoreCornerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    priority = json['priority'];
    backgroundColor = json['background_color'];
    backgroundType = json['background_type'];
    backgroundColor2 = json['background_color_2'];
    viewMoreButtonColor = json['view_more_button_color'];
    viewMoreButtonText = json['view_more_button_text'];
    viewMoreButtonWidth = json['view_more_button_width'];
    coverImageFullUrl = json['cover_image_full_url'];
    itemWidth = json['item_width'] != null ? double.parse(json['item_width'].toString()) : null;
    store = json['store'] != null ? Store.fromJson(json['store']) : null;
    if (json['items'] != null) {
      items = <Item>[];
      json['items'].forEach((v) {
        items!.add(Item.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_id'] = storeId;
    data['priority'] = priority;
    data['background_color'] = backgroundColor;
    data['background_type'] = backgroundType;
    data['background_color_2'] = backgroundColor2;
    data['view_more_button_color'] = viewMoreButtonColor;
    data['view_more_button_text'] = viewMoreButtonText;
    data['view_more_button_width'] = viewMoreButtonWidth;
    data['cover_image_full_url'] = coverImageFullUrl;
    data['item_width'] = itemWidth;
    if (store != null) {
      data['store'] = store!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StoreCornerDataModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<StoreCornerModel>? storeCorners;

  StoreCornerDataModel({this.totalSize, this.limit, this.offset, this.storeCorners});

  StoreCornerDataModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['store_corners'] != null) {
      storeCorners = <StoreCornerModel>[];
      json['store_corners'].forEach((v) {
        storeCorners!.add(StoreCornerModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (storeCorners != null) {
      data['store_corners'] = storeCorners!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
