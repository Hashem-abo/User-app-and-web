class GlobalCartItemModel {
  int? id;
  int? userId;
  String? guestId;
  String? source;
  String? externalProductId;
  String? title;
  String? image;
  String? variant;
  int? quantity;
  double? unitPrice;
  double? originalPrice;
  String? currency;
  String? productUrl;

  GlobalCartItemModel({
    this.id,
    this.userId,
    this.guestId,
    this.source,
    this.externalProductId,
    this.title,
    this.image,
    this.variant,
    this.quantity,
    this.unitPrice,
    this.originalPrice,
    this.currency,
    this.productUrl,
  });

  factory GlobalCartItemModel.fromJson(Map<String, dynamic> json) {
    return GlobalCartItemModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      guestId: json['guest_id']?.toString(),
      source: json['source']?.toString(),
      externalProductId: json['external_product_id']?.toString(),
      title: json['title']?.toString(),
      image: json['image']?.toString(),
      variant: json['variant']?.toString(),
      quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) : 1,
      unitPrice: json['unit_price'] != null ? double.tryParse(json['unit_price'].toString()) : 0.0,
      originalPrice: json['original_price'] != null ? double.tryParse(json['original_price'].toString()) : 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      productUrl: json['product_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'guest_id': guestId,
      'source': source,
      'external_product_id': externalProductId,
      'title': title,
      'image': image,
      'variant': variant,
      'quantity': quantity,
      'unit_price': unitPrice,
      'original_price': originalPrice,
      'currency': currency,
      'product_url': productUrl,
    };
  }
}
