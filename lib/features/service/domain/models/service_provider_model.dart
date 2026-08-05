class ServiceProviderModel {
  int? id;
  int? moduleId;
  int? vendorId;
  int? zoneId;
  int? shelfId;
  String? companyName;
  String? companyAddress;
  String? companyPhone;
  String? companyEmail;
  String? logoFullUrl;
  String? coverImageFullUrl;
  bool? status;
  double? avgRating;
  int? reviewsCount;
  int? verified;

  ServiceProviderModel({
    this.id,
    this.moduleId,
    this.vendorId,
    this.zoneId,
    this.shelfId,
    this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyEmail,
    this.logoFullUrl,
    this.coverImageFullUrl,
    this.status,
    this.avgRating,
    this.reviewsCount,
    this.verified,
  });

  double? get rating => avgRating;

  ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleId = json['module_id'];
    vendorId = json['vendor_id'];
    zoneId = json['zone_id'];
    shelfId = json['shelf_id'];
    companyName = json['company_name'];
    companyAddress = json['address'] ?? json['company_address'];
    companyPhone = json['phone'] ?? json['company_phone'];
    companyEmail = json['email'] ?? json['company_email'];
    logoFullUrl = json['logo_full_url'];
    coverImageFullUrl = json['cover_image_full_url'];
    status = json['status'] == 1 || json['status'] == true;
    avgRating = json['avg_rating'] != null ? double.tryParse(json['avg_rating'].toString()) : null;
    reviewsCount = json['reviews_count'];
    verified = json['verified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['module_id'] = moduleId;
    data['vendor_id'] = vendorId;
    data['zone_id'] = zoneId;
    data['shelf_id'] = shelfId;
    data['company_name'] = companyName;
    data['address'] = companyAddress;
    data['phone'] = companyPhone;
    data['email'] = companyEmail;
    data['logo_full_url'] = logoFullUrl;
    data['cover_image_full_url'] = coverImageFullUrl;
    data['status'] = status;
    data['avg_rating'] = avgRating;
    data['reviews_count'] = reviewsCount;
    data['verified'] = verified;
    return data;
  }
}
