class GlobalStoreModel {
  int? id;
  String? name;
  String? logo;
  double? fixedShippingFee;
  double? serviceFee;
  double? commissionPercentage;
  String? urlPlaceholder;
  String? logoFullUrl;

  GlobalStoreModel({
    this.id,
    this.name,
    this.logo,
    this.fixedShippingFee,
    this.serviceFee,
    this.commissionPercentage,
    this.urlPlaceholder,
    this.logoFullUrl,
  });

  GlobalStoreModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    fixedShippingFee = json['fixed_shipping_fee'] != null ? double.parse(json['fixed_shipping_fee'].toString()) : 0.0;
    serviceFee = json['service_fee'] != null ? double.parse(json['service_fee'].toString()) : 0.0;
    commissionPercentage = json['commission_percentage'] != null ? double.parse(json['commission_percentage'].toString()) : 0.0;
    urlPlaceholder = json['url_placeholder'];
    logoFullUrl = json['logo_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    data['fixed_shipping_fee'] = fixedShippingFee;
    data['service_fee'] = serviceFee;
    data['commission_percentage'] = commissionPercentage;
    data['url_placeholder'] = urlPlaceholder;
    data['logo_full_url'] = logoFullUrl;
    return data;
  }
}
