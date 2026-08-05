import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';

class BestReviewItemView extends StatefulWidget {
  final String? title;
  final double? height;
  const BestReviewItemView({super.key, this.title, this.height});

  @override
  State<BestReviewItemView> createState() => _BestReviewItemViewState();
}

class _BestReviewItemViewState extends State<BestReviewItemView> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    var itemController = Get.find<ItemController>();
    if (itemController.reviewedItemList == null) {
      itemController.getReviewedItemList(offset: '1');
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ItemController>();
    if (controller.reviewedItemList == null) {
      controller.getReviewedItemList(offset: '1');
    }
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? reviewItemList = itemController.reviewedItemList;
      bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
      bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'ecommerce';

      return reviewItemList != null ? reviewItemList.isNotEmpty ? Column(children: [

        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: 3),
          child: TitleWidget(
            title: widget.title ?? 'best_reviewed_item'.tr,
              //titleColor: titlesColor,
            onTap: () => Get.toNamed(RouteHelper.getItemViewAllScreen(false, false)),
          ),
        ),

        SizedBox(
          height: isFood ? 260 : (widget.height??340), width: Get.width,
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            itemCount: reviewItemList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
                child: ItemCard(
                  item: reviewItemList[index],
                  isFood: isFood,
                  isShop: isShop,
                  isPopularItem: false,
                  width: 220,
                ),
              );
            },
          ),
        ),
      ]) : const SizedBox() : const BestReviewItemShimmer();
    });
  }
}

class BestReviewItemShimmer extends StatelessWidget {
  const BestReviewItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeDefault),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Shimmer(
              child: Container(
                height: 20, width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).shadowColor,
                ),
              ),
            ),

            Shimmer(
              child: Container(
                height: 20, width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).shadowColor,
                ),
              ),
            ),
          ]),
        ),

        SizedBox(
          height: 285, width: Get.width,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
                child: Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
                    width: 210, height: 285,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      color: Theme.of(context).shadowColor,
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Expanded(
                        child: Stack(children: [
                          Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                              child: Container(
                                color: Theme.of(context).shadowColor,
                                width: 210, height: 285,
                              ),
                            ),
                          ),

                          Positioned(
                            top: 10, right: 10,
                            child: Icon(Icons.favorite, size: 20, color: Theme.of(context).cardColor),
                          ),


                          Positioned(
                            bottom: 5, left: 0, right: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    height: 100, width: double.infinity,
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                                      color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                                    ),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                      Container(
                                        width: 100, height: 10,
                                        color: Theme.of(context).shadowColor,
                                      ),

                                      Container(
                                        width: 100, height: 10,
                                        color: Theme.of(context).shadowColor,
                                      ),

                                      Container(
                                        width: 100, height: 10,
                                        color: Theme.of(context).shadowColor,
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ]),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
