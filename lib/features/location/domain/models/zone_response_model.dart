import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/checkout/domain/models/pickup_center_model.dart';

class ZoneResponseModel {
  final bool _isSuccess;
  final List<int> _zoneIds;
  final String? _message;
  final List<ZoneData> _zoneData;
  final List<int> _areaIds;
  final int? statusCode;
  ZoneResponseModel(this._isSuccess, this._message, this._zoneIds, this._zoneData, this._areaIds, this.statusCode);

  String? get message => _message;
  List<int> get zoneIds => _zoneIds;
  bool get isSuccess => _isSuccess;
  List<ZoneData> get zoneData => _zoneData;
  List<int> get areaIds => _areaIds;
  int? get status => statusCode;
}

class ZoneData {
  int? id;
  int? status;
  String? name;
  bool? cashOnDelivery;
  bool? digitalPayment;
  bool? offlinePayment;
  List<Modules>? modules;
  List<LatLng>? formatedCoordinates;
  List<String>? districts;
  List<PickupCenterModel>? pickupCenters;

  ZoneData({
    this.id,
    this.status,
    this.name,
    this.cashOnDelivery,
    this.digitalPayment,
    this.offlinePayment,
    this.modules,
    this.formatedCoordinates,
    this.districts,
    this.pickupCenters,
  });

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    name = json['name'];
    cashOnDelivery = json['cash_on_delivery'];
    digitalPayment = json['digital_payment'];
    offlinePayment = json['offline_payment'];
    if (json['modules'] != null) {
      modules = <Modules>[];
      json['modules'].forEach((v) {
        modules!.add(Modules.fromJson(v));
      });
    }
    if (json['formated_coordinates'] != null) {
      formatedCoordinates = [];
      json['formated_coordinates'].forEach((v) {
        if (v != null && v['lat'] != null && v['lng'] != null) {
          final lat = double.tryParse(v['lat'].toString());
          final lng = double.tryParse(v['lng'].toString());
          if (lat != null && lng != null) {
            formatedCoordinates!.add(LatLng(lat, lng));
          }
        }
      });
    }
    if (json['districts'] != null) {
      districts = [];
      json['districts'].forEach((v) {
        districts!.add(v.toString());
      });
    }
    if (json['pickup_centers'] != null) {
      pickupCenters = <PickupCenterModel>[];
      dynamic pcData = json['pickup_centers'];
      if (pcData is String) {
        try { pcData = jsonDecode(pcData); } catch (e) { pcData = []; }
      }
      if (pcData is List) {
        for (var v in pcData) {
          if (v is Map<String, dynamic>) {
            pickupCenters!.add(PickupCenterModel.fromJson(v));
          } else if (v is String) {
            pickupCenters!.add(PickupCenterModel(name: v, address: v));
          }
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['name'] = name;
    data['cash_on_delivery'] = cashOnDelivery;
    data['digital_payment'] = digitalPayment;
    data['offline_payment'] = offlinePayment;
    if (modules != null) {
      data['modules'] = modules!.map((v) => v.toJson()).toList();
    }
    if (formatedCoordinates != null) {
      data['formated_coordinates'] = formatedCoordinates!.map((v) => {'lat': v.latitude, 'lng': v.longitude}).toList();
    }
    if (districts != null) {
      data['districts'] = districts;
    }
    return data;
  }
}

class MinimumDeliveryTime {
  String? value;
  String? unit;

  MinimumDeliveryTime({this.value, this.unit});

  MinimumDeliveryTime.fromJson(Map<String, dynamic> json) {
    value = json['value']?.toString();
    unit = json['unit']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['unit'] = unit;
    return data;
  }
}

class DeliveryOptions {
  int? id;
  int? zoneId;
  String? deliveryType;
  double? extraCharge;
  double? reduceCharge;
  MinimumDeliveryTime? addDeliveryTime;
  MinimumDeliveryTime? reduceDeliveryTime;
  String? createdAt;
  String? updatedAt;

  DeliveryOptions({
    this.id, this.zoneId, this.deliveryType, this.extraCharge, this.reduceCharge,
    this.addDeliveryTime, this.reduceDeliveryTime, this.createdAt, this.updatedAt,
  });

  DeliveryOptions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    zoneId = json['zone_id'];
    deliveryType = json['delivery_type'];
    extraCharge = double.tryParse(json['extra_charge'].toString());
    reduceCharge = double.tryParse(json['reduce_charge'].toString());
    final dynamic rawAdd = json['add_delivery_time'];
    if (rawAdd is Map<String, dynamic>) {
      addDeliveryTime = MinimumDeliveryTime.fromJson(rawAdd);
    } else if (rawAdd != null) {
      addDeliveryTime = MinimumDeliveryTime(value: rawAdd.toString(), unit: 'min');
    }

    final dynamic rawReduce = json['reduce_delivery_time'];
    if (rawReduce is Map<String, dynamic>) {
      reduceDeliveryTime = MinimumDeliveryTime.fromJson(rawReduce);
    } else if (rawReduce != null) {
      reduceDeliveryTime = MinimumDeliveryTime(value: rawReduce.toString(), unit: 'min');
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['zone_id'] = zoneId;
    data['delivery_type'] = deliveryType;
    data['extra_charge'] = extraCharge;
    data['reduce_charge'] = reduceCharge;
    if (addDeliveryTime != null) {
      data['add_delivery_time'] = addDeliveryTime!.toJson();
    }
    if (reduceDeliveryTime != null) {
      data['reduce_delivery_time'] = reduceDeliveryTime!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Modules {
  int? id;
  String? moduleName;
  String? moduleType;
  String? thumbnail;
  String? status;
  int? storesCount;
  String? createdAt;
  String? updatedAt;
  String? icon;
  int? themeId;
  String? description;
  int? allZoneService;
  bool? additionalDeliveryOptionStatus;
  List<DeliveryOptions>? deliveryOptions;
  Pivot? pivot;

  Modules({
    this.id,
    this.moduleName,
    this.moduleType,
    this.thumbnail,
    this.status,
    this.storesCount,
    this.createdAt,
    this.updatedAt,
    this.icon,
    this.themeId,
    this.description,
    this.allZoneService,
    this.additionalDeliveryOptionStatus,
    this.deliveryOptions,
    this.pivot,
  });

  Modules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleName = json['module_name'];
    moduleType = json['module_type'];
    thumbnail = json['thumbnail'];
    status = json['status'];
    storesCount = json['stores_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    icon = json['icon'];
    themeId = json['theme_id'];
    description = json['description'];
    allZoneService = json['all_zone_service'];
    additionalDeliveryOptionStatus = json['additional_delivery_option_status'] ?? false;
    if (json['delivery_options'] != null) {
      deliveryOptions = <DeliveryOptions>[];
      json['delivery_options'].forEach((v) {
        deliveryOptions!.add(DeliveryOptions.fromJson(v));
      });
    }
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['module_name'] = moduleName;
    data['module_type'] = moduleType;
    data['thumbnail'] = thumbnail;
    data['status'] = status;
    data['stores_count'] = storesCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['icon'] = icon;
    data['theme_id'] = themeId;
    data['description'] = description;
    data['all_zone_service'] = allZoneService;
    data['additional_delivery_option_status'] = additionalDeliveryOptionStatus;
    if (deliveryOptions != null) {
      data['delivery_options'] = deliveryOptions!.map((v) => v.toJson()).toList();
    }
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? zoneId;
  int? moduleId;
  double? perKmShippingCharge;
  double? minimumShippingCharge;
  double? maximumShippingCharge;
  double? maximumCodOrderAmount;
  String? deliveryChargeType;
  double? fixedShippingCharge;
  double? perKmShippingChargeGroup;
  double? minimumShippingChargeGroup;
  MinimumDeliveryTime? minimumDeliveryTime;
  double? minimumDeliveryCharge;

  int? pickupCenterStatus;
  String? pickupCenterChargeType;
  double? pickupCenterFixedCharge;
  double? pickupCenterPerKmCharge;
  double? pickupCenterMinimumCharge;
  String? pickupCenterOutsideChargeType;
  double? pickupCenterOutsideFixedCharge;
  double? pickupCenterOutsidePerKmCharge;
  double? pickupCenterOutsideMinimumCharge;

  Pivot({
    this.zoneId,
    this.moduleId,
    this.perKmShippingCharge,
    this.minimumShippingCharge,
    this.maximumShippingCharge,
    this.maximumCodOrderAmount,
    this.deliveryChargeType,
    this.fixedShippingCharge,
    this.perKmShippingChargeGroup,
    this.minimumShippingChargeGroup,
    this.minimumDeliveryTime,
    this.minimumDeliveryCharge,
    this.pickupCenterStatus,
    this.pickupCenterChargeType,
    this.pickupCenterFixedCharge,
    this.pickupCenterPerKmCharge,
    this.pickupCenterMinimumCharge,
    this.pickupCenterOutsideChargeType,
    this.pickupCenterOutsideFixedCharge,
    this.pickupCenterOutsidePerKmCharge,
    this.pickupCenterOutsideMinimumCharge,
  });

  Pivot.fromJson(Map<String, dynamic> json) {
    zoneId = json['zone_id'];
    moduleId = json['module_id'];
    perKmShippingCharge = json['per_km_shipping_charge'] != null ? double.tryParse(json['per_km_shipping_charge'].toString()) : null;
    minimumShippingCharge = json['minimum_shipping_charge'] != null ? double.tryParse(json['minimum_shipping_charge'].toString()) : null;
    maximumShippingCharge = json['maximum_shipping_charge'] != null ? double.tryParse(json['maximum_shipping_charge'].toString()) : null;
    maximumCodOrderAmount = json['maximum_cod_order_amount'] != null ? double.tryParse(json['maximum_cod_order_amount'].toString()) : null;
    deliveryChargeType = json['delivery_charge_type'];
    fixedShippingCharge = double.tryParse(json['fixed_shipping_charge'].toString()) ?? 0.0;
    perKmShippingChargeGroup = json['per_km_shipping_charge_group'] != null ? double.tryParse(json['per_km_shipping_charge_group'].toString()) : null;
    minimumShippingChargeGroup = json['minimum_shipping_charge_group'] != null ? double.tryParse(json['minimum_shipping_charge_group'].toString()) : null;
    final dynamic rawMinDeliveryTime = json['minimum_delivery_time'];
    if (rawMinDeliveryTime is Map<String, dynamic>) {
      minimumDeliveryTime = MinimumDeliveryTime.fromJson(rawMinDeliveryTime);
    } else if (rawMinDeliveryTime != null) {
      minimumDeliveryTime = MinimumDeliveryTime(value: rawMinDeliveryTime.toString(), unit: 'min');
    }
    minimumDeliveryCharge = json['minimum_delivery_charge'] != null ? double.tryParse(json['minimum_delivery_charge'].toString()) : null;

    pickupCenterStatus = json['pickup_center_status'] != null ? int.tryParse(json['pickup_center_status'].toString()) : 0;
    pickupCenterChargeType = json['pickup_center_charge_type']?.toString();
    pickupCenterFixedCharge = double.tryParse(json['pickup_center_fixed_charge'].toString()) ?? 0.0;
    pickupCenterPerKmCharge = double.tryParse(json['pickup_center_per_km_charge'].toString()) ?? 0.0;
    pickupCenterMinimumCharge = double.tryParse(json['pickup_center_minimum_charge'].toString()) ?? 0.0;
    pickupCenterOutsideChargeType = json['pickup_center_outside_charge_type']?.toString();
    pickupCenterOutsideFixedCharge = double.tryParse(json['pickup_center_outside_fixed_charge'].toString()) ?? 0.0;
    pickupCenterOutsidePerKmCharge = double.tryParse(json['pickup_center_outside_per_km_charge'].toString()) ?? 0.0;
    pickupCenterOutsideMinimumCharge = double.tryParse(json['pickup_center_outside_minimum_charge'].toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['zone_id'] = zoneId;
    data['module_id'] = moduleId;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    data['maximum_cod_order_amount'] = maximumCodOrderAmount;
    data['delivery_charge_type'] = deliveryChargeType;
    data['fixed_shipping_charge'] = fixedShippingCharge;
    data['per_km_shipping_charge_group'] = perKmShippingChargeGroup;
    data['minimum_shipping_charge_group'] = minimumShippingChargeGroup;
    if (minimumDeliveryTime != null) {
      data['minimum_delivery_time'] = minimumDeliveryTime!.toJson();
    }
    data['minimum_delivery_charge'] = minimumDeliveryCharge;
    return data;
  }
}
