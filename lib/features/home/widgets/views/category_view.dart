import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      bool isPharmacy = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.pharmacy;
      bool isFood = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.food;

      return GetBuilder<CategoryController>(builder: (categoryController) {
        return (categoryController.categoryList != null && categoryController.categoryList!.isEmpty)
        ? const SizedBox() : isPharmacy ? PharmacyCategoryView(categoryController: categoryController)
          : isFood ? FoodCategoryView(categoryController: categoryController) : Column(
          children: [
            SizedBox(
              height: (splashController.module?.categoryRows ?? 2) * 175, // Increased height for dynamic rows (150 * rows + spacing)
              child: categoryController.categoryList != null ? GridView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: splashController.module?.categoryRows ?? 2, // Dynamic Rows
                  mainAxisExtent: splashController.module?.categoryItemWidth ?? 120, // Width of each item
                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                ),
                itemCount: categoryController.categoryList!.length > ((splashController.module?.categoryRows ?? 2) * 10) ? ((splashController.module?.categoryRows ?? 2) * 10) : categoryController.categoryList!.length,
                itemBuilder: (context, index) {
                  int rows = splashController.module?.categoryRows ?? 2;
                  int totalItems = rows * 10;
                  bool isSeeAll = index == (totalItems - 1) && categoryController.categoryList!.length > totalItems;
                  return InkWell(
                      onTap: () {
                        if(isSeeAll) {
                          Get.toNamed(RouteHelper.getCategoryRoute());
                        } else {
                          Get.toNamed(RouteHelper.getCategoryItemRoute(
                            categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                          ));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          gradient: splashController.module?.categoryViewBgColor != null ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(int.parse('0xFF${splashController.module!.categoryViewBgColor!.replaceAll('#', '')}')),
                              Color(int.parse('0xFF${splashController.module!.categoryViewBgColor!.replaceAll('#', '')}')).withValues(alpha: 0.05),
                            ],
                          ) : null,
                          color: splashController.module?.categoryViewBgColor == null ? Theme.of(context).primaryColor.withValues(alpha: 0.25) : null,
                        ),
                          child: splashController.module?.categoryViewTextPosition == 'hide' ? ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: Stack(children: [
                              CustomImage(
                                image: '${categoryController.categoryList![index].imageFullUrl}',
                                fit: BoxFit.cover, height: double.infinity, width: double.infinity,
                              ),
                              if(isSeeAll) Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${categoryController.categoryList!.length - (totalItems - 1)}',
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ) : Column(children: splashController.module?.categoryViewTextPosition == 'bottom' ? [
                            Expanded(
                              child: Stack(children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                                  child: CustomImage(
                                    image: '${categoryController.categoryList![index].imageFullUrl}',
                                    fit: BoxFit.contain, height: double.infinity, width: double.infinity,
                                  ),
                                ),
                                if(isSeeAll) Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+${categoryController.categoryList!.length - (totalItems - 1)}',
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5), // Adjusted padding
                              child: Text(
                                isSeeAll ? 'see_all'.tr : categoryController.categoryList![index].name!,
                                style: robotoBold.copyWith(
                                  fontSize: isSeeAll ? Dimensions.fontSizeDefault : (splashController.module?.categoryViewFontSize ?? Dimensions.fontSizeLarge),
                                  color: isSeeAll ? Theme.of(context).primaryColor : (splashController.module?.categoryViewFontColor != null
                                    ? Color(int.parse('0xFF${splashController.module!.categoryViewFontColor!.replaceAll('#', '')}'))
                                    : Theme.of(context).textTheme.bodyLarge?.color),

                                ),
                                maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                              ),
                            ),
                          ] : [
                            Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5), // Adjusted padding
                              child: Text(
                                isSeeAll ? 'see_all'.tr : categoryController.categoryList![index].name!,
                                style: robotoBold.copyWith(
                                  fontSize: isSeeAll ? Dimensions.fontSizeDefault : (splashController.module?.categoryViewFontSize ?? Dimensions.fontSizeLarge),
                                  color: isSeeAll ? Theme.of(context).primaryColor : (splashController.module?.categoryViewFontColor != null
                                    ? Color(int.parse('0xFF${splashController.module!.categoryViewFontColor!.replaceAll('#', '')}'))
                                    : Theme.of(context).textTheme.bodyLarge?.color),

                                ),
                                maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                              ),
                            ),
                            
                            Expanded(
                              child: Stack(children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
                                  child: CustomImage(
                                    image: '${categoryController.categoryList![index].imageFullUrl}',
                                    fit: BoxFit.contain, height: double.infinity, width: double.infinity,
                                  ),
                                ),
                                if(isSeeAll) Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+${categoryController.categoryList!.length - (totalItems - 1)}',
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ]),
                      ),
                    );
                },
              ) : SizedBox(height: splashController.module?.categoryViewHeight ?? 320, child: CategoryShimmer(categoryController: categoryController)),
            ),
          ],
        );
      });
    }
    );
  }
}

class PharmacyCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: splashController.module?.categoryViewHeight ?? 160,
          child: categoryController.categoryList != null ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
            itemCount: categoryController.categoryList!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault, right: index == categoryController.categoryList!.length - 1 ? Dimensions.paddingSizeDefault : 0),
                child: InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getCategoryItemRoute(
                    categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                  )),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: Container(
                    width: splashController.module?.categoryItemWidth ?? 70,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Column(children: [

                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault), // ahmed: Square
                        child: CustomImage(
                          image: '${categoryController.categoryList![index].imageFullUrl}',
                           height: 60, width: double.infinity, fit: BoxFit.cover,isUseMemCache: false,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Expanded(child: Text(
                        categoryController.categoryList![index].name!,
                        style: robotoMedium.copyWith(
                          fontSize: splashController.module?.categoryViewFontSize ?? Dimensions.fontSizeSmall,
                          color: splashController.module?.categoryViewFontColor != null
                                  ? Color(int.parse('0xFF${splashController.module!.categoryViewFontColor!.replaceAll('#', '')}'))
                                  : Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      )),
                    ]),
                  ),
                ),
              );
            },
          ) : CategoryShimmer(categoryController: categoryController),
        ),
      ]);
    });
  }
}

class FoodCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return GetBuilder<SplashController>(builder: (splashController) {
      return Stack(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: splashController.module?.categoryViewHeight ?? 160,
            child: categoryController.categoryList != null ? ListView.builder(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
              itemCount: categoryController.categoryList!.length > 10 ? 10 : categoryController.categoryList!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
                  child: InkWell(
                    onTap: () {
                      if(index == 9 && categoryController.categoryList!.length > 10) {
                        Get.toNamed(RouteHelper.getCategoryRoute());
                      } else {
                        Get.toNamed(RouteHelper.getCategoryItemRoute(
                          categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                        ));
                      }
                    },
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: SizedBox(
                      width: splashController.module?.categoryItemWidth ?? 60,
                      child: Column(children: [

                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault), // ahmed: Square
                                child: CustomImage(
                                  image: '${categoryController.categoryList![index].imageFullUrl}',
                                  height: double.infinity, width: double.infinity, fit: BoxFit.cover,
                                ),
                              ),

                              (index == 9 && categoryController.categoryList!.length > 10) ? Positioned(
                                right: 0, left: 0, top: 0, bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Theme.of(context).primaryColor.withValues(alpha: 0.4),
                                        Theme.of(context).primaryColor.withValues(alpha: 0.6),
                                        Theme.of(context).primaryColor.withValues(alpha: 0.4),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${categoryController.categoryList!.length - 10}',
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
                                      maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                    ),
                                  )
                                ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          (index == 9 && categoryController.categoryList!.length > 10) ?  'see_all'.tr : categoryController.categoryList![index].name ?? '',
                          style: robotoMedium.copyWith(
                            fontSize: (index == 9 && categoryController.categoryList!.length > 10) ? Dimensions.fontSizeDefault : (splashController.module?.categoryViewFontSize ?? Dimensions.fontSizeSmall),
                            color: (index == 9 && categoryController.categoryList!.length > 10)
                              ? Theme.of(context).primaryColor
                              : (splashController.module?.categoryViewFontColor != null
                                  ? Color(int.parse('0xFF${splashController.module!.categoryViewFontColor!.replaceAll('#', '')}'))
                                  : Theme.of(context).textTheme.bodyMedium!.color),
                          ),
                          maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                        ),
                      ]),
                    ),
                  ),
                );
              },
            ) : FoodCategoryShimmer(categoryController: categoryController),
          ),
        ]),

      ]);
    });
  }
}

class CategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const CategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeExtraSmall),
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: Dimensions.paddingSizeExtraSmall),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: SizedBox(
              width: 80,
              child: Column(children: [
                Container(
                  height: 60, width: 60,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : Dimensions.paddingSizeExtraSmall,
                    right: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.grey[300],
                  )
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Padding(
                  padding: EdgeInsets.only(right: index == 0 ? Dimensions.paddingSizeExtraSmall : 0),
                  child: Container(
                    height: 10, width: 50,
                    color: Colors.grey[300],
                  ),
                ),

              ]),
            ),
          ),
        );
      },
    );
  }
}

class FoodCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
          child: SizedBox(
            width: 60,
            child: Column(children: [

              Expanded(
                child: ClipOval(
                  child: Shimmer(
                    child: Container(
                      height: double.infinity, width: double.infinity,
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).shadowColor,
                      )
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Shimmer(
                child: Container(
                  height: 10, width: 50,
                  color: Theme.of(context).shadowColor,
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class PharmacyCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              width: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(100)),
              ),
              child: Column(children: [

                Container(
                  height: 60, width: double.infinity,
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(100)),
                    color: Colors.grey[300],
                  )
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Container(
                    height: 10, width: 50,
                    color: Colors.grey[300],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
