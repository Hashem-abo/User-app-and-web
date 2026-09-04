import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart'; // + ahmed
import 'package:sixam_mart/helper/responsive_helper.dart'; // + ahmed
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart'; // + ahmed
import 'package:sixam_mart/util/app_constants.dart'; // + ahmed
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class NationalProductsView extends StatefulWidget {
  const NationalProductsView({super.key});

  @override
  State<NationalProductsView> createState() => _NationalProductsViewState();
}

class _NationalProductsViewState extends State<NationalProductsView> {
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    ItemController itemController = Get.find<ItemController>();
    // Initialize with default national aggregated items
    itemController.setOffset(1);
    // + ahmed
    itemController.initNationalProductsAggregation();
    itemController.getNationalAggregatedItemList(notify: false, offset: '1', dataSource: DataSourceEnum.local);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition = Scrollable.of(context).position;
    _scrollPosition?.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollPosition != null && _scrollPosition!.pixels >= _scrollPosition!.maxScrollExtent - 500) {
      if (Get.find<ItemController>().hasMoreData(isPopular: true) && !Get.find<ItemController>().isLoading) {
        int offset = Get.find<ItemController>().offset;
        Get.find<ItemController>().setOffset(offset + 1);
        Get.find<ItemController>().showBottomLoader();
        Get.find<ItemController>().getNationalAggregatedItemList(
          dataSource: DataSourceEnum.client, 
          offset: (offset + 1).toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      if (itemController.nationalAggregatedItemList == null) {
        return MultiSliver(
          children: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                  mainAxisExtent: 350,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return const NationalItemCardShimmer();
                  },
                  childCount: ResponsiveHelper.isDesktop(context) ? 10 : 8,
                ),
              ),
            ),
          ],
        );
      }

      return MultiSliver(
        children: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                mainAxisSpacing: Dimensions.paddingSizeSmall,
                crossAxisSpacing: Dimensions.paddingSizeSmall,
                mainAxisExtent: 350,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ItemCard(
                    item: itemController.nationalAggregatedItemList![index],
                    isPopularItem: true,
                    isFood: Get.find<SplashController>().module?.moduleType.toString() == AppConstants.food,
                    isShop: Get.find<SplashController>().module?.moduleType.toString() == AppConstants.ecommerce,
                    isPopularItemCart: true,
                  );
                },
                childCount: itemController.nationalAggregatedItemList!.length,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: itemController.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CustomLoaderWidget()),
                  )
                : const SizedBox(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      );
    });
  }
}

class NationalItemCardShimmer extends StatelessWidget {
  const NationalItemCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, spreadRadius: 1)],
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image skeleton
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
              ),
            ),
          ),
          
          // Details skeleton
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(height: 15, width: 100, color: Theme.of(context).disabledColor.withOpacity(0.2)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Container(height: 12, width: 120, color: Theme.of(context).disabledColor.withOpacity(0.2)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Container(height: 15, width: 80, color: Theme.of(context).disabledColor.withOpacity(0.2)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
