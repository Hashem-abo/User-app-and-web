import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_product_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/helper/price_converter.dart';

class GlobalProductCard extends StatelessWidget {
  final GlobalProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final double? width;

  const GlobalProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first
        : '';
    final double price = product.price ?? 0;
    final double originalPrice = product.originalPrice ?? 0;
    final bool hasDiscount = originalPrice > 0 && price != originalPrice;
    final double discountPercent = hasDiscount ? (((originalPrice - price) / originalPrice) * 100) : 0;

    return OnHover(
      isItem: true,
      child: Stack(
        children: [
          Container(
            width: width ?? 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: Theme.of(context).cardColor,
            ),
            child: CustomInkWell(
              onTap: onTap,
              radius: Dimensions.radiusLarge,
              child: TextHover(
                builder: (isHovered) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(Dimensions.radiusLarge),
                                  topRight: Radius.circular(Dimensions.radiusLarge),
                                ),
                                child: CustomImage(
                                  isHovered: isHovered,
                                  placeholder: Images.defultImage,
                                  image: imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),

                            if (hasDiscount)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${discountPercent.toStringAsFixed(0)}% OFF',
                                    style: robotoBold.copyWith(color: Colors.white, fontSize: 8),
                                  ),
                                ),
                              ),

                            // Source Badge (placed like discount tag or organic tag)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _sourceColor(product.source),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _sourceLabel(product.source),
                                  style: robotoBold.copyWith(color: Colors.white, fontSize: 8),
                                ),
                              ),
                            ),

                            // Add to Cart button overlapping bottom-left of the image, exactly like ItemCard
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: onAddToCart,
                                child: Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).cardColor.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(color: Theme.of(context).cardColor),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Details Section
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeSmall,
                            right: Dimensions.paddingSizeSmall,
                            top: Dimensions.paddingSizeExtraSmall,
                            bottom: Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Title
                              Text(
                                product.title ?? 'Unknown Product',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Source Details
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _sourceColor(product.source).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      border: Border.all(color: _sourceColor(product.source).withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      _sourceLabel(product.source),
                                      style: robotoMedium.copyWith(color: _sourceColor(product.source), fontSize: 9),
                                    ),
                                  ),
                                ],
                              ),

                              // Price Section
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (hasDiscount)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        '\$${originalPrice.toStringAsFixed(2)}',
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).disabledColor.withValues(alpha: 0.6),
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                  if (hasDiscount) const SizedBox(width: 6),
                                  Text(
                                    '\$${price.toStringAsFixed(2)}',
                                    style: robotoBlack.copyWith(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$4.50 Ship',
                                    style: robotoRegular.copyWith(
                                      fontSize: 9,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _sourceColor(String? source) {
    switch (source) {
      case 'shein':
        return const Color(0xFFE91E63);
      case 'aliexpress':
        return const Color(0xFFFF6900);
      case 'cj':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  String _sourceLabel(String? source) {
    switch (source) {
      case 'shein':
        return 'SHEIN';
      case 'aliexpress':
        return 'AliExpress';
      case 'cj':
        return 'CJ Drop';
      default:
        return 'GLOBAL';
    }
  }
}
