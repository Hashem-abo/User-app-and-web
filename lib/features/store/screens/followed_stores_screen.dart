import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/common/widgets/card_design/store_card.dart';
import 'package:sixam_mart/util/dimensions.dart';

class FollowedStoresScreen extends StatefulWidget {
  const FollowedStoresScreen({super.key});

  @override
  State<FollowedStoresScreen> createState() => _FollowedStoresScreenState();
}

class _FollowedStoresScreenState extends State<FollowedStoresScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<StoreController>().getFollowedStores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'followed_stores'.tr),
      body: GetBuilder<StoreController>(builder: (storeController) {
        return storeController.followedStoreList != null ? storeController.followedStoreList!.isNotEmpty ? ListView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          children: storeController.followedStoreList!.map((store) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: SizedBox(
                height: 220,
                child: StoreCard(store: store),
              ),
            );
          }).toList(),
        ) : NoDataScreen(text: 'no_followed_stores'.tr) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
