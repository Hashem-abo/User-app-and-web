import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/styles.dart';

class BuyAgainContentView extends StatefulWidget {
  const BuyAgainContentView({super.key});

  @override
  State<BuyAgainContentView> createState() => _BuyAgainContentViewState();
}

class _BuyAgainContentViewState extends State<BuyAgainContentView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    Get.find<ItemController>().getBuyAgainItemList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ItemController>(builder: (itemController) {
        bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
        bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'ecommerce';
        
        List<Item>? buyAgainList;

        if(itemController.buyAgainItemList != null) {
          buyAgainList = [];
          if(_searchText.isEmpty) {
            buyAgainList = itemController.buyAgainItemList;
          } else {
             for(var item in itemController.buyAgainItemList!) {
               if(item.name != null && item.name!.toLowerCase().contains(_searchText.toLowerCase())) {
                 buyAgainList.add(item);
               }
             }
          }
        }

        return Column(children: [
          SizedBox(
            width: Dimensions.webMaxWidth,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                  decoration: InputDecoration(
                    hintText: 'search'.tr,
                    hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    isDense: true,
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).disabledColor, size: 24),
                    suffixIcon: _searchText.isNotEmpty ? IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).disabledColor, size: 24),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchText = '';
                        });
                        FocusScope.of(context).unfocus();
                      },
                    ) : null,
                  ),
                  onChanged: (String query) {
                    setState(() {
                      _searchText = query;
                    });
                  },
                ),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await itemController.getBuyAgainItemList(reload: true);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: FooterView(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 0 : 80.0),
                      child: buyAgainList != null ? buyAgainList.isNotEmpty ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : ResponsiveHelper.isDesktop(context) ? 3 : 3,
                          crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : Dimensions.paddingSizeSmall,
                          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : Dimensions.paddingSizeSmall,
                          mainAxisExtent: isFood ? 220 :340,
                        ),
                        itemCount: buyAgainList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        itemBuilder: (context, index) {
                          return ItemCard(
                            item: buyAgainList![index],
                            isShop: isShop,
                            isFood: isFood,
                          );
                        },
                      ) : Center(child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text('no_item_found'.tr),
                      )) : const Center(child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: CircularProgressIndicator(),
                      )),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}
