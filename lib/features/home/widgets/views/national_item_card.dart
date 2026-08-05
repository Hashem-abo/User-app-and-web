import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class NationalItemCard extends StatelessWidget {
  final Item item;
  final bool isCampaign;

  const NationalItemCard({
    super.key,
    required this.item,
    this.isCampaign = false,
  });

  @override
  Widget build(BuildContext context) {
    double priceValue = Get.find<ItemController>().getStartingPrice(item) ?? 0;
    double finalPrice = PriceConverter.convertWithDiscount(priceValue, item.discount, item.discountType) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
      ),
      child: CustomInkWell(
        onTap: () {
          Get.find<ItemController>().navigateToItemPage(item, context, isCampaign: isCampaign);
        },
        radius: Dimensions.radiusLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Section ---
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                    child: CustomImage(
                      image: '${item.imageFullUrl}',
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // Top Right: 100% Natural Badge
                  Positioned(
                    top: Dimensions.paddingSizeSmall,
                    right: Dimensions.paddingSizeSmall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.eco, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '100% طبيعي',
                            style: robotoMedium.copyWith(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top Left: Favorite Button
                  Positioned(
                    top: Dimensions.paddingSizeSmall,
                    left: Dimensions.paddingSizeSmall,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: const Icon(Icons.favorite_border, color: Colors.white, size: 16),
                    ),
                  ),

                  // Bottom Center: City Badge
                  Positioned(
                    bottom: Dimensions.paddingSizeSmall,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                        ),
                        child: Text(
                          item.storeName ?? 'صنعاء',
                          style: robotoMedium.copyWith(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Details Section ---
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and Verified Icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name ?? '',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 16),
                      ],
                    ),

                    // Store Name
                    Text(
                      item.storeName ?? '',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Rating and Category
                    Row(
                      children: [
                        Icon(Icons.star, color: Theme.of(context).primaryColor, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${item.avgRating?.toStringAsFixed(1) ?? '0.0'} (${item.ratingCount ?? 0})',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Icon(Icons.category, color: Theme.of(context).disabledColor, size: 14),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'منتج وطني',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          PriceConverter.convertPrice(finalPrice),
                          style: robotoBold.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
