import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/item_shimmer.dart';

class SimilarProductsSameTypeWidget extends StatelessWidget {
  const SimilarProductsSameTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;

    return GetBuilder<ItemController>(
      id: 'similar_same_type',
      builder: (itemController) {
        if (itemController.sameTypeProductList == null || itemController.sameTypeProductList!.isNotEmpty) {
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
                Text('similar_products'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                SizedBox(
                  height: 295,
                  child: itemController.sameTypeProductList != null ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: itemController.sameTypeProductList!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 5),
                        child: ItemCard(item: itemController.sameTypeProductList![index], isFood: isFood, isShop: isShop, isPopularItem: true, index: index),
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
