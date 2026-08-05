import 'package:sixam_mart/features/search/controllers/search_controller.dart' as search;
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/search/widgets/custom_check_box_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterWidget extends StatelessWidget {
  final double? maxValue;
  final bool isStore;
  const FilterWidget({super.key, required this.maxValue, required this.isStore});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: GetBuilder<search.SearchController>(builder: (searchController) {
        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Column(children: [
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Container(
                height: 5, width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(
                  onPressed: () {
                    if(isStore) {
                      searchController.resetStoreFilter();
                    } else {
                      searchController.resetFilter();
                    }
                  },
                  child: Text('reset'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
                ),
                Text('filter'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Theme.of(context).primaryColor, size: 25),
                ),
              ]),
            ]),
          ),
          const Divider(height: 1),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [


                // Filter By Section
                Text('filter_by'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                CustomCheckBoxWidget(
                  title: 'currently_available_items'.tr,
                  value: isStore ? searchController.isAvailableStore : searchController.isAvailableItems,
                  onClick: () => isStore ? searchController.toggleAvailableStore() : searchController.toggleAvailableItems(),
                ),

                CustomCheckBoxWidget(
                  title: 'discounted_items'.tr,
                  value: isStore ? searchController.isDiscountedStore : searchController.isDiscountedItems,
                  onClick: () => isStore ? searchController.toggleDiscountedStore() : searchController.toggleDiscountedItems(),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                const Divider(),

                // Price Section
                if(!isStore) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text('price'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('from'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '${searchController.lowerValue.toInt()} ${Get.find<SplashController>().configModel!.currencySymbol}',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                      ),
                    ])),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('to'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '${searchController.upperValue.toInt()} ${Get.find<SplashController>().configModel!.currencySymbol}',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                      ),
                    ])),
                  ]),

                  RangeSlider(
                    values: RangeValues(searchController.lowerValue, searchController.upperValue),
                    max: maxValue!.toInt().toDouble(), min: 0,
                    divisions: maxValue!.toInt() > 0 ? maxValue!.toInt() : 1,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                    onChanged: (RangeValues rangeValues) => searchController.setLowerAndUpperValue(rangeValues.start, rangeValues.end),
                  ),
                  const Divider(),
                ],

                // Sort By Section
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text('sort_by'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      bool isFull = isStore ? searchController.storeRating >= (index + 1) : searchController.rating >= (index + 1);
                      return InkWell(
                        onTap: () => isStore ? searchController.setStoreRating(index + 1) : searchController.setRating(index + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                          child: Icon(
                            isFull ? Icons.star : Icons.star_border,
                            size: 35,
                            color: isFull ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                const SizedBox(height: Dimensions.paddingSizeLarge),

              ]),
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: ElevatedButton(
              onPressed: () {
                if(isStore) {
                  searchController.sortStoreSearchList();
                }else {
                  searchController.sortItemSearchList();
                }
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              child: Text(
                '${'apply_filters'.tr} (${(isStore ? searchController.searchStoreList?.length : searchController.searchItemList?.length) ?? 0} ${'items'.tr})',
                style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
              ),
            ),
          ),

        ]);
      }),
    );
  }
}
