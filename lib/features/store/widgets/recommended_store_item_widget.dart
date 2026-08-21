import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class RecommendedStoreItemWidget extends StatelessWidget {
  final Item item;
  final int index;
  const RecommendedStoreItemWidget({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    double discount = item.discount ?? 0;
    double price = item.price ?? 0;
    String? discountType = item.discountType;
    double discountPercentage = discount;
    
    if(discountType == 'amount' && price > 0){
      discountPercentage = (discount / price) * 100;
    }
    
    return Container(
      margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: CustomInkWell(
        onTap: () {
          Get.find<ItemController>().navigateToItemPage(item, context, inStore: true, isCampaign: false);
        },
        radius: Dimensions.radiusDefault,
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
          // Image on the Start
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadiusDirectional.horizontal(
                start: Radius.circular(Dimensions.radiusDefault),
              ).resolve(Directionality.of(context)),
              child: CustomImage(
                image: '${item.imageFullUrl}',
                height: 115, width: 95, fit: BoxFit.cover, // Increased height to fill card
              ),
            ),
            
            // Organic/Local Tag - Moved to Bottom
            if(item.organic == 1) Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  borderRadius: BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(Dimensions.radiusDefault),
                  ).resolve(Directionality.of(context)),
                ),
                child: Text(
                  'organic'.tr, 
                  style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Integrated Favorite Icon
            Positioned(
              top: 0, right: 0, left: 0,
              child: Align(
                alignment: Directionality.of(context) == TextDirection.rtl 
                    ? Alignment.topRight 
                    : Alignment.topLeft,
                child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                  bool isWished = favouriteController.wishItemIdList.contains(item.id);
                  return InkWell(
                    onTap: () {
                      if (AuthHelper.isLoggedIn()) {
                        isWished ? favouriteController.removeFromFavouriteList(item.id, false)
                            : favouriteController.addToFavouriteList(item, null, false);
                      } else {
                        showCustomSnackBar('you_are_not_logged_in'.tr);
                      }
                    },
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadiusDirectional.only(
                          bottomEnd: Radius.circular(Dimensions.radiusDefault), 
                          topStart: Radius.circular(Dimensions.radiusDefault) 
                        ).resolve(Directionality.of(context)),
                      ),
                      child: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 18),
                    ),
                  );
                }),
              ),
            ),
          ]),
          
          // Info on the End
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeExtraSmall, 
                right: Dimensions.paddingSizeSmall, 
                top: Dimensions.paddingSizeSmall, 
                bottom: Dimensions.paddingSizeSmall // Adjusted padding
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                const SizedBox(height: 4), 

                // Name and Price Row (Combined)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name!,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), 
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    
                    // Price Row (Compact)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                         // Current Price
                        Text(
                          PriceConverter.convertPrice(item.price, discount: discount, discountType: discountType),
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr, 
                        ),
                        
                        Row(
                          children: [
                            // Previous Price
                            if(discount > 0) ...[
                              Text(
                                PriceConverter.convertPrice(item.price),
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall, 
                                  color: Theme.of(context).disabledColor,
                                  decoration: TextDecoration.lineThrough,
                                ), textDirection: TextDirection.ltr,
                              ),
                              const SizedBox(width: 2),
                            ],

                             // Discount Percentage
                            if(discount > 0) Text(
                              '${discountPercentage.toStringAsFixed(0)}% ${'off'.tr}',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor), 
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                
                const Spacer(),

                // Rating and Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rating
                    if(item.ratingCount! > 0) ...[
                       Row(children: [
                          Text(
                            item.avgRating!.toStringAsFixed(1),
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.star, size: 12, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 2),
                          Text(
                            '(${item.ratingCount})',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                          ),
                       ])
                    ] else const SizedBox(),

                    // Add to Cart Button (Details)
                    CartCountView(
                      item: item,
                      index: index,
                      child: InkWell(
                        onTap: () {
                          Get.find<ItemController>().itemDirectlyAddToCart(item, context, inStore: true, isCampaign: false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(50), 
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [ 
                            
                            // Custom White Circle Icon - Moved to Start (Right in RTL)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).primaryColor, size: 14),
                            ),
                            
                            const SizedBox(width: 6),

                            Text(
                              'add_to_cart'.tr, 
                              style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
                
              ]),
            ),
          ),
          
        ]),
      ),
    );
  }
}
