
class ModuleModel {
  int? id;
  String? moduleName;
  String? moduleType;
  String? thumbnailFullUrl;
  String? iconFullUrl;
  int? themeId;
  String? description;
  int? storesCount;
  String? createdAt;
  String? updatedAt;
  List<ModuleZoneData>? zones;

  String? skyHeaderFullUrl;
  String? shopModuleBannerBgFullUrl;
  String? middleButtonIconFullUrl;
  String? adsBannerImageFullUrl;
  String? adsBannerLinkType;
  dynamic adsBannerLinkId;
  String? primaryColor;
  String? splashScreenImageFullUrl;
  String? floatingAdImageFullUrl;
  String? floatingAdLinkType;
  dynamic floatingAdLinkId;
  bool? floatingAdStatus;

  double? categoryViewHeight;
  double? categoryItemWidth;
  double? categoryViewFontSize;
  String? categoryViewFontColor;
  String? categoryViewTextPosition;
  int? categoryRows;
  String? categoryViewBgColor;
  String? fontFamily;
  String? iconAddToCart;
  String? iconRating;
  String? iconStore;
  List<ModuleLayoutConfig>? layoutConfig;
  Map<String, dynamic>? bottomNavConfig;
  bool? showLocationHeader;
  String? locationHeaderFontColor;
  bool? showNationalProducts;
  bool? showStoreList;
  int? adsBannerHeight;
  List<String>? searchHints;
  String? moduleButtonShape;
  int? moduleButtonRadius;
  String? moduleButtonUnselectedColor;
  double? moduleButtonWidth;
  double? moduleButtonHeight;
  String? moduleViewTextPosition;

  ModuleModel({
    this.id,
    this.moduleName,
    this.moduleType,
    this.thumbnailFullUrl,
    this.storesCount,
    this.iconFullUrl,
    this.themeId,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.zones,
    this.skyHeaderFullUrl,
    this.shopModuleBannerBgFullUrl,
    this.adsBannerImageFullUrl,
    this.adsBannerLinkType,
    this.adsBannerLinkId,
    this.primaryColor,
    this.splashScreenImageFullUrl,
    this.floatingAdImageFullUrl,
    this.floatingAdLinkType,
    this.floatingAdLinkId,
    this.floatingAdStatus,
    this.categoryViewHeight,
    this.categoryItemWidth,
    this.categoryViewFontSize,
    this.categoryViewFontColor,
    this.categoryViewTextPosition,
    this.categoryRows,
    this.categoryViewBgColor,
    this.fontFamily,
    this.iconAddToCart,
    this.iconRating,
    this.iconStore,
    this.layoutConfig,
    this.bottomNavConfig,
    this.showLocationHeader,
    this.locationHeaderFontColor,
    this.showNationalProducts,
    this.showStoreList,
    this.searchHints,
    this.moduleButtonShape,
    this.moduleButtonRadius,
    this.moduleButtonUnselectedColor,
    this.moduleButtonWidth,
    this.moduleButtonHeight,
    this.moduleViewTextPosition,
  });

  ModuleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleName = json['module_name'];
    moduleType = json['module_type'];
    thumbnailFullUrl = json['thumbnail_full_url'];
    iconFullUrl = json['icon_full_url'];
    themeId = json['theme_id'];
    description = json['description'];
    storesCount = json['stores_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    skyHeaderFullUrl = json['sky_header_full_url'];
    shopModuleBannerBgFullUrl = json['shop_module_banner_bg_full_url'];
    middleButtonIconFullUrl = json['middle_button_icon_full_url'];
    adsBannerImageFullUrl = json['ads_banner_image_full_url'];
    adsBannerLinkType = json['ads_banner_link_type'];
    adsBannerHeight = json['ads_banner_height'] != null ? int.parse(json['ads_banner_height'].toString()) : null;
    adsBannerLinkId = json['ads_banner_link_id'];
    searchHints = json['search_hints']?.cast<String>();
    primaryColor = json['primary_color'];
    splashScreenImageFullUrl = json['splash_screen_image_full_url'];
    floatingAdImageFullUrl = json['floating_ad_image_full_url'];
    floatingAdLinkType = json['floating_ad_link_type'];
    floatingAdLinkId = json['floating_ad_link_id'];
    floatingAdStatus = (json['floating_ad_status'].toString() == '1' || json['floating_ad_status'].toString() == 'true');
    categoryViewHeight = json['category_view_height']?.toDouble();
    categoryItemWidth = json['category_item_width']?.toDouble();
    categoryViewFontSize = json['category_view_font_size']?.toDouble();
    categoryViewFontColor = json['category_view_font_color'];
    categoryViewTextPosition = json['category_view_text_position'];
    categoryRows = json['category_rows'];
    categoryViewBgColor = json['category_view_bg_color'];
    fontFamily = json['font_family'];
    iconAddToCart = json['icon_add_to_cart'];
    iconRating = json['icon_rating'];
    iconStore = json['icon_store'];
    bottomNavConfig = json['bottom_nav_config'];
    showLocationHeader = (json['show_location_header'].toString() == '1' || json['show_location_header'].toString() == 'true');
    locationHeaderFontColor = json['location_header_font_color'];
    showNationalProducts = (json['show_national_products'].toString() == '1' || json['show_national_products'].toString() == 'true');
    showStoreList = (json['show_store_list'].toString() == '1' || json['show_store_list'].toString() == 'true');
    adsBannerHeight = json['ads_banner_height'] != null ? int.parse(json['ads_banner_height'].toString()) : null;
    searchHints = json['search_hints']?.cast<String>();
    moduleButtonShape = json['module_button_shape'];
    moduleButtonRadius = json['module_button_radius'] != null ? int.parse(json['module_button_radius'].toString()) : null;
    moduleButtonUnselectedColor = json['module_button_unselected_color'];
    moduleButtonWidth = json['module_button_width'] != null ? double.parse(json['module_button_width'].toString()) : null;
    moduleButtonHeight = json['module_button_height'] != null ? double.parse(json['module_button_height'].toString()) : null;
    moduleViewTextPosition = json['module_view_text_position'];
    if (json['home_layout_config'] != null) {
      layoutConfig = [];
      json['home_layout_config'].forEach((v) {
        layoutConfig!.add(ModuleLayoutConfig.fromJson(v));
      });
      layoutConfig!.sort((a, b) => (a.priority ?? 100).compareTo(b.priority ?? 100));
    }

    if (json['zones'] != null) {
      zones = <ModuleZoneData>[];
      json['zones'].forEach((v) => zones!.add(ModuleZoneData.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['module_name'] = moduleName;
    data['module_type'] = moduleType;
    data['thumbnail_full_url'] = thumbnailFullUrl;
    data['icon_full_url'] = iconFullUrl;
    data['theme_id'] = themeId;
    data['description'] = description;
    data['stores_count'] = storesCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['sky_header_full_url'] = skyHeaderFullUrl;
    data['shop_module_banner_bg_full_url'] = shopModuleBannerBgFullUrl;
    data['middle_button_icon_full_url'] = middleButtonIconFullUrl;
    data['ads_banner_image_full_url'] = adsBannerImageFullUrl;
    data['ads_banner_link_type'] = adsBannerLinkType;
    data['ads_banner_link_id'] = adsBannerLinkId;
    data['primary_color'] = primaryColor;
    data['splash_screen_image_full_url'] = splashScreenImageFullUrl;
    data['floating_ad_image_full_url'] = floatingAdImageFullUrl;
    data['floating_ad_link_type'] = floatingAdLinkType;
    data['floating_ad_link_id'] = floatingAdLinkId;
    data['floating_ad_status'] = floatingAdStatus;
    data['category_view_height'] = categoryViewHeight;
    data['category_item_width'] = categoryItemWidth;
    data['category_view_font_size'] = categoryViewFontSize;
    data['category_view_font_color'] = categoryViewFontColor;
    data['category_view_text_position'] = categoryViewTextPosition;
    data['category_rows'] = categoryRows;
    data['category_view_bg_color'] = categoryViewBgColor;
    data['font_family'] = fontFamily;
    data['icon_add_to_cart'] = iconAddToCart;
    data['icon_rating'] = iconRating;
    data['icon_store'] = iconStore;
    data['bottom_nav_config'] = bottomNavConfig;
    data['show_location_header'] = showLocationHeader;
    data['location_header_font_color'] = locationHeaderFontColor;
    data['show_national_products'] = showNationalProducts;
    data['show_store_list'] = showStoreList;
    data['ads_banner_height'] = adsBannerHeight;
    data['search_hints'] = searchHints;
    data['module_button_shape'] = moduleButtonShape;
    data['module_button_radius'] = moduleButtonRadius;
    data['module_button_unselected_color'] = moduleButtonUnselectedColor;
    data['module_button_width'] = moduleButtonWidth;
    data['module_button_height'] = moduleButtonHeight;
    data['module_view_text_position'] = moduleViewTextPosition;
    if (layoutConfig != null) {
      data['home_layout_config'] = layoutConfig!.map((v) => v.toJson()).toList();
    }

    if (zones != null) {
      data['zones'] = zones!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ModuleLayoutConfig {
  String? name;
  bool? active;
  int? priority;
  Map<String, dynamic>? titles;
  Map<String, dynamic>? params;
  String? backgroundColor;
  String? height;

  ModuleLayoutConfig({this.name, this.active, this.priority, this.titles, this.params, this.backgroundColor, this.height});

  ModuleLayoutConfig.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    active = json['active'];
    priority = json['priority'];
    titles = json['titles'] is Map ? json['titles'] : null;
    params = json['params'] is Map ? json['params'] : null;
    backgroundColor = json['backgroundColor']?.toString();
    height = json['height']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['active'] = active;
    data['priority'] = priority;
    data['titles'] = titles;
    data['params'] = params;
    data['backgroundColor'] = backgroundColor;
    data['height'] = height;
    return data;
  }
}

class ModuleZoneData {
  int? id;
  String? name;
  int? status;
  String? createdAt;
  String? updatedAt;
  bool? cashOnDelivery;
  bool? digitalPayment;

  ModuleZoneData({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.cashOnDelivery,
    this.digitalPayment,
  });

  ModuleZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cashOnDelivery = json['cash_on_delivery'];
    digitalPayment = json['digital_payment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['cash_on_delivery'] = cashOnDelivery;
    data['digital_payment'] = digitalPayment;
    return data;
  }
}
