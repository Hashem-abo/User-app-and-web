import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/card_design/store_card_with_distance.dart'; // + ahmed
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/shelf/controllers/shelf_controller.dart';
import 'package:sixam_mart/features/shelf/domain/models/shelf_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/service/widgets/service_widget.dart';
import 'package:sixam_mart/features/service/widgets/service_provider_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class DynamicShelfViewAllScreen extends StatefulWidget {
  final int shelfId;
  const DynamicShelfViewAllScreen({super.key, required this.shelfId});

  @override
  State<DynamicShelfViewAllScreen> createState() => _DynamicShelfViewAllScreenState();
}

class _DynamicShelfViewAllScreenState extends State<DynamicShelfViewAllScreen> {
  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'ecommerce';
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
    ShelfModel? shelf;
    if (Get.find<ShelfController>().shelfList != null) {
      shelf = Get.find<ShelfController>().shelfList!.firstWhereOrNull((s) => s.id == widget.shelfId);
    }

    return Scaffold(
      appBar: CustomAppBar(title: shelf?.name ?? 'products'.tr),
      endDrawer: const MenuDrawer(),
      body: GetBuilder<ShelfController>(builder: (shelfController) {
        if (shelfController.shelfList != null) {
          shelf = shelfController.shelfList!.firstWhereOrNull((s) => s.id == widget.shelfId);
        }

        return shelf != null ? SingleChildScrollView(
          child: FooterView(
            child: Column(children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (shelf!.type == 'store' || shelf!.type == 'service_provider' || shelf!.type == 'service') ? 1 : 2,
                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                  mainAxisExtent: shelf!.type == 'store' ? 200 : (shelf!.type == 'service_provider' || shelf!.type == 'service' ? 120 : 350),
                  childAspectRatio: (shelf!.type == 'category' || shelf!.type == 'service_category') ? 1 : 0.65,
                ),
                itemCount: 
                    shelf!.type == 'category' ? shelf!.categories?.length ?? 0
                  : shelf!.type == 'service_category' ? shelf!.serviceCategories?.length ?? 0
                  : shelf!.type == 'store' ? shelf!.stores?.length ?? 0
                  : shelf!.type == 'service_provider' ? shelf!.serviceProviders?.length ?? 0
                  : shelf!.type == 'service' ? shelf!.services?.length ?? 0
                  : shelf!.items?.length ?? 0,
                itemBuilder: (context, index) {
                  if (shelf!.type == 'category') {
                    return InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getCategoryItemRoute(
                        shelf!.categories![index].id, shelf!.categories![index].name!,
                      )),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
                        ),
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: shelf!.categories![index].isTitleVisible == 0 
                                  ? BorderRadius.circular(Dimensions.radiusDefault)
                                  : const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                              child: CustomImage(
                                image: '${shelf!.categories![index].imageFullUrl}',
                                fit: BoxFit.cover, height: double.infinity, width: double.infinity,
                              ),
                            ),
                          ),

                          if(shelf!.categories![index].isTitleVisible != 0) Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Text(
                              shelf!.categories![index].name ?? '',
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                      ),
                    );
                  } else if (shelf!.type == 'service_category') {
                    return InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getServicesRoute()),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
                        ),
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                              child: CustomImage(
                                image: '${shelf!.serviceCategories![index].imageFullUrl}',
                                fit: BoxFit.cover, height: double.infinity, width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Text(
                              shelf!.serviceCategories![index].name ?? '',
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                      ),
                    );
                  } else if (shelf!.type == 'store') {
                    return StoreCardWithDistance(store: shelf!.stores![index], fromAllStore: true);
                  } else if (shelf!.type == 'service_provider') {
                    return ServiceProviderWidget(provider: shelf!.serviceProviders![index]);
                  } else if (shelf!.type == 'service') {
                    return ServiceWidget(service: shelf!.services![index], index: index);
                  } else {
                    return ItemCard(
                      item: shelf!.items![index],
                      isFood: isFood,
                      isShop: isShop,
                    );
                  }
                },
              ),
            ]),
          ),
        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
