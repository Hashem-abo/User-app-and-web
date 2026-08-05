import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_medicine_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/web_basic_medicine_nearby_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/medicine_item_card.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ProductWithCategoriesView extends StatefulWidget {
  final bool fromShop;
  final double? height;
  const ProductWithCategoriesView({super.key, this.fromShop = false, this.height});

  @override
  State<ProductWithCategoriesView> createState() => _ProductWithCategoriesViewState();
}

class _ProductWithCategoriesViewState extends State<ProductWithCategoriesView> {
  int selectedCategory = 0;
  int? _moduleId;

  @override
  Widget build(BuildContext context) {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if (_moduleId != currentModuleId) {
      _moduleId = currentModuleId;
      selectedCategory = 0;
    }

    return GetBuilder<ItemController>(builder: (itemController) {
      List<Categories>? categories = [];
      List<Item>? products = [];
      if(widget.fromShop ? itemController.reviewedCategoriesList != null && itemController.reviewedItemList != null : itemController.basicMedicineModel != null){
        categories.add(Categories(name: 'all'.tr, id: 0));
        for (var category in widget.fromShop ? itemController.reviewedCategoriesList! : itemController.basicMedicineModel!.categories!) {
          categories.add(category);
        }
        for (var product in widget.fromShop ? itemController.reviewedItemList! : itemController.basicMedicineModel!.products!) {
          bool isMatched = false;
          var selectedId = categories[selectedCategory].id;
          String selectedIdStr = selectedId?.toString() ?? '0';

          if (selectedCategory == 0 || selectedIdStr == '0') {
            isMatched = true;
          } else {
            if (product.categoryId?.toString() == selectedIdStr) {
              isMatched = true;
            } else if (product.categoryIds != null) {
              for (var categoryId in product.categoryIds!) {
                if (categoryId.id?.toString() == selectedIdStr) {
                  isMatched = true;
                  break;
                }
              }
            }
          }

          if (isMatched) {
            products.add(product);
          }
        }
      }
      bool hasData = widget.fromShop ? (itemController.reviewedCategoriesList != null && itemController.reviewedItemList != null) : itemController.basicMedicineModel != null;

      return hasData ? Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, bottom: 3),
            child: Text(widget.fromShop ? 'best_reviewed_products'.tr : 'basic_medicine_nearby'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          ),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 50,
              child: Container(
                height: 40,
                color: widget.fromShop ? Theme.of(context).disabledColor.withValues(alpha: 0.1) : Colors.transparent,
                child: ListView.builder(
                  itemCount: categories.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedCategory == index;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedCategory = index;
                        });
                      },
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 5),
                          child: Text(
                            '${categories[index].name}',
                            style: robotoMedium.copyWith(
                              color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).disabledColor,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),

                        isSelected ? SizedBox(
                          height: 6, width: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ) : const SizedBox(),
                      ]),
                    );
                  },
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: widget.fromShop ? Theme.of(context).disabledColor.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              child: SizedBox(
                height: widget.height ?? (ResponsiveHelper.isDesktop(context) ? widget.fromShop ?320 : 260 : widget.fromShop ? 350 : 350), width: Get.width,
                child: (widget.fromShop ? itemController.reviewedCategoriesList != null : itemController.basicMedicineModel != null) ? products.isNotEmpty ? ListView.builder(
                  key: ValueKey('category_products_$selectedCategory'),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                     return Padding(
                       padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
                       child: MedicineItemCard(item: products[index], width: 170),
                    );
                  },
                ) : Center(child: Text('no_products_found'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor))) : const MedicineCardShimmer(),
              ),
            ),
          ]),

        ]),
      ) : const SizedBox();
    });
  }
}




