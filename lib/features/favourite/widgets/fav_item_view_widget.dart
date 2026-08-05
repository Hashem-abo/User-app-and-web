import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/card_design/store_card_with_distance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class FavItemViewWidget extends StatelessWidget {
  final bool isStore;
  final bool isSearch;
  final String searchText;
  const FavItemViewWidget({super.key, required this.isStore, this.isSearch = false, this.searchText = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<FavouriteController>(builder: (favouriteController) {
        
        bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
        bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'ecommerce';
        
        List<Item?>? wishItemList;
        List<Store?>? wishStoreList;

        if(favouriteController.wishItemList != null) {
          wishItemList = [];
          if(searchText.isEmpty) {
            wishItemList = favouriteController.wishItemList;
          } else {
             for(var item in favouriteController.wishItemList!) {
               if(item != null && item.name != null && item.name!.toLowerCase().contains(searchText.toLowerCase())) {
                 wishItemList.add(item);
               }
             }
          }
        }

        if(favouriteController.wishStoreList != null) {
          wishStoreList = [];
          if(searchText.isEmpty) {
            wishStoreList = favouriteController.wishStoreList;
          } else {
            for(var store in favouriteController.wishStoreList!) {
              if(store != null && store.name != null && store.name!.toLowerCase().contains(searchText.toLowerCase())) {
                wishStoreList.add(store);
              }
            }
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            await favouriteController.getFavouriteList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 0 : 80.0),
                  child: (isStore ? wishStoreList != null && wishStoreList.isNotEmpty : wishItemList != null && wishItemList.isNotEmpty) ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isMobile(context) ? (isStore ? 1 : 2) : ResponsiveHelper.isDesktop(context) ? 3 : 3,
                      crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : Dimensions.paddingSizeSmall,
                      mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : Dimensions.paddingSizeSmall,
                      mainAxisExtent: ResponsiveHelper.isDesktop(context) && isStore ? 220 : ResponsiveHelper.isMobile(context) && isStore ? (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 250 : 200) : (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 220 : 350),
                    ),
                    itemCount: isStore ? wishStoreList!.length : wishItemList!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      return isStore ? StoreCardWithDistance(
                        store: wishStoreList![index]!,
                        fromAllStore: true,
                        isNewStore: false,
                      ) : ItemCard(
                        item: wishItemList![index],
                        isShop: isShop,
                        isFood: isFood,
                      );
                    },
                  ) : Center(child: Text('no_wish_data_found'.tr)),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
