import 'package:suliman/common/widgets/card_design/store_card_with_distance.dart';
import 'package:suliman/features/store/controllers/store_controller.dart';
import 'package:suliman/features/store/domain/models/store_model.dart';
import 'package:suliman/features/home/widgets/web/web_new_on_view_widget.dart';
import 'package:suliman/helper/route_helper.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecommendedStoreView extends StatefulWidget {
  const RecommendedStoreView({super.key});

  @override
  State<RecommendedStoreView> createState() => _RecommendedStoreViewState();
}

class _RecommendedStoreViewState extends State<RecommendedStoreView> {
  @override
  void initState() {
    super.initState();
    var storeController = Get.find<StoreController>();
    if (storeController.recommendedStoreList == null) {
      storeController.getRecommendedStoreList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = storeController.recommendedStoreList;

      return storeList != null ? storeList.isNotEmpty ? Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: TitleWidget(
              title: 'recommended_store'.tr,
              onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute('recommended')),
            ),
          ),

          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              itemCount: storeList.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                  child: StoreCardWithDistance(store: storeList[index], recommendedStore: true),
                );
              },
            ),
          ),
        ]),
      ) : const SizedBox.shrink() : const WebNewOnShimmerView();
    });
  }
}
