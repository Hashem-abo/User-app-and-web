import 'package:carousel_slider/carousel_slider.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/sliver_delegate.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  final bool isSubSub;
  const CategoryItemScreen({super.key, required this.categoryID, required this.categoryName, this.isSubSub = false});

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CategoryController>().getCategoryDetails(widget.categoryID!);
      if(!widget.isSubSub) {
        Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
      }

      Get.find<CategoryController>().getCategoryStoreList(
        widget.categoryID, 1, Get.find<CategoryController>().type, false,
      );
      Get.find<CategoryController>().getCategoryItemList(
        widget.categoryID, 1, Get.find<CategoryController>().type, false,
      );
    });
  }

  @override
  void dispose() {
    Get.find<CategoryController>().clearCategoryItemList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item;
      List<Store>? stores;
      if(catController.isSearching ? catController.searchItemList != null : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }
      if(catController.isSearching ? catController.searchStoreList != null : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if(catController.isSearching) {
            catController.toggleSearch();
          }else {
            return;
          }
        },
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : AppBar(
            backgroundColor: Theme.of(context).cardColor,
            surfaceTintColor: Theme.of(context).cardColor,
            shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
            elevation: 2,
            title: catController.isSearching ? SizedBox(
              height: 45,
              child: TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    borderSide: BorderSide(color: Theme.of(context).disabledColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    borderSide: BorderSide(color: Theme.of(context).disabledColor),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => catController.toggleSearch(),
                    icon: Icon(
                      catController.isSearching ? Icons.close_sharp : Icons.search,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ),
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                onSubmitted: (String query) {
                  catController.searchData(
                    query, catController.subCategoryIndex == 0 ? widget.categoryID
                      : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                    catController.type,
                  );
                }
              ),
            ) : Text(widget.categoryName, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color,
            )),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if(catController.isSearching) {
                  catController.toggleSearch();
                }else {
                  Get.back();
                }
              },
            ),
            actions: [

              !catController.isSearching ? IconButton(
                onPressed: () => catController.toggleSearch(),
                icon: Icon(
                  catController.isSearching ? Icons.close_sharp : Icons.search,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ) : const SizedBox(),

              IconButton(
                onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                icon: CartWidget(color: Theme.of(context).textTheme.bodyLarge!.color, size: 25),
              ),

              VegFilterWidget(type: catController.type, fromAppBar: true, onSelected: (String type) {
                if(catController.isSearching) {
                  catController.searchData(
                    catController.subCategoryIndex == 0 ? widget.categoryID
                        : catController.subCategoryList![catController.subCategoryIndex].id.toString(), '1', type,
                  );
                }else {
                  if(catController.isStore) {
                    catController.getCategoryStoreList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                    );
                  }else {
                    catController.getCategoryItemList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                    );
                  }
                }
              }),

              const SizedBox(width: Dimensions.paddingSizeSmall),
            ],
          )),
          endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          body: ResponsiveHelper.isDesktop(context) ? SingleChildScrollView(
            child: FooterView(
              child: Center(child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(children: [

                  // Web Banners
                    if(catController.categoryModel != null && catController.categoryModel!.bannersFullUrl != null && catController.categoryModel!.bannersFullUrl!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                      height: 300,
                      child: CarouselSlider.builder(
                        itemCount: catController.categoryModel!.bannersDetails != null ? catController.categoryModel!.bannersDetails!.length : catController.categoryModel!.bannersFullUrl!.length,
                        itemBuilder: (context, index, realIndex) {
                          String? imageUrl;
                          int? id;
                          String? type;
                          if(catController.categoryModel!.bannersDetails != null) {
                            imageUrl = catController.categoryModel!.bannersDetails![index].image;
                            id = catController.categoryModel!.bannersDetails![index].id;
                            type = catController.categoryModel!.bannersDetails![index].type;
                          } else {
                            imageUrl = catController.categoryModel!.bannersFullUrl![index];
                          }
                          return InkWell(
                             onTap: () {
                              if(id != null && type != null) {
                                if(type == 'item') {
                                  Get.toNamed(RouteHelper.getItemDetailsRoute(id, true));
                                } else if(type == 'store') {
                                  Get.toNamed(RouteHelper.getStoreRoute(id: id, page: 'banner'));
                                } else if(type == 'shelf') {
                                  Get.toNamed(RouteHelper.getDynamicShelfItemsRoute(id));
                                }
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              child: CustomImage(
                                image: imageUrl ?? '',
                                fit: BoxFit.cover,
                                width: 1000,
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 1,
                          autoPlayInterval: const Duration(seconds: 5),
                          aspectRatio: 3,
                        ),
                      ),
                    ),


                    // Web Ads Banner
                    if(catController.categoryModel != null && catController.categoryModel!.bannerAdFullUrl != null && catController.categoryModel!.bannerAdFullUrl!.isNotEmpty)
                      InkWell(
                        onTap: () {
                          if(catController.categoryModel!.bannerAdItemId != null) {
                            Get.toNamed(RouteHelper.getItemDetailsRoute(catController.categoryModel!.bannerAdItemId!, true));
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          height: 100,
                          width: Dimensions.webMaxWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              image: catController.categoryModel!.bannerAdFullUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                    (catController.subCategoryList != null && !catController.isSearching)
                      ? Container(
                          height: 70,
                          width: Dimensions.webMaxWidth,
                          color: Theme.of(context).cardColor,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                            itemCount: catController.subCategoryList!.length,
                            itemBuilder: (context, index) {
                              bool showTitle = (catController.categoryModel?.isTitleVisible ?? 1) == 1;
                              return Padding(
                                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                child: InkWell(
                                  onTap: () {
                                    Get.toNamed(RouteHelper.getCategoryItemRoute(
                                      catController.subCategoryList![index].id,
                                      catController.subCategoryList![index].name!,
                                    ))?.then((value) {
                                      if(mounted) {
                                        Get.find<CategoryController>().getCategoryDetails(widget.categoryID!);
                                        if(!widget.isSubSub) {
                                          Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
                                        }
                                        Get.find<CategoryController>().getCategoryStoreList(
                                          widget.categoryID, 1, Get.find<CategoryController>().type, false,
                                        );
                                        Get.find<CategoryController>().getCategoryItemList(
                                          widget.categoryID, 1, Get.find<CategoryController>().type, false,
                                        );
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.3)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 48, width: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).cardColor,
                                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 3, spreadRadius: 1)],
                                          ),
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Transform(
                                              transform: Matrix4.identity()
                                                ..setEntry(3, 2, 0.003)
                                                ..rotateY(0.15)
                                                ..rotateX(-0.08),
                                              alignment: Alignment.center,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(4, 6)),
                                                  ],
                                                ),
                                                child: ClipOval(
                                                  child: CustomImage(
                                                    image: catController.subCategoryList![index].imageFullUrl ?? '',
                                                    height: 40, width: 40, fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (showTitle) const SizedBox(width: Dimensions.paddingSizeSmall),
                                        if (showTitle) Text(
                                          catController.subCategoryList![index].name!,
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          ),
                        ],
                      ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox(),

                  Center(child: Container(
                    width: Dimensions.webMaxWidth,
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
                    labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                    unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall), 
                    labelPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    tabs: [
                      Tab(
                        text: Get.find<SplashController>().module?.moduleType == AppConstants.food
                            ? 'meals'.tr : 'item'.tr,
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        iconMargin: const EdgeInsets.only(bottom: 1),
                      ),
                      Tab(
                        text: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                            ? 'restaurants'.tr : 'stores'.tr,
                        icon: Icon(
                          Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                              ? Icons.restaurant : Icons.storefront,
                          size: 18,
                        ),
                        iconMargin: const EdgeInsets.only(bottom: 1),
                      ),
                    ],
                  ),  ),
                  ),

                  SizedBox(
                    height: 600,
                    child: NotificationListener(
                      onNotification: (dynamic scrollNotification) {
                        return false;
                      },
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          SingleChildScrollView(
                            child: FooterView(
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: item != null ? item.isNotEmpty ? GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                                    mainAxisSpacing: 0,
                                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                                    mainAxisExtent: (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food) ? 255 :340,
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: item.length,
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  itemBuilder: (context, index) {
                                    return ItemCard(
                                      item: item![index],
                                      isPopularItem: false,
                                      isFood: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food,
                                      isShop: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce,
                                    );
                                  },
                                ) : Center(child: Text('no_category_item_found'.tr)) : const Center(child: CustomLoaderWidget()),
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            child: ItemsView(
                              isStore: true, items: null, stores: stores,
                              noDataText: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'no_category_restaurant_found'.tr : 'no_category_store_found'.tr,
                              mobileItemCrossAxisCount: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  catController.isLoading ? const Center(child: Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CustomLoaderWidget(size: 30),
                  )) : const SizedBox(),

                ]),
              )),
            ),
          ) : NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Column(children: [
                    // Mobile Banners
                    if(catController.categoryModel != null && catController.categoryModel!.bannersFullUrl != null && catController.categoryModel!.bannersFullUrl!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: CarouselSlider.builder(
                        itemCount: catController.categoryModel!.bannersDetails != null ? catController.categoryModel!.bannersDetails!.length : catController.categoryModel!.bannersFullUrl!.length,
                        itemBuilder: (context, index, realIndex) {
                          String? imageUrl;
                          int? id;
                          String? type;
                          if(catController.categoryModel!.bannersDetails != null) {
                            imageUrl = catController.categoryModel!.bannersDetails![index].image;
                            id = catController.categoryModel!.bannersDetails![index].id;
                            type = catController.categoryModel!.bannersDetails![index].type;
                          } else {
                            imageUrl = catController.categoryModel!.bannersFullUrl![index];
                          }
                          return InkWell(
                            onTap: () {
                              if(id != null && type != null) {
                                if(type == 'item') {
                                  Get.toNamed(RouteHelper.getItemDetailsRoute(id, true));
                                } else if(type == 'store') {
                                  Get.toNamed(RouteHelper.getStoreRoute(id: id, page: 'banner'));
                                } else if(type == 'shelf') {
                                  Get.toNamed(RouteHelper.getDynamicShelfItemsRoute(id));
                                }
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              child: CustomImage(
                                image: imageUrl ?? '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          aspectRatio: 3,
                          autoPlayInterval: const Duration(seconds: 5),
                        ),
                      ),
                    ),


                    // Mobile Ads Banner
                    if(catController.categoryModel != null && catController.categoryModel!.bannerAdFullUrl != null && catController.categoryModel!.bannerAdFullUrl!.isNotEmpty)
                      InkWell(
                        onTap: () {
                          if(catController.categoryModel!.bannerAdItemId != null) {
                            Get.toNamed(RouteHelper.getItemDetailsRoute(catController.categoryModel!.bannerAdItemId!, true));
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                          height: 50,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              image: catController.categoryModel!.bannerAdFullUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                  ]),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(
                    height: (catController.subCategoryList != null && !catController.isSearching && catController.subCategoryList!.isNotEmpty) ? 120 : 50,
                    child: Container(
                      width: Dimensions.webMaxWidth,
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: [
                          if (catController.subCategoryList != null && !catController.isSearching && catController.subCategoryList!.isNotEmpty)
                            SizedBox(
                              height: 70,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                itemCount: catController.subCategoryList!.length,
                                itemBuilder: (context, index) {
                                  bool showTitle = (catController.subCategoryList![index].isTitleVisible ?? 1) == 1;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                    child: InkWell(
                                      onTap: () {
                                        Get.toNamed(RouteHelper.getCategoryItemRoute(
                                          catController.subCategoryList![index].id,
                                          catController.subCategoryList![index].name!,
                                        ))?.then((value) {
                                          if(mounted) {
                                            Get.find<CategoryController>().getCategoryDetails(widget.categoryID!);
                                            if(!widget.isSubSub) {
                                              Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
                                            }
                                            Get.find<CategoryController>().getCategoryStoreList(
                                              widget.categoryID, 1, Get.find<CategoryController>().type, false,
                                            );
                                            Get.find<CategoryController>().getCategoryItemList(
                                              widget.categoryID, 1, Get.find<CategoryController>().type, false,
                                            );
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(50),
                                          border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.3)),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              height: 48, width: 48,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context).cardColor,
                                                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 3, spreadRadius: 1)],
                                              ),
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.all(4),
                                                child: Transform(
                                                  transform: Matrix4.identity()
                                                    ..setEntry(3, 2, 0.003)
                                                    ..rotateY(0.15)
                                                    ..rotateX(-0.08),
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(4, 6)),
                                                      ],
                                                    ),
                                                    child: ClipOval(
                                                      child: CustomImage(
                                                        image: catController.subCategoryList![index].imageFullUrl ?? '',
                                                        height: 40, width: 40, fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (showTitle) const SizedBox(width: Dimensions.paddingSizeSmall),
                                            if (showTitle) Text(
                                              catController.subCategoryList![index].name!,
                                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          Expanded(
                            child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.white,
                            unselectedLabelColor: Theme.of(context).textTheme.bodyLarge!.color,
                            labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                            unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                            dividerColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall), 
                            labelPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            tabs: [
                              Tab(
                                text: Get.find<SplashController>().module?.moduleType == AppConstants.food
                                    ? 'meals'.tr : 'item'.tr,
                                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                                iconMargin: const EdgeInsets.only(bottom: 1),
                              ),
                              Tab(
                                text: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                                    ? 'restaurants'.tr : 'stores'.tr,
                                icon: Icon(
                                  Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                                      ? Icons.restaurant : Icons.storefront,
                                  size: 18,
                                ),
                                iconMargin: const EdgeInsets.only(bottom: 1),
                              ),
                            ],
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent
                        && Get.find<CategoryController>().categoryItemList != null
                        && !Get.find<CategoryController>().isLoading) {
                      int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
                      if (Get.find<CategoryController>().offset < pageSize) {
                        Get.find<CategoryController>().showBottomLoader();
                        Get.find<CategoryController>().getCategoryItemList(
                          Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                              : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
                          Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
                        );
                      }
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: FooterView(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(children: [
                          item != null ? item.isNotEmpty ? GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                              mainAxisExtent: (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food) ? 255 :340,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: item.length,
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            itemBuilder: (context, index) {
                              return ItemCard(
                                item: item![index],
                                isPopularItem: false,
                                isFood: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food,
                                isShop: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce,
                              );
                            },
                          ) : Center(child: Padding(padding: const EdgeInsets.only(top: 200), child: Text('no_category_item_found'.tr))) : const Center(child: Padding(padding: EdgeInsets.only(top: 200), child: CustomLoaderWidget())),
                          
                           catController.isLoading ? const Center(child: Padding(
                            padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: CustomLoaderWidget(size: 30),
                          )) : const SizedBox(),
                        ]),
                      ),
                    ),
                  ),
                ),

                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent
                        && Get.find<CategoryController>().categoryStoreList != null
                        && !Get.find<CategoryController>().isLoading) {
                      int pageSize = (Get.find<CategoryController>().restPageSize! / 10).ceil();
                      if (Get.find<CategoryController>().offset < pageSize) {
                         Get.find<CategoryController>().showBottomLoader();
                         Get.find<CategoryController>().getCategoryStoreList(
                          Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                              : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
                          Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
                        );
                      }
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: FooterView(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(children: [
                          ItemsView(
                            isStore: true,
                            items: null,
                            stores: stores,
                            noDataText: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'no_category_restaurant_found'.tr : 'no_category_store_found'.tr,
                            mobileItemCrossAxisCount: 2,
                          ),
                           catController.isLoading ? const Center(child: Padding(
                            padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: CustomLoaderWidget(size: 30),
                          )) : const SizedBox(),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
