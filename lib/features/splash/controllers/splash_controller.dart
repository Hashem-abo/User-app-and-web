import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/splash/domain/models/landing_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/controllers/taxi_favourite_controller.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_cart_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/splash/domain/services/splash_service_interface.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:universal_html/html.dart' as html;
import 'package:app_links/app_links.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _deepLinkUri;

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  ModuleModel? _module;
  ModuleModel? get module => _module;

  ModuleModel? _cacheModule;
  ModuleModel? get cacheModule => _cacheModule;

  List<ModuleModel>? _moduleList;
  List<ModuleModel>? get moduleList => _moduleList;

  int _moduleIndex = 0;
  int get moduleIndex => _moduleIndex;

  Map<String, dynamic>? _data = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedModuleIndex = 0;
  int get selectedModuleIndex => _selectedModuleIndex;

  LandingModel? _landingModel;
  LandingModel? get landingModel => _landingModel;

  bool _savedCookiesData = false;
  bool get savedCookiesData => _savedCookiesData;

  bool _webSuggestedLocation = false;
  bool get webSuggestedLocation => _webSuggestedLocation;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  bool _showReferBottomSheet = false;
  bool get showReferBottomSheet => _showReferBottomSheet;

  bool _isFloatingAdClosed = false;
  bool get isFloatingAdClosed => _isFloatingAdClosed;

  void closeFloatingAd() {
    _isFloatingAdClosed = true;
    update();
  }
  bool _videoFinished = false;
  bool get videoFinished => _videoFinished;

  void setVideoFinished() {
    _videoFinished = true;
    update(); // This triggers the UI to refresh
  }

  DateTime get currentTime => DateTime.now();

  void selectModuleIndex(int index) {
    _selectedModuleIndex = index;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    initDeepLinks();
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }

  void initDeepLinks() async {
    // Check initial link
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    // Subscribe to links
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Deep link stream error: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');
    _deepLinkUri = uri;

    // If we are already past splash, navigate immediately
    if (_configModel != null && Get.currentRoute != RouteHelper.splash) {
      _navigateDeepLink(uri);
    }
  }

  void _navigateDeepLink(Uri uri) {
    String? ref = uri.queryParameters['ref'];
    if (ref != null && ref.isNotEmpty) {
      Get.find<AuthController>().saveProductRefCode(ref);
    }

    if (uri.path.contains(RouteHelper.itemDetails)) {
      String? id = uri.queryParameters['id'];
      String? page = uri.queryParameters['page'];
      if (id != null) {
        Get.toNamed(RouteHelper.getItemDetailsRoute(int.parse(id), page == 'restaurant'));
      }
    } else if (uri.path.contains(RouteHelper.store)) {
      String? id = uri.queryParameters['id'];
      String? page = uri.queryParameters['page'];
      if (id != null) {
        Get.toNamed(RouteHelper.getStoreRoute(id: int.parse(id), page: page ?? 'item'));
      }
    }
    _deepLinkUri = null;
  }

  Future<void> getConfigData({NotificationBodyModel? notificationBody, bool loadModuleData = false, bool loadLandingData = false, DataSourceEnum source = DataSourceEnum.local, bool fromMainFunction = false, bool fromDemoReset = false}) async {
    _hasConnection = true;
    _moduleIndex = 0;
    Response response;
    if(source == DataSourceEnum.local && !fromDemoReset) {
      response = await splashServiceInterface.getConfigData(source: DataSourceEnum.local);
      _handleConfigResponse(response, loadModuleData, loadLandingData, fromMainFunction, fromDemoReset, notificationBody);
      getConfigData(loadModuleData: loadModuleData, loadLandingData: loadLandingData, source: DataSourceEnum.client);

    } else {
      response = await splashServiceInterface.getConfigData(source: DataSourceEnum.client);
      _handleConfigResponse(response, loadModuleData, loadLandingData, fromMainFunction, fromDemoReset, notificationBody);
    }

  }

  Future<void> _handleConfigResponse(Response response, bool loadModuleData, bool loadLandingData, bool fromMainFunction, bool fromDemoReset, NotificationBodyModel? notificationBody) async {
    if(response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      if(_configModel!.module != null) {
        setModule(_configModel!.module);
      }else if(GetPlatform.isWeb || _module != null) {
        setModule(GetPlatform.isWeb ? splashServiceInterface.getModule() : _module);
      }
      if(loadLandingData){
        await getLandingPageData();
      }
      if(fromMainFunction) {
        _mainConfigRouting();
      } else if (fromDemoReset) {
        Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
      } else {
        route(body: notificationBody);
      }
      _onRemoveLoader();
    }else {
      if(response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
    }
    update();
  }

  Future<void> _mainConfigRouting() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<AuthController>().updateToken();
      if(Get.find<SplashController>().module != null) {
       // await Get.find<FavouriteController>().getFavouriteList();
      }
    }
  }

  Future<void> route({NotificationBodyModel? body}) async {
    int duration = 1;
    if(_cacheModule?.splashScreenImageFullUrl != null || _module?.splashScreenImageFullUrl != null) {
      duration = 4;
    }
    Timer(Duration(seconds: duration), () async {
      double? minimumVersion = _getMinimumVersion();
      double? latestVersion = _getLatestVersion();
      bool isMaintenanceMode = _configModel!.maintenanceMode!;
      bool needsUpdate = AppConstants.appVersion < minimumVersion!;
      bool canUpdate = AppConstants.appVersion < latestVersion!;

      if(needsUpdate || isMaintenanceMode) {
        Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
      } else if (canUpdate) {
        Get.offNamed(RouteHelper.getUpdateRoute(true, isOptional: true));
      } else {
        if(body != null) {
          _forNotificationRouteProcess(body);
        }else {
          _handleUserRouting();
        }
      }
    });
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return _configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return _configModel!.appMinimumVersionIos;
    }
    return 0;
  }

  double? _getLatestVersion() {
    if (GetPlatform.isAndroid) {
      return _configModel!.appLatestVersionAndroid ?? 0;
    } else if (GetPlatform.isIOS) {
      return _configModel!.appLatestVersionIos ?? 0;
    }
    return 0;
  }

  void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
    if (notificationBody?.notificationType == NotificationType.order) {
      Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationBody!.orderId, fromNotification: true));
    } else if (notificationBody?.notificationType == NotificationType.block) {
      Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification));
    } else if (notificationBody?.notificationType == NotificationType.unblock) {
      Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification));
    } else if (notificationBody?.notificationType == NotificationType.message) {
      Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationID: notificationBody!.conversationId, fromNotification: true));
    } else if (notificationBody?.notificationType == NotificationType.otp) {
      // null;
    } else if (notificationBody?.notificationType == NotificationType.add_fund) {
      Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true));
    } else if (notificationBody?.notificationType == NotificationType.referral_earn) {
      Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true));
    } else if (notificationBody?.notificationType == NotificationType.cashback) {
      Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true));
    } else if (notificationBody?.notificationType == NotificationType.loyalty_point) {
      Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true));
    } else if (notificationBody?.notificationType == NotificationType.general) {
      Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
    }
  }

  Future<void> _handleUserRouting() async {
    // + ahmed: Ensure guest login first so APIs (getZone, getModules) have a token
    if (!AuthHelper.isLoggedIn() && !AuthHelper.isGuestLoggedIn()) {
      await Get.find<AuthController>().guestLogin();
    }

    // ahmed: Initialize default address (Sanaa) if not set to skip location permission on first run
    await _initDefaultAddress();

    // Auto-select module if not set to skip Home Screen module selection
    if (Get.find<SplashController>().module == null) {
      try {
        await getModules(dataSource: DataSourceEnum.client);
        if (_moduleList != null && _moduleList!.isNotEmpty) {
           ModuleModel? targetModule = _moduleList![0];
           await setModule(targetModule, notify: true);
           try {
             if(targetModule.moduleType.toString() != AppConstants.taxi) {
                Get.find<CartController>().getCartDataOnline();
                Get.find<ItemController>().clearItemLists();
                Get.find<BannerController>().clearBanner();
                Get.find<CategoryController>().clearCategoryList();
                Get.find<CampaignController>().itemAndBasicCampaignNull();
                Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: true);

                if(AuthHelper.isLoggedIn()) {
                  Get.find<HomeController>().getCashBackOfferList();
                }
             } else {
                 if(AuthHelper.isLoggedIn()) {
                   Get.find<HomeController>().getCashBackOfferList();
                 }
                 Get.find<TaxiCartController>().getCarCartList();
             }
           } catch (e) {
             debugPrint('Error preparing module data: $e');
           }
                 }
      } catch (e) {
        debugPrint('Error during auto-module selection: $e');
      }
    }

    if (AuthHelper.isLoggedIn()) {
      await _forLoggedInUserRouteProcess();
    } else if (showIntro() == true) {
      if (_configModel != null && _configModel!.onboardingScreens != null && _configModel!.onboardingScreens!.isNotEmpty) {
        _newlyRegisteredRouteProcess();
      } else {
        disableIntro();
        _forGuestUserRouteProcess();
      }
    } else if (AuthHelper.isGuestLoggedIn()) {
      _forGuestUserRouteProcess();
    } else {
      // Already logged in as guest at the top
      _forGuestUserRouteProcess();
    }
  }

  Future<void> _forLoggedInUserRouteProcess() async {
    Get.find<AuthController>().updateToken();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      if(Get.find<SplashController>().module != null) {
       // await Get.find<FavouriteController>().getFavouriteList();
      }
      if(_deepLinkUri != null) {
        Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
        _navigateDeepLink(_deepLinkUri!);
      } else {
        Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
      }
    } else {
      Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  void _newlyRegisteredRouteProcess() {
    Get.offNamed(RouteHelper.getOnBoardingRoute());
  }

  void _forGuestUserRouteProcess() {
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      if(_deepLinkUri != null) {
        Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
        _navigateDeepLink(_deepLinkUri!);
      } else {
        Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
      }
    } else {
      Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  void _onRemoveLoader() {
    final preloader = html.document.querySelector('.preloader');
    if (preloader != null) {
      preloader.remove();
    }
  }

  Future<void> getLandingPageData({DataSourceEnum source = DataSourceEnum.local}) async {
    LandingModel? landingModel;
    if(source == DataSourceEnum.local) {
      landingModel = await splashServiceInterface.getLandingPageData(source: DataSourceEnum.local);
      _prepareLandingModel(landingModel);
      getLandingPageData(source: DataSourceEnum.client);
    } else {
      landingModel = await splashServiceInterface.getLandingPageData(source: DataSourceEnum.client);
      _prepareLandingModel(landingModel);
    }

  }

  void _prepareLandingModel(LandingModel? landingModel) {
    if(landingModel != null) {
      _landingModel = landingModel;
      hoverStates = List<bool>.generate(_landingModel!.availableZoneList!.length, (index) => false);
    }
    update();
  }

  Future<void> initSharedData() async {
    _module = await splashServiceInterface.initSharedData();
    _cacheModule = splashServiceInterface.getCacheModule();
    setModule(_module, notify: false);
  }

  void setCacheConfigModule(ModuleModel? cacheModule) {
    _configModel!.moduleConfig!.module = Module.fromJson(_data!['module_config'][cacheModule!.moduleType]);
  }

  bool? showIntro() {
    return splashServiceInterface.showIntro();
  }

  void disableIntro() {
    splashServiceInterface.disableIntro();
  }

  bool showLoginSuggestion() {
    return splashServiceInterface.showLoginSuggestion();
  }

  void disableLoginSuggestion() {
    splashServiceInterface.disableLoginSuggestion();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  Future<void> setModule(ModuleModel? module, {bool notify = true}) async {
    _isFloatingAdClosed = false;
    _module = module;
    splashServiceInterface.setModule(module);

    AddressModel? addressModel = AddressHelper.getUserAddressFromSharedPref();
    Get.find<ApiClient>().updateHeader(
      Get.find<ApiClient>().token,
      addressModel?.zoneIds,
      addressModel?.areaIds,
      Get.find<LocalizationController>().locale.languageCode,
      module?.id,
      addressModel?.latitude,
      addressModel?.longitude,
    );

    if(module != null) {
      if(module.primaryColor != null) {
        String colorCode = module.primaryColor!.replaceAll('#', '');
        if(colorCode.length == 6) {
          Get.find<ThemeController>().changePrimaryColor(Color(int.parse('0xFF$colorCode')));
        }
      }
      if(_configModel != null) {
        _configModel!.moduleConfig!.module = Module.fromJson(_data!['module_config'][module.moduleType]);
      }
      _cacheModule = await splashServiceInterface.setCacheModule(module);
      if((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) && cacheModule != null) {
        if(cacheModule!.moduleType.toString() == AppConstants.globalShopping) {
          Get.find<GlobalCartController>().getCartList();
        } else {
          Get.find<CartController>().filterCartForModuleLocal(module == null ? null : module.id);
          Get.find<CartController>().getCartDataOnline();
        }
      }
    }

    if(_cacheModule != null && _cacheModule!.moduleType.toString() == AppConstants.taxi) {
      Get.find<TaxiCartController>().getCarCartList();
    }

    if(_cacheModule != null && _cacheModule!.moduleType.toString() == AppConstants.globalShopping) {
      Get.find<GlobalCartController>().getCartList();
    }

    if(_cacheModule != null && _cacheModule!.moduleType.toString() == AppConstants.services) {
      Get.find<ServiceController>().getCategories();
      Get.find<ServiceController>().getProviders();
    }

    if(AuthHelper.isLoggedIn()) {
      if(Get.find<SplashController>().module != null) {
        Get.find<HomeController>().getCashBackOfferList();
        if(module?.moduleType.toString() == AppConstants.taxi) {
          Get.find<TaxiFavouriteController>().getFavouriteTaxiList();
        } else {
         // Get.find<FavouriteController>().getFavouriteList();
        }
      } else if (_cacheModule != null && _cacheModule!.moduleType.toString() == AppConstants.taxi){
        Get.find<TaxiCartController>().getCarCartList();
      }
    }
    if(notify) {
      update();
    }
  }

  Module getModuleConfig(String? moduleType) {
    if (_data != null && _data!['module_config'] != null && _data!['module_config'][moduleType] != null) {
      Module module = Module.fromJson(_data!['module_config'][moduleType]);
      moduleType == 'food' ? module.newVariation = true : module.newVariation = false;
      return module;
    }
    return Module(newVariation: moduleType == 'food');
  }

  Future<void> getModules({Map<String, String>? headers, DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _moduleIndex = 0;
    List<ModuleModel>? moduleList;
    if(dataSource == DataSourceEnum.local) {
      moduleList = await splashServiceInterface.getModules(headers: headers, source: DataSourceEnum.local);
      _prepareModuleList(moduleList);
      getModules(headers: headers, dataSource: DataSourceEnum.client);
    } else {
      moduleList = await splashServiceInterface.getModules(headers: headers, source: DataSourceEnum.client);
      _prepareModuleList(moduleList);
    }

  }

  void setModuleList(List<ModuleModel>? moduleList) {
    _prepareModuleList(moduleList);
    update();
  }

  void _prepareModuleList(List<ModuleModel>? moduleList) {
    if (moduleList != null) {
      _moduleList = [];
      for (var module in moduleList) {
        if(module.moduleType != AppConstants.taxi && GetPlatform.isWeb) {
          _moduleList!.add(module);
        } else if(!GetPlatform.isWeb) {
          _moduleList!.add(module);
        }
      }
      // if (_module != null && !_moduleList!.any((m) => m.id == _module!.id || m.moduleType == _module!.moduleType)) {
      //   _moduleList!.add(_module!);
      // }
      if (_moduleList!.isNotEmpty) {
        if (_module == null) {
           setModule(_moduleList![0]);
        } else {
          int index = _moduleList!.indexWhere((module) => module.id == _module!.id);
          if (index != -1) {
            setModule(_moduleList![index]);
            if(_configModel != null && _configModel!.module != null && _configModel!.module!.id == _moduleList![index].id) {
               _configModel!.module = _moduleList![index];
            }
          } else {
            setModule(null);
          }
        }
      }
    }
    update();
  }

  Future<void> _showInterestPage() async {
    final userInfo = Get.find<ProfileController>().userInfoModel;
    if(userInfo != null && userInfo.selectedModuleForInterest != null 
        && !userInfo.selectedModuleForInterest!.contains(Get.find<SplashController>().module!.id)
        && (Get.find<SplashController>().module!.moduleType == 'food' || Get.find<SplashController>().module!.moduleType == 'grocery' || Get.find<SplashController>().module!.moduleType == 'ecommerce')
    ) {
      await Get.find<CategoryController>().getCategoryList(true, allCategory: false).then((_) async {
        if(Get.find<CategoryController>().categoryList != null && Get.find<CategoryController>().categoryList!.isNotEmpty){
          await Get.toNamed(RouteHelper.getInterestRoute());
        }else{
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      });
    }
  }

  Future<void> switchModule(int index, bool fromPhone) async {
    if(_module == null || _module!.id != _moduleList![index].id) {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator ?? false) {
        Vibration.vibrate(duration: 30);
      }
      await Get.find<SplashController>().setModule(_moduleList![index]);

      if(_module!.moduleType.toString() == AppConstants.globalShopping) {
        Get.find<GlobalCartController>().getCartList();
      } else if(_module!.moduleType.toString() != AppConstants.taxi) {
        Get.find<CartController>().getCartDataOnline();
        Get.find<ItemController>().clearItemLists();
        Get.find<BannerController>().clearBanner();
        Get.find<CategoryController>().clearCategoryList();
        Get.find<CampaignController>().itemAndBasicCampaignNull();
        Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: true);
        Get.find<StoreController>().getPopularStoreList(true, 'all', false);
        Get.find<StoreController>().getLatestStoreList(true, 'all', false);
        Get.find<StoreController>().getFeaturedStoreList();

        if(AuthHelper.isLoggedIn()) {
          Get.find<HomeController>().getCashBackOfferList();
          await _showInterestPage();
        }
        HomeScreen.loadData(true, fromModule: true);
      } else {
        if(AuthHelper.isLoggedIn()) {
          Get.find<HomeController>().getCashBackOfferList();
        }
        Get.find<TaxiCartController>().getCarCartList();
      }
    }
  }

  int getCacheModule() {
    return splashServiceInterface.getCacheModule()?.id ?? 0;
  }

  void setModuleIndex(int index) {
    _moduleIndex = index;
    update();
  }

  void removeModule() {
    setModule(null);
    Get.find<BannerController>().getFeaturedBanner();
    getModules();
    Get.find<HomeController>().forcefullyNullCashBackOffers();
    if(AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
    Get.find<StoreController>().getFeaturedStoreList();
    Get.find<CampaignController>().itemAndBasicCampaignNull();
  }

  Future<void> removeCacheModule() async {
    _cacheModule = await splashServiceInterface.setCacheModule(null);
  }

  Future<bool> subscribeMail(String email) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await splashServiceInterface.subscribeEmail(email);
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
    }else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  void saveCookiesData(bool data) {
    splashServiceInterface.saveCookiesData(data);
    _savedCookiesData = true;
    update();
  }

  void getCookiesData(){
    _savedCookiesData = splashServiceInterface.getSavedCookiesData();
    update();
  }

  void cookiesStatusChange(String? data) {
    splashServiceInterface.cookiesStatusChange(data);
  }

  bool getAcceptCookiesStatus(String data) => splashServiceInterface.getAcceptCookiesStatus(data);


  void saveWebSuggestedLocationStatus(bool data) {
    splashServiceInterface.saveSuggestedLocationStatus(data);
    _webSuggestedLocation = true;
    update();
  }

  void getWebSuggestedLocationStatus(){
    _webSuggestedLocation = splashServiceInterface.getSuggestedLocationStatus();
  }

  void setRefreshing(bool status) {
    _isRefreshing = status;
    update();
  }

  void saveReferBottomSheetStatus(bool data) {
    splashServiceInterface.saveReferBottomSheetStatus(data);
    _showReferBottomSheet = data;
    update();
  }

  void getReferBottomSheetStatus(){
    _showReferBottomSheet = splashServiceInterface.getReferBottomSheetStatus();
  }

  var hoverStates = <bool>[];

  void setHover(int index, bool state) {
    hoverStates[index] = state;
    update();
  }

  // ahmed: Helper method to set default location to Sana'a if no user address exists
  Future<void> _initDefaultAddress() async {
    if (AddressHelper.getUserAddressFromSharedPref() == null) {
      AddressModel defaultAddress = AddressModel(
        latitude: '15.369445',
        longitude: '44.191006',
        address: "Sana'a, Yemen",
        addressType: 'others',
      );
      try {
        var response = await Get.find<LocationController>().getZone(defaultAddress.latitude, defaultAddress.longitude, false);
        if(response.isSuccess) {
          defaultAddress.zoneId = response.zoneIds[0];
          defaultAddress.zoneIds = response.zoneIds;
          defaultAddress.zoneData = response.zoneData;
          defaultAddress.areaIds = response.areaIds;
        }
      } catch(e) {
        // ignore
      }
      await AddressHelper.saveUserAddressInSharedPref(defaultAddress);
    }
  }
  // Pro feature status — reads from config model
  bool get proStaus => _configModel?.proMemberStatus ?? false;

}