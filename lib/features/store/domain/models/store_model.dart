import 'package:get/get.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/vendor_type_helper.dart';

class StoreModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Store>? stores;

  StoreModel({this.totalSize, this.limit, this.offset, this.stores});

  StoreModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['stores'] != null) {
      stores = [];
      json['stores'].forEach((v) {
        stores!.add(Store.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (stores != null) {
      data['stores'] = stores!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Store {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? logoFullUrl;
  String? latitude;
  String? longitude;
  String? address;
  double? minimumOrder;
  String? currency;
  bool? freeDelivery;
  String? coverPhotoFullUrl;
  bool? delivery;
  bool? takeAway;
  bool? scheduleOrder;
  double? avgRating;
  double? tax;
  int? ratingCount;
  int? featured;
  int? zoneId;
  int? selfDeliverySystem;
  bool? posSystem;
  double? minimumShippingCharge;
  double? maximumShippingCharge;
  double? perKmShippingCharge;
  int? open;
  bool? active;
  String? deliveryTime;
  List<int>? categoryIds;
  int? veg;
  int? nonVeg;
  int? moduleId;
  int? orderPlaceToScheduleInterval;
  Discount? discount;
  List<Schedules>? schedules;
  int? vendorId;
  bool? prescriptionOrder;
  bool? cutlery;
  String? slug;
  bool? announcementActive;
  String? announcementMessage;
  int? itemCount;
  List<Items>? items;
  bool? extraPackagingStatus;
  double? extraPackagingAmount;
  List<int>? ratings;
  int? reviewsCommentsCount;
  StoreSubscription? storeSubscription;
  String? storeBusinessModel;
  double? distance;
  String? storeOpeningTime;
  double? perKmShippingChargeGroup;
  double? minimumShippingChargeGroup;
  String? metaTitle;
  String? metaDescription;
  String? metaImage;
  int? verifiedSeller;
  String? moduleType;
  ModuleModel? module;
  String? rawVendorType;

  Store({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.logoFullUrl,
    this.latitude,
    this.longitude,
    this.address,
    this.minimumOrder,
    this.currency,
    this.freeDelivery,
    this.coverPhotoFullUrl,
    this.delivery,
    this.takeAway,
    this.scheduleOrder,
    this.avgRating,
    this.tax,
    this.featured,
    this.zoneId,
    this.ratingCount,
    this.selfDeliverySystem,
    this.posSystem,
    this.minimumShippingCharge,
    this.maximumShippingCharge,
    this.perKmShippingCharge,
    this.open,
    this.active,
    this.deliveryTime,
    this.categoryIds,
    this.veg,
    this.nonVeg,
    this.moduleId,
    this.orderPlaceToScheduleInterval,
    this.discount,
    this.schedules,
    this.vendorId,
    this.prescriptionOrder,
    this.cutlery,
    this.slug,
    this.announcementActive,
    this.announcementMessage,
    this.itemCount,
    this.items,
    this.extraPackagingStatus,
    this.extraPackagingAmount,
    this.ratings,
    this.reviewsCommentsCount,
    this.storeSubscription,
    this.storeBusinessModel,
    this.verifiedSeller,
    this.distance,
    this.storeOpeningTime,
    this.perKmShippingChargeGroup,
    this.minimumShippingChargeGroup,
    this.metaTitle,
    this.metaDescription,
    this.metaImage,
    this.moduleType,
    this.module,
    this.rawVendorType,
  });

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    logoFullUrl = json['logo_full_url'] ?? '';
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    minimumOrder = json['minimum_order'] != null ? double.tryParse(json['minimum_order'].toString()) ?? 0 : 0;
    currency = json['currency'];
    freeDelivery = json['free_delivery'];
    coverPhotoFullUrl = json['cover_photo_full_url'] ?? '';
    delivery = json['delivery'];
    takeAway = json['take_away'];
    scheduleOrder = json['schedule_order'];
    avgRating = json['avg_rating'] != null ? double.parse(json['avg_rating'].toString()) : null;
    tax = json['tax'] != null ? double.tryParse(json['tax'].toString()) : null;
    ratingCount = json['rating_count'];
    selfDeliverySystem = json['self_delivery_system'];
    posSystem = json['pos_system'];
    minimumShippingCharge = json['minimum_shipping_charge'] != null ? double.tryParse(json['minimum_shipping_charge'].toString()) : null;
    maximumShippingCharge = json['maximum_shipping_charge'] != null ? double.tryParse(json['maximum_shipping_charge'].toString()) : null;
    perKmShippingCharge = json['per_km_shipping_charge'] != null ? double.tryParse(json['per_km_shipping_charge'].toString()) ?? 0 : 0;
    perKmShippingChargeGroup = json['per_km_shipping_charge_group'] != null ? double.tryParse(json['per_km_shipping_charge_group'].toString()) ?? 0 : 0;
    minimumShippingChargeGroup = json['minimum_shipping_charge_group'] != null ? double.tryParse(json['minimum_shipping_charge_group'].toString()) ?? 0 : 0;
    open = json['open'];
    active = json['active'];
    featured = json['featured'] != null ? int.tryParse(json['featured'].toString()) : 0;
    zoneId = json['zone_id'];
    deliveryTime = json['delivery_time'];
    veg = json['veg'];
    nonVeg = json['non_veg'];
    moduleId = json['module_id'];
    moduleType = json['module_type']?.toString();
    if (json['module'] != null && json['module'] is Map<String, dynamic>) {
      module = ModuleModel.fromJson(json['module']);
    }
    orderPlaceToScheduleInterval = json['order_place_to_schedule_interval'];
    categoryIds = json['category_ids'] != null ? List<int>.from(json['category_ids'].map((e) => int.tryParse(e.toString()) ?? 0)) : [];
    discount = json['discount'] != null ? Discount.fromJson(json['discount']) : null;
    if (json['schedules'] != null) {
      schedules = <Schedules>[];
      json['schedules'].forEach((v) {
        schedules!.add(Schedules.fromJson(v));
      });
    }
    vendorId = json['vendor_id'];
    prescriptionOrder = json['prescription_order'] ?? false;
    cutlery = json['cutlery'];
    slug = json['slug'];
    announcementActive = json['announcement'] == 1;
    announcementMessage = json['announcement_message'];
    itemCount = json['total_items'] ?? 0;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    extraPackagingStatus = json['extra_packaging_status'] ?? false;
    extraPackagingAmount = json['extra_packaging_amount'] != null ? double.tryParse(json['extra_packaging_amount'].toString()) ?? 0 : 0;
    if (json['ratings'] != null && json['ratings'] != 0) {
      ratings = [];
      json['ratings'].forEach((v) {
        ratings!.add(v);
      });
    }
    reviewsCommentsCount = json['reviews_comments_count'];
    storeSubscription = json['store_sub'] != null ? StoreSubscription.fromJson(json['store_sub']) : null;
    storeBusinessModel = json['store_business_model'];
    distance = json['distance'] != null ? double.tryParse(json['distance'].toString()) : null;
    storeOpeningTime = json['current_opening_time'];
    metaTitle = json['meta_title'];
    metaDescription = json['meta_description'];
    metaImage = json['meta_image'];
    verifiedSeller = json['verified_seller'] != null ? int.tryParse(json['verified_seller'].toString()) : null;
    final parsedVendorType = json['vendor_type']?.toString() ?? json['store_type']?.toString();
    if (parsedVendorType != null &&
        parsedVendorType.trim().isNotEmpty &&
        parsedVendorType.trim().toLowerCase() != 'null' &&
        parsedVendorType.trim().toLowerCase() != 'none') {
      rawVendorType = parsedVendorType.trim();
    } else {
      rawVendorType = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['logo_full_url'] = logoFullUrl;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['minimum_order'] = minimumOrder;
    data['currency'] = currency;
    data['free_delivery'] = freeDelivery;
    data['cover_photo_full_url'] = coverPhotoFullUrl;
    data['delivery'] = delivery;
    data['take_away'] = takeAway;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['tax'] = tax;
    data['rating_count'] = ratingCount;
    data['self_delivery_system'] = selfDeliverySystem;
    data['pos_system'] = posSystem;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['open'] = open;
    data['active'] = active;
    data['veg'] = veg;
    data['featured'] = featured;
    data['zone_id'] = zoneId;
    data['non_veg'] = nonVeg;
    data['module_id'] = moduleId;
    data['order_place_to_schedule_interval'] = orderPlaceToScheduleInterval;
    data['delivery_time'] = deliveryTime;
    data['category_ids'] = categoryIds;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    if (schedules != null) {
      data['schedules'] = schedules!.map((v) => v.toJson()).toList();
    }
    data['vendor_id'] = vendorId;
    data['prescription_order'] = prescriptionOrder;
    data['cutlery'] = cutlery;
    data['slug'] = slug;
    data['announcement'] = announcementActive;
    data['announcement_message'] = announcementMessage;
    data['total_items'] = itemCount;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['extra_packaging_status'] = extraPackagingStatus;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['ratings'] = ratings;
    data['reviews_comments_count'] = reviewsCommentsCount;
    if (storeSubscription != null) {
      data['store_sub'] = storeSubscription!.toJson();
    }
    data['store_business_model'] = storeBusinessModel;
    data['distance'] = distance;
    data['per_km_shipping_charge_group'] = perKmShippingChargeGroup;
    data['minimum_shipping_charge_group'] = minimumShippingChargeGroup;
    data['current_opening_time'] = storeOpeningTime;
    data['meta_title'] = metaTitle;
    data['meta_description'] = metaDescription;
    data['meta_image'] = metaImage;
    data['verified_seller'] = verifiedSeller;
    data['module_type'] = moduleType;
    if (module != null) {
      data['module'] = module!.toJson();
    }
    data['vendor_type'] = rawVendorType;
    return data;
  }

  bool get isZad {
    if (moduleId == 1) return true;
    if (module?.id == 1) return true;
    final name = (module?.moduleName ?? '').trim().toLowerCase();
    if (name.contains('zad') || name.contains('زاد')) return true;
    if (moduleType == 'zad' || module?.moduleType == 'zad') return true;

    if (Get.isRegistered<SplashController>()) {
      final splash = Get.find<SplashController>();
      final curModule = splash.module ?? splash.cacheModule;
      if (curModule != null) {
        final curName = (curModule.moduleName ?? '').trim().toLowerCase();
        final isCurZad = curModule.id == 1 ||
            curName.contains('zad') ||
            curName.contains('زاد') ||
            curModule.moduleType == 'zad';
        if (isCurZad && (moduleId == null || moduleId == curModule.id)) {
          return true;
        }
      }
    }
    return false;
  }

  String get vendorType {
    if (rawVendorType != null &&
        rawVendorType!.trim().isNotEmpty &&
        rawVendorType!.trim().toLowerCase() != 'null' &&
        rawVendorType!.trim().toLowerCase() != 'none') {
      if (VendorTypeHelper.isRetailer(rawVendorType)) {
        return '';
      }
      return VendorTypeHelper.resolveVendorType(rawVendorType);
    }

    if (storeBusinessModel != null &&
        storeBusinessModel!.trim().isNotEmpty &&
        storeBusinessModel!.trim().toLowerCase() != 'null' &&
        storeBusinessModel!.trim().toLowerCase() != 'none') {
      if (VendorTypeHelper.isRetailer(storeBusinessModel)) {
        return '';
      }
      if (VendorTypeHelper.isWholesaler(storeBusinessModel) || VendorTypeHelper.isFactory(storeBusinessModel)) {
        return VendorTypeHelper.resolveVendorType(storeBusinessModel);
      }
    }

    // In Zad (grocery / module 1), if vendor_type is null or not explicitly set, hide it completely.
    if (isZad) {
      return '';
    }

    if (module?.moduleName != null && module!.moduleName!.trim().isNotEmpty) {
      return module!.moduleName!;
    }
    if (moduleType != null && moduleType!.trim().isNotEmpty) {
      return moduleType!.tr;
    }
    if (moduleId != null && Get.isRegistered<SplashController>()) {
      final splash = Get.find<SplashController>();
      if (splash.moduleList != null) {
        for (final m in splash.moduleList!) {
          if (m.id == moduleId) {
            return m.moduleName ?? (m.moduleType != null ? m.moduleType!.tr : '');
          }
        }
      }
      if (splash.module != null && splash.module!.id == moduleId) {
        return splash.module!.moduleName ?? (splash.module!.moduleType != null ? splash.module!.moduleType!.tr : '');
      }
    }
    if (storeBusinessModel != null &&
        storeBusinessModel!.trim().isNotEmpty &&
        storeBusinessModel!.trim().toLowerCase() != 'null' &&
        storeBusinessModel!.trim().toLowerCase() != 'none' &&
        storeBusinessModel!.trim().toLowerCase() != 'commission' &&
        storeBusinessModel!.trim().toLowerCase() != 'subscription') {
      return storeBusinessModel!.tr;
    }
    if (Get.isRegistered<SplashController>() && Get.find<SplashController>().module != null) {
      final m = Get.find<SplashController>().module!;
      return m.moduleName ?? (m.moduleType != null ? m.moduleType!.tr : '');
    }
    return '';
  }
}

class Discount {
  int? id;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  int? storeId;
  String? createdAt;
  String? updatedAt;

  Discount({
    this.id,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.minPurchase,
    this.maxDiscount,
    this.discount,
    this.discountType,
    this.storeId,
    this.createdAt,
    this.updatedAt,
  });

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    if (json['start_time'] != null) {
      final s = json['start_time'].toString();
      startTime = s.length > 5 ? s.substring(0, 5) : s;
    }
    if (json['end_time'] != null) {
      final s = json['end_time'].toString();
      endTime = s.length > 5 ? s.substring(0, 5) : s;
    }
    minPurchase = json['min_purchase'] != null ? double.tryParse(json['min_purchase'].toString()) : null;
    maxDiscount = json['max_discount'] != null ? double.tryParse(json['max_discount'].toString()) : null;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
    discountType = json['discount_type'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['store_id'] = storeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Schedules {
  int? id;
  int? storeId;
  int? day;
  String? openingTime;
  String? closingTime;

  Schedules({
    this.id,
    this.storeId,
    this.day,
    this.openingTime,
    this.closingTime,
  });

  Schedules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    day = json['day'];
    if (json['opening_time'] != null) {
      final s = json['opening_time'].toString();
      openingTime = s.length > 5 ? s.substring(0, 5) : s;
    }
    if (json['closing_time'] != null) {
      final s = json['closing_time'].toString();
      closingTime = s.length > 5 ? s.substring(0, 5) : s;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_id'] = storeId;
    data['day'] = day;
    data['opening_time'] = openingTime;
    data['closing_time'] = closingTime;
    return data;
  }
}

class Refund {
  int? id;
  int? orderId;
  List<String>? imageFullUrl;
  String? customerReason;
  String? customerNote;
  String? adminNote;

  Refund({
    this.id,
    this.orderId,
    this.imageFullUrl,
    this.customerReason,
    this.customerNote,
    this.adminNote,
  });

  Refund.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    if (json['image_full_url'] != null) {
      imageFullUrl = [];
      json['image_full_url'].forEach((v) => imageFullUrl!.add(v));
    }
    customerReason = json['customer_reason'];
    customerNote = json['customer_note'];
    adminNote = json['admin_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['image_full_url'] = imageFullUrl;
    data['customer_reason'] = customerReason;
    data['customer_note'] = customerNote;
    data['admin_note'] = adminNote;
    return data;
  }
}

class Items {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  int? categoryId;
  String? categoryIds;
  String? variations;
  String? addOns;
  String? attributes;
  String? choiceOptions;
  double? price;
  double? tax;
  String? taxType;
  double? discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? veg;
  int? status;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  int? orderCount;
  double? avgRating;
  int? ratingCount;
  String? rating;
  int? moduleId;
  int? stock;
  int? unitId;
  List<String>? images;
  String? foodVariations;
  String? slug;
  int? recommended;
  int? organic;
  int? maximumCartQuantity;
  int? isApproved;
  String? unitType;

  Items({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.categoryId,
    this.categoryIds,
    this.variations,
    this.addOns,
    this.attributes,
    this.choiceOptions,
    this.price,
    this.tax,
    this.taxType,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.veg,
    this.status,
    this.storeId,
    this.createdAt,
    this.updatedAt,
    this.orderCount,
    this.avgRating,
    this.ratingCount,
    this.rating,
    this.moduleId,
    this.stock,
    this.unitId,
    this.images,
    this.foodVariations,
    this.slug,
    this.recommended,
    this.organic,
    this.maximumCartQuantity,
    this.isApproved,
    this.unitType,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    categoryId = json['category_id'];
    categoryIds = json['category_ids'];
    variations = json['variations'];
    addOns = json['add_ons'];
    attributes = json['attributes'];
    choiceOptions = json['choice_options'];
    price = json['price']?.toDouble();
    tax = json['tax']?.toDouble();
    taxType = json['tax_type'];
    discount = json['discount']?.toDouble();
    discountType = json['discount_type'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    veg = json['veg'];
    status = json['status'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    orderCount = json['order_count'];
    avgRating = json['avg_rating']?.toDouble();
    ratingCount = json['rating_count'];
    rating = json['rating'];
    moduleId = json['module_id'];
    stock = json['stock'];
    unitId = json['unit_id'];
    images = json['images'].cast<String>();
    foodVariations = json['food_variations'];
    slug = json['slug'];
    recommended = json['recommended'];
    organic = json['organic'];
    maximumCartQuantity = json['maximum_cart_quantity'];
    isApproved = json['is_approved'];
    unitType = json['unit_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['category_id'] = categoryId;
    data['category_ids'] = categoryIds;
    data['variations'] = variations;
    data['add_ons'] = addOns;
    data['attributes'] = attributes;
    data['choice_options'] = choiceOptions;
    data['price'] = price;
    data['tax'] = tax;
    data['tax_type'] = taxType;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['veg'] = veg;
    data['status'] = status;
    data['store_id'] = storeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['order_count'] = orderCount;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['rating'] = rating;
    data['module_id'] = moduleId;
    data['stock'] = stock;
    data['unit_id'] = unitId;
    data['images'] = images;
    data['food_variations'] = foodVariations;
    data['slug'] = slug;
    data['recommended'] = recommended;
    data['organic'] = organic;
    data['maximum_cart_quantity'] = maximumCartQuantity;
    data['is_approved'] = isApproved;
    data['unit_type'] = unitType;
    return data;
  }
}

class StoreSubscription {
  int? id;
  int? packageId;
  int? storeId;
  String? expiryDate;
  String? maxOrder;
  String? maxProduct;
  int? pos;
  int? mobileApp;
  int? chat;
  int? review;
  int? selfDelivery;
  int? status;
  int? totalPackageRenewed;
  String? createdAt;
  String? updatedAt;

  StoreSubscription({
    this.id,
    this.packageId,
    this.storeId,
    this.expiryDate,
    this.maxOrder,
    this.maxProduct,
    this.pos,
    this.mobileApp,
    this.chat,
    this.review,
    this.selfDelivery,
    this.status,
    this.totalPackageRenewed,
    this.createdAt,
    this.updatedAt,
  });

  StoreSubscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageId = json['package_id'];
    storeId = json['store_id'];
    expiryDate = json['expiry_date'];
    maxOrder = json['max_order'];
    maxProduct = json['max_product'];
    pos = json['pos'];
    mobileApp = json['mobile_app'];
    chat = (json['chat'] != null && json['chat'] != 'null') ? json['chat'] : 0;
    review = json['review'] ?? 0;
    selfDelivery = json['self_delivery'];
    status = json['status'];
    totalPackageRenewed = json['total_package_renewed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_id'] = packageId;
    data['store_id'] = storeId;
    data['expiry_date'] = expiryDate;
    data['max_order'] = maxOrder;
    data['max_product'] = maxProduct;
    data['pos'] = pos;
    data['mobile_app'] = mobileApp;
    data['chat'] = chat;
    data['review'] = review;
    data['self_delivery'] = selfDelivery;
    data['status'] = status;
    data['total_package_renewed'] = totalPackageRenewed;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
