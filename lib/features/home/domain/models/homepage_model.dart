import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/banner/domain/models/banner_model.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/banner/domain/models/promotional_banner_model.dart';
import 'package:sixam_mart/features/shelf/domain/models/shelf_model.dart';
import 'package:sixam_mart/features/home/domain/models/store_corner_model.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/home/domain/models/super_banner_model.dart';

class HomepageModel {
  List<ModuleModel>? modules;
  BannerModel? banners;
  List<CategoryModel>? categories;
  PromotionalBanner? otherBanners;
  List<ShelfModel>? shelves;
  StoreCornerDataModel? storeCorner;
  List<BasicCampaignModel>? campaignsBasic;
  List<Item>? campaignsItem;
  List<SuperBanner>? superBanners;

  HomepageModel({
    this.modules,
    this.banners,
    this.categories,
    this.otherBanners,
    this.shelves,
    this.storeCorner,
    this.campaignsBasic,
    this.campaignsItem,
    this.superBanners,
  });
  HomepageModel.fromJson(Map<String, dynamic> json) {
    // ====> DIAGNOSTIC: print all top-level keys in the homepage JSON
    if (json['modules'] != null && json['modules'] is List) {
      modules = <ModuleModel>[];
      for (var v in json['modules']) {
        modules!.add(ModuleModel.fromJson(v));
      }
    }
    if (json['banners'] != null) {
      banners = json['banners'] is Map ? BannerModel.fromJson(json['banners']) : null;
    }
    if (json['categories'] != null && json['categories'] is List) {
      categories = <CategoryModel>[];
      for (var v in json['categories']) {
        categories!.add(CategoryModel.fromJson(v));
      }
    }
    if (json['other_banners'] != null) {
      otherBanners = json['other_banners'] is Map ? PromotionalBanner.fromJson(json['other_banners']) : null;
    }
    if (json['shelves'] != null) {
    //  print("HOMEPAGE_MODEL: shelves raw json data: ${json['shelves']}");
      var shelvesJson = json['shelves'];
      if (shelvesJson is Map && shelvesJson.containsKey('shelves')) {
        shelvesJson = shelvesJson['shelves'];
      }
      if (shelvesJson is List) {
        shelves = <ShelfModel>[];
        for (var v in shelvesJson) {
          shelves!.add(ShelfModel.fromJson(v));
        }
      } else {
      //  print("HOMEPAGE_MODEL: shelves is NOT a List! Type is: ${shelvesJson.runtimeType}");
      }
    }
    if (json['store_corner'] != null) {
      storeCorner = json['store_corner'] is Map ? StoreCornerDataModel.fromJson(json['store_corner']) : null;
    }
    if (json['campaigns_basic'] != null && json['campaigns_basic'] is List) {
      campaignsBasic = <BasicCampaignModel>[];
      for (var v in json['campaigns_basic']) {
        campaignsBasic!.add(BasicCampaignModel.fromJson(v));
      }
    }
    if (json['campaigns_item'] != null && json['campaigns_item'] is List) {
      campaignsItem = <Item>[];
      for (var v in json['campaigns_item']) {
        campaignsItem!.add(Item.fromJson(v));
      }
    }
    if (json['super_banners'] != null && json['super_banners'] is List) {
    // print("HOMEPAGE_MODEL: super_banners raw json data: ${json['super_banners']}");
       superBanners = <SuperBanner>[];
      for (var v in json['super_banners']) {
        superBanners!.add(SuperBanner.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (modules != null) {
      data['modules'] = modules!.map((v) => v.toJson()).toList();
    }
    if (banners != null) {
      data['banners'] = banners!.toJson();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (otherBanners != null) {
      data['other_banners'] = otherBanners!.toJson();
    }
    if (shelves != null) {
      data['shelves'] = shelves!.map((v) => v.toJson()).toList();
    }
    if (storeCorner != null) {
      data['store_corner'] = storeCorner!.toJson();
    }
    if (campaignsBasic != null) {
      data['campaigns_basic'] = campaignsBasic!.map((v) => v.toJson()).toList();
    }
    if (campaignsItem != null) {
      data['campaigns_item'] = campaignsItem!.map((v) => v.toJson()).toList();
    }
    if (superBanners != null) {
      data['super_banners'] = superBanners!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
