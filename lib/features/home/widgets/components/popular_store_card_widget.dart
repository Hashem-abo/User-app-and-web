import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart'; // + ahmed
import 'package:sixam_mart/helper/auth_helper.dart'; // + ahmed
import 'package:sixam_mart/common/widgets/custom_snackbar.dart'; // + ahmed
import 'package:sixam_mart/common/widgets/vendor_type_badge_widget.dart';

class PopularStoreCard extends StatelessWidget {
  final Store store;
  const PopularStoreCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 315 : 260,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 0))],
      ),
      child: TextHover(
        builder: (hovered) {
          return CustomInkWell(
            onTap: () {
              Get.toNamed(RouteHelper.getStoreRoute(id: store.id, page: 'store'),
                arguments: StoreScreen(store: store, fromModule: false),
              );
            },
            radius: Dimensions.radiusDefault,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: Column(
                children: [
                  // Top Section: Cover Image + Overlays
                  Stack(
                    children: [
                      CustomImage(
                        isHovered: hovered,
                        image: '${store.coverPhotoFullUrl}',
                        fit: BoxFit.cover, width: double.infinity, height: 125, // ahmed: Cover Height
                      ),

                      // Logo: Top Right
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CustomImage(
                              image: '${store.logoFullUrl}',
                              height: 45, width: 45, // ahmed: Small Logo
                            ),
                          ),
                        ),
                      ),

                      // Favorite: Top Left
                      Positioned(
                        top: 0, left: 0,
                        child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                          bool isWished = favouriteController.wishStoreIdList.contains(store.id);
                          return InkWell(
                            onTap: () {
                              if(AuthHelper.isLoggedIn()) {
                                isWished ? favouriteController.removeFromFavouriteList(store.id, true)
                                    : favouriteController.addToFavouriteList(null, store.id, true);
                              }else {
                                showCustomSnackBar('you_are_not_logged_in'.tr);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(Dimensions.radiusDefault),
                                  topLeft: Radius.circular(Dimensions.radiusDefault),
                                ),
                              ),
                              child: Icon(
                                isWished ? Icons.favorite : Icons.favorite_border,
                                color: Colors.white, size: 18,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  // Bottom Section: Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(store.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              store.verifiedSeller == 1 ? Image.asset(Images.verifiedBadge2, width: 16, height: 16) : const SizedBox.shrink(),
                              if (store.vendorType.isNotEmpty) ...[
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                VendorTypeBadgeWidget(store: store),
                              ],
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Row(
                            children: [
                              // Address/Category (Right in RTL)
                              Expanded(
                                flex: 3,
                                child: Text(
                                  store.address ?? '',
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                ),
                              ),

                              Expanded(
                                flex: 1,
                                child: Center(child: Text('|', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor))),
                              ),

                              // Item Count (Center)
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${store.itemCount}+ ' 'منتج'.tr,
                                  style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                                  textAlign: TextAlign.center,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              Expanded(
                                flex: 1,
                                child: Center(child: Text('|', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor))),
                              ),

                              // Rating (Left in RTL)
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 2),
                                    Text(store.avgRating!.toStringAsFixed(1), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                    const SizedBox(width: 2),
                                    Flexible(child: Text('(${store.ratingCount})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis)),
                                  ],
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
      ),
    );
  }
}