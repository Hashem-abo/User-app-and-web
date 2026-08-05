import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/organic_tag.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/trends/domain/models/trend_model.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/module_icon_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/util/images.dart';

class TrendHeaderBanner extends StatelessWidget {
  final TrendHashtagModel hashtag;
  const TrendHeaderBanner({super.key, required this.hashtag});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: CustomImage(
              image: hashtag.coverImage ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: Dimensions.paddingSizeDefault,
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                    child: Text(
                      (hashtag.tag ?? '').tr,
                    style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
                const SizedBox(height: 6),
                  Text(
                    (hashtag.title ?? '').tr,
                  style: robotoBold.copyWith(color: Colors.white, fontSize: 22, letterSpacing: -0.5),
                ),
                  Text(
                    (hashtag.subtitle ?? '').tr,
                  style: robotoRegular.copyWith(color: Colors.white.withOpacity(0.8), fontSize: Dimensions.fontSizeSmall),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrendHashtagSelector extends StatelessWidget {
  final List<TrendHashtagModel> hashtags;
  final int selectedIndex;
  final Function(int) onSelected;
  const TrendHashtagSelector({
    super.key,
    required this.hashtags,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        physics: const BouncingScrollPhysics(),
        itemCount: hashtags.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  (hashtags[index].tag ?? '').tr,
                  style: isSelected
                      ? robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault)
                      : robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7), fontSize: Dimensions.fontSizeDefault),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TrendBrandsCarousel extends StatelessWidget {
  final List<TrendBrandModel> brands;
  const TrendBrandsCarousel({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: Text(
            'curated_boutiques'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, letterSpacing: -0.2),
          ),
        ),
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            physics: const BouncingScrollPhysics(),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return Container(
                width:290,
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Brand Info (Left)
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: CustomImage(
                              image: brand.logo ?? '',
                              height: 48,
                              width: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            (brand.name ?? '').tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (brand.tagline ?? '').tr,
                            style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    // Product Previews (Right)
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          (brand.items?.length ?? 0) > 2 ? 2 : (brand.items?.length ?? 0),
                          (itemIndex) {
                            final item = brand.items![itemIndex];
                            return GestureDetector(
                              onTap: () => Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, false)),
                              child: Container(
                                width: 70,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).disabledColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                                        child: CustomImage(
                                          image: item.imageFullUrl ?? '',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        PriceConverter.convertPrice(item.price),
                                        style: robotoBold.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TrendProductCard extends StatelessWidget {
  final Item item;
  const TrendProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    double? discount = item.discount;
    String? discountType = item.discountType;
    double priceValue = Get.find<ItemController>().getStartingPrice(item) ?? 0;
    double finalPrice = PriceConverter.convertWithDiscount(priceValue, discount, discountType) ?? 0;
    bool isAvailable = Get.find<ItemController>().isAvailable(item);

    // Calculate dynamic badges based on database values
    String? badgeText;
    Color? badgeColor;
    IconData? badgeIcon;

    if (item.orderCount != null && item.orderCount! > 100) {
      badgeText = 'best_seller'.tr;
      badgeColor = Colors.amber.shade800;
      badgeIcon = Icons.stars_rounded;
    } else if (item.avgRating != null && item.avgRating! >= 4.5 && (item.ratingCount ?? 0) > 2) {
      badgeText = 'most_loved'.tr;
      badgeColor = Colors.orange;
      badgeIcon = Icons.favorite_rounded;
    } else if (item.wishlistCount != null && item.wishlistCount! > 0) {
      badgeText = 'most_liked'.tr;
      badgeColor = Colors.pink;
      badgeIcon = Icons.thumb_up_alt_rounded;
    } else if (item.itemViewCount != null && item.itemViewCount! > 0) {
      badgeText = 'most_viewed'.tr;
      badgeColor = Colors.teal;
      badgeIcon = Icons.visibility_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: CustomInkWell(
        onTap: () => Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, false)),
        radius: Dimensions.radiusLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                    child: CustomImage(
                      image: item.imageFullUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                  // Discount tag
                  DiscountTag(
                    discount: discount,
                    discountType: discountType,
                    freeDelivery: false,
                    inLeft: true,
                    fromTop: Dimensions.paddingSizeExtraSmall,
                  ),

                  // Wishlist button
                  AddFavouriteView(
                    item: item,
                    top: Dimensions.paddingSizeExtraSmall,
                    right: Dimensions.paddingSizeExtraSmall,
                    left: null,
                    isCorner: true,
                  ),

                  // Organic tag
                  OrganicTag(item: item, placeInImage: true),

                  // Availability overlay
                  if (!isAvailable)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                      ),
                      child: Center(
                        child: Text(
                          'not_available_now'.tr,
                          style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                        ),
                      ),
                    ),

                  // Dynamic Badge (below discount tag)
                  if (badgeText != null)
                    Positioned(
                      top: 34,
                      left: Dimensions.paddingSizeExtraSmall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, color: Colors.white, size: 10),
                            const SizedBox(width: 3),
                            Text(
                              badgeText,
                              style: robotoBold.copyWith(color: Colors.white, fontSize: 8),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Quick add to cart overlay circular button
                  Positioned(
                    bottom: Dimensions.paddingSizeExtraSmall,
                    left: Dimensions.paddingSizeExtraSmall,
                    child: CartCountView(
                      item: item,
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.4),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            )
                          ],
                          border: Border.all(color: Theme.of(context).cardColor, width: 1.5),
                        ),
                        child: Icon(
                          ModuleIconHelper.getIcon(Get.find<SplashController>().module?.iconAddToCart, Icons.add),
                          size: 18,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeSmall, Dimensions.paddingSizeExtraSmall,
                Dimensions.paddingSizeSmall, Dimensions.paddingSizeExtraSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        item.avgRating?.toStringAsFixed(1) ?? '0.0',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                      if (item.orderCount != null && item.orderCount! > 0) ...[
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Container(width: 1, height: 10, color: Theme.of(context).disabledColor.withOpacity(0.3)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Icon(Icons.shopping_bag_outlined, size: 12, color: Theme.of(context).disabledColor),
                        const SizedBox(width: 3),
                        Text(
                          item.orderCount! >= 1000 
                              ? '${(item.orderCount! / 1000).toStringAsFixed(1)}k+'
                              : '${item.orderCount}',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        PriceConverter.convertPrice(finalPrice),
                        style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                      ),
                      if (discount != null && discount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          PriceConverter.convertPrice(priceValue),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).disabledColor.withOpacity(0.6),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
