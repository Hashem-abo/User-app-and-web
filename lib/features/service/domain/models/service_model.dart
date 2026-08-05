import 'package:sixam_mart/features/service/domain/models/service_provider_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_category_model.dart';

class ServiceModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Service>? services;

  ServiceModel({this.totalSize, this.limit, this.offset, this.services});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['services'] != null) {
      services = <Service>[];
      json['services'].forEach((v) {
        services!.add(Service.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Service {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  double? price;
  String? priceType;
  String? serviceMode;
  String? rentalUnit;
  int? providerId;
  int? categoryId;
  int? subCategoryId;
  int? shelfId;
  int? moduleId;
  bool? status;
  double? avgRating;
  int? reviewsCount;
  ServiceProviderModel? provider;
  ServiceCategoryModel? category;
  ServiceCategoryModel? subCategory;

  String? categoryName;

  Service({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.price,
    this.priceType,
    this.serviceMode,
    this.rentalUnit,
    this.providerId,
    this.categoryId,
    this.subCategoryId,
    this.shelfId,
    this.moduleId,
    this.status,
    this.avgRating,
    this.reviewsCount,
    this.provider,
    this.category,
    this.subCategory,
    this.categoryName,
  });

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    priceType = json['price_type'];
    serviceMode = json['service_mode'];
    rentalUnit = json['rental_unit'];
    providerId = json['provider_id'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    shelfId = json['shelf_id'];
    moduleId = json['module_id'];
    status = json['status'] == 1 || json['status'] == true;
    avgRating = json['avg_rating'] != null ? double.tryParse(json['avg_rating'].toString()) : null;
    reviewsCount = json['reviews_count'];
    if (json['category'] != null) {
      category = ServiceCategoryModel.fromJson(json['category']);
      categoryName = category!.name;
    }
    if (json['provider'] != null) {
      provider = ServiceProviderModel.fromJson(json['provider']);
    }
    if (json['sub_category'] != null) {
      subCategory = ServiceCategoryModel.fromJson(json['sub_category']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['price'] = price;
    data['price_type'] = priceType;
    data['service_mode'] = serviceMode;
    data['rental_unit'] = rentalUnit;
    data['provider_id'] = providerId;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['shelf_id'] = shelfId;
    data['module_id'] = moduleId;
    data['status'] = status;
    data['avg_rating'] = avgRating;
    data['reviews_count'] = reviewsCount;
    return data;
  }
}
