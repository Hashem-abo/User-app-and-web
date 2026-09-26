import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/common/widgets/custom_ink_well.dart';
import 'package:suliman/common/widgets/hover/text_hover.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';
import 'package:suliman/common/models/module_model.dart';
import 'package:suliman/features/store/domain/models/store_model.dart';
import 'package:suliman/helper/route_helper.dart';
import 'package:suliman/helper/responsive_helper.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';
import 'package:suliman/common/widgets/custom_image.dart';
import 'package:suliman/common/widgets/new_tag.dart';
import 'package:suliman/features/store/screens/store_screen.dart';
import 'package:suliman/features/favourite/controllers/favourite_controller.dart';
import 'package:suliman/helper/auth_helper.dart';
import 'package:suliman/common/widgets/custom_snackbar.dart';
import 'package:suliman/common/widgets/vendor_type_badge_widget.dart';


class StoreCardWithDistance extends StatelessWidget {
  final Store store;
  final bool fromAllStore;
  final bool? isNewStore;
  final bool? fromTopOffers;
  final bool recommendedStore;
  const StoreCardWithDistance({super.key, required this.store, this.fromAllStore = false, this.isNewStore = false, this.fromTopOffers = false, this.recommendedStore = false});

  @override
  Widget build(BuildContext context) {
    return fromAllStore
        ? _buildHorizontalCard(context)
        : _buildVerticalCard(context);
  }

  Widget _buildHorizontalCard(BuildContext context) {
    bool isOpen = store.open == 1 && (store.active ?? true);

    String distanceText = '';
    if (store.distance != null) {
      double d = store.distance! > 100 ? store.distance! / 1000 : store.distance!;
      distanceText = '${d.toStringAsFixed(2)} ${'km'.tr}';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextHover(
        builder: (hovered) {
          return CustomInkWell(
            onTap: () {
              if (Get.find<SplashController>().moduleList != null) {
                for (ModuleModel module in Get.find<SplashController>().moduleList!) {
                  if (module.id == store.moduleId) {
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
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Store Logo + Distance + Rating (Right in RTL / Start)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 58,
                              width: 58,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CustomImage(
                                  image: '${store.logoFullUrl}',
                                  fit: BoxFit.cover,
                                  height: 58,
                                  width: 58,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (distanceText.isNotEmpty)
                              Text(
                                distanceText,
                                style: robotoMedium.copyWith(
                                  fontSize: 10,
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                double rating = store.avgRating ?? 0.0;
                                return Icon(
                                  index < rating.floor()
                                      ? Icons.star
                                      : (index < rating ? Icons.star_half : Icons.star_border),
                                  size: 11,
                                  color: const Color(0xFFE83B5E),
                                );
                              }),
                            ),
                          ],
                        ),

                        const SizedBox(width: 10),

                        // Store Info: Name, Address, Badges (Center)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Store Name
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      store.name ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault + 1,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                  if (store.verifiedSeller == 1) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, size: 14, color: Colors.blue),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 3),

                              // Address
                              if (store.address != null && store.address!.isNotEmpty)
                                Text(
                                  store.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall - 1,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),

                              const SizedBox(height: 5),

                              // Badges Row
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (store.vendorType.isNotEmpty) ...[
                                      VendorTypeBadgeWidget(store: store),
                                      const SizedBox(width: 4),
                                    ],
                                    if (store.discount != null && (store.discount?.discount ?? 0) > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFF38BDF8), width: 0.5),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.workspace_premium, size: 11, color: Color(0xFF0284C7)),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${'discount'.tr} ${store.discount?.discount}%',
                                              style: robotoMedium.copyWith(
                                                fontSize: 9,
                                                color: const Color(0xFF0369A1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    if (store.takeAway == true) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF7ED),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFFDBA74), width: 0.5),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.shopping_bag_outlined, size: 10, color: Color(0xFFC2410C)),
                                            const SizedBox(width: 2),
                                            Text(
                                              'take_away'.tr,
                                              style: robotoMedium.copyWith(
                                                fontSize: 9,
                                                color: const Color(0xFFC2410C),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    if (store.freeDelivery == true) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFF86EFAC), width: 0.5),
                                        ),
                                        child: Text(
                                          'free_delivery'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: 9,
                                            color: const Color(0xFF15803D),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),
                      ],
                    ),
                  ),

                  // Favorite: Top Left with Primary Color Background
                  Positioned(
                    top: 0,
                    left: 0,
                    child: GetBuilder<FavouriteController>(
                      builder: (favouriteController) {
                        bool isWished = favouriteController.wishStoreIdList.contains(store.id);
                        return InkWell(
                          onTap: () {
                            if (AuthHelper.isLoggedIn()) {
                              isWished
                                  ? favouriteController.removeFromFavouriteList(store.id, true)
                                  : favouriteController.addToFavouriteList(null, store.id, true);
                            } else {
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
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Open / Closed Status Tag at Bottom Left with Primary Color
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isOpen ? Colors.green: Colors.red,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: Text(
                        isOpen ? 'open'.tr : 'closed'.tr,
                        style: robotoBold.copyWith(
                          color: Colors.white,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
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
              if (Get.find<SplashController>().moduleList != null) {
                for (ModuleModel module in Get.find<SplashController>().moduleList!) {
                  if (module.id == store.moduleId) {
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
                        fit: BoxFit.cover, width: double.infinity, height: 140,
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
                              height: 45, width: 45,
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
                              if (AuthHelper.isLoggedIn()) {
                                isWished ? favouriteController.removeFromFavouriteList(store.id, true)
                                    : favouriteController.addToFavouriteList(null, store.id, true);
                              } else {
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

                      if (isNewStore!) const NewTag(),
                    ],
                  ),

                  // Bottom Section: Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Row(
                            children: [
                              Flexible(
                                child: Text(store.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              store.verifiedSeller == 1 ? const Icon(Icons.check_circle, size: 16, color: Colors.blue) : const SizedBox.shrink(),
                              if (store.vendorType.isNotEmpty) ...[
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                VendorTypeBadgeWidget(store: store),
                              ],
                            ],
                          ), 
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Row(
                            children: [
                              // Address/Category
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
                                      ? '${store.distance != null ? (store.distance! > 100 ? store.distance! / 1000 : store.distance!).toStringAsFixed(1) : '0.0'} ' 'km'.tr
                                      : '${store.itemCount ?? 0}+ ${((store.itemCount ?? 0) == 1 ? 'item' : 'items').tr}',
                                  style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                                  textAlign: TextAlign.center,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Text('|', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)),
                              ),

                              // Rating
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
        },
      ),
    );
  }
}
