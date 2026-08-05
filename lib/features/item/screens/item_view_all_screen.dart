import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/item/widgets/item_view_all_filter_bottom_sheet.dart';
import 'package:sixam_mart/features/item/widgets/item_view_all_sort_bottom_sheet.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/search/widgets/search_field_widget.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class ItemViewAllScreen extends StatefulWidget {
  final bool isPopular;
  final bool isSpecial;
  final bool backButton;
  const ItemViewAllScreen({super.key, this.isPopular = false, this.isSpecial = true, this.backButton = true});

  @override
  State<ItemViewAllScreen> createState() => _ItemViewAllScreenState();
}

class _ItemViewAllScreenState extends State<ItemViewAllScreen> {
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ItemController itemController = Get.find<ItemController>();
    itemController.setOffset(1);
    itemController.clearFilters(isPopular: widget.isPopular, isSpecial: widget.isSpecial);
    itemController.clearSearch(withUpdate: false);

    _scrollController.addListener(() {
      final itemController = Get.find<ItemController>();
      List<Item?>? items;

      if (widget.isPopular) {
        items = itemController.popularItemList;
      } else if (widget.isSpecial) {
        items = itemController.discountedItemList;
      } else {
        items = itemController.reviewedItemList;
      }

      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && items != null && !itemController.isLoading) {

        int pageSize = (itemController.pageSize! / 10).ceil();
        if (itemController.offset < pageSize) {
          itemController.setOffset(itemController.offset + 1);
          debugPrint('end of the page, offset: ${itemController.offset}');

          itemController.showBottomLoader();

          if (widget.isPopular) {
            itemController.getPopularItemList(notify: false, dataSource: DataSourceEnum.client, offset: itemController.offset.toString());
          } else if (widget.isSpecial) {
            itemController.getDiscountedItemList(notify: false, dataSource: DataSourceEnum.client, offset: itemController.offset.toString());
          } else {
            itemController.getReviewedItemList(notify: false, dataSource: DataSourceEnum.client, offset: itemController.offset.toString());
          }
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {

    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;

    return GetBuilder<ItemController>(builder: (itemController) {

      List<Item?>? items;
      if(widget.isPopular){
        items = itemController.popularItemList;
      }else if(widget.isSpecial){
        items = itemController.discountedItemList;
      }else{
        items = itemController.reviewedItemList;
      }

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          Get.find<ItemController>().resetFilters(isPopular: widget.isPopular, isSpecial: widget.isSpecial);
          Get.find<ItemController>().clearSearch();
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(children: [
        
              Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: Get.find<ThemeController>().darkTheme ? Colors.black12 : Theme.of(context).cardColor,
                  boxShadow: Get.find<ThemeController>().darkTheme ? null : [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 3, offset: const Offset(0, 5))]
                ),
                child: Row(children: [
        
                  widget.backButton ? IconButton(
                    onPressed: (){
                      Get.find<ItemController>().resetFilters(isPopular: widget.isPopular, isSpecial: widget.isSpecial);
                      Get.find<ItemController>().clearSearch();
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ) : const SizedBox(),
        
                  Expanded(child: Container(
                    margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall + 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: SearchFieldWidget(
                      controller: itemController.searchController,
                      isFocused: false,
                      radius: 50,
                      hint: 'search_your_desired_item'.tr,
                      prefixIcon: CupertinoIcons.search,
                      suffixIcon: itemController.isSearching ? CupertinoIcons.clear_thick : null,
                      iconPressed: () {
                        if (!itemController.isSearching) {
                          if (itemController.searchController.text.trim().isNotEmpty) {
                            if (widget.isPopular) {
                              itemController.getPopularItemList(notify: true, offset: '1');
                            } else if (widget.isSpecial) {
                              itemController.getDiscountedItemList(notify: true, offset: '1');
                            } else {
                              itemController.getReviewedItemList(notify: true, offset: '1');
                            }
                          } else {
                            showCustomSnackBar('write_item_name_for_search'.tr);
                          }
                        } else {
                          itemController.clearSearch();
                          if (widget.isPopular) {
                            itemController.getPopularItemList(notify: true, offset: '1');
                          } else if (widget.isSpecial) {
                            itemController.getDiscountedItemList(notify: true, offset: '1');
                          } else {
                            itemController.getReviewedItemList(notify: true, offset: '1');
                          }
                        }
                      },
                      onSubmit: (String text) {
                        if (itemController.searchController.text.trim().isNotEmpty) {
                          if (widget.isPopular) {
                            itemController.getPopularItemList(notify: true, offset: '1');
                          } else if (widget.isSpecial) {
                            itemController.getDiscountedItemList(notify: true, offset: '1');
                          } else {
                            itemController.getReviewedItemList(notify: true, offset: '1');
                          }
                        } else {
                          showCustomSnackBar('write_item_name_for_search'.tr);
                        }
                      },
                    ),
                  )),
        
                  IconButton(
                    onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                    icon: CartWidget(color: Theme.of(context).textTheme.bodyLarge!.color, size: 25),
                  ),
        
                ]),
              ),
        
              Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
                child: Row(children: [
        
                  Text(widget.isPopular ? isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr : widget.isSpecial ? 'special_offer'.tr : 'best_reviewed_item'.tr, style: robotoBold),
                  Text(' (${itemController.pageSize ?? 0})', style: robotoBold),
                  const Spacer(),

                  InkWell(
                    onTap: () {
                      showCustomBottomSheet(child: ItemViewAllSortBottomSheet(isPopular: widget.isPopular, isSpecial: widget.isSpecial));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).hintColor),
                      ),
                      child: Icon(CupertinoIcons.sort_down, color: Theme.of(context).hintColor, size: 18),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  InkWell(
                    onTap: () {
        
                      List<double?> prices = [];
                      for (var product in itemController.discountedItemList!) {
                        prices.add(product.price);
                      }
                      prices.sort();
                      double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 99999999;
        
                      showCustomBottomSheet(child: ItemViewAllFilterBottomSheet(maxValue: maxValue, isPopular: widget.isPopular, isSpecial: widget.isSpecial));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).primaryColor),
                      ),
                      child: Icon(Icons.filter_list, color: Theme.of(context).primaryColor, size: 18),
                    ),
                  ),
        
                ]),
              ),
        
              Expanded(
                child: items != null ? items.isNotEmpty ? GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    mainAxisExtent: isFood ? 220 :340,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ItemCard(
                      key: ValueKey(items![index]!.id),
                      item: items[index]!,
                      isFood: isFood,
                      isShop: isShop,
                      isPopularItem: widget.isPopular,
                    );
                  },
                ) : Center(
                  child: Text(
                    'no_items_found'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                  ),
                ) : GridView.builder(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    mainAxisExtent: isFood ? 220 :340,
                  ),
                  itemCount: 14,
                  itemBuilder: (context, index) {
                    return const ItemShimmerView();
                  },
                ),
              ),

              itemController.isLoading ? Center(child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
              )) : const SizedBox(),
        
            ]),
          ),
        ),
      );
    });
  }
}

class ItemShimmerView extends StatelessWidget {
  const ItemShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        height: 350, width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Column(children: [

          Container(
            height: 150, width: double.infinity,
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
    );
  }
}

