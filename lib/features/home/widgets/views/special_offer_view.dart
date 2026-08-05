import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';

class SpecialOfferView extends StatefulWidget {
  final bool isFood;
  final bool isShop;
  final String? title;
  final double? height;
  const SpecialOfferView({super.key, required this.isFood, required this.isShop, this.title, this.height});

  @override
  State<SpecialOfferView> createState() => _SpecialOfferViewState();
}

class _SpecialOfferViewState extends State<SpecialOfferView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    var itemController = Get.find<ItemController>();
    if (itemController.discountedItemList == null) {
      itemController.getDiscountedItemList(offset: '1');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(seconds: (_scrollController.position.maxScrollExtent / 10).round()),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? discountedItemList = itemController.discountedItemList;

      if (discountedItemList != null && discountedItemList.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
      }

      return discountedItemList != null ? discountedItemList.isNotEmpty ? Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Container(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
          child: Column(children: [

            Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: 3),
              child: TitleWidget(
                title: widget.title ?? 'special_offer'.tr,
                image: Images.discountOfferIcon,
                imageHeight: 35, imageWidth: 35,
                onTap: () => Get.toNamed(RouteHelper.getItemViewAllScreen(false, true)),
              ),
            ),

            SizedBox(
              height: widget.isFood ? 260 : (widget.height??340), width: Get.width,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                itemCount: discountedItemList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeDefault),
                    child: ItemCard(item: discountedItemList[index], isPopularItem: false, isFood: widget.isFood, isShop: widget.isShop, index: index, width: 180),
                  );
                },
              ),
            ),
          ]),
        ),
      ) : const SizedBox() : const ItemShimmerView(isPopularItem: false);
    });
  }
}

class ItemShimmerView extends StatelessWidget {
  final bool isPopularItem;
  const ItemShimmerView({super.key, required this.isPopularItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Container(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
            child: TitleWidget(
              title: isPopularItem ? 'most_popular_items'.tr : 'special_offer'.tr,
               //titleColor: titlesColor,
                image: isPopularItem ? Images.mostPopularIcon : Images.discountOfferIcon,
                imageHeight: 30, imageWidth: 30,
            ),
          ),

          SizedBox(
            height: 260, width: Get.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeDefault),
                  child: Shimmer(
                    duration: const Duration(seconds: 2),
                    enabled: true,
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      height: 220, width: 180,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      child: Column(children: [

                        Container(
                          height: 100, width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Column(children: [

                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              height: 15, width: 100,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              height: 20, width: 200,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              height: 15, width: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
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
        ]),
      ),
    );
  }
}
