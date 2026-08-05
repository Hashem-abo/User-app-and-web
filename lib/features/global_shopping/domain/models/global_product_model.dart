class GlobalProductModel {
  String? id;
  String? source;
  String? title;
  double? price;
  double? originalPrice;
  String? currency;
  List<String>? images;
  List<ProductVariant>? variants;
  String? category;
  String? url;
  String? description;

  GlobalProductModel({
    this.id,
    this.source,
    this.title,
    this.price,
    this.originalPrice,
    this.currency,
    this.images,
    this.variants,
    this.category,
    this.url,
    this.description,
  });

  factory GlobalProductModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] != null) {
      parsedImages = List<String>.from(json['images']);
    } else if (json['image'] != null) {
      parsedImages = [json['image'].toString()];
    }

    List<ProductVariant> parsedVariants = [];
    if (json['variants'] != null) {
      parsedVariants = (json['variants'] as List).map((v) {
        if (v is Map<String, dynamic> && v.containsKey('name') && v.containsKey('options')) {
          return ProductVariant.fromJson(v);
        }
        final rawName = v['variantNameEn']?.toString() ?? '';
        final name = rawName.isNotEmpty
            ? rawName
            : (v['variantKey']?.toString() ?? v['properties']?.toString() ?? '');
        final price = v['variantSellPrice'];
        return ProductVariant(
          name: name,
          options: price != null
              ? [name, '\$${price}']
              : name.isNotEmpty ? [name] : [],
        );
      }).toList();
    }

    return GlobalProductModel(
      id: json['id']?.toString(),
      source: json['source']?.toString(),
      title: json['title']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : 0.0,
      originalPrice: json['original_price'] != null ? double.tryParse(json['original_price'].toString()) : 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      images: parsedImages,
      variants: parsedVariants,
      category: json['category']?.toString(),
      url: json['url']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'title': title,
      'price': price,
      'original_price': originalPrice,
      'currency': currency,
      'images': images,
      'variants': variants?.map((v) => v.toJson()).toList(),
      'category': category,
      'url': url,
      'description': description,
    };
  }
}

class ProductVariant {
  String? name;
  List<String>? options;

  ProductVariant({this.name, this.options});

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      name: json['name']?.toString(),
      options: json['options'] != null ? List<String>.from(json['options']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'options': options,
    };
  }
}
