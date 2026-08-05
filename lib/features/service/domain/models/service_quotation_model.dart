import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_provider_model.dart';

class ServiceQuotationModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<ServiceQuotation>? quotations;

  ServiceQuotationModel({this.totalSize, this.limit, this.offset, this.quotations});

  ServiceQuotationModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = json['offset'].toString();
    if (json['quotations'] != null) {
      quotations = <ServiceQuotation>[];
      json['quotations'].forEach((v) {
        quotations!.add(ServiceQuotation.fromJson(v));
      });
    }
  }
}

class ServiceQuotation {
  int? id;
  int? customerId;
  int? providerId;
  int? serviceId;
  String? description;
  List<String>? images;
  double? offeredPrice;
  String? providerNote;
  String? status;
  int? bookingId;
  String? createdAt;
  Service? service;
  ServiceProviderModel? provider;

  ServiceQuotation({
    this.id,
    this.customerId,
    this.providerId,
    this.serviceId,
    this.description,
    this.images,
    this.offeredPrice,
    this.providerNote,
    this.status,
    this.bookingId,
    this.createdAt,
    this.service,
    this.provider,
  });

  ServiceQuotation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    providerId = json['provider_id'];
    serviceId = json['service_id'];
    description = json['description'];
    if (json['images'] != null) {
      if (json['images'] is String) {
        images = [];
        try {
          List<dynamic> list = jsonDecode(json['images']);
          for (var v in list) {
            images!.add(v.toString());
          }
        } catch (e) {
          debugPrint('Error parsing images: $e');
        }
      } else {
        images = json['images'].cast<String>();
      }
    }
    offeredPrice = json['offered_price'] != null ? double.tryParse(json['offered_price'].toString()) : null;
    providerNote = json['provider_note'];
    status = json['status'];
    bookingId = json['booking_id'];
    createdAt = json['created_at'];
    service = json['service'] != null ? Service.fromJson(json['service']) : null;
    provider = json['provider'] != null ? ServiceProviderModel.fromJson(json['provider']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['provider_id'] = providerId;
    data['service_id'] = serviceId;
    data['description'] = description;
    data['images'] = images;
    data['offered_price'] = offeredPrice;
    data['provider_note'] = providerNote;
    data['status'] = status;
    data['booking_id'] = bookingId;
    data['created_at'] = createdAt;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    return data;
  }
}
