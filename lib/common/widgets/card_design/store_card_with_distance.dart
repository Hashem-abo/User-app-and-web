import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/new_tag.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';


class StoreCardWithDistance extends StatelessWidget {
  final Store store;
  final bool fromAllStore;
  final bool? isNewStore;
  final bool? fromTopOffers;
  final bool recommendedStore;
  const StoreCardWithDistance({super.key, required this.store, this.fromAllStore = false, this.isNewStore = false, this.fromTopOffers = false, this.recommendedStore = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  fromAllStore ? double.infinity : (ResponsiveHelper.isDesktop(context) ? 315 : 260),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 0))],
      ),
      child: TextHover(
        builder: (hovered) {
          return CustomInkWell(
            onTap: () {
              if(Get.find<SplashController>().moduleList != null) {
                for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                  if(module.id == store.moduleId) {
                    Get.find<SplashController>().setModule(module);
                    break;
                  }
                }
              }
              Get.toNamed(
                RouteHelper.getStoreRoute(id: store.id, page: 'store'),
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
                        fit: BoxFit.cover, width: double.infinity, height: 140, // Cover Height
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
                              height: 45, width: 45, // Small Logo
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

                      if(isNewStore!) const NewTag(),
                    ],
                  ),

                  // Bottom Section: Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start, // Changed from center
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Row(
                            children: [
                              Flexible(
                                child: Text(store.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              store.verifiedSeller == 1 ? Image.asset(Images.verifiedBadge2, width: 16, height: 16) : const SizedBox.shrink(),
                            ],
                          ), 
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Row(
                            children: [
                              // Address/Category (Right in RTL)
                              Expanded(
                                flex: 4,
                                child: Text(
                                  store.address ?? '',
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Text('|', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)),
                              ),

                              Expanded(
                                flex: 3,
                                child: Text(
                                  (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food')
                                      ? '${store.distance != null ? (store.distance! > 100 ? store.distance! / 1000 : store.distance!).toStringAsFixed(1) : '0.0'} ' 'كم'.tr
                                      : '${store.itemCount}+ ' 'منتج'.tr,
                                  style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                                  textAlign: TextAlign.center,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Text('|', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)),
                              ),

                              // Rating (Left in RTL)
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 12),
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
