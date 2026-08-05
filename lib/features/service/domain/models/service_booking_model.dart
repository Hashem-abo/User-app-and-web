import 'dart:convert';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_provider_model.dart';

class ServiceBookingModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<ServiceBooking>? bookings;

  ServiceBookingModel({this.totalSize, this.limit, this.offset, this.bookings});

  ServiceBookingModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['bookings'] != null) {
      bookings = <ServiceBooking>[];
      json['bookings'].forEach((v) {
        bookings!.add(ServiceBooking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (bookings != null) {
      data['bookings'] = bookings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceBooking {
  int? id;
  String? bookingId;
  int? customerId;
  int? providerId;
  int? serviceId;
  String? scheduledDate;
  String? scheduledTime;
  String? endDate;
  String? endTime;
  int? addressId;
  double? latitude;
  double? longitude;
  String? status;
  double? totalAmount;
  double? paidAmount;
  String? paymentStatus;
  String? paymentMethod;
  String? customerNote;
  Map<String, dynamic>? bookingDetails;
  String? createdAt;
  String? confirmedAt;
  String? ongoingAt;
  String? completedAt;
  String? canceledAt;
  Service? service;
  ServiceProviderModel? provider;

  ServiceBooking({
    this.id,
    this.bookingId,
    this.customerId,
    this.providerId,
    this.serviceId,
    this.scheduledDate,
    this.scheduledTime,
    this.endDate,
    this.endTime,
    this.addressId,
    this.latitude,
    this.longitude,
    this.status,
    this.totalAmount,
    this.paidAmount,
    this.paymentStatus,
    this.paymentMethod,
    this.customerNote,
    this.bookingDetails,
    this.createdAt,
    this.confirmedAt,
    this.ongoingAt,
    this.completedAt,
    this.canceledAt,
    this.service,
    this.provider,
  });

  ServiceBooking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'].toString();
    customerId = json['customer_id'];
    providerId = json['provider_id'];
    serviceId = json['service_id'];
    scheduledDate = json['scheduled_date'];
    scheduledTime = json['scheduled_time'];
    endDate = json['end_date'];
    endTime = json['end_time'];
    addressId = json['address_id'];
    latitude = json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null;
    longitude = json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null;
    status = json['status'];
    totalAmount = json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) : null;
    paidAmount = json['paid_amount'] != null ? double.tryParse(json['paid_amount'].toString()) : null;
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    customerNote = json['customer_note'];
    if (json['booking_details'] != null) {
      bookingDetails = json['booking_details'] is String ? jsonDecode(json['booking_details']) : json['booking_details'];
    }
    createdAt = json['created_at'];
    confirmedAt = json['confirmed_at'];
    ongoingAt = json['ongoing_at'];
    completedAt = json['completed_at'];
    canceledAt = json['canceled_at'];
    service = json['service'] != null ? Service.fromJson(json['service']) : null;
    provider = json['provider'] != null ? ServiceProviderModel.fromJson(json['provider']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['customer_id'] = customerId;
    data['provider_id'] = providerId;
    data['service_id'] = serviceId;
    data['scheduled_date'] = scheduledDate;
    data['scheduled_time'] = scheduledTime;
    data['end_date'] = endDate;
    data['end_time'] = endTime;
    data['address_id'] = addressId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['total_amount'] = totalAmount;
    data['paid_amount'] = paidAmount;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['customer_note'] = customerNote;
    if (bookingDetails != null) {
      data['booking_details'] = bookingDetails;
    }
    data['created_at'] = createdAt;
    data['confirmed_at'] = confirmedAt;
    data['ongoing_at'] = ongoingAt;
    data['completed_at'] = completedAt;
    data['canceled_at'] = canceledAt;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    return data;
  }
}
