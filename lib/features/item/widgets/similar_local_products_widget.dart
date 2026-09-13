import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/features/item/controllers/item_controller.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';
import 'package:suliman/util/app_constants.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';
import 'package:suliman/common/widgets/card_design/item_card.dart';

class SimilarLocalProductsWidget extends StatelessWidget {
  const SimilarLocalProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;

    return GetBuilder<ItemController>(
      id: 'similar_local',
      builder: (itemController) {
        if (itemController.similarLocalProductList != null && itemController.similarLocalProductList!.isNotEmpty) {
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
                Text('similar_local_products'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                SizedBox(
                  height: 295,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: itemController.similarLocalProductList!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 5),
                        child: ItemCard(item: itemController.similarLocalProductList![index], isFood: isFood, isShop: isShop, isPopularItem: true, index: index),
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
