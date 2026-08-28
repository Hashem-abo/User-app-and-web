class PickupCenterModel {
  String? name;
  String? address;
  String? latitude;
  String? longitude;

  PickupCenterModel({this.name, this.address, this.latitude, this.longitude});

  PickupCenterModel.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    address = json['address']?.toString();
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
