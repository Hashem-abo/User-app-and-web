import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/trends/controllers/trends_controller.dart';
import 'package:sixam_mart/features/trends/widgets/trend_widgets.dart';
import 'package:sixam_mart/util/dimensions.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<TrendsController>().getTrendsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<TrendsController>(builder: (trendsController) {
        if (trendsController.isLoading) {
          return const CustomLoaderWidget();
        }

        bool hasHashtags = (trendsController.hashtags?.isNotEmpty ?? false);
        bool hasBrands = (trendsController.brands?.isNotEmpty ?? false);
        bool hasItems = hasHashtags && (trendsController.hashtags![trendsController.selectedHashtagIndex].items?.isNotEmpty ?? false);

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + Dimensions.paddingSizeDefault,
            bottom: Platform.isIOS ? 80.0 : 65.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasHashtags) ...[
                TrendHeaderBanner(hashtag: trendsController.hashtags![trendsController.selectedHashtagIndex]),
                TrendHashtagSelector(
                  hashtags: trendsController.hashtags!,
                  selectedIndex: trendsController.selectedHashtagIndex,
                  onSelected: (index) => trendsController.selectHashtag(index),
                ),
                if (hasItems)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault, 0,
                      Dimensions.paddingSizeDefault, 0,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.58,
                        mainAxisSpacing: Dimensions.paddingSizeSmall,
                        crossAxisSpacing: Dimensions.paddingSizeSmall,
                      ),
                      itemCount: trendsController.hashtags![trendsController.selectedHashtagIndex].items!.length,
                      itemBuilder: (context, index) {
                        return ItemCard(
                          item: trendsController.hashtags![trendsController.selectedHashtagIndex].items![index],
                          isFood: false,
                          isShop: false,
                        );
                      },
                    ),
                  ),
              ],
              if (hasBrands) TrendBrandsCarousel(brands: trendsController.brands!),
              if (!hasHashtags && !hasBrands)
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Center(child: Text('no_items_found'.tr)),
                ),
            ],
          ),
        );
      }),
    );
  }
}
