class PickupCenterModel {
  String? name;
  String? address;
  String? latitude;
  String? longitude;
  String? phone;

  PickupCenterModel({this.name, this.address, this.latitude, this.longitude, this.phone});

  PickupCenterModel.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    address = json['address']?.toString();
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
    phone = json['phone']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['phone'] = phone;
    return data;
  }
}
