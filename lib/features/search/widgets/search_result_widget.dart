import 'package:sixam_mart/features/search/controllers/search_controller.dart' as search;
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/search/widgets/filter_widget.dart';
import 'package:sixam_mart/features/search/widgets/sort_widget.dart';
import 'package:sixam_mart/features/search/widgets/item_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultWidget extends StatefulWidget {
  final String searchText;
  final TabController? tabController;
  const SearchResultWidget({super.key, required this.searchText, this.tabController});

  @override
  SearchResultWidgetState createState() => SearchResultWidgetState();
}

class SearchResultWidgetState extends State<SearchResultWidget> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if(widget.tabController != null){
      _tabController = widget.tabController;
    } else {
      _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      GetBuilder<search.SearchController>(builder: (searchController) {
        bool isNull = true;
        int length = 0;
        bool isService = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType == 'services';

        if (isService) {
          final serviceController = Get.find<ServiceController>();
          if(searchController.isStore) {
            isNull = serviceController.searchProvidersList == null;
            if(!isNull) {
              length = serviceController.searchProvidersList!.length;
            }
          } else {
            isNull = serviceController.searchServicesList == null;
            if(!isNull) {
              length = serviceController.searchServicesList!.length;
            }
          }
        } else {
          if(searchController.isStore) {
            isNull = searchController.searchStoreList == null;
            if(!isNull) {
              length = searchController.searchStoreList!.length;
            }
          }else {
            isNull = searchController.searchItemList == null;
            if(!isNull) {
              length = searchController.searchItemList!.length;
            }
          }
        }
        return isNull ? const SizedBox() : Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                  length.toString(),
                  style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(child: Text(
                  'results_found'.tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                )),
              ]),
              
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              
              // Horizontal Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context, 
                      'sort'.tr, 
                      Icons.sort, 
                      onTap: () => _openSortDialog(context),
                      isSelected: searchController.sortIndex != -1,
                    ),
                    _buildFilterChip(
                      context, 
                      'price'.tr, 
                      Icons.attach_money, 
                      onTap: () => _openFilterDialog(context),
                      isSelected: searchController.lowerValue > 0 || searchController.upperValue > 0,
                    ),
                    _buildFilterChip(
                      context, 
                      'rating'.tr, 
                      Icons.star_border, 
                      onTap: () => _openFilterDialog(context),
                      isSelected: searchController.rating != -1,
                    ),
                    if (!searchController.isStore) _buildFilterChip(
                      context, 
                      'filter'.tr, 
                      Icons.filter_alt_outlined, 
                      onTap: () => _openFilterDialog(context),
                      isSelected: searchController.veg || searchController.nonVeg || searchController.isAvailableItems || searchController.isDiscountedItems,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )));
      }),

      ResponsiveHelper.isDesktop(context) ? const SizedBox() :
      Center(child: Container(
        width: Dimensions.webMaxWidth, height: 40,
        color: Theme.of(context).cardColor,
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).textTheme.bodyLarge!.color,
          labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
          unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4), 
          labelPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
          tabs: [
            Tab(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.shopping_bag_outlined, size: 14),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType == 'services'
                    ? 'services'.tr
                    : (Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText == true
                        ? 'meals'.tr : 'item'.tr)),
              ]),
            ),
            Tab(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                    ? Icons.restaurant : Icons.storefront, size: 14),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                    ? 'restaurants'.tr : (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType == 'services' ? 'service_providers'.tr : 'stores'.tr)),
              ]),
            ),
          ],
        ),
      )),

      Expanded(child: NotificationListener(
        onNotification: (dynamic scrollNotification) {
          if (scrollNotification is ScrollEndNotification && scrollNotification.metrics.axis == Axis.horizontal) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.find<search.SearchController>().setStore(_tabController!.index == 1);
              Get.find<search.SearchController>().searchData(widget.searchText, false);
            });
          }
          return false;
        },
        child: TabBarView(
          controller: _tabController,
          children: const [
            ItemViewWidget(isItem: true),
            ItemViewWidget(isItem: false),
          ],
        ),
      )),

    ]);
  }

  void _openSortDialog(BuildContext context) {
    final searchController = Get.find<search.SearchController>();
    Get.bottomSheet(SortWidget(isStore: searchController.isStore), isScrollControlled: true);
  }

  void _openFilterDialog(BuildContext context) {
    List<double?> prices = [];
    final searchController = Get.find<search.SearchController>();
    if(!searchController.isStore) {
      if (searchController.allItemList != null) {
        for (var product in searchController.allItemList!) {
          prices.add(product.price);
        }
      }
      prices.sort();
    }
    double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;
    Get.bottomSheet(FilterWidget(maxValue: maxValue, isStore: searchController.isStore), isScrollControlled: true);
  }

  Widget _buildFilterChip(BuildContext context, String label, IconData icon, {required VoidCallback onTap, bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                label,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Icon(Icons.keyboard_arrow_down, size: 16, color: Theme.of(context).disabledColor),
            ],
          ),
        ),
      ),
    );
  }
}
