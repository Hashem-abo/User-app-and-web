import 'package:sixam_mart/features/service/widgets/service_provider_widget.dart';
import 'package:sixam_mart/features/service/widgets/service_widget.dart';
import 'package:sixam_mart/features/search/controllers/search_controller.dart' as search;
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/web_item_view.dart';

class ItemViewWidget extends StatelessWidget {
  final bool isItem;
  const ItemViewWidget({super.key, required this.isItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<search.SearchController>(builder: (searchController) {
        bool isService = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType == 'services';
        
        return GetBuilder<ServiceController>(builder: (serviceController) {
          dynamic results;
          if (isService) {
            results = isItem ? serviceController.searchServicesList : serviceController.searchProvidersList;
          } else {
            results = isItem ? searchController.searchItemList : searchController.searchStoreList;
          }

          if (results == null) {
            return const Center(child: CustomLoaderWidget());
          }

          if (isService) {
            return SingleChildScrollView(
              child: FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: results != null ? results!.isNotEmpty ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: results!.length,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      return isItem ? ServiceWidget(service: results![index], index: index) : ServiceProviderWidget(provider: results![index]);
                    },
                  ) : Center(child: Text(isItem ? 'no_service_available'.tr : 'no_provider_available'.tr)) : const CustomLoaderWidget(),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: FooterView(
              child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: ResponsiveHelper.isDesktop(context) ? WebItemsView(
                    isStore: !isItem, items: isItem ? results : null, stores: !isItem ? results : null,
                  ) : ItemsView(
                    isStore: !isItem, items: isItem ? results : null, stores: !isItem ? results : null,
                    mobileItemCrossAxisCount: 2,
                  ),
              ),
            ),
          );
        });
      }),
    );
  }
}
