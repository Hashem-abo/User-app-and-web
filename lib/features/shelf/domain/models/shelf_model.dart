import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_category_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_provider_model.dart';

class ShelfModel {
  int? id;
  String? name;
  String? image;
  String? backColor;
  String? backgroundType;
  String? backColor2;
  String? backImage;
  double? height;
  int? itemCardWidth;
  int? moduleId;
  int? status;
  String? type;
  String? dynamicType;
  int? parentId;
  List<Item>? items;
  List<CategoryModel>? categories;
  List<Store>? stores;
  List<Service>? services;
  List<ServiceCategoryModel>? serviceCategories;
  List<ServiceProviderModel>? serviceProviders;
  List<ShelfModel>? children;
  String? titleColor;
  int? titleFontSize;
  String? imageType;
  String? viewAllColor;
  int? headerHeight;
  bool? hideTitle;
  bool? hideViewAll;
  bool? autoPlay;
  int? rowCount;

  ShelfModel({
    this.id,
    this.name,
    this.image,
    this.backColor,
    this.backgroundType,
    this.backColor2,
    this.backImage,
    this.height,
    this.itemCardWidth,
    this.moduleId,
    this.status,
    this.type,
    this.dynamicType,
    this.parentId,
    this.items,
    this.categories,
    this.stores,
    this.services,
    this.serviceCategories,
    this.serviceProviders,
    this.children,
    this.titleColor,
    this.titleFontSize,
    this.imageType,
    this.viewAllColor,
    this.headerHeight,
    this.hideTitle,
    this.hideViewAll,
    this.autoPlay,
    this.rowCount,
  });

  ShelfModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    backColor = json['back_color'];
    backgroundType = json['background_type'];
    backColor2 = json['back_color_2'];
    backImage = json['back_image_full_url'];
    height = json['height'] != null ? double.parse(json['height'].toString()) : null;
    itemCardWidth = json['item_card_width'];
    moduleId = json['module_id'];
    status = json['status'];
    type = json['type'];
    dynamicType = json['dynamic_type'];
    parentId = json['parent_id'];
    titleColor = json['title_color'];
    titleFontSize = json['title_font_size'];
    imageType = json['image_type'];
    viewAllColor = json['view_all_color'];
    headerHeight = json['header_height'];
    hideTitle = json['hide_title'] == 1 || json['hide_title'] == true;
    hideViewAll = json['hide_view_all'] == 1 || json['hide_view_all'] == true;
    autoPlay = json['auto_play'] == 1 || json['auto_play'] == true;
    rowCount = json['row_count'] != null ? int.parse(json['row_count'].toString()) : 1;
    if (json['items'] != null) {
      items = <Item>[];
      json['items'].forEach((v) {
        items!.add(Item.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = <CategoryModel>[];
      json['categories'].forEach((v) {
        categories!.add(CategoryModel.fromJson(v));
      });
    }
    if (json['stores'] != null) {
      stores = <Store>[];
      json['stores'].forEach((v) {
        stores!.add(Store.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = <Service>[];
      json['services'].forEach((v) {
        services!.add(Service.fromJson(v));
      });
    }
    if (json['service_categories'] != null) {
      serviceCategories = <ServiceCategoryModel>[];
      json['service_categories'].forEach((v) {
        serviceCategories!.add(ServiceCategoryModel.fromJson(v));
      });
    }
    if (json['service_providers'] != null) {
      serviceProviders = <ServiceProviderModel>[];
      json['service_providers'].forEach((v) {
        serviceProviders!.add(ServiceProviderModel.fromJson(v));
      });
    }
    if (json['children'] != null) {
      children = <ShelfModel>[];
      json['children'].forEach((v) {
        children!.add(ShelfModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['back_color'] = backColor;
    data['background_type'] = backgroundType;
    data['back_color_2'] = backColor2;
    data['back_image_full_url'] = backImage;
    data['height'] = height;
    data['item_card_width'] = itemCardWidth;
    data['module_id'] = moduleId;
    data['status'] = status;
    data['type'] = type;
    data['dynamic_type'] = dynamicType;
    data['parent_id'] = parentId;
    data['title_color'] = titleColor;
    data['title_font_size'] = titleFontSize;
    data['image_type'] = imageType;
    data['view_all_color'] = viewAllColor;
    data['header_height'] = headerHeight;
    data['hide_title'] = hideTitle;
    data['hide_view_all'] = hideViewAll;
    data['auto_play'] = autoPlay;
    data['row_count'] = rowCount;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (stores != null) {
      data['stores'] = stores!.map((v) => v.toJson()).toList();
    }
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    if (serviceCategories != null) {
      data['service_categories'] = serviceCategories!.map((v) => v.toJson()).toList();
    }
    if (serviceProviders != null) {
      data['service_providers'] = serviceProviders!.map((v) => v.toJson()).toList();
    }
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ShelfDataModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<ShelfModel>? shelves;

  ShelfDataModel({this.totalSize, this.limit, this.offset, this.shelves});

  ShelfDataModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['shelves'] != null) {
      shelves = <ShelfModel>[];
      json['shelves'].forEach((v) {
        shelves!.add(ShelfModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (shelves != null) {
      data['shelves'] = shelves!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
