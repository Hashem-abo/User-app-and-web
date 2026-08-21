import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class CategoryTreeScreen extends StatefulWidget {
  const CategoryTreeScreen({super.key});

  @override
  State<CategoryTreeScreen> createState() => _CategoryTreeScreenState();
}

class _CategoryTreeScreenState extends State<CategoryTreeScreen> {
  int _currentHintIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CategoryController>().getCategoryList(false);
      CategoryController categoryController = Get.find<CategoryController>();
      if(categoryController.categoryList != null && categoryController.categoryList!.isNotEmpty && categoryController.subCategoryList == null) {
        categoryController.getSubCategoryList(categoryController.categoryList![0].id.toString());
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentHintIndex++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: GetBuilder<CategoryController>(builder: (categoryController) {
          return Column(
            children: [
              
              // Search Box (Top)
              Container(
                height: 65, width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                child: InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                          blurRadius: 15, spreadRadius: 1, offset: const Offset(0, 5),
                        )
                      ],
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 1),
                    ),
                    child: Row(children: [
                      Icon(
                        CupertinoIcons.search, size: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: Row(
                        children: [
                          Text(
                            '${'search_for'.tr} : ', 
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                final inTween = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation);
                                final outTween = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(animation);
                                if (child.key == ValueKey<int>(_currentHintIndex)) {
                                  return SlideTransition(position: inTween, child: FadeTransition(opacity: animation, child: child));
                                } else {
                                  return SlideTransition(position: outTween, child: FadeTransition(opacity: animation, child: child));
                                }
                              },
                              child: Container(
                                key: ValueKey<int>(_currentHintIndex),
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  (categoryController.categoryList != null && categoryController.categoryList!.isNotEmpty)
                                      ? categoryController.categoryList![_currentHintIndex % categoryController.categoryList!.length].name!
                                      : '',
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                      
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Icon(Icons.camera_alt, size: 18, color: Theme.of(context).primaryColor),
                      ),
                    ]),
                  ),
                ),
              ),

              // Top: Main Categories (Horizontal)
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 5, spreadRadius: 1, offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: categoryController.categoryList != null ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  itemCount: categoryController.categoryList!.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedCategoryIndex == index;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                        categoryController.getSubCategoryList(categoryController.categoryList![index].id.toString());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3), width: 1),
                          boxShadow: isSelected ? [
                            BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                          ] : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          categoryController.categoryList![index].name!,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                    );
                  },
                ) : const SizedBox(),
              ),

              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (categoryController.categoryList == null || categoryController.categoryList!.isEmpty) return;
                    
                    if (details.primaryVelocity! < -300 ) {
                      // Swiped Right -> Previous Category
                      if (_selectedCategoryIndex > 0) {
                        setState(() {
                          _selectedCategoryIndex--;
                        });
                        categoryController.getSubCategoryList(categoryController.categoryList![_selectedCategoryIndex].id.toString());
                      }
                    } else if (details.primaryVelocity! > 300) {
                      // Swiped Left -> Next Category
                      if (_selectedCategoryIndex < categoryController.categoryList!.length - 1) {
                        setState(() {
                          _selectedCategoryIndex++;
                        });
                        categoryController.getSubCategoryList(categoryController.categoryList![_selectedCategoryIndex].id.toString());
                      }
                    }
                  },
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Sidebar: Sub Categories
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                        border: Border(right: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), width: 1)),
                      ),
                      child: (categoryController.subCategoryList != null && categoryController.subCategoryList!.isNotEmpty) ? ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall + 80),
                        itemCount: categoryController.subCategoryList!.length,
                        itemBuilder: (context, index) {
                          bool isSelected = categoryController.subCategoryIndex == index;
                          return InkWell(
                            onTap: () {
                              categoryController.setSubCategoryIndex(index, categoryController.subCategoryList![index].id.toString());
                              categoryController.getSubSubCategoryList(categoryController.subCategoryList![index].id.toString());
                            },
                            child: Container(
                              height: 100,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).cardColor : Colors.transparent,
                                border: isSelected ? Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 4)) : null,
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: CustomImage(
                                    height: 50, width: 50,
                                    fit: BoxFit.cover,
                                    image: '${categoryController.subCategoryList![index].imageFullUrl}',
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                (categoryController.subCategoryList![index].isTitleVisible == 1) ? Text(
                                  categoryController.subCategoryList![index].name!,
                                  textAlign: TextAlign.center,
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: isSelected ? robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor) 
                                  : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium!.color),
                                ) : const SizedBox(),
                              ]),
                            ),
                          );
                        },
                      ) : categoryController.subCategoryList != null && categoryController.subCategoryList!.isEmpty
                          ? Center(child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Text(
                                'no_subcategory_found'.tr == 'no_subcategory_found' ? 'لا توجد فئات فرعية' : 'no_subcategory_found'.tr,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                              ),
                            ))
                          : const Center(child: CircularProgressIndicator()),
                    ),

                    // Center: Sub-Sub Categories / Items
                    Expanded(
                       child: categoryController.subSubCategoryList != null && categoryController.subSubCategoryList!.isNotEmpty
                        ? GridView.builder(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.8,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                            ),
                            itemCount: categoryController.subSubCategoryList!.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Get.toNamed(RouteHelper.getCategoryItemRoute(
                                    categoryController.subSubCategoryList![index].id, 
                                    categoryController.subSubCategoryList![index].name!,
                                    isSubSub: true,
                                  ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 3),
                                      )
                                    ],
                                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), width: 1),
                                  ),
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      child: CustomImage(
                                        height: 65, width: 65,
                                        fit: BoxFit.cover,
                                        image: '${categoryController.subSubCategoryList![index].imageFullUrl}',
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                                    (categoryController.subSubCategoryList![index].isTitleVisible == 1) ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                      child: Text(
                                        categoryController.subSubCategoryList![index].name!,
                                        textAlign: TextAlign.center,
                                        maxLines: 2, overflow: TextOverflow.ellipsis,
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      ),
                                    ) : const SizedBox(),
                                  ]),
                                ),
                              );
                            },
                          )
                        : categoryController.categoryItemList != null && categoryController.categoryItemList!.isNotEmpty
                          ? GridView.builder(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 4 : 2,
                                childAspectRatio: ResponsiveHelper.isDesktop(context) ? 1.2 : 0.4,
                                mainAxisSpacing: Dimensions.paddingSizeSmall,
                                crossAxisSpacing: Dimensions.paddingSizeSmall,
                              ),
                              itemCount: categoryController.categoryItemList!.length,
                              itemBuilder: (context, index) {
                                return ItemCard(
                                  item: categoryController.categoryItemList![index],
                                  isShop: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce,
                                  isFood: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food,
                                );
                              },
                            )
                          : (categoryController.subCategoryList != null && categoryController.subCategoryList!.isEmpty) ||
                            (categoryController.subSubCategoryList == null && categoryController.categoryItemList != null && categoryController.categoryItemList!.isEmpty) ||
                            (categoryController.subSubCategoryList != null && categoryController.subSubCategoryList!.isEmpty && (categoryController.categoryItemList == null || categoryController.categoryItemList!.isEmpty))
                              ? Center(child: Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.category_outlined, size: 50, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Text(
                                        'no_data_found'.tr == 'no_data_found' ? 'لا توجد بيانات متاحة في هذه الفئة' : 'no_data_found'.tr,
                                        style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ))
                              : const Center(child: CircularProgressIndicator())
                    ),
                  ],
                ),
              ),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  int _selectedCategoryIndex = 0;

}
