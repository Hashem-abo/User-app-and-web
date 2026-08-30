import 'package:get/get.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';

// class SplashRouteHelper{

  void route({NotificationBodyModel? body}) {
    double? minimumVersion = _getMinimumVersion();
    bool isMaintenanceMode = Get.find<SplashController>().configModel!.maintenanceMode!;
    bool needsUpdate = AppConstants.appVersion < minimumVersion!;

    if(needsUpdate || isMaintenanceMode) {
      Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
    }else if(!GetPlatform.isWeb){
      if(body != null) {
        _forNotificationRouteProcess(body);
      }else {
        _handleUserRouting();
      }
    }
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }
    return 0;
  }

  void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
    final notificationType = notificationBody?.notificationType;

    final Map<NotificationType, Function> notificationActions = {
      NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationBody!.orderId, fromNotification: true)),
      NotificationType.block: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
      NotificationType.unblock: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
      NotificationType.message: () =>  Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationID: notificationBody!.conversationId, fromNotification: true)),
      NotificationType.otp: () => null,
      NotificationType.add_fund: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
      NotificationType.referral_earn: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
      NotificationType.cashback: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
      NotificationType.loyalty_point: () => Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true)),
      NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
    };

    notificationActions[notificationType]?.call();
  }

  Future<void> _forLoggedInUserRouteProcess() async {
    Get.find<AuthController>().updateToken();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      if(Get.find<SplashController>().module != null) {
        await Get.find<FavouriteController>().getFavouriteList();
      }
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  void _newlyRegisteredRouteProcess() {
    Get.offNamed(RouteHelper.getOnBoardingRoute());
  }

  void _forGuestUserRouteProcess() {
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  Future<void> _handleUserRouting() async {
    await _initDefaultAddress();
    if (AuthHelper.isLoggedIn()) {
      _forLoggedInUserRouteProcess();
    } else if (Get.find<SplashController>().showIntro() == true) {
      if (Get.find<SplashController>().configModel != null && Get.find<SplashController>().configModel!.onboardingScreens != null && Get.find<SplashController>().configModel!.onboardingScreens!.isNotEmpty) {
        _newlyRegisteredRouteProcess();
      } else {
        Get.find<SplashController>().disableIntro();
        _forGuestUserRouteProcess();
      }
    } else if (AuthHelper.isGuestLoggedIn()) {
      _forGuestUserRouteProcess();
    } else {
      await Get.find<AuthController>().guestLogin();
      _forGuestUserRouteProcess();
    }
  }
// }

Future<void> _initDefaultAddress() async {
  if (AddressHelper.getUserAddressFromSharedPref() == null) {
    AddressModel defaultAddress = AddressModel(
      latitude: '15.369445',
      longitude: '44.191006',
      address: "صنعاء، اليمن",
      addressType: 'others',
      zoneId: 1,
      zoneIds: [1],
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