import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class BrowseByCategoryView extends StatefulWidget {
  final bool isShop;
  final bool isFood;
  final String? title;
  final double? height;
  final Color? backgroundColor;

  const BrowseByCategoryView({
    super.key,
    required this.isShop,
    required this.isFood,
    this.title,
    this.height,
    this.backgroundColor,
  });

  @override
  State<BrowseByCategoryView> createState() => _BrowseByCategoryViewState();
}

class _BrowseByCategoryViewState extends State<BrowseByCategoryView> with AutomaticKeepAliveClientMixin {
  int _selectedCategoryIndex = 0;
  bool _isInitialFetchDone = false;

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<CategoryController>(builder: (categoryController) {
      if (categoryController.categoryList == null || categoryController.categoryList!.isEmpty) {
        return const SizedBox();
      }
      
      if (!_isInitialFetchDone && categoryController.categoryList != null && categoryController.categoryList!.isNotEmpty) {
        _isInitialFetchDone = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          categoryController.getBrowseBySubCategoryList(categoryController.categoryList![0].id.toString());
        });
      }

      Color bgColor = widget.backgroundColor ?? Theme.of(context).primaryColor;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgColor.withOpacity(0.4),
              bgColor.withOpacity(0.3),
              bgColor.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                     widget.title ?? 'browse_by_category'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Category Tabs (Main Categories)
            SizedBox(
              height: 40,
              child: ListView.builder(
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
                      categoryController.getBrowseBySubCategoryList(
                        categoryController.categoryList![index].id.toString(),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                        border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Text(
                        categoryController.categoryList![index].name ?? '',
                        style: robotoMedium.copyWith(
                          color: isSelected ? Colors.black : Colors.black54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Content Area (Sub-Categories Left, Featured Image Right)
            SizedBox(
              height: widget.height != null ? (widget.height! > 100 ? widget.height! - 110 : widget.height!) : 220,
              child: Row(
                children: [
                  // Featured Image
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        // color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImage(
                          image: '${categoryController.categoryList![_selectedCategoryIndex].imageFullUrl}',
                          fit: BoxFit.fill,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),

                   // Sub-Category List
                   Expanded(
                    flex: 2,
                    child: categoryController.browseBySubCategoryList == null
                        ? const Center(child: CircularProgressIndicator())
                        : categoryController.browseBySubCategoryList!.isEmpty
                            ? Center(child: Text('no_sub_categories_found'.tr))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                itemCount: categoryController.browseBySubCategoryList!.length,
                                itemBuilder: (context, index) {
                                  CategoryModel subCategory = categoryController.browseBySubCategoryList![index];
                                  bool showTitle = subCategory.isTitleVisible == 1;

                                  return Container(
                                    width: 140, // Reverted to 140
                                    margin: const EdgeInsets.only(
                                      right: Dimensions.paddingSizeSmall,
                                      bottom: Dimensions.paddingSizeSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                        )
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () => Get.toNamed(RouteHelper.getCategoryItemRoute(
                                        subCategory.id, subCategory.name!,
                                      )),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // Image Logic
                                          Expanded(
                                            flex: showTitle ? 3 : 1, // Expand if no title
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: const Radius.circular(Dimensions.radiusDefault),
                                                topRight: const Radius.circular(Dimensions.radiusDefault),
                                                bottomLeft: showTitle ? Radius.zero : const Radius.circular(Dimensions.radiusDefault),
                                                bottomRight: showTitle ? Radius.zero : const Radius.circular(Dimensions.radiusDefault),
                                              ),
                                              child: CustomImage(
                                                image: '${subCategory.imageFullUrl}',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          
                                          // Title Logic
                                          if (showTitle)
                                            Padding(
                                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                              child: Center(
                                                child: Text(
                                                  subCategory.name ?? '',
                                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
