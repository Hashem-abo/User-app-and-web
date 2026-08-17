import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/item_shimmer.dart';

class MoreFromStoreWidget extends StatelessWidget {
  const MoreFromStoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;

    return GetBuilder<ItemController>(
      id: 'more_from_store',
      builder: (itemController) {
        if (itemController.storeProductList == null || itemController.storeProductList!.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('more_from_store'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                SizedBox(
                  height: 285,
                  child: itemController.storeProductList != null ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: itemController.storeProductList!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 5),
                        child: ItemCard(item: itemController.storeProductList![index], isFood: isFood, isShop: isShop, isPopularItem: true, index: index),
                      );
                    },
                  ) : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: SizedBox(width: 200, child: ItemShimmer(isEnabled: true, hasDivider: false, isStore: false)),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
