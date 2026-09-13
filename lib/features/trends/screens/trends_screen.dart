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

        // Use CustomScrollView + Slivers so the product GridView renders lazily
        // instead of measuring all items at once with shrinkWrap: true.
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top safe-area + hashtag header + selector
            if (hasHashtags) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrendHeaderBanner(hashtag: trendsController.hashtags![trendsController.selectedHashtagIndex]),
                      TrendHashtagSelector(
                        hashtags: trendsController.hashtags!,
                        selectedIndex: trendsController.selectedHashtagIndex,
                        onSelected: (index) => trendsController.selectHashtag(index),
                      ),
                    ],
                  ),
                ),
              ),

              // Items grid — lazy via SliverGrid (replaces GridView(shrinkWrap:true))
              if (hasItems)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    0,
                    Dimensions.paddingSizeDefault,
                    0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                      crossAxisSpacing: Dimensions.paddingSizeSmall,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ItemCard(
                        item: trendsController.hashtags![trendsController.selectedHashtagIndex].items![index],
                        isFood: false,
                        isShop: false,
                      ),
                      childCount: trendsController.hashtags![trendsController.selectedHashtagIndex].items!.length,
                    ),
                  ),
                ),
            ],

            // Brands carousel
            if (hasBrands)
              SliverToBoxAdapter(
                child: TrendBrandsCarousel(brands: trendsController.brands!),
              ),

            // Empty state
            if (!hasHashtags && !hasBrands)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Center(child: Text('no_items_found'.tr)),
                ),
              ),

            // Bottom safe area
            SliverToBoxAdapter(
              child: SizedBox(height: Platform.isIOS ? 80.0 : 65.0),
            ),
          ],
        );
      }),
    );
  }
}
