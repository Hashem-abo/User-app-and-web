import 'package:sixam_mart/features/address/domain/models/address_model.dart';

class GlobalOrderModel {
  int? id;
  int? userId;
  String? guestId;
  String? orderNumber;
  String? status;
  double? subtotal;
  double? markupAmount;
  double? shippingCost;
  double? total;
  String? currency;
  String? paymentMethod;
  String? paymentStatus;
  AddressModel? shippingAddress;
  String? customerEmail;
  String? customerPhone;
  String? notes;
  String? fulfillmentProvider;
  String? externalOrderId;
  String? externalTracking;
  String? externalStatus;
  List<GlobalOrderItemModel>? items;
  DateTime? createdAt;

  GlobalOrderModel({
    this.id,
    this.userId,
    this.guestId,
    this.orderNumber,
    this.status,
    this.subtotal,
    this.markupAmount,
    this.shippingCost,
    this.total,
    this.currency,
    this.paymentMethod,
    this.paymentStatus,
    this.shippingAddress,
    this.customerEmail,
    this.customerPhone,
    this.notes,
    this.fulfillmentProvider,
    this.externalOrderId,
    this.externalTracking,
    this.externalStatus,
    this.items,
    this.createdAt,
  });

  factory GlobalOrderModel.fromJson(Map<String, dynamic> json) {
    AddressModel? address;
    if (json['shipping_address'] != null) {
      try {
        address = AddressModel.fromJson(json['shipping_address']);
      } catch (e) {
        // ignore
      }
    }

    return GlobalOrderModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      guestId: json['guest_id']?.toString(),
      orderNumber: json['order_number']?.toString(),
      status: json['status']?.toString(),
      subtotal: json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) : 0.0,
      markupAmount: json['markup_amount'] != null ? double.tryParse(json['markup_amount'].toString()) : 0.0,
      shippingCost: json['shipping_cost'] != null ? double.tryParse(json['shipping_cost'].toString()) : 0.0,
      total: json['total'] != null ? double.tryParse(json['total'].toString()) : 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      shippingAddress: address,
      customerEmail: json['customer_email']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      notes: json['notes']?.toString(),
      fulfillmentProvider: json['fulfillment_provider']?.toString(),
      externalOrderId: json['external_order_id']?.toString(),
      externalTracking: json['external_tracking']?.toString(),
      externalStatus: json['external_status']?.toString(),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => GlobalOrderItemModel.fromJson(i)).toList()
          : [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'guest_id': guestId,
      'order_number': orderNumber,
      'status': status,
      'subtotal': subtotal,
      'markup_amount': markupAmount,
      'shipping_cost': shippingCost,
      'total': total,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'shipping_address': shippingAddress?.toJson(),
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'notes': notes,
      'fulfillment_provider': fulfillmentProvider,
      'external_order_id': externalOrderId,
      'external_tracking': externalTracking,
      'external_status': externalStatus,
      'items': items?.map((i) => i.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class GlobalOrderItemModel {
  int? id;
  int? globalOrderId;
  String? source;
  String? externalProductId;
  String? title;
  String? image;
  String? variant;
  int? quantity;
  double? unitPrice;
  double? originalPrice;
  String? productUrl;

  GlobalOrderItemModel({
    this.id,
    this.globalOrderId,
    this.source,
    this.externalProductId,
    this.title,
    this.image,
    this.variant,
    this.quantity,
    this.unitPrice,
    this.originalPrice,
    this.productUrl,
  });

  factory GlobalOrderItemModel.fromJson(Map<String, dynamic> json) {
    return GlobalOrderItemModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      globalOrderId: json['global_order_id'] != null ? int.tryParse(json['global_order_id'].toString()) : null,
      source: json['source']?.toString(),
      externalProductId: json['external_product_id']?.toString(),
      title: json['title']?.toString(),
      image: json['image']?.toString(),
      variant: json['variant']?.toString(),
      quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) : 0,
      unitPrice: json['unit_price'] != null ? double.tryParse(json['unit_price'].toString()) : 0.0,
      originalPrice: json['original_price'] != null ? double.tryParse(json['original_price'].toString()) : 0.0,
      productUrl: json['product_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'global_order_id': globalOrderId,
      'source': source,
      'external_product_id': externalProductId,
      'title': title,
      'image': image,
      'variant': variant,
      'quantity': quantity,
      'unit_price': unitPrice,
      'original_price': originalPrice,
      'product_url': productUrl,
    };
  }
}
