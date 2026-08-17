class CustomerCreditModel {
  int? id;
  int? vendorId;
  int? customerId;
  double? creditLimit;
  double? usedCredit;
  double? availableCredit;
  int? paymentTermsDays;
  String? status;
  String? notes;
  StoreInfo? store;

  CustomerCreditModel({
    this.id,
    this.vendorId,
    this.customerId,
    this.creditLimit,
    this.usedCredit,
    this.availableCredit,
    this.paymentTermsDays,
    this.status,
    this.notes,
    this.store,
  });

  CustomerCreditModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    customerId = json['customer_id'];
    creditLimit = json['credit_limit'] != null ? double.parse(json['credit_limit'].toString()) : 0.0;
    usedCredit = json['used_credit'] != null ? double.parse(json['used_credit'].toString()) : 0.0;
    availableCredit = json['available_credit'] != null ? double.parse(json['available_credit'].toString()) : 0.0;
    paymentTermsDays = json['payment_terms_days'];
    status = json['status'];
    notes = json['notes'];
    store = json['store'] != null ? StoreInfo.fromJson(json['store']) : null;
  }
}

class StoreInfo {
  int? id;
  String? name;
  String? logo;
  String? phone;

  StoreInfo({this.id, this.name, this.logo, this.phone});

  StoreInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    phone = json['phone'];
  }
}
