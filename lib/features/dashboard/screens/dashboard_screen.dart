import 'dart:async';
import 'dart:io';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:sixam_mart/common/widgets/login_suggestion_bottomsheet.dart';
import 'package:sixam_mart/features/dashboard/widgets/store_registration_success_bottom_sheet.dart';
import 'package:sixam_mart/features/store/screens/all_store_screen.dart';
import 'package:sixam_mart/features/item/screens/item_campaign_screen.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/screens/service_booking_list_screen.dart';
import 'package:sixam_mart/features/item/screens/item_view_all_screen.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/address/screens/address_screen.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/screens/vehicle_favourite_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/taxi_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:sixam_mart/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/dashboard/widgets/running_order_view_widget.dart';
import 'package:sixam_mart/features/favourite/screens/favourite_screen.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/menu/screens/menu_screen.dart';
import 'package:sixam_mart/features/order/screens/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:sixam_mart/features/chat/screens/ai_chat_screen.dart';
import 'package:sixam_mart/features/category/screens/category_tree_screen.dart';
import 'package:sixam_mart/features/cart/screens/cart_screen.dart';
import 'package:sixam_mart/features/shelf/screens/dynamic_shelf_view_all_screen.dart';
import 'package:sixam_mart/features/service/screens/service_provider_screen.dart';
import 'package:sixam_mart/common/widgets/floating_ad_widget.dart';
import 'package:sixam_mart/features/trends/screens/trends_screen.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_home_screen.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_cart_screen.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_order_list_screen.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_cart_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  const DashboardScreen(
      {super.key, required this.pageIndex, this.fromSplash = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;

  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  late bool _isLogin;
  bool active = false;

  // FAB position — ValueNotifier so only the FAB widget rebuilds on drag
  final ValueNotifier<Offset> _fabPosition = ValueNotifier(const Offset(16, 100));

  // ── Floating-ad scroll visibility ──────────────────────────────────────────
  bool _isScrollingContent = false;
  Timer? _scrollHideTimer;

  // Track last module type to avoid rebuilding _screens unnecessarily
  String? _lastModuleType;

  @override
  void initState() {
    super.initState();

    _isLogin = AuthHelper.isLoggedIn();

    _showRegistrationSuccessBottomSheet();
    if (!_isLogin &&
        Get.find<SplashController>().showLoginSuggestion() &&
        (GetPlatform.isAndroid || GetPlatform.isIOS)) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        Get.bottomSheet(LoginSuggestionBottomSheet(), isScrollControlled: true)
            .then((v) {
          Get.find<SplashController>().disableLoginSuggestion();
        });
      });
    }

    if (_isLogin) {
      if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 &&
          Get.find<AuthController>().getEarningPint().isNotEmpty &&
          !ResponsiveHelper.isDesktop(Get.context)) {
        Future.delayed(
            const Duration(seconds: 1),
            () => showAnimatedDialog(
                Get.context!, const CongratulationDialogue()));
      }
      suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1, fromDashboard: true);
    }

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    // Build screens once during init
    _buildScreens();
  }

  @override
  void dispose() {
    _fabPosition.dispose();
    _scrollHideTimer?.cancel();
    super.dispose();
  }

  /// Rebuild _screens only when module type actually changes
  void _buildScreens({bool isParcel = false, bool isTaxi = false, bool isGlobal = false}) {
    _screens = [
      const HomeScreen(),
      isParcel
          ? const AddressScreen(fromDashboard: true)
          : isTaxi
              ? const VehicleFavouriteScreen()
              : isGlobal
                  ? const GlobalHomeScreen()
                  : const CategoryTreeScreen(),
      isGlobal ? const GlobalOrderListScreen() : const OrderScreen(),
      isGlobal ? const GlobalCartScreen() : const CartScreen(fromNav: true),
      isTaxi ? const OrderScreen(index: 1) : const FavouriteScreen(),
      const MenuScreen(),
      const AllStoreScreen(
          isPopular: true,
          isFeatured: false,
          isNearbyStore: true,
          isTopOfferStore: false,
          isRecommendedStore: false,
          backButton: false),
      const ItemViewAllScreen(
          isSpecial: true, isPopular: false, backButton: false),
      const ItemCampaignScreen(isJustForYou: false, backButton: false),
      const ServiceBookingListScreen(), // Index 9
      const TrendsScreen(), // Index 10
    ];
  }


  void _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet =
        Get.find<HomeController>().getRegistrationSuccessfulSharedPref();
    if (canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context)
            ? Get.dialog(
                    const Dialog(child: StoreRegistrationSuccessBottomSheet()))
                .then((value) {
                Get.find<HomeController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<HomeController>()
                    .saveIsStoreRegistrationSharedPref(false);
                setState(() {});
              })
            : showModalBottomSheet(
                context: Get.context!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (con) => const StoreRegistrationSuccessBottomSheet(),
              ).then((value) {
                Get.find<HomeController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<HomeController>()
                    .saveIsStoreRegistrationSharedPref(false);
                setState(() {});
              });
      });
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if (widget.fromSplash &&
        Get.find<LocationController>().showLocationSuggestion &&
        active &&
        AddressHelper.getUserAddressFromSharedPref() == null) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheetWidget(),
        ).then((value) {
          Get.find<LocationController>().showSuggestedLocation(false);
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return GetBuilder<SplashController>(builder: (splashController) {
      bool isParcel = splashController.module != null &&
          splashController.configModel!.moduleConfig!.module!.isParcel!;
      bool isTaxiWithCache = ((splashController.module != null &&
                  splashController.module!.moduleType.toString() ==
                      AppConstants.taxi) ||
              (splashController.cacheModule != null &&
                  splashController.cacheModule!.moduleType.toString() ==
                      AppConstants.taxi)) &&
          TaxiHelper.haveTaxiModule();
      bool isTaxi = (splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.taxi);
      bool isServices = (splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.services);
      bool isGlobal = (splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.globalShopping);
      isParcel = isParcel && !isTaxiWithCache;

      // Only rebuild _screens when the module type actually changes (performance)
      final String newModuleKey = '${splashController.module?.moduleType}_${isParcel}_${isTaxi}_$isGlobal';
      if (newModuleKey != _lastModuleType) {
        _lastModuleType = newModuleKey;
        _buildScreens(isParcel: isParcel, isTaxi: isTaxi, isGlobal: isGlobal);
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (_pageIndex != 0) {
            _setPage(0);
          } else {
            // Directly exit the app if on Home Screen, skipping the "clear module" step
            // which caused the empty page after removing ModuleView.
            if (_canExit) {
              if (GetPlatform.isAndroid) {
                SystemNavigator.pop();
              } else if (GetPlatform.isIOS) {
                exit(0);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('back_press_again_to_exit'.tr,
                    style: const TextStyle(color: Colors.white)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              ));
              _canExit = true;
              Timer(const Duration(seconds: 2), () {
                _canExit = false;
              });
            }
          }
        },
        child: GetBuilder<OrderController>(builder: (orderController) {
          List<OrderModel> runningOrder =
              orderController.runningOrderModel != null
                  ? orderController.runningOrderModel!.orders!
                  : [];

          List<OrderModel> reversOrder = List.from(runningOrder.reversed);

          bool showRunningOrders = (widget.fromSplash &&
                  Get.find<LocationController>().showLocationSuggestion &&
                  active &&
                  !ResponsiveHelper.isDesktop(context))
              ? false
              : (ResponsiveHelper.isDesktop(context) ||
                      !_isLogin ||
                      orderController.runningOrderModel == null ||
                      orderController.runningOrderModel!.orders!.isEmpty ||
                      !orderController.showBottomSheet)
                  ? false
                  : true;

          return SafeArea(
            top: false,
            bottom: GetPlatform.isAndroid,
            child: Scaffold(
              key: _scaffoldKey,
              body: ExpandableBottomSheet(
                background: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    if (notification.direction != ScrollDirection.idle) {
                      // User actively scrolling — hide the ad
                      if (!_isScrollingContent) {
                        setState(() => _isScrollingContent = true);
                      }
                      _scrollHideTimer?.cancel();
                    } else {
                      // Scroll settled — show the ad after a short delay
                      _scrollHideTimer?.cancel();
                      _scrollHideTimer = Timer(
                        const Duration(milliseconds: 600),
                        () {
                          if (mounted) {
                            setState(() => _isScrollingContent = false);
                          }
                        },
                      );
                    }
                    return false;
                  },
                  child: Stack(children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _screens.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _screens[index];
                      },
                    ),
                    FloatingAdWidget(isScrolling: _isScrollingContent),
                    // FAB — uses ValueListenableBuilder so ONLY this widget
                    // rebuilds on drag, NOT the entire Scaffold/PageView
                    ValueListenableBuilder<Offset>(
                      valueListenable: _fabPosition,
                      builder: (context, fabPos, _) {
                        return Positioned(
                          bottom: fabPos.dy,
                          right: fabPos.dx,
                          child: AnimatedScale(
                            scale: _isScrollingContent ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: IgnorePointer(
                              ignoring: _isScrollingContent,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  _fabPosition.value = Offset(
                                    (fabPos.dx - details.delta.dx).clamp(0.0, double.infinity),
                                    (fabPos.dy - details.delta.dy).clamp(80.0, double.infinity),
                                  );
                                },
                                onPanEnd: (_) {
                                  // Snap right edge back to 16 on release
                                  _fabPosition.value = Offset(16, _fabPosition.value.dy);
                                },
                                onTap: () => Get.to(() => const AIChatScreen()),
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: ClipOval(
                                      child: (splashController.configModel
                                                  ?.splashScreenImageFullUrl !=
                                              null)
                                          ? CustomImage(
                                              image: splashController.configModel!
                                                  .splashScreenImageFullUrl!,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(Images.ucleSul,
                                              fit: BoxFit.cover),
                                    ),
                                  ),
                                )
                                    .animate(
                                        onPlay: (controller) =>
                                            controller.repeat(reverse: true))
                                    .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.1, 1.1),
                                        duration: 1500.ms,
                                        curve: Curves.easeInOut),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    ResponsiveHelper.isDesktop(context) || keyboardVisible || _pageIndex == 3
                        ? const SizedBox()
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: GetBuilder<SplashController>(
                                builder: (splashController) {
                              return Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      width: size.width,
                                      height: GetPlatform.isIOS ? 88 : 72,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.08),
                                            blurRadius: 20,
                                            spreadRadius: 0,
                                            offset: const Offset(0, -4),
                                          ),
                                        ],
                                        color: Theme.of(context).cardColor,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                                      ),
                                      child: Stack(
                                        children: [
                                          const SizedBox(),
                                          showRunningOrders
                                              ? const SizedBox()
                                              : Center(
                                                  child: SizedBox(
                                                    width: size.width,
                                                    height: 80,
                                                    child: GetBuilder<
                                                            CartController>(
                                                        builder:
                                                            (cartController) {
                                                      return GetBuilder<
                                                              GlobalCartController>(
                                                          builder:
                                                              (globalCartCtrl) {
                                                        return Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children:
                                                                _getBottomNavItems(
                                                                    context,
                                                                    isParcel,
                                                                    isTaxi,
                                                                    isServices,
                                                                    isGlobal,
                                                                    cartController));
                                                      });
                                                    }),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    if ((splashController
                                                    .module?.bottomNavConfig?[
                                                'middle_button']?['enabled'] ??
                                            false) &&
                                        !showRunningOrders)
                                      Positioned(
                                        bottom:
                                            30, // Floats the button above the bar
                                        child: Builder(builder: (context) {
                                          var middleButtonConfig =
                                              splashController
                                                      .module!.bottomNavConfig![
                                                  'middle_button'];
                                          String? type =
                                              middleButtonConfig?['type'];
                                          String? storeId =
                                              middleButtonConfig?['store_id']
                                                  ?.toString();
                                          String? itemId =
                                              middleButtonConfig?['item_id']
                                                  ?.toString();
                                          String? shelfId =
                                              middleButtonConfig?['shelf_id']
                                                  ?.toString();
                                          String? link =
                                              middleButtonConfig?['link'];
                                          String? storeLogo =
                                              middleButtonConfig?['store_logo'];
                                          // String? iconSource = middleButtonConfig?['icon_source']; // Unused
                                          // String? customIcon = middleButtonConfig?['custom_icon']; // Unused

                                          return InkWell(
                                            onTap: () async {
                                              int? safeStoreId =
                                                  (storeId != null &&
                                                          storeId.isNotEmpty)
                                                      ? int.tryParse(storeId)
                                                      : null;
                                              int? safeItemId =
                                                  (itemId != null &&
                                                          itemId.isNotEmpty)
                                                      ? int.tryParse(itemId)
                                                      : null;
                                              int? safeShelfId =
                                                  (shelfId != null &&
                                                          shelfId.isNotEmpty)
                                                      ? int.tryParse(shelfId)
                                                      : null;

                                              if (type == 'store' &&
                                                  safeStoreId != null) {
                                                if (isServices) {
                                                  Get.to(() =>
                                                      ServiceProviderScreen(
                                                          providerId:
                                                              safeStoreId));
                                                } else {
                                                  Get.toNamed(
                                                      RouteHelper.getStoreRoute(
                                                          id: safeStoreId,
                                                          page: 'store'));
                                                }
                                              } else if (type == 'item' &&
                                                  safeItemId != null) {
                                                if (isServices) {
                                                  Get.toNamed(RouteHelper
                                                      .getServiceDetailsRoute(
                                                          safeItemId));
                                                } else {
                                                  Get.toNamed(RouteHelper
                                                      .getItemDetailsRoute(
                                                          safeItemId, false));
                                                }
                                              } else if (type == 'shelf' &&
                                                  safeShelfId != null) {
                                                Get.to(() =>
                                                    DynamicShelfViewAllScreen(
                                                        shelfId: safeShelfId));
                                              } else if (type == 'url' &&
                                                  link != null &&
                                                  link.isNotEmpty) {
                                                if (await canLaunchUrlString(
                                                    link)) {
                                                  launchUrlString(link,
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }
                                              } else if (type == 'page' &&
                                                  link != null &&
                                                  link.isNotEmpty) {
                                                switch (link) {
                                                  case 'item_campaign':
                                                    Get.toNamed(RouteHelper
                                                        .getItemCampaignRoute());
                                                    break;
                                                  case 'popular_items':
                                                    Get.toNamed(RouteHelper
                                                        .getPopularItemRoute(
                                                            false, true));
                                                    break;
                                                  case 'all_stores':
                                                    Get.toNamed(RouteHelper
                                                        .getAllStoreRoute('all',
                                                            isNearbyStore:
                                                                true));
                                                    break;
                                                  case 'category':
                                                    Get.toNamed(RouteHelper
                                                        .getCategoryRoute());
                                                    break;
                                                  case 'favourite':
                                                    Get.toNamed(RouteHelper
                                                        .getFavouriteScreen());
                                                    break;
                                                  case 'coupon':
                                                    Get.toNamed(RouteHelper
                                                        .getCouponRoute());
                                                    break;
                                                  default:
                                                    Get.toNamed(RouteHelper
                                                        .getAllStoreRoute(
                                                            'all'));
                                                }
                                              } else {
                                                Get.toNamed(RouteHelper
                                                    .getAllStoreRoute('all'));
                                              }
                                            },
                                            child: Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    width: 3),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.2),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                      offset:
                                                          const Offset(0, -3))
                                                ],
                                              ),
                                              child: (splashController.module
                                                          ?.middleButtonIconFullUrl !=
                                                      null)
                                                  ? ClipOval(
                                                      child: CustomImage(
                                                        image: splashController
                                                            .module!
                                                            .middleButtonIconFullUrl!,
                                                        height: 60,
                                                        width: 60,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : (storeLogo != null)
                                                      ? ClipOval(
                                                          child: CustomImage(
                                                            image:
                                                                '${Get.find<SplashController>().configModel?.baseUrls?.storeImageUrl}/$storeLogo',
                                                            height: 60,
                                                            width: 60,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : Icon(Icons.store,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: 40),
                                            )
                                                .animate(
                                                    onPlay: (controller) =>
                                                        controller.repeat(
                                                            reverse: true))
                                                .scale(
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    begin: const Offset(1, 1),
                                                    end:
                                                        const Offset(1.1, 1.1)),
                                          );
                                        }),
                                      ),
                                  ]);
                            }),
                          ),
                  ]), // Stack
                ), // NotificationListener

                persistentContentHeight:
                    showRunningOrders ? (GetPlatform.isIOS ? 110 : 100) : 0,

                onIsContractedCallback: () {
                  if (!orderController.showOneOrder) {
                    orderController.showOrders();
                  }
                },
                onIsExtendedCallback: () {
                  if (orderController.showOneOrder) {
                    orderController.showOrders();
                  }
                },

                enableToggle: true,

                expandableContent: showRunningOrders
                    ? Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          if (orderController.showBottomSheet) {
                            orderController.showRunningOrders();
                          }
                        },
                        child: RunningOrderViewWidget(
                            reversOrder: reversOrder,
                            onOrderTap: () {
                              _setPage(2);
                              if (orderController.showBottomSheet) {
                                orderController.showRunningOrders();
                              }
                            }),
                      )
                    : const SizedBox(),
              ),
            ),
          );
        }),
      );
    });
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
        height: 3,
        decoration: BoxDecoration(
            color: status
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }

  List<Widget> _getBottomNavItems(
      BuildContext context,
      bool isParcel,
      bool isTaxi,
      bool isServices,
      bool isGlobal,
      CartController cartController) {
    List<Widget> navWidgets = [];
    final module = Get.find<SplashController>().module;
    final globalCartCtrl = isGlobal ? Get.find<GlobalCartController>() : null;

    List<dynamic> configItems = [];
    if (module != null && module.bottomNavConfig != null) {
      configItems = module.bottomNavConfig!['items'] ?? [];
    }

    // If no config items found, use default order
    if (configItems.isEmpty) {
      configItems = [
        {'key': 'home', 'visible': true},
        {'key': 'section_1', 'visible': true},
        {'key': 'orders', 'visible': true},
        {'key': 'cart', 'visible': true},
        {'key': 'section_2', 'visible': true},
        {'key': 'menu', 'visible': true},
      ];
    }

    for (var item in configItems) {
      if (item is! Map) continue;
      String key = item['key'] ?? '';
      bool visible = (item['visible'] == null)
          ? true
          : (item['visible'].toString() == 'true' ||
              item['visible'].toString() == '1');
      if (key.isEmpty || !visible) continue;

      String? customTitle;
      var rawTitles = item['titles'];
      if (rawTitles != null && rawTitles is Map) {
        String currentLang = Get.locale?.languageCode ?? 'en';
        customTitle = rawTitles[currentLang]?.toString() ??
            rawTitles['default']?.toString();
      }

      String? customIconName = item['icon'];
      String? iconType = item['icon_type'];
      String? iconSvg = item['icon_svg'];
      String? iconUrl;

      if (iconType == 'svg' && iconSvg != null && iconSvg.isNotEmpty) {
        iconUrl =
            '${Get.find<SplashController>().configModel!.baseUrls!.moduleImageUrl}/nav_icon/$iconSvg';
      }

      navWidgets.add(_buildNavItem(key, customTitle, customIconName, iconUrl,
          isParcel, isTaxi, isServices, cartController,
          isGlobal: isGlobal));
    }

    // Insert Special Middle Button if enabled
    var middleButtonConfig = module?.bottomNavConfig?['middle_button'];
    if (middleButtonConfig != null &&
        (middleButtonConfig['enabled'] ?? false)) {
      int middleIndex = (navWidgets.length / 2).ceil();
      navWidgets.insert(middleIndex, const SizedBox(width: 70, height: 70));
    }

    return navWidgets;
  }

  Widget _buildNavItem(
      String key,
      String? customTitle,
      String? customIconName,
      String? iconUrl,
      bool isParcel,
      bool isTaxi,
      bool isServices,
      CartController cartController,
      {bool isGlobal = false}) {
    IconData? customIcon =
        customIconName != null ? _getIconDataFromString(customIconName) : null;
    final globalCartCtrl = isGlobal ? Get.find<GlobalCartController>() : null;

    switch (key) {
      case 'home':
        return BottomNavItemWidget(
          title: customTitle ?? (isGlobal ? 'global_shopping'.tr : 'home'.tr),
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.home_outlined,
          selectedIconData: customIcon != null ? null : Icons.home,
          isSelected: _pageIndex == 0,
          onTap: () => _setPage(0),
        );
      case 'section_1':
        IconData defaultIcon = isParcel
            ? Icons.location_on_outlined
            : isTaxi
                ? Icons.favorite_border
                : isGlobal
                    ? Icons.home_outlined
                    : isServices
                        ? Icons.home_repair_service_outlined
                        : Icons.grid_view;
        IconData defaultSelected = isParcel
            ? Icons.location_on
            : isTaxi
                ? Icons.favorite
                : isGlobal
                    ? Icons.home
                    : isServices
                        ? Icons.home_repair_service
                        : Icons.grid_view_rounded;
        String defaultTitle = isParcel
            ? 'address'.tr
            : isTaxi
                ? 'wishlist'.tr
                : isGlobal
                    ? 'global_shopping'.tr
                    : isServices
                        ? 'services'.tr
                        : 'categories'.tr;
        return BottomNavItemWidget(
          title: customTitle ?? defaultTitle,
          iconUrl: iconUrl,
          iconData: customIcon ?? defaultIcon,
          selectedIconData: customIcon != null ? null : defaultSelected,
          isSelected: _pageIndex == 1,
          onTap: () => _setPage(1),
        );
      case 'orders':
        return BottomNavItemWidget(
          title:
              customTitle ?? (isGlobal ? 'global_my_orders'.tr : 'orders'.tr),
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.receipt_long_outlined,
          selectedIconData: customIcon != null ? null : Icons.receipt_long,
          isSelected: _pageIndex == 2,
          onTap: () {
            if (isGlobal && !AuthHelper.isLoggedIn()) {
              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
              showCustomSnackBar('you_are_not_logged_in'.tr);
            } else {
              _setPage(2);
            }
          },
        );
      case 'cart':
        final cartCount = isGlobal
            ? (globalCartCtrl?.cartList.length ?? 0)
            : cartController.cartList.length;
        return BottomNavItemWidget(
          title: customTitle ?? (isGlobal ? 'my_global_cart'.tr : 'cart'.tr),
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.shopping_cart_outlined,
          selectedIconData: customIcon != null ? null : Icons.shopping_cart,
          isSelected: _pageIndex == 3,
          onTap: () => _setPage(3),
          cartCount: cartCount,
        );
      case 'section_2':
        IconData defaultIcon =
            isTaxi ? Icons.map_outlined : Icons.favorite_outline;
        IconData defaultSelected = isTaxi ? Icons.map : Icons.favorite;
        String defaultTitle = isTaxi ? 'trips'.tr : 'favourite'.tr;
        return BottomNavItemWidget(
          title: customTitle ?? defaultTitle,
          iconUrl: iconUrl,
          iconData: customIcon ?? defaultIcon,
          selectedIconData: customIcon != null ? null : defaultSelected,
          isSelected: _pageIndex == 4,
          onTap: () => _setPage(4),
        );
      case 'nearest_store':
        return BottomNavItemWidget(
          title: customTitle ??
              (isServices ? 'nearest_service_provider'.tr : 'nearest_store'.tr),
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.store_outlined,
          selectedIconData: customIcon != null ? null : Icons.store,
          isSelected: _pageIndex == 6,
          onTap: () => _setPage(6),
        );
      case 'special_offers':
        return BottomNavItemWidget(
          title: customTitle ?? 'special_offers'.tr,
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.local_offer_outlined,
          selectedIconData: customIcon != null ? null : Icons.local_offer,
          isSelected: _pageIndex == 7,
          onTap: () => _setPage(7),
        );
      case 'campaign':
        return BottomNavItemWidget(
          title: customTitle ?? 'campaign'.tr,
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.campaign_outlined,
          selectedIconData: customIcon != null ? null : Icons.campaign,
          isSelected: _pageIndex == 8,
          onTap: () => _setPage(8),
        );
      case 'trends':
        return BottomNavItemWidget(
          title: customTitle ?? 'trends'.tr,
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.trending_up_outlined,
          selectedIconData: customIcon != null ? null : Icons.trending_up,
          isSelected: _pageIndex ==
              10, // Adjust index to your matching PageView/index state
          onTap: () => _setPage(10),
        );
      case 'menu':
        return BottomNavItemWidget(
          title: customTitle ?? 'menu'.tr,
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.person_outline,
          selectedIconData: customIcon != null ? null : Icons.person,
          isSelected: _pageIndex == 5,
          onTap: () => _setPage(5),
        );
      case 'my_bookings':
        return BottomNavItemWidget(
          title: customTitle ?? 'my_bookings'.tr,
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.assignment_outlined,
          selectedIconData: customIcon != null ? null : Icons.assignment,
          isSelected: _pageIndex == 9,
          onTap: () {
            if (AuthHelper.isLoggedIn()) {
              _setPage(9);
            } else {
              Get.bottomSheet(const LoginSuggestionBottomSheet(),
                  isScrollControlled: true);
            }
          },
        );
      case 'booking_tracking':
        return BottomNavItemWidget(
          title: customTitle ?? 'booking_tracking'.tr,
          iconUrl: iconUrl,
          iconData: customIcon ?? Icons.track_changes_outlined,
          selectedIconData: customIcon != null ? null : Icons.track_changes,
          isSelected: false,
          onTap: () {
            if (AuthHelper.isLoggedIn()) {
              Get.find<ServiceController>().getBookingList(1).then((value) {
                if (Get.find<ServiceController>().bookings != null &&
                    Get.find<ServiceController>().bookings!.isNotEmpty) {
                  bool hasActiveBookings = Get.find<ServiceController>()
                      .bookings!
                      .any((b) =>
                          b.status != 'completed' && b.status != 'canceled');
                  if (hasActiveBookings) {
                    Get.toNamed(RouteHelper.getServiceBookingTrackingRoute());
                  } else {
                    Get.snackbar('info'.tr, 'no_active_bookings_found'.tr);
                  }
                } else {
                  Get.snackbar('info'.tr, 'no_active_bookings_found'.tr);
                }
              });
            } else {
              Get.bottomSheet(const LoginSuggestionBottomSheet(),
                  isScrollControlled: true);
            }
          },
        );
      default:
        return const SizedBox();
    }
  }

  IconData? _getIconDataFromString(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'home_outlined':
        return Icons.home_outlined;
      case 'house':
        return Icons.house;
      case 'house_outlined':
        return Icons.house_outlined;
      case 'store':
        return Icons.store;
      case 'store_outlined':
        return Icons.store_outlined;
      case 'roofing':
        return Icons.roofing;
      case 'cottage':
        return Icons.cottage;

      case 'list':
        return Icons.list;
      case 'list_alt':
        return Icons.list_alt;
      case 'location_on':
        return Icons.location_on;
      case 'location_on_outlined':
        return Icons.location_on_outlined;
      case 'favorite':
        return Icons.favorite;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'category':
        return Icons.category;
      case 'grid_view':
        return Icons.grid_view;
      case 'map':
        return Icons.map;
      case 'map_outlined':
        return Icons.map_outlined;

      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'receipt':
        return Icons.receipt;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'history':
        return Icons.history;
      case 'assignment':
        return Icons.assignment;
      case 'description':
        return Icons.description;

      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'shopping_cart_outlined':
        return Icons.shopping_cart_outlined;
      case 'shopping_basket':
        return Icons.shopping_basket;
      case 'add_shopping_cart':
        return Icons.add_shopping_cart;
      case 'production_quantity_limits':
        return Icons.production_quantity_limits;

      case 'trending_up':
        return Icons.trending_up;
      case 'trending_up_outlined':
        return Icons.trending_up_outlined;

      case 'star':
        return Icons.star;
      case 'star_border':
        return Icons.star_border;
      case 'thumb_up':
        return Icons.thumb_up;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'commute':
        return Icons.commute;

      case 'menu':
        return Icons.menu;
      case 'menu_open':
        return Icons.menu_open;
      case 'person':
        return Icons.person;
      case 'person_outline':
        return Icons.person_outline;
      case 'settings':
        return Icons.settings;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'widgets':
        return Icons.widgets;

      case 'near_me':
        return Icons.near_me;
      case 'near_me_outlined':
        return Icons.near_me_outlined;
      case 'local_offer':
        return Icons.local_offer;
      case 'local_offer_outlined':
        return Icons.local_offer_outlined;
      case 'redeem':
        return Icons.redeem;
      case 'campaign':
        return Icons.campaign;
      case 'discount':
        return Icons.discount;

      case 'assignment':
        return Icons.assignment;
      case 'receipt':
        return Icons.receipt;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'history':
        return Icons.history;
      case 'description':
        return Icons.description;
      case 'list_alt':
        return Icons.list_alt;
      case 'track_changes':
        return Icons.track_changes;

      default:
        return null;
    }
  }
}
