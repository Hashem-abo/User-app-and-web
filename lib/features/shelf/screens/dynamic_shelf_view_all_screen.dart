import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/common/widgets/custom_app_bar.dart';
import 'package:suliman/helper/route_helper.dart';
import 'package:suliman/common/widgets/card_design/item_card.dart';
import 'package:suliman/common/widgets/menu_drawer.dart';
import 'package:suliman/common/widgets/card_design/store_card_with_distance.dart';
import 'package:suliman/common/widgets/custom_image.dart';
import 'package:suliman/features/shelf/controllers/shelf_controller.dart';
import 'package:suliman/features/shelf/domain/models/shelf_model.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';
import 'package:suliman/features/service/widgets/service_widget.dart';
import 'package:suliman/features/service/widgets/service_provider_widget.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';

class DynamicShelfViewAllScreen extends StatefulWidget {
  final int shelfId;
  const DynamicShelfViewAllScreen({super.key, required this.shelfId});

  @override
  State<DynamicShelfViewAllScreen> createState() => _DynamicShelfViewAllScreenState();
}

class _DynamicShelfViewAllScreenState extends State<DynamicShelfViewAllScreen> {
  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() == 'ecommerce';
    bool isFood = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() == 'food';
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

        if (shelf == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final ShelfModel s = shelf!;
        final bool isSingleColumn =
            s.type == 'store' || s.type == 'service_provider' || s.type == 'service';
        final int crossAxisCount = isSingleColumn ? 1 : 2;
        final double? mainAxisExtent = s.type == 'store'
            ? 200
            : (s.type == 'service_provider' || s.type == 'service' ? 120 : 350);
        final double childAspectRatio =
            (s.type == 'category' || s.type == 'service_category') ? 1 : 0.65;
        final int itemCount = s.type == 'category'
            ? s.categories?.length ?? 0
            : s.type == 'service_category'
                ? s.serviceCategories?.length ?? 0
                : s.type == 'store'
                    ? s.stores?.length ?? 0
                    : s.type == 'service_provider'
                        ? s.serviceProviders?.length ?? 0
                        : s.type == 'service'
                            ? s.services?.length ?? 0
                            : s.items?.length ?? 0;

        // CustomScrollView + SliverGrid — lazy rendering, no shrinkWrap
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                  mainAxisExtent: mainAxisExtent,
                  childAspectRatio: childAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (s.type == 'category') {
                      return InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getCategoryItemRoute(
                          s.categories![index].id,
                          s.categories![index].name!,
                        )),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 1)
                            ],
                          ),
                          child: Column(children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: s.categories![index].isTitleVisible == 0
                                    ? BorderRadius.circular(Dimensions.radiusDefault)
                                    : const BorderRadius.vertical(
                                        top: Radius.circular(Dimensions.radiusDefault)),
                                child: CustomImage(
                                  image: '${s.categories![index].imageFullUrl}',
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            if (s.categories![index].isTitleVisible != 0)
                              Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: Text(
                                  s.categories![index].name ?? '',
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ]),
                        ),
                      );
                    } else if (s.type == 'service_category') {
                      return InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getServicesRoute()),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 1)
                            ],
                          ),
                          child: Column(children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(Dimensions.radiusDefault)),
                                child: CustomImage(
                                  image: '${s.serviceCategories![index].imageFullUrl}',
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Text(
                                s.serviceCategories![index].name ?? '',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]),
                        ),
                      );
                    } else if (s.type == 'store') {
                      return StoreCardWithDistance(
                          store: s.stores![index], fromAllStore: true);
                    } else if (s.type == 'service_provider') {
                      return ServiceProviderWidget(provider: s.serviceProviders![index]);
                    } else if (s.type == 'service') {
                      return ServiceWidget(service: s.services![index], index: index);
                    } else {
                      return ItemCard(
                        item: s.items![index],
                        isFood: isFood,
                        isShop: isShop,
                      );
                    }
                  },
                  childCount: itemCount,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
