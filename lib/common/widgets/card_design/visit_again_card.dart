import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/common/widgets/vendor_type_badge_widget.dart';

class VisitAgainCard extends StatelessWidget {
  final Store store;
  final bool fromFood;
  const VisitAgainCard({super.key, required this.store, required this.fromFood});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;
    bool isAvailable = store.open == 1 && store.active!;

    return TextHover(
      builder: (hovered) {
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: CustomInkWell(
                onTap: () {
                  Get.toNamed(
                    RouteHelper.getStoreRoute(id: store.id, page: 'store'),
                    arguments: StoreScreen(store: store, fromModule: false),
                  );
                },
                radius: Dimensions.radiusLarge,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Store Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: CustomImage(
                            image: '${store.logoFullUrl}',
                            height: 65, width: 65, fit: BoxFit.cover,
                            isHovered: hovered,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        // Store Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: Text(store.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  if (store.vendorType.isNotEmpty) ...[
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    VendorTypeBadgeWidget(store: store),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              
                              if(store.ratingCount! > 0)
                              Row(children: [
                                const Icon(Icons.star, size: 16, color: Colors.orange),
                                const SizedBox(width: 2),
                                Text(store.avgRating!.toStringAsFixed(1), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                const SizedBox(width: 2),
                                Text("(${store.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                              ]),
                              
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.location_on_outlined, size: 16, color: Theme.of(context).disabledColor),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    store.address ?? '',
                                    overflow: TextOverflow.ellipsis, maxLines: 1,
                                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Visited Items
                    store.items != null ? SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Text('items'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Expanded(
                            child: ListView.builder(
                              itemCount: store.items!.length,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    child: CustomImage(
                                      image: '${store.items![index].imageFullUrl}',
                                      fit: BoxFit.cover, height: 40, width: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ) : const SizedBox(),
                  ],
                ),
              ),
            ),
            
            // Favorite Button
            AddFavouriteView(
              item: null, storeId: store.id,
              top: 15, left: 15, right: null,
            ),
          ],
        );
      }
    );
  }
}
