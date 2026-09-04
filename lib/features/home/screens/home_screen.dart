import 'package:flutter/cupertino.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/service/widgets/service_provider_widget.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'dart:async'; // + ahmed
import 'package:flutter/rendering.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/brands/controllers/brands_controller.dart';
import 'package:sixam_mart/features/home/controllers/advertisement_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/shelf/controllers/shelf_controller.dart';
import 'package:sixam_mart/features/home/controllers/store_corner_controller.dart';
import 'package:sixam_mart/features/home/widgets/all_store_filter_widget.dart';
import 'package:sixam_mart/features/home/widgets/cashback_logo_widget.dart';
import 'package:sixam_mart/features/home/widgets/cashback_dialog_widget.dart';
import 'package:sixam_mart/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/home/screens/modules/food_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/grocery_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/pharmacy_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/shop_home_screen.dart';
import 'package:sixam_mart/features/service/screens/service_screen.dart';
import 'package:sixam_mart/features/reels/controllers/reels_controller.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/home/screens/taxi_home_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/home/screens/web_new_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/module_view.dart';
import 'package:sixam_mart/features/parcel/screens/parcel_category_screen.dart';
import 'package:sixam_mart/features/redesign_feature/parcel/screens/parcel_module_screen.dart';
import 'package:sixam_mart/features/home/widgets/horizontal_module_view.dart'; // + ahmed
import 'package:sixam_mart/features/home/widgets/module_sticky_delegate.dart'; // + ahmed
import 'package:sixam_mart/features/home/widgets/views/national_products_view.dart'; // + ahmed
import 'package:sixam_mart/features/home/widgets/views/national_products_filter_widget.dart'; // + ahmed
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/store/widgets/prescription_store_bottom_sheet_widget.dart';
import 'package:sixam_mart/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
    // Phase 1: Critical Core Data — fire zone sync & user info in parallel
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: fromModule);
    await Future.wait([
      Get.find<LocationController>().syncZoneData(),
      if (AuthHelper.isLoggedIn()) Get.find<ProfileController>().getUserInfo(),
    ]);

    // Query the aggregated homepage endpoint to prefetch modules, banners, categories, shelves, corners, campaigns in one call
    await Get.find<HomeController>().getHomepageData();

    if (Get.find<SplashController>().module == null &&
        Get.find<SplashController>().configModel!.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      if (AuthHelper.isLoggedIn()) {
        Get.find<AddressController>().getAddressList();
      }
    }

    if (Get.find<SplashController>().module != null &&
        !Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .isParcel! &&
        !Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .isTaxi!) {
      // Banners, categories, shelves, store corners, campaigns are already loaded and populated into their controllers via getHomepageData()!

      // Phase 3a: Below-the-fold data that isn't aggregated (ads, stores list)
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.find<AdvertisementController>().getAdvertisementList();
        Get.find<StoreController>().getStoreList(1, reload);
        Get.find<ReelsController>().getReelsList(offset: 1);
      });

      if (Get.find<SplashController>().module!.moduleType.toString() ==
          AppConstants.grocery) {
        Get.find<FlashSaleController>().getFlashSale(reload, false);
      }
      if (Get.find<SplashController>().module!.moduleType.toString() ==
          AppConstants.ecommerce) {
        Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
        Get.find<FlashSaleController>().getFlashSale(reload, false);
        Get.find<BrandsController>().getBrandList();
      }

      if (Get.find<SplashController>().module!.moduleType.toString() ==
          AppConstants.pharmacy) {
        Get.find<ItemController>().getBasicMedicine(reload, false);
        Get.find<ItemController>().getCommonConditions(false).then((_) {
          if (Get.find<ItemController>().commonConditions != null &&
              Get.find<ItemController>().commonConditions!.isNotEmpty) {
            Get.find<ItemController>().getConditionsWiseItem(
                Get.find<ItemController>().commonConditions![0].id!, false);
          }
        });
      }

      // Phase 3b: user-specific / heavy data (delayed further)
      if (AuthHelper.isLoggedIn()) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.find<NotificationController>().getNotificationList(reload);
          Get.find<CouponController>().getCouponList();
          Get.find<StoreController>()
              .getVisitAgainStoreList(fromModule: fromModule);
        });
      }
    }
  }

  static Future<void> refreshAllData() async {
    SplashController splashController = Get.find<SplashController>();
    bool isGrocery = splashController.module != null &&
        splashController.module!.moduleType.toString().trim().toLowerCase() ==
            AppConstants.grocery;
    bool isPharmacy = splashController.module != null &&
        splashController.module!.moduleType.toString().trim().toLowerCase() ==
            AppConstants.pharmacy;
    bool isShop = splashController.module != null &&
        splashController.module!.moduleType.toString().trim().toLowerCase() ==
            AppConstants.ecommerce;
    bool isTaxi = splashController.module != null &&
        splashController.module!.moduleType.toString().trim().toLowerCase() ==
            AppConstants.taxi;
    bool isParcel = splashController.module != null &&
        splashController.module!.moduleType.toString().trim().toLowerCase() ==
            AppConstants.parcel;

    splashController.setRefreshing(true);
    if (splashController.module != null && !isTaxi) {
      await Get.find<LocationController>().syncZoneData();
      await Get.find<HomeController>()
          .getHomepageData(); // Unified fetch for banners, categories, campaigns, shelves, corners, etc.

      if (isGrocery) {
        await Get.find<FlashSaleController>().getFlashSale(true, true);
      }
      await Get.find<ItemController>().getDiscountedItemList(offset: '1');
      await Get.find<StoreController>().getPopularStoreList(true, 'all', false);
      await Get.find<ItemController>().getPopularItemList(offset: '1');
      await Get.find<StoreController>().getLatestStoreList(true, 'all', false);
      await Get.find<StoreController>().getTopOfferStoreList(true, false);
      await Get.find<ItemController>().getReviewedItemList(offset: '1');
      await Get.find<StoreController>().getStoreList(1, true);
      Get.find<AdvertisementController>().getAdvertisementList();
      if (AuthHelper.isLoggedIn()) {
        await Get.find<ProfileController>().getUserInfo();
        await Get.find<NotificationController>().getNotificationList(true);
        Get.find<CouponController>().getCouponList();
      }
      if (isPharmacy) {
        Get.find<ItemController>().getBasicMedicine(true, true);
        Get.find<ItemController>().getCommonConditions(true);
      }
      if (isShop) {
        await Get.find<FlashSaleController>().getFlashSale(true, true);
        Get.find<ItemController>().getFeaturedCategoriesItemList(true, true);
        Get.find<BrandsController>().getBrandList();
      }
      if (isParcel) {
        await Get.find<ParcelController>().getParcelCategoryList();
        await Get.find<BannerController>().getParcelOtherBannerList(true);
        await Get.find<ParcelController>().getWhyChooseDetails();
        await Get.find<ParcelController>().getVideoContentDetails();
      }
    } else if (isTaxi) {
      await Get.find<TaxiHomeController>().getTaxiBannerList(true);
      await Get.find<TaxiHomeController>().getTopRatedCarList(1, true);
      if (AuthHelper.isLoggedIn()) {
        await Get.find<AddressController>().getAddressList();
        await Get.find<TaxiHomeController>().getTaxiCouponList(true);
        await Get.find<TaxiCartController>().getCarCartList();
      }
    } else {
      await Get.find<BannerController>().getFeaturedBanner();
      await splashController.getModules();
      if (AuthHelper.isLoggedIn()) {
        await Get.find<AddressController>().getAddressList();
      }
      await Get.find<StoreController>().getFeaturedStoreList();
    }
    splashController.setRefreshing(false);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late final ScrollController _expandedModuleController;
  late final ScrollController _collapsedModuleController;
  bool _isSyncing = false;
  bool _showBackToTop = false;
  bool searchBgShow = false;
  final GlobalKey _headerKey = GlobalKey();
  Timer? _timer;
  int _currentHintIndex = 0;
  final bool _firstTimeSubModuleLoaded = true;
  int? _currentModuleId;
  final GlobalKey _exploreFilterKey = GlobalKey();
  double _appBarRatio = 1.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _expandedModuleController = ScrollController();
    _collapsedModuleController = ScrollController();

    _expandedModuleController.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      if (_collapsedModuleController.hasClients && _expandedModuleController.hasClients) {
        double maxExpanded = _expandedModuleController.position.maxScrollExtent;
        double maxCollapsed = _collapsedModuleController.position.maxScrollExtent;
        if (maxExpanded > 0) {
          double ratio = _expandedModuleController.offset / maxExpanded;
          _collapsedModuleController.jumpTo((ratio * maxCollapsed).clamp(0.0, maxCollapsed));
        }
      }
      _isSyncing = false;
    });

    _collapsedModuleController.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      if (_expandedModuleController.hasClients && _collapsedModuleController.hasClients) {
        double maxExpanded = _expandedModuleController.position.maxScrollExtent;
        double maxCollapsed = _collapsedModuleController.position.maxScrollExtent;
        if (maxCollapsed > 0) {
          double ratio = _collapsedModuleController.offset / maxCollapsed;
          _expandedModuleController.jumpTo((ratio * maxExpanded).clamp(0.0, maxExpanded));
        }
      }
      _isSyncing = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Only rebuild if widget is still active (mounted guard)
      if (mounted) {
        setState(() {
          _currentHintIndex++;
        });
      }
    });

    HomeScreen.loadData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();

      if ((Get.find<ProfileController>().userInfoModel?.isValidForDiscount ??
              false) &&
          Get.find<SplashController>().showReferBottomSheet) {
        _showReferBottomSheet();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > 1000) {
        if (!_showBackToTop) {
          setState(() => _showBackToTop = true);
        }
      } else {
        if (_showBackToTop) {
          setState(() => _showBackToTop = false);
        }
      }
      bool isAggregatedModule = Get.find<SplashController>().module?.showNationalProducts ?? false;
      if (isAggregatedModule) {
        final context = _exploreFilterKey.currentContext;
        if (context != null) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero);
            double paddingTop = MediaQuery.of(context).padding.top;
            double appBarBottom = 60.0 + 50.0 + paddingTop;
            double distance = position.dy - appBarBottom;
            double ratio = 1.0;
            if (distance < 0) {
              double overlap = -distance;
              ratio = ((50.0 - overlap) / 50.0).clamp(0.0, 1.0);
            }
            // Only setState when ratio changes meaningfully (threshold = 0.02)
            // Prevents rebuilding on every micro-scroll tick
            if ((ratio - _appBarRatio).abs() > 0.02) {
              setState(() {
                _appBarRatio = ratio;
              });
            }
          }
        }
      } else {
        if (_appBarRatio != 1.0) {
          setState(() {
            _appBarRatio = 1.0;
          });
        }
      }

      int? currentModuleId = Get.find<SplashController>().module?.id;
      if (currentModuleId != null) {
        Get.find<HomeController>()
            .saveScrollOffset(currentModuleId, _scrollController.offset);
      }

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        if (Get.find<ShelfController>().shelfList != null &&
            !Get.find<ShelfController>().isLoading &&
            (Get.find<ShelfController>().pageSize == null ||
                Get.find<ShelfController>().shelfList!.length <
                    Get.find<ShelfController>().pageSize!)) {
          Get.find<ShelfController>().getShelfList(false);
        }
        if (Get.find<StoreCornerController>().storeCornerList != null &&
            !Get.find<StoreCornerController>().isLoading &&
            (Get.find<StoreCornerController>().pageSize == null ||
                Get.find<StoreCornerController>().storeCornerList!.length <
                    Get.find<StoreCornerController>().pageSize!)) {
          Get.find<StoreCornerController>().getStoreCornerList(false);
        }
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
        }
      } else {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
              () => Get.find<HomeController>().changeFavVisibility());
        }
      }
    });
  }

  @override
  void dispose() {
    _expandedModuleController.dispose();
    _collapsedModuleController.dispose();
    super.dispose();
    _scrollController.dispose();
    _timer?.cancel();
  }

  void _scrollToSelectedModule(SplashController splashController) {
    if (splashController.module != null && splashController.moduleList != null) {
      int selectedIndex = splashController.moduleList!.indexWhere((m) =>
          m.id == splashController.module!.id ||
          (m.moduleType != null && m.moduleType == splashController.module!.moduleType));
      if (selectedIndex >= 0) {
        double expandedOffset = 0;
        for (int i = 0; i < selectedIndex; i++) {
          double buttonWidth = splashController.moduleList![i].moduleButtonWidth ?? 65;
          expandedOffset += buttonWidth + Dimensions.paddingSizeSmall;
        }
        double collapsedOffset = selectedIndex * 112.0; // 100 width + 12 padding

        _isSyncing = true;
        if (_expandedModuleController.hasClients) {
          _expandedModuleController.jumpTo(expandedOffset.clamp(0.0, _expandedModuleController.position.maxScrollExtent));
        }
        if (_collapsedModuleController.hasClients) {
          _collapsedModuleController.jumpTo(collapsedOffset.clamp(0.0, _collapsedModuleController.position.maxScrollExtent));
        }
        _isSyncing = false;
      }
    }
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context)
        ? Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge)),
              insetPadding: const EdgeInsets.all(22),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: const ReferBottomSheetWidget(),
            ),
            useSafeArea: false,
          ).then((value) =>
            Get.find<SplashController>().saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
            isScrollControlled: true,
            useRootNavigator: true,
            context: Get.context!,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                  topRight: Radius.circular(Dimensions.radiusExtraLarge)),
            ),
            builder: (context) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: const ReferBottomSheetWidget(),
              );
            },
          ).then((value) =>
            Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  Future<void> loadTaxiApis() async {
    await Get.find<TaxiHomeController>().getTaxiBannerList(true);
    await Get.find<TaxiHomeController>().getTopRatedCarList(1, true);
    if (AuthHelper.isLoggedIn()) {
      await Get.find<AddressController>().getAddressList();
      await Get.find<TaxiHomeController>().getTaxiCouponList(true);
      await Get.find<TaxiCartController>().getCarCartList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      int? newModuleId = splashController.module?.id;
      if (newModuleId != _currentModuleId) {
        _currentModuleId = newModuleId;
        _appBarRatio = 1.0;
        if (newModuleId != null) {
          double offset =
              Get.find<HomeController>().getScrollOffset(newModuleId);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(offset);
            }
            _scrollToSelectedModule(splashController);
          });
        }
      }

      bool showMobileModule = !ResponsiveHelper.isDesktop(context) &&
          splashController.module == null &&
          splashController.configModel!.module == null;
      bool isParcel = splashController.module != null &&
          splashController.module!.moduleType.toString().trim().toLowerCase() ==
              AppConstants.parcel;
      bool isPharmacy = splashController.module != null &&
          splashController.module!.moduleType.toString().trim().toLowerCase() ==
              AppConstants.pharmacy;
      bool isFood = splashController.module != null &&
          splashController.module!.moduleType.toString().trim().toLowerCase() ==
              AppConstants.food;
      bool isShop = splashController.module != null &&
          splashController.module!.moduleType.toString().trim().toLowerCase() ==
              AppConstants.ecommerce;
      bool isGrocery = splashController.module != null &&
          splashController.module!.moduleType.toString().trim().toLowerCase() ==
              AppConstants.grocery;
      bool isTaxi = splashController.module != null &&
          splashController.module!.moduleType.toString().trim().toLowerCase() ==
              AppConstants.taxi;
      bool isServices = splashController.module != null &&
          splashController.module!.moduleType.toString().trim().toLowerCase() ==
              AppConstants.services;
      bool isGlobal = splashController.module != null &&
          splashController.module!.moduleType.toString().trim().toLowerCase() ==
              AppConstants.globalShopping;

      // + ahmed
      bool isAggregatedModule =
          splashController.module?.showNationalProducts ?? false;
      bool showStoreList = splashController.module?.showStoreList ?? true;
      // + ahmed

      return GetBuilder<HomeController>(builder: (homeController) {
        // if(splashController.module != null && !_firstTimeSubModuleLoaded) {
        //   _firstTimeSubModuleLoaded = true;
        //   print("AHMED_DEBUG: Lazy triggering loadData(true)");
        //   HomeScreen.loadData(true, fromModule: true);
        // }
        return Scaffold(
          appBar:
              ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Stack(
            children: [
              // Positioned Sky Background removed as it's now integrated into sticky headers
              ResponsiveHelper.isDesktop(context)
                  ? RefreshIndicator(
                      onRefresh: () async {
                        await HomeScreen.refreshAllData();
                      },
                      child: WebNewHomeScreen(
                        scrollController: _scrollController,
                      ),
                    )
                  : GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity == null) return;
                        if (details.primaryVelocity!.abs() < 300)
                          return; // Ignore slow swipes

                        if (isAggregatedModule) {
                          final ItemController itemController =
                              Get.find<ItemController>();
                          List<String> tabs = [
                            'latest',
                            'popular',
                            'recommended',
                            'discounted',
                            'most-reviewed'
                          ];
                          int currentIndex =
                              tabs.indexOf(itemController.nationalFilterType);
                          if (currentIndex == -1) return;

                          bool isRtl =
                              Directionality.of(context) == TextDirection.rtl;

                          if (details.primaryVelocity! < 0) {
                            // Swiped Left
                            int nextIndex =
                                isRtl ? currentIndex - 1 : currentIndex + 1;
                            if (nextIndex >= 0 && nextIndex < tabs.length) {
                              itemController
                                  .setNationalFilterType(tabs[nextIndex]);
                            }
                          } else {
                            // Swiped Right
                            int prevIndex =
                                isRtl ? currentIndex + 1 : currentIndex - 1;
                            if (prevIndex >= 0 && prevIndex < tabs.length) {
                              itemController
                                  .setNationalFilterType(tabs[prevIndex]);
                            }
                          }
                        }
                      },
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await HomeScreen.refreshAllData();
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            /// App Bar

                            !showMobileModule && !isTaxi
                                ? SliverPersistentHeader(
                                    key: ValueKey(isAggregatedModule ? 'header_explore' : 'header_default'),
                                    pinned: true,
                                    floating: false,
                                    delegate: ModuleStickyDelegate(
                                      splashController: splashController,
                                      expandedHeight: isAggregatedModule ? (115.0 * _appBarRatio) : 115.0,
                                      collapsedHeight: isAggregatedModule ? (60.0 * _appBarRatio) : 60.0,
                                      expandedScrollController: _expandedModuleController,
                                      collapsedScrollController: _collapsedModuleController,
                                      paddingTop: isAggregatedModule ? (MediaQuery.of(context).padding.top * _appBarRatio) : MediaQuery.of(context).padding.top, // + ahmed
                                      searchBarHeight: isAggregatedModule ? (50.0 * _appBarRatio) : 50.0,
                                      searchBar: isAggregatedModule && _appBarRatio == 0.0 ? const SizedBox() : Opacity(
                                        opacity: isAggregatedModule ? _appBarRatio : 1.0,
                                        child: Center(
                                          child: isParcel
                                              ? const SizedBox()
                                              : Container(
                                                  height: 50,
                                                  width: Dimensions.webMaxWidth,
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: isGlobal
                                                            ? Container(
                                                                height: 48,
                                                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Theme.of(context).primaryColor,
                                                                      Theme.of(context).primaryColor.withValues(alpha: 0.85),
                                                                    ],
                                                                    begin: Alignment.topLeft,
                                                                    end: Alignment.bottomRight,
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                                                      blurRadius: 6,
                                                                      offset: const Offset(0, 2),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(Icons.public_rounded, size: 24, color: Colors.white),
                                                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                                    Expanded(
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'المتاجر العالمية (Global Stores)',
                                                                            style: robotoBold.copyWith(
                                                                              fontSize: Dimensions.fontSizeSmall,
                                                                              color: Colors.white,
                                                                            ),
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                          Text(
                                                                            'اختر المتجر، انسخ رابط السلة وسنقوم بشرائه وتوصيله إليك!',
                                                                            style: robotoRegular.copyWith(
                                                                              fontSize: 10,
                                                                              color: Colors.white.withValues(alpha: 0.9),
                                                                            ),
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : InkWell(
                                                          onTap: () {
                                                            Get.toNamed(RouteHelper.getSearchRoute(queryText: ''));
                                                          },
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            Dimensions
                                                                .radiusDefault,
                                                          ),
                                                          child: Container(
                                                            clipBehavior: Clip.hardEdge,
                                                            height: 48,
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .only(
                                                              start: Dimensions
                                                                  .paddingSizeSmall,
                                                              end: 4,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .cardColor,
                                                              border:
                                                                  Border.all(
                                                                color:Theme.of(context).primaryColor,
                                                                width: 1.4,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                Dimensions
                                                                    .radiusDefault,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                // أيقونة البحث في بداية الحقل
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .search,
                                                                  size: 23,
                                                                  color: Theme.of(context).primaryColor,
                                                                ),

                                                                const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeExtraSmall,
                                                                ),

                                                                // النص والتلميحات المتحركة
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        '${'search_for'.tr} : ',
                                                                        style: robotoBold
                                                                            .copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeDefault,
                                                                          color:
                                                                              Theme.of(context).hintColor,
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                         child: AnimatedSwitcher(
                                                                           duration: const Duration(milliseconds: 500),
                                                                           transitionBuilder: (Widget child, Animation<double> animation) {
                                                                             final inAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation);
                                                                             final outAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(animation);
                                                                             final isCurrentHint = child.key == ValueKey<int>(_currentHintIndex);
                                                                             return SlideTransition(
                                                                               position: isCurrentHint ? inAnimation : outAnimation,
                                                                               child: FadeTransition(
                                                                                 opacity: animation,
                                                                                 child: child,
                                                                               ),
                                                                             );
                                                                           },
                                                                           child: Container(
                                                                             key: ValueKey<int>(_currentHintIndex),
                                                                             alignment: AlignmentDirectional.centerStart,
                                                                             child: GestureDetector(
                                                                               behavior: HitTestBehavior.deferToChild,
                                                                               onTap: () {
                                                                                 String currentHint = (Get.find<SplashController>().module?.searchHints?.isNotEmpty ?? false)
                                                                                     ? Get.find<SplashController>().module!.searchHints![_currentHintIndex % Get.find<SplashController>().module!.searchHints!.length]
                                                                                     : (Get.find<CategoryController>().categoryList?.isNotEmpty ?? false)
                                                                                         ? Get.find<CategoryController>().categoryList![_currentHintIndex % Get.find<CategoryController>().categoryList!.length].name!
                                                                                         : '';
                                                                                 Get.toNamed(RouteHelper.getSearchRoute(queryText: currentHint));
                                                                               },
                                                                               child: Text(
                                                                                 (Get.find<SplashController>().module?.searchHints?.isNotEmpty ?? false)
                                                                                     ? Get.find<SplashController>().module!.searchHints![_currentHintIndex % Get.find<SplashController>().module!.searchHints!.length]
                                                                                     : (Get.find<CategoryController>().categoryList?.isNotEmpty ?? false)
                                                                                         ? Get.find<CategoryController>().categoryList![_currentHintIndex % Get.find<CategoryController>().categoryList!.length].name!
                                                                                         : '',
                                                                                 style: robotoBold.copyWith(
                                                                                   fontSize: Dimensions.fontSizeDefault,
                                                                                   color: Theme.of(context).hintColor,
                                                                                 ),
                                                                                 maxLines: 1,
                                                                                 overflow: TextOverflow.ellipsis,
                                                                               ),
                                                                             ),
                                                                           ),
                                                                         ),
                                                                       ),
                                                                    ],
                                                                  ),
                                                                ),

                                                                // أيقونة الكاميرا بخلفية شفافة داخل الحقل
                                                                InkWell(
                                                                  onTap: () {
                                                                        Get.toNamed(
                                                                            RouteHelper
                                                                                .getSearchRoute());
                                                                      },
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                                      color: Theme.of(context).primaryColor.withAlpha(30)
                                                                    ),
                                                                    width: 40,
                                                                    height: 40,
                                                                    child:
                                                                        Icon(
                                                                        Icons
                                                                            .camera_alt_rounded,
                                                                        size: 23,
                                                                        color: Theme.of(context).primaryColor,
                                                                      ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 6),

                                                      // أيقونة الإشعارات فقط بدون خلفية
                                                      GetBuilder<
                                                          NotificationController>(
                                                        builder:
                                                            (notificationController) {
                                                          return InkWell(
                                                            onTap: () {
                                                              Get.toNamed(
                                                                  RouteHelper
                                                                      .getNotificationRoute());
                                                            },
                                                            child: SizedBox(
                                                              height: 48,
                                                              width: 48,
                                                              child: Stack(
                                                                clipBehavior:
                                                                    Clip.none,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    width: 48,
                                                                    height: 48,
                                                                    decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                                    color: Theme.of(context).primaryColor
                                                                  ),
                                                                    child: const Icon(
                                                                      CupertinoIcons
                                                                          .bell,
                                                                      size: 26,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                  if (notificationController
                                                                      .hasNotification)
                                                                    PositionedDirectional(
                                                                      top: 7,
                                                                      end: 6,
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            9,
                                                                        height:
                                                                            9,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.red,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Theme.of(context).cardColor,
                                                                            width:
                                                                                1.5,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ))),
                                    ),
                                  )
                                : const SliverToBoxAdapter(),

                            if (!showMobileModule)
                              SliverPadding(
                                key: ValueKey(
                                    splashController.module?.id ?? 'default'),
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        ResponsiveHelper.isDesktop(context)
                                            ? (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    Dimensions.webMaxWidth) /
                                                2
                                            : 0),
                                sliver: isGrocery
                                    ? const GroceryHomeScreen()
                                    : isPharmacy
                                        ? const PharmacyHomeScreen()
                                        : isFood
                                            ? const FoodHomeScreen()
                                            : isShop
                                                ? const ShopHomeScreen()
                                                : isTaxi
                                                    ? const SliverToBoxAdapter(
                                                        child: TaxiHomeScreen())
                                                    : isServices
                                                        ? const SliverToBoxAdapter(
                                                            child: ServiceScreen(
                                                                fromHomeScreen:
                                                                    true))
                                                        : isParcel
                                                            ? ParcelModuleScreen(
                                                                searchHeaderKey:
                                                                    _headerKey,
                                                                exploreRestaurantKey:
                                                                    _headerKey)
                                                             : isGlobal
                                                                 ? const SliverToBoxAdapter(
                                                                     child: GlobalHomeScreen())
                                                                 : const SliverToBoxAdapter(),
                              ),

                            !showMobileModule &&
                                    !isTaxi &&
                                    !isServices &&
                                    !isGlobal &&
                                    showStoreList
                                ?
                                // Hide if Aggregated Module // + ahmed
                                (isAggregatedModule
                                    ? const SliverToBoxAdapter()
                                    : SliverPersistentHeader(
                                        key: _headerKey,
                                        pinned: true,
                                        delegate: SliverDelegate(
                                          height: 85,
                                          callback: (val) {
                                            searchBgShow = val;
                                          },
                                          child: const AllStoreFilterWidget(),
                                        ),
                                      ))
                                : const SliverToBoxAdapter(),

                            SliverToBoxAdapter(
                                child: !showMobileModule &&
                                        !isTaxi &&
                                        !isServices &&
                                        !isGlobal &&
                                        showStoreList
                                    ? Center(
                                        key: ValueKey(
                                            Get.find<SplashController>()
                                                    .module
                                                    ?.id ??
                                                'default'),
                                        child: GetBuilder<StoreController>(
                                            builder: (storeController) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                bottom: (ResponsiveHelper
                                                        .isDesktop(context)
                                                    ? 0
                                                    : isAggregatedModule
                                                        ? Dimensions
                                                            .paddingSizeSmall
                                                        : 100)),
                                            // Hide Store List if aggregated // + ahmed
                                            child: isAggregatedModule
                                                ? const SizedBox()
                                                : PaginatedListView(
                                                    scrollController:
                                                        _scrollController,
                                                    totalSize: storeController
                                                        .storeModel?.totalSize,
                                                    offset: storeController
                                                        .storeModel?.offset,
                                                    onPaginate: (int?
                                                            offset) async =>
                                                        await storeController
                                                            .getStoreList(
                                                                offset!, false),
                                                    itemView: ItemsView(
                                                      isStore: true,
                                                      items: null,
                                                      isFoodOrGrocery:
                                                          (isFood || isGrocery),
                                                      stores: storeController
                                                          .storeModel?.stores,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: ResponsiveHelper
                                                                .isDesktop(
                                                                    context)
                                                            ? Dimensions
                                                                .paddingSizeExtraSmall
                                                            : Dimensions
                                                                .paddingSizeSmall,
                                                        vertical: ResponsiveHelper
                                                                .isDesktop(
                                                                    context)
                                                            ? Dimensions
                                                                .paddingSizeExtraSmall
                                                            : Dimensions
                                                                .paddingSizeDefault,
                                                      ),
                                                    ),
                                                  ),
                                          );
                                        }),
                                     )
                                    : const SizedBox()),

                             isAggregatedModule // + ahmed
                                 ? SliverPersistentHeader(
                                     pinned: true,
                                     delegate: SliverDelegate(
                                       height: 90,
                                       paddingTop: (1.0 - _appBarRatio) * MediaQuery.of(context).padding.top,
                                       child: NationalProductsFilterWidget(key: _exploreFilterKey),
                                     ),
                                   )
                                 : const SliverToBoxAdapter(),

                            // Aggregated Products View (More view with Infinite Scroll) // + ahmed
                            if (isAggregatedModule) // + ahmed
                              NationalProductsView(
                                  key: ValueKey(Get.find<SplashController>()
                                      .module
                                      ?.id)), // + ahmed: Force rebuild on module change

                            // For Service Module: Show Providers instead of Stores (only if NO layout config)
                            if (isServices &&
                                (splashController.module?.layoutConfig ==
                                        null ||
                                    splashController
                                        .module!.layoutConfig!.isEmpty))
                              GetBuilder<ServiceController>(
                                  builder: (serviceController) {
                                if (serviceController.providers == null) {
                                  return const SliverToBoxAdapter(
                                      child:
                                          Center(child: CustomLoaderWidget()));
                                }

                                return MultiSliver(
                                  children: [
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: ResponsiveHelper
                                                    .isDesktop(context)
                                                ? Dimensions
                                                    .paddingSizeExtraSmall
                                                : Dimensions.paddingSizeSmall,
                                            vertical:
                                                Dimensions.paddingSizeDefault),
                                        child: Text(
                                            '${serviceController.providers?.length ?? 0} ${'providers_near_you'.tr}',
                                            style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge)),
                                      ),
                                    ),
                                    SliverPadding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            ResponsiveHelper.isDesktop(context)
                                                ? Dimensions
                                                    .paddingSizeExtraSmall
                                                : Dimensions.paddingSizeSmall,
                                      ),
                                      sliver: SliverList.builder(
                                        itemCount:
                                            serviceController.providers!.length,
                                        itemBuilder: (context, index) {
                                          return ServiceProviderWidget(
                                              provider: serviceController
                                                  .providers![index]);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }),

                            if (!ResponsiveHelper.isDesktop(context))
                              const SliverToBoxAdapter(
                                  child: SizedBox(height: 120)),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(
                bottom: ResponsiveHelper.isDesktop(context) ? 0 : 70),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isPharmacy &&
                    Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment! &&
                    Get.find<SplashController>().configModel!.prescriptionStatus! &&
                    AuthHelper.isLoggedIn() &&
                    homeController.showFavButton) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(2, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: ResponsiveHelper.isDesktop(context) ? 180 : 150,
                          height: 30,
                          child: Center(
                            child: Text(
                              'prescription_order'.tr,
                              textAlign: TextAlign.center,
                              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showCustomBottomSheet(
                              child: const PrescriptionStoreBottomSheetWidget(),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Image.asset(Images.prescriptionIcon, height: 25, width: 25),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ],
                if (_showBackToTop) ...[
                  FloatingActionButton(
                    mini: true,
                    onPressed: () => _scrollController.animateTo(0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut),
                    backgroundColor: Colors.grey.withValues(alpha: 0.5),
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ],
                if (AuthHelper.isLoggedIn() &&
                    homeController.cashBackOfferList != null &&
                    homeController.cashBackOfferList!.isNotEmpty &&
                    homeController.showFavButton)
                  Padding(
                    padding: EdgeInsets.only(
                        right: ResponsiveHelper.isDesktop(context) ? 50 : 0),
                    child: InkWell(
                      onTap: () => Get.dialog(const CashBackDialogWidget()),
                      child: const CashBackLogoWidget(),
                    ),
                  ),
              ],
            ),
          ),
        );
      });
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  double paddingTop;
  Function(bool isPinned)? callback;
  bool isPinned = false;

  SliverDelegate({required this.child, this.height = 50, this.paddingTop = 0.0, this.callback});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    isPinned = shrinkOffset == maxExtent || overlapsContent;
    if (callback != null) {
      callback!(isPinned);
    }
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(top: isPinned ? paddingTop : 0),
      child: child,
    );
  }

  @override
  double get maxExtent => height + paddingTop;

  @override
  double get minExtent => height + paddingTop;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != (height + paddingTop) ||
        oldDelegate.minExtent != (height + paddingTop) ||
        child != oldDelegate.child;
  }
}
