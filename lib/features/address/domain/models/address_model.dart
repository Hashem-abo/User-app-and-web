import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';

class AddressModel {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? additionalAddress;
  String? latitude;
  String? longitude;
  int? zoneId;
  List<int>? zoneIds;
  String? method;
  String? contactPersonName;
  String? streetNumber;
  String? house;
  String? floor;
  List<ZoneData>? zoneData;
  List<int>? areaIds;
  String? email;

  AddressModel({
    this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.additionalAddress,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.zoneIds,
    this.method,
    this.contactPersonName,
    this.streetNumber,
    this.house,
    this.floor,
    this.zoneData,
    this.areaIds,
    this.email,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number']?.toString();
    address = json['address'];
    additionalAddress = json['additional_address'];
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
    zoneId = (json['zone_id'] != null && json['zone_id'] != 'null') ? int.tryParse(json['zone_id'].toString()) : null;
    if (json['zone_ids'] != null) {
      try {
        if (json['zone_ids'] is List) {
          zoneIds = (json['zone_ids'] as List).map((e) => int.tryParse(e.toString()) ?? 1).toList();
        }
      } catch (_) {
        zoneIds = [1];
      }
    }
    if ((zoneIds == null || zoneIds!.isEmpty) && zoneId != null) {
      zoneIds = [zoneId!];
    }
    method = json['_method'];
    contactPersonName = json['contact_person_name'];
    streetNumber = json['road'];
    house = json['house'];
    floor = json['floor'];
    if (json['zone_data'] != null) {
      zoneData = [];
      try {
        if (json['zone_data'] is List) {
          for (var v in json['zone_data']) {
            try {
              if (v is Map<String, dynamic>) {
                zoneData!.add(ZoneData.fromJson(v));
              } else if (v is Map) {
                zoneData!.add(ZoneData.fromJson(Map<String, dynamic>.from(v)));
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
    }
    if (json['area_ids'] != null) {
      try {
        if (json['area_ids'] is List) {
          areaIds = (json['area_ids'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
        }
      } catch (_) {
        areaIds = [];
      }
    }
    if(json['contact_person_email'] != null) {
      email = json['contact_person_email'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['additional_address'] = additionalAddress;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['zone_id'] = zoneId;
    data['zone_ids'] = zoneIds;
    data['_method'] = method;
    data['contact_person_name'] = contactPersonName;
    data['road'] = streetNumber;
    data['house'] = house;
    data['floor'] = floor;
    if (zoneData != null) {
      data['zone_data'] = zoneData!.map((v) => {
        'id': v.id,
        'name': v.name,
        'status': v.status,
        'cash_on_delivery': v.cashOnDelivery,
        'digital_payment': v.digitalPayment,
        'offline_payment': v.offlinePayment,
      }).toList();
    }
    data['area_ids'] = areaIds;
    if(email != null) {
      data['contact_person_email'] = email;
    }
    return data;
  }
}
