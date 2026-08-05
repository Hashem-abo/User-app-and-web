import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';

class MostPopularItemView extends StatefulWidget {
  final bool isFood;
  final bool isShop;
  final String? title;
  final int? categoryId;
  final double? height;
  const MostPopularItemView({super.key, required this.isFood, required this.isShop, this.title, this.categoryId, this.height});

  @override
  State<MostPopularItemView> createState() => _MostPopularItemViewState();
}

class _MostPopularItemViewState extends State<MostPopularItemView> {
  final ScrollController _scrollController = ScrollController();
  List<Item>? _itemList;

  @override
  void initState() {
    super.initState();
    if(widget.categoryId != null) {
      _fetchItems();
    } else {
      var itemController = Get.find<ItemController>();
      if (itemController.popularItemList == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          itemController.getPopularItemList(offset: '1');
        });
      }
    }
  }

  Future<void> _fetchItems() async {
    ItemModel? itemModel = await Get.find<ItemController>().itemServiceInterface.getPopularItemList(
      type: 'all', offset: 1, categoryIds: [widget.categoryId!],
    );
    if(itemModel != null && mounted) {
      setState(() {
        _itemList = itemModel.items;
      });
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
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? itemList = widget.categoryId != null ? _itemList : itemController.popularItemList;

      if (itemList != null && itemList.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
      }

      return (itemList != null) ? itemList.isNotEmpty ? Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Container(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Column(children: [

            Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: 3),
              child: TitleWidget(
                title: widget.title ?? (isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr),
                //titleColor: titlesColor,
                image: Images.mostPopularIcon,
                onTap: () => Get.toNamed(RouteHelper.getItemViewAllScreen(true, false)),
              ),
            ),

            SizedBox(
              height: widget.isFood ? 260 : (widget.height??340), width: Get.width,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeDefault),
                    child: ItemCard(
                      isPopularItem: isShop ? false : true,
                      isPopularItemCart: true,
                      item: itemList[index],
                      isShop: isShop,
                      isFood: widget.isFood,
                      width: 180,
                    ),
                  );
                },
              ),
            ),

          ]),
        ),
      ) : const SizedBox() : const ItemShimmerView(isPopularItem: true);
    });
  }
}
