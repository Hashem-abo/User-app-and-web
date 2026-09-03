import 'package:flutter/cupertino.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/history/controllers/item_history_controller.dart';
import 'package:sixam_mart/features/search/controllers/search_controller.dart' as search;
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/voice_permission_handler.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/search/widgets/filter_widget.dart';
import 'package:sixam_mart/features/search/widgets/search_field_widget.dart';
import 'package:sixam_mart/features/search/widgets/search_result_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/store/widgets/bottom_cart_widget.dart';
import 'package:sixam_mart/features/search/screens/barcode_scanner_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? queryText;
  const SearchScreen({super.key, required this.queryText});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  final TextEditingController _searchController = TextEditingController();
  late bool _isLoggedIn;

  List<String> _itemsAndStors = <String>[];
  bool _showSuggestion = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _isLoggedIn = AuthHelper.isLoggedIn();
    Get.find<search.SearchController>().setSearchMode(true, canUpdate: false);
    Get.find<search.SearchController>().getPopularCategories();
    if(_isLoggedIn) {
      Get.find<search.SearchController>().getSuggestedItems();
    }
    Get.find<search.SearchController>().getHistoryList();
    if(widget.queryText!.isNotEmpty) {
      _searchController.text = widget.queryText!;
      _actionSearch(true, widget.queryText, true);
    }
  }

  Future<void> _searchSuggestions(String query) async {
    _itemsAndStors = [];
    if (query == '') {
      _showSuggestion = false;
      _itemsAndStors = [];
    } else {
      _showSuggestion = true;
      _itemsAndStors = await Get.find<search.SearchController>().getSearchSuggestions(query);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if(Get.find<search.SearchController>().isSearchMode) {
          return;
        }else {
          Get.find<search.SearchController>().setSearchMode(true);
        }
      },
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
        body: SafeArea(child: Padding(
          padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: GetBuilder<search.SearchController>(builder: (searchController) {
            if(!GetPlatform.isWeb) {
              _searchController.text = searchController.searchText!;
            }
            return Column(children: [
              ResponsiveHelper.isDesktop(context) ? Container(
                width : double.infinity,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text('search_items_and_stores'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      SizedBox(width: Dimensions.webMaxWidth, child: GetBuilder<search.SearchController>(builder: (searchController) {
                        return SearchFieldWidget(
                          controller: _searchController,
                          radius: 50,
                          hint: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                              ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                          suffixIcon: searchController.searchHomeText!.isNotEmpty ? Icons.cancel : Icons.keyboard_voice_sharp,
                          iconColor: Theme.of(context).disabledColor,
                          filledColor: Theme.of(context).colorScheme.surface,
                          onChanged: (text) {
                            _searchSuggestions(text);
                            searchController.setSearchText(text);
                          },
                          iconPressed: () async {
                            if(searchController.searchHomeText!.isNotEmpty) {
                              _searchController.text = '';
                              _showSuggestion = false;
                              searchController.setSearchMode(true);
                              searchController.clearSearchHomeText();
                            }else {
                              // searchData();
                              await VoicePermissionHandler.openVoiceSearch(
                                context: context,
                                searchTextEditingController: _searchController,
                                isDesktop: ResponsiveHelper.isDesktop(context),
                              );
                            }
                          },
                          showCamera: true,
                          onCameraTap: () => searchController.searchByImage(true),
                          showAiMic: true,
                          onAiMicTap: () async {
                              await VoicePermissionHandler.openVoiceSearch(
                                context: context,
                                searchTextEditingController: _searchController,
                                isDesktop: ResponsiveHelper.isDesktop(context),
                                isAi: true,
                              );
                          },
                          showBarcode: true,
                          onBarcodeTap: () => _openBarcodeScanner(context, searchController, true),
                          onSubmit: (text) => searchData(),
                        );
                      })),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      !searchController.isSearchMode ?
                      Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 200,
                                color: Colors.transparent,
                                child: TabBar(
                                  tabAlignment: TabAlignment.start,
                                  controller: _tabController,
                                  indicatorColor: Theme.of(context).primaryColor,
                                  indicatorWeight: 3,
                                  labelColor: Theme.of(context).primaryColor,
                                  unselectedLabelColor: Theme.of(context).disabledColor,
                                  unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                  labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                  labelPadding: const EdgeInsets.symmetric(horizontal: Dimensions.radiusDefault, vertical: 0 ),
                                  isScrollable: true,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  tabs: [
                                    Tab(text: Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText == true
                                        ? 'meals'.tr : 'item'.tr),
                                    Tab(text: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants'.tr : 'stores'.tr),
                                  ],
                                ),
                              ),
                              
                              InkWell(
                                onTap: () {
                                  _actionSearch(false, _searchController.text.trim(), false);
                                },
                                child: Image.asset(Images.filter, height: 28, width: 28))
                            ],
                          )
                        ),
                      ) : const SizedBox(),
                    ],
                  ),
                ),
              ) : const SizedBox(),

              Center(child: ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: Get.find<ThemeController>().darkTheme ? Colors.black12 : Theme.of(context).cardColor,
                  boxShadow: Get.find<ThemeController>().darkTheme ? null : [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 3, offset: const Offset(0, 5))]
                ),
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(children: [

                IconButton(
                  onPressed: (){
                    if(searchController.isSearchMode) {
                      Get.back();
                    } else {
                      _showSuggestion = false;
                      searchController.setSearchMode(true);
                      searchController.setStore(false);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),

                Expanded(child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 3),
                      )
                    ],
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 1),
                  ),
                  child: SearchFieldWidget(
                    controller: _searchController,
                    radius: 40,
                    filledColor: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                    hint: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                        ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                    suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : Icons.keyboard_voice_sharp,
                    prefixIcon: CupertinoIcons.search,
                    iconPressed: () async {
                      if(_searchController.text.isNotEmpty) {
                        _showSuggestion = false;
                        searchController.setSearchMode(true);
                        searchController.setStore(false);
                        if(GetPlatform.isWeb) {
                          _searchController.text = '';
                        }
                      } else {
                        await VoicePermissionHandler.openVoiceSearch(
                          context: context,
                          searchTextEditingController: _searchController,
                          isDesktop: ResponsiveHelper.isDesktop(context),
                        );
                      }

                    },
                    onChanged: (text) {
                      searchController.setSearchText(text);
                      _searchSuggestions(text);
                      // _searchController.text = searchController.searchText!;
                    },
                    onSubmit: (text) => _actionSearch(true, _searchController.text.trim(), false),
                    showCamera: true,
                    onCameraTap: () => searchController.searchByImage(false),
                    showAiMic: true,
                    onAiMicTap: () async {
                        await VoicePermissionHandler.openVoiceSearch(
                          context: context,
                          searchTextEditingController: _searchController,
                          isDesktop: ResponsiveHelper.isDesktop(context),
                          isAi: true,
                        );
                    },
                    showBarcode: true,
                    onBarcodeTap: () => _openBarcodeScanner(context, searchController, false),
                  ),
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),
              ]))),

              Expanded(child: searchController.isSearchMode ? _showSuggestion ? showSuggestions(
                context, searchController, _itemsAndStors,
                            ) : SingleChildScrollView(
                padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: FooterView(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: GetBuilder<ItemHistoryController>(builder: (itemHistoryController) {
                      final bool isLtr = Get.find<LocalizationController>().isLtr;
                      final bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
                      final double cardHeight = isFood ? 235 :340;
                      final double containerHeight = isFood ? 245  :350;

                      // Helper for section headers
                      Widget buildSectionHeader(String title, VoidCallback? onTap, {String? actionText}) {
                        return Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                              ),
                              if (onTap != null)
                                InkWell(
                                  onTap: onTap,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    child: Text(
                                      actionText ?? 'view_all'.tr,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: Suggestions
                          if (_isLoggedIn && searchController.suggestedItemList != null && searchController.suggestedItemList!.isNotEmpty) ...[
                            buildSectionHeader('suggestions'.tr, () {
                              Get.toNamed(RouteHelper.getItemViewAllScreen(true, false));
                            }),
                             SizedBox(
                              height: containerHeight,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: searchController.suggestedItemList!.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: isLtr ? 0 : Dimensions.paddingSizeSmall,
                                      right: isLtr ? Dimensions.paddingSizeSmall : 0,
                                    ),
                                    child: SizedBox(
                                      height: cardHeight, width: 180,
                                      child: ItemCard(
                                        item: searchController.suggestedItemList![index],
                                        isShop: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'ecommerce',
                                        isFood: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // SECTION 2: Recent Searches
                          if (searchController.historyList.isNotEmpty) ...[
                            buildSectionHeader(
                              'recent_searches'.tr,
                              () {
                                searchController.clearSearchHistory();
                              },
                              actionText: 'clear_all'.tr,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).disabledColor.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: ListView.separated(
                                itemCount: searchController.historyList.length > 3 ? 3 : searchController.historyList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) => Divider(
                                  color: Theme.of(context).disabledColor.withOpacity(0.15),
                                  height: 1,
                                  indent: Dimensions.paddingSizeDefault,
                                  endIndent: Dimensions.paddingSizeDefault,
                                ),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () => searchController.searchData(searchController.historyList[index], false),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeDefault,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_outlined,
                                            size: 20,
                                            color: Theme.of(context).disabledColor,
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),
                                          Expanded(
                                            child: Text(
                                              searchController.historyList[index],
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeDefault,
                                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            Icons.north_west_rounded,
                                            color: Theme.of(context).primaryColor,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // SECTION 3: Most Searched
                          if (searchController.popularCategoryList != null && searchController.popularCategoryList!.isNotEmpty) ...[
                            buildSectionHeader('most_searched'.tr, null),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).disabledColor.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: ListView.separated(
                                itemCount: searchController.popularCategoryList!.length > 3 ? 3 : searchController.popularCategoryList!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) => Divider(
                                  color: Theme.of(context).disabledColor.withOpacity(0.15),
                                  height: 1,
                                  indent: Dimensions.paddingSizeDefault,
                                  endIndent: Dimensions.paddingSizeDefault,
                                ),
                                itemBuilder: (context, index) {
                                  final category = searchController.popularCategoryList![index];
                                  return InkWell(
                                    onTap: () {
                                      _searchController.text = category?.name ?? '';
                                      searchController.searchData(category?.name ?? '', false);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeDefault,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_outlined,
                                            size: 20,
                                            color: Theme.of(context).disabledColor,
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),
                                          Expanded(
                                            child: Text(
                                              category?.name ?? '',
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeDefault,
                                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            Icons.north_west_rounded,
                                            color: Theme.of(context).primaryColor,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // SECTION 4: Recently Viewed (آخر ما تم مشاهدته)
                          Builder(builder: (context) {
                            final int? currentModuleId = Get.find<SplashController>().module?.id;
                            final recentlyViewedItems = itemHistoryController.recentlyViewedList
                                .where((item) => item.moduleId == currentModuleId)
                                .toList();

                            if (!itemHistoryController.isHistoryEnabled || recentlyViewedItems.isEmpty) return const SizedBox();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildSectionHeader('recently_viewed'.tr, () {
                                  Get.offAllNamed('${RouteHelper.getMainRoute('favourite')}&tab=history');
                                }),
                                SizedBox(
                                  height: containerHeight,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: recentlyViewedItems.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: isLtr ? 0 : Dimensions.paddingSizeSmall,
                                          right: isLtr ? Dimensions.paddingSizeSmall : 0,
                                        ),
                                        child: SizedBox(
                                          height: cardHeight, width: 180,
                                          child: ItemCard(
                                            item: recentlyViewedItems[index],
                                            isShop: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'ecommerce',
                                            isFood: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }),

                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],
                      );
                    }),
                  ),
                ),
              ) : SearchResultWidget(searchText: _searchController.text.trim(), tabController: ResponsiveHelper.isDesktop(context) ? _tabController : null)),
            ]);
          }),
        )),

        bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
        })
      ),
    );
  }

  void searchData() {
    bool isService = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType == 'services';
    if (_searchController.text.trim().isEmpty) {
      showCustomSnackBar(isService ? 'search_service_or_provider'.tr : (Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
        ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr));
    } else {
      _actionSearch(true, _searchController.text, true);
    }
  }

  void _actionSearch(bool isSubmit, String? queryText, bool fromHome) {
    bool isService = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType == 'services';
    if(Get.find<search.SearchController>().isSearchMode || isSubmit) {
      if(queryText!.isNotEmpty) {
        Get.find<search.SearchController>().searchData(queryText, fromHome);
      } else {
        showCustomSnackBar(isService ? 'search_service_or_provider'.tr : (Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
            ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr));
      }
    } else {
      List<double?> prices = [];
      if(!Get.find<search.SearchController>().isStore) {
        for (var product in Get.find<search.SearchController>().allItemList!) {
          prices.add(product.price);
        }
        prices.sort();
      }
      double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;
      Get.bottomSheet(FilterWidget(maxValue: maxValue, isStore: Get.find<search.SearchController>().isStore), isScrollControlled: true);
    }
  }


  Future<void> _openBarcodeScanner(BuildContext context, search.SearchController searchController, bool fromHome) async {
    final barcodeValue = await Get.to(() => const BarcodeScannerScreen());
    if (barcodeValue != null && barcodeValue is String && barcodeValue.isNotEmpty) {
      _searchController.text = barcodeValue;
      _showSuggestion = false;
      _actionSearch(true, barcodeValue, fromHome);
    }
  }

  Widget showSuggestions(BuildContext context, search.SearchController searchController, List<String> foodsAndRestaurants) {
    return SingleChildScrollView(
      child: FooterView(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: foodsAndRestaurants.isNotEmpty ? ListView.builder(
            itemCount: foodsAndRestaurants.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final item = foodsAndRestaurants[index];
              final searchQuery = _searchController.text.trim();

              if(searchQuery.isNotEmpty && item.toLowerCase().contains(searchQuery.toLowerCase())){
                final startIndex = item.toLowerCase().indexOf(searchQuery.toLowerCase());
                final prefix = item.substring(0, startIndex);
                final suffix = item.substring(startIndex + searchQuery.length);
                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: prefix,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                        ),
                        TextSpan(
                          text: prefix.isEmpty ? searchQuery.capitalizeFirst : searchQuery,
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                        ),
                        TextSpan(
                          text: suffix,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(Icons.north_west_rounded, color: Theme.of(context).disabledColor),
                  leading: Icon(Icons.search,color: Theme.of(context).disabledColor),
                  onTap: (){
                    FocusScope.of(context).unfocus();
                    _searchController.text = foodsAndRestaurants[index];
                    _actionSearch(true, _searchController.text.trim(), false);
                  },
                );

              }
              return ListTile(
                title: Text(foodsAndRestaurants[index], style: robotoRegular,),
                leading: Icon(CupertinoIcons.search, color: Theme.of(context).disabledColor),
                trailing: Icon(Icons.north_west, color: Theme.of(context).disabledColor),
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  _searchController.text = foodsAndRestaurants[index];
                  _actionSearch(true, _searchController.text.trim(), false);
                },
              );
            },
          ) : Padding(
            padding: EdgeInsets.only(top: context.height * 0.2),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CustomAssetImageWidget(Images.emptyBox, height: 100, width: 100),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('no_suggestions_found'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
            ]),
          ),
        ),
      ),
    );
  }

}
