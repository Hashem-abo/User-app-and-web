import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class SimilarItemsScreen extends StatefulWidget {
  final Item item;
  const SimilarItemsScreen({super.key, required this.item});

  @override
  State<SimilarItemsScreen> createState() => _SimilarItemsScreenState();
}

class _SimilarItemsScreenState extends State<SimilarItemsScreen> {
  @override
  void initState() {
    super.initState();
    int categoryId = 0;
    int parentCategoryId = 0;
    if (widget.item.categoryIds != null && widget.item.categoryIds!.isNotEmpty) {
      categoryId = widget.item.categoryIds!.last.id ?? 0;
      parentCategoryId = widget.item.categoryIds!.first.id ?? 0;
    } else if (widget.item.categoryId != null) {
      categoryId = widget.item.categoryId!;
      parentCategoryId = widget.item.categoryId!;
    }

    Get.find<ItemController>().getSimilarItems(
      widget.item.name ?? '',
      widget.item.moduleId ?? 0,
      categoryId,
      widget.item.id ?? 0,
      widget.item.storeId,
      parentCategoryId: parentCategoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFood = widget.item.moduleType == 'food';
    bool isShop = widget.item.moduleType == 'ecommerce' ||
        widget.item.moduleType == 'shop' ||
        widget.item.moduleType == 'grocery' ||
        widget.item.moduleType == 'pharmacy';

    double? startingPrice = widget.item.price;
    double? discount = widget.item.discount;
    String? discountType = widget.item.discountType;
    double finalPrice = PriceConverter.convertWithDiscount(startingPrice, discount, discountType) ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.05),
      appBar: AppBar(
        title: Text('similar_products'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Parent Product Header Card
            Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImage(
                      image: '${widget.item.imageFullUrl}',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name ?? '',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              PriceConverter.convertPrice(finalPrice),
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (discount != null && discount > 0) ...[
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                PriceConverter.convertPrice(startingPrice),
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).disabledColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Similar Products Section Title
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       'similar_products'.tr,
            //       style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            //     ),
            //   ),
            // ),

            // Grid of Similar Products
            Expanded(
              child: GetBuilder<ItemController>(
                id: 'explore_more',
                builder: (itemController) {
                  if (itemController.similarProductList == null) {
                    return const SimilarItemsShimmer();
                  }

                  if (itemController.similarProductList!.isEmpty) {
                    return Center(
                      child: Text(
                        'no_similar_products_found'.tr,
                        style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
                      ),
                    );
                  }

                  // Sort the similarProductList by similarity (sub-category levels and shared name keywords)
                  List<Item> sortedList = List.from(itemController.similarProductList!);

                  int calculateSimilarityScore(Item product) {
                    int score = 0;

                    // 1. Sub-category (last category ID) match
                    int parentSubCategoryId = 0;
                    if (widget.item.categoryIds != null && widget.item.categoryIds!.isNotEmpty) {
                      parentSubCategoryId = widget.item.categoryIds!.last.id ?? 0;
                    }

                    int productSubCategoryId = 0;
                    if (product.categoryIds != null && product.categoryIds!.isNotEmpty) {
                      productSubCategoryId = product.categoryIds!.last.id ?? 0;
                    }

                    if (parentSubCategoryId != 0 && parentSubCategoryId == productSubCategoryId) {
                      score += 1000;
                    }

                    // 2. Parent category match
                    if (widget.item.categoryIds != null && product.categoryIds != null) {
                      Set<int> parentCatIds = widget.item.categoryIds!.map((c) => c.id ?? 0).toSet();
                      Set<int> productCatIds = product.categoryIds!.map((c) => c.id ?? 0).toSet();
                      int commonCats = parentCatIds.intersection(productCatIds).length;
                      score += commonCats * 100;
                    }

                    // 3. Name word matching
                    if (widget.item.name != null && product.name != null) {
                      List<String> parentWords = widget.item.name!.toLowerCase().split(' ')
                          .where((w) => w.trim().length > 1).toList();
                      List<String> productWords = product.name!.toLowerCase().split(' ')
                          .where((w) => w.trim().length > 1).toList();

                      int matchingWords = 0;
                      for (var word in parentWords) {
                        if (productWords.contains(word)) {
                          matchingWords++;
                        }
                      }
                      score += matchingWords * 50;
                    }

                    // 4. Same store match
                    if (widget.item.storeId != null && widget.item.storeId == product.storeId) {
                      score += 10;
                    }

                    return score;
                  }

                  sortedList.sort((a, b) {
                    int scoreA = calculateSimilarityScore(a);
                    int scoreB = calculateSimilarityScore(b);
                    return scoreB.compareTo(scoreA);
                  });

                  return GridView.builder(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    itemCount: sortedList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: Dimensions.paddingSizeDefault,
                      crossAxisSpacing: Dimensions.paddingSizeDefault,
                      childAspectRatio: 0.72,
                      mainAxisExtent: (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food) ? 220 : 335,
                    ),
                    itemBuilder: (context, index) {
                      return ItemCard(
                        item: sortedList[index],
                        isFood: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food,
                        isShop: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce,
                        isPopularItem: true,
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimilarItemsShimmer extends StatelessWidget {
  const SimilarItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: Dimensions.paddingSizeDefault,
        crossAxisSpacing: Dimensions.paddingSizeDefault,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            ),
            child: Column(children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    height: 15, width: 100,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    height: 20, width: 150,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    height: 15, width: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}
