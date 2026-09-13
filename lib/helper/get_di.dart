import 'package:suliman/features/bnpl_credit/controllers/customer_credit_controller.dart';
import 'dart:convert';
import 'package:suliman/features/brands/controllers/brands_controller.dart';
import 'package:suliman/features/trends/controllers/trends_controller.dart';
import 'package:suliman/features/brands/domain/repositories/brands_repository.dart';
import 'package:suliman/features/global_shopping/domain/repositories/global_shopping_repository_interface.dart';
import 'package:suliman/features/global_shopping/domain/repositories/global_shopping_repository.dart';
import 'package:suliman/features/global_shopping/domain/services/global_shopping_service_interface.dart';
import 'package:suliman/features/global_shopping/domain/services/global_shopping_service.dart';
import 'package:suliman/features/global_shopping/controllers/global_browse_controller.dart';
import 'package:suliman/features/global_shopping/controllers/global_cart_controller.dart';
import 'package:suliman/features/global_shopping/controllers/global_order_controller.dart';
import 'package:suliman/features/brands/domain/repositories/brands_repository_interface.dart';
import 'package:suliman/features/brands/domain/services/brands_service.dart';
import 'package:suliman/features/brands/domain/services/brands_service_interface.dart';
import 'package:suliman/features/business/controllers/business_controller.dart';
import 'package:suliman/features/business/domain/repositories/business_repo.dart';
import 'package:suliman/features/business/domain/repositories/business_repo_interface.dart';
import 'package:suliman/features/business/domain/services/business_service.dart';
import 'package:suliman/features/business/domain/services/business_service_interface.dart';
import 'package:suliman/features/coupon/domain/repositories/coupon_repository.dart';
import 'package:suliman/features/coupon/domain/repositories/coupon_repository_interface.dart';
import 'package:suliman/features/home/domain/services/home_service_interface.dart';
import 'package:suliman/features/home/controllers/home_controller.dart';
import 'package:suliman/features/home/controllers/advertisement_controller.dart';
import 'package:suliman/features/home/controllers/store_corner_controller.dart';
import 'package:suliman/features/home/domain/repositories/home_repository.dart';
import 'package:suliman/features/home/domain/repositories/home_repository_interface.dart';
import 'package:suliman/features/home/domain/repositories/advertisement_repository.dart';
import 'package:suliman/features/home/domain/repositories/advertisement_repository_interface.dart';
import 'package:suliman/features/home/domain/repositories/store_corner_repository.dart';
import 'package:suliman/features/home/domain/services/home_service.dart';
import 'package:suliman/features/home/domain/services/advertisement_service.dart';
import 'package:suliman/features/home/domain/services/advertisement_service_interface.dart';
import 'package:suliman/features/home/domain/services/store_corner_service.dart';
import 'package:suliman/features/home/controllers/super_banner_controller.dart';
import 'package:suliman/features/home/domain/repositories/super_banner_repository.dart';
import 'package:suliman/features/home/domain/repositories/super_banner_repository_interface.dart';
import 'package:suliman/features/cart/controllers/cart_controller.dart';
import 'package:suliman/features/banner/controllers/banner_controller.dart';
import 'package:suliman/features/banner/domain/repositories/banner_repository.dart';
import 'package:suliman/features/banner/domain/repositories/banner_repository_interface.dart';
import 'package:suliman/features/banner/domain/services/banner_service.dart';
import 'package:suliman/features/banner/domain/services/banner_service_interface.dart';
import 'package:suliman/features/cart/domain/repositories/cart_repository.dart';
import 'package:suliman/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:suliman/features/cart/domain/services/cart_service.dart';
import 'package:suliman/features/cart/domain/services/cart_service_interface.dart';
import 'package:suliman/features/category/controllers/category_controller.dart';
import 'package:suliman/features/category/domain/reposotories/category_repository.dart';
import 'package:suliman/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:suliman/features/category/domain/services/category_service.dart';
import 'package:suliman/features/category/domain/services/category_service_interface.dart';
import 'package:suliman/features/chat/controllers/chat_controller.dart';
import 'package:suliman/features/chat/domain/repositories/chat_repository.dart';
import 'package:suliman/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:suliman/features/chat/domain/services/chat_service.dart';
import 'package:suliman/features/chat/domain/services/chat_service_interface.dart';
import 'package:suliman/features/coupon/controllers/coupon_controller.dart';
import 'package:suliman/features/coupon/domain/services/coupon_service.dart';
import 'package:suliman/features/coupon/domain/services/coupon_service_interface.dart';
import 'package:suliman/features/favourite/controllers/favourite_controller.dart';
import 'package:suliman/features/favourite/controllers/wish_list_controller.dart';
import 'package:suliman/features/favourite/domain/repositories/favourite_repository.dart';
import 'package:suliman/features/favourite/domain/repositories/favourite_repository_interface.dart';
import 'package:suliman/features/favourite/domain/services/favourite_service.dart';
import 'package:suliman/features/favourite/domain/services/favourite_service_interface.dart';
import 'package:suliman/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:suliman/features/flash_sale/domain/repositories/flash_sale_repository.dart';
import 'package:suliman/features/flash_sale/domain/repositories/flash_sale_repository_interface.dart';
import 'package:suliman/features/flash_sale/domain/services/flash_sale_service.dart';
import 'package:suliman/features/flash_sale/domain/services/flash_sale_service_interface.dart';
import 'package:suliman/features/html/controllers/html_controller.dart';
import 'package:suliman/features/html/domain/repositories/html_repository.dart';
import 'package:suliman/features/html/domain/repositories/html_repository_interface.dart';
import 'package:suliman/features/html/domain/services/html_service.dart';
import 'package:suliman/features/html/domain/services/html_service_interface.dart';
import 'package:suliman/features/item/controllers/campaign_controller.dart';
import 'package:suliman/features/item/controllers/item_controller.dart';
import 'package:suliman/features/item/domain/repositories/campaign_repository.dart';
import 'package:suliman/features/item/domain/repositories/campaign_repository_interface.dart';
import 'package:suliman/features/item/domain/repositories/item_repository.dart';
import 'package:suliman/features/item/domain/repositories/item_repository_interface.dart';
import 'package:suliman/features/item/domain/services/campaign_service.dart';
import 'package:suliman/features/item/domain/services/campaign_service_interface.dart';
import 'package:suliman/features/item/domain/services/item_service.dart';
import 'package:suliman/features/item/domain/services/item_service_interface.dart';
import 'package:suliman/features/language/controllers/language_controller.dart';
import 'package:suliman/features/language/domain/repository/language_repository.dart';
import 'package:suliman/features/language/domain/repository/language_repository_interface.dart';
import 'package:suliman/features/language/domain/service/language_service.dart';
import 'package:suliman/features/language/domain/service/language_service_interface.dart';
import 'package:suliman/features/location/controllers/location_controller.dart';
import 'package:suliman/common/controllers/theme_controller.dart';
import 'package:suliman/api/api_client.dart';
import 'package:suliman/features/address/controllers/address_controller.dart';
import 'package:suliman/features/address/domain/repositories/address_repository.dart';
import 'package:suliman/features/address/domain/repositories/address_repository_interface.dart';
import 'package:suliman/features/address/domain/services/address_service.dart';
import 'package:suliman/features/address/domain/services/address_service_interface.dart';
import 'package:suliman/features/suggestion/controllers/suggestion_controller.dart';
import 'package:suliman/features/suggestion/domain/repositories/suggestion_repository.dart';
import 'package:suliman/features/suggestion/domain/repositories/suggestion_repository_interface.dart';
import 'package:suliman/features/suggestion/domain/services/suggestion_service.dart';
import 'package:suliman/features/suggestion/domain/services/suggestion_service_interface.dart';
import 'package:suliman/features/auth/controllers/auth_controller.dart';
import 'package:suliman/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:suliman/features/auth/controllers/store_registration_controller.dart';
import 'package:suliman/features/auth/domain/reposotories/auth_repository.dart';
import 'package:suliman/features/auth/domain/reposotories/auth_repository_interface.dart';
import 'package:suliman/features/auth/domain/reposotories/deliveryman_registration_repository.dart';
import 'package:suliman/features/auth/domain/reposotories/deliveryman_registration_repository_interface.dart';
import 'package:suliman/features/auth/domain/reposotories/store_registration_repository.dart';
import 'package:suliman/features/auth/domain/reposotories/store_registration_repository_interface.dart';
import 'package:suliman/features/auth/domain/services/auth_service.dart';
import 'package:suliman/features/auth/domain/services/auth_service_interface.dart';
import 'package:suliman/features/auth/domain/services/deliveryman_registration_service.dart';
import 'package:suliman/features/auth/domain/services/deliveryman_registration_service_interface.dart';
import 'package:suliman/features/auth/domain/services/store_registration_service.dart';
import 'package:suliman/features/auth/domain/services/store_registration_service_interface.dart';
import 'package:suliman/features/checkout/controllers/checkout_controller.dart';
import 'package:suliman/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:suliman/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:suliman/features/checkout/domain/services/checkout_service.dart';
import 'package:suliman/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:suliman/features/location/domain/repositories/location_repository.dart';
import 'package:suliman/features/location/domain/repositories/location_repository_interface.dart';
import 'package:suliman/features/location/domain/services/location_service.dart';
import 'package:suliman/features/location/domain/services/location_service_interface.dart';
import 'package:suliman/features/loyalty/controllers/loyalty_controller.dart';
import 'package:suliman/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:suliman/features/loyalty/domain/repositories/loyalty_repository_interface.dart';
import 'package:suliman/features/loyalty/domain/services/loyalty_service.dart';
import 'package:suliman/features/loyalty/domain/services/loyalty_service_interface.dart';
import 'package:suliman/features/notification/controllers/notification_controller.dart';
import 'package:suliman/features/notification/domain/repository/notification_repository.dart';
import 'package:suliman/features/notification/domain/repository/notification_repository_interface.dart';
import 'package:suliman/features/notification/domain/service/notification_service.dart';
import 'package:suliman/features/notification/domain/service/notification_service_interface.dart';
import 'package:suliman/features/onboard/controllers/onboard_controller.dart';
import 'package:suliman/features/onboard/domain/repository/onboard_repository.dart';
import 'package:suliman/features/onboard/domain/repository/onboard_repository_interface.dart';
import 'package:suliman/features/onboard/domain/service/onboard_service.dart';
import 'package:suliman/features/onboard/domain/service/onboard_service_interface.dart';
import 'package:suliman/features/order/controllers/order_controller.dart';
import 'package:suliman/features/order/domain/repositories/order_repository.dart';
import 'package:suliman/features/order/domain/repositories/order_repository_interface.dart';
import 'package:suliman/features/order/domain/services/order_service.dart';
import 'package:suliman/features/order/domain/services/order_service_interface.dart';
import 'package:suliman/features/parcel/controllers/parcel_controller.dart';
import 'package:suliman/features/parcel/domain/repositories/parcel_repository.dart';
import 'package:suliman/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:suliman/features/parcel/domain/services/parcel_service.dart';
import 'package:suliman/features/parcel/domain/services/parcel_service_interface.dart';
import 'package:suliman/features/payment/controllers/payment_controller.dart';
import 'package:suliman/features/payment/domain/repositories/payement_repository.dart';
import 'package:suliman/features/payment/domain/repositories/payment_repository_interface.dart';
import 'package:suliman/features/payment/domain/services/payment_service.dart';
import 'package:suliman/features/payment/domain/services/payment_service_interface.dart';
import 'package:suliman/features/profile/controllers/profile_controller.dart';
import 'package:suliman/features/profile/domain/repositories/profile_repository.dart';
import 'package:suliman/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:suliman/features/profile/domain/services/profile_service.dart';
import 'package:suliman/features/profile/domain/services/profile_service_interface.dart';
import 'package:suliman/features/review/controllers/review_controller.dart';
import 'package:suliman/features/review/domain/repositories/review_repository.dart';
import 'package:suliman/features/review/domain/repositories/review_repository_interface.dart';
import 'package:suliman/features/review/domain/services/review_service.dart';
import 'package:suliman/features/review/domain/services/review_service_interface.dart';
import 'package:suliman/features/search/controllers/search_controller.dart';
import 'package:suliman/features/search/domain/repositories/search_repository.dart';
import 'package:suliman/features/search/domain/repositories/search_repository_interface.dart';
import 'package:suliman/features/search/domain/services/search_service.dart';
import 'package:suliman/features/search/domain/services/search_service_interface.dart';
import 'package:suliman/features/smart_shopping_list/controllers/smart_shopping_list_controller.dart';
import 'package:suliman/features/service/controllers/service_controller.dart';
import 'package:suliman/features/service/domain/repositories/service_repository.dart';
import 'package:suliman/features/service/domain/repositories/service_repository_interface.dart';
import 'package:suliman/features/service/domain/services/service_service.dart';
import 'package:suliman/features/service/domain/services/service_service_interface.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';
import 'package:suliman/features/splash/domain/repositories/splash_repository.dart';
import 'package:suliman/features/splash/domain/repositories/splash_repository_interface.dart';
import 'package:suliman/features/splash/domain/services/splash_service.dart';
import 'package:suliman/features/splash/domain/services/splash_service_interface.dart';
import 'package:suliman/features/store/controllers/store_controller.dart';
import 'package:suliman/features/store/domain/repositories/store_repository.dart';
import 'package:suliman/features/store/domain/repositories/store_repository_interface.dart';
import 'package:suliman/features/store/domain/services/store_service.dart';
import 'package:suliman/features/store/domain/services/store_service_interface.dart';
import 'package:suliman/features/pro/controllers/pro_controller.dart';
import 'package:suliman/features/pro/domain/repositories/pro_repository.dart';
import 'package:suliman/features/pro/domain/repositories/pro_repository_interface.dart';
import 'package:suliman/features/pro/domain/services/pro_service.dart';
import 'package:suliman/features/pro/domain/services/pro_service_interface.dart';
import 'package:suliman/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';
import 'package:suliman/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:suliman/features/rental_module/home/domain/repositories/taxi_home_repository.dart';
import 'package:suliman/features/rental_module/home/domain/repositories/taxi_home_repository_interface.dart';
import 'package:suliman/features/rental_module/home/domain/services/taxi_home_service.dart';
import 'package:suliman/features/rental_module/home/domain/services/taxi_home_service_interface.dart';
import 'package:suliman/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:suliman/features/rental_module/rental_cart_screen/domain/repository/taxi_cart_repository.dart';
import 'package:suliman/features/rental_module/rental_cart_screen/domain/repository/taxi_cart_repository_interface.dart';
import 'package:suliman/features/rental_module/rental_cart_screen/domain/services/taxi_cart_service.dart';
import 'package:suliman/features/rental_module/rental_cart_screen/domain/services/taxi_cart_service_interface.dart';
import 'package:suliman/features/rental_module/rental_favourite/controllers/taxi_favourite_controller.dart';
import 'package:suliman/features/rental_module/rental_favourite/domain/repositories/taxi_favourite_repository.dart';
import 'package:suliman/features/rental_module/rental_favourite/domain/repositories/taxi_favourite_repository_interface.dart';
import 'package:suliman/features/rental_module/rental_favourite/domain/services/taxi_favourite_service.dart';
import 'package:suliman/features/rental_module/rental_favourite/domain/services/taxi_favourite_service_interface.dart';
import 'package:suliman/features/rental_module/rental_location_screen/domain/repository/taxi_repository.dart';
import 'package:suliman/features/rental_module/rental_location_screen/domain/repository/taxi_repository_interface.dart';
import 'package:suliman/features/rental_module/rental_location_screen/domain/services/taxi_location_service.dart';
import 'package:suliman/features/rental_module/rental_location_screen/domain/services/taxi_location_service_interface.dart';
import 'package:suliman/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:suliman/features/rental_module/rental_order/domain/repository/taxi_order_repository.dart';
import 'package:suliman/features/rental_module/rental_order/domain/repository/taxi_order_repository_interface.dart';
import 'package:suliman/features/rental_module/rental_order/domain/services/taxi_order_service.dart';
import 'package:suliman/features/rental_module/rental_order/domain/services/taxi_order_service_interface.dart';
import 'package:suliman/features/rental_module/vendor/controllers/taxi_vendor_controller.dart';
import 'package:suliman/features/rental_module/vendor/domain/repositories/taxi_vendor_repository.dart';
import 'package:suliman/features/rental_module/vendor/domain/repositories/taxi_vendor_repository_interface.dart';
import 'package:suliman/features/rental_module/vendor/domain/services/taxi_vendor_service.dart';
import 'package:suliman/features/rental_module/vendor/domain/services/taxi_vendor_service_interface.dart';
import 'package:suliman/features/verification/controllers/verification_controller.dart';
import 'package:suliman/features/verification/domein/reposotories/verification_repository.dart';
import 'package:suliman/features/verification/domein/reposotories/verification_repository_interface.dart';
import 'package:suliman/features/verification/domein/services/verification_service.dart';
import 'package:suliman/features/verification/domein/services/verification_service_interface.dart';
import 'package:suliman/features/wallet/controllers/wallet_controller.dart';
import 'package:suliman/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:suliman/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:suliman/features/wallet/domain/services/wallet_service.dart';
import 'package:suliman/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:suliman/features/shelf/controllers/shelf_controller.dart';
import 'package:suliman/features/shelf/domain/repositories/shelf_repository.dart';
import 'package:suliman/features/shelf/domain/repositories/shelf_repository_interface.dart';
import 'package:suliman/features/shelf/domain/services/shelf_service.dart';
import 'package:suliman/features/shelf/domain/services/shelf_service_interface.dart';
import 'package:suliman/util/app_constants.dart';
import 'package:suliman/features/product_question/controllers/product_question_controller.dart';
import 'package:suliman/features/product_question/domain/repositories/product_question_repository.dart';
import 'package:suliman/features/product_question/domain/repositories/product_question_repository_interface.dart';
import 'package:suliman/features/product_question/domain/services/product_question_service.dart';
import 'package:suliman/features/product_question/domain/services/product_question_service_interface.dart';
import 'package:suliman/features/report/controllers/report_controller.dart';
import 'package:suliman/features/report/domain/repositories/report_repository.dart';
import 'package:suliman/features/report/domain/repositories/report_repository_interface.dart';
import 'package:suliman/features/report/domain/services/report_service.dart';
import 'package:suliman/features/report/domain/services/report_service_interface.dart';
import 'package:suliman/features/language/domain/models/language_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suliman/features/history/controllers/item_history_controller.dart';
import 'package:suliman/features/contact_share/controllers/contact_share_controller.dart';
import 'package:suliman/features/reels/controllers/reels_controller.dart';
import 'package:suliman/features/reels/domain/repositories/reels_repository.dart';
import 'package:suliman/features/reels/domain/repositories/reels_repository_interface.dart';
import 'package:suliman/features/reels/domain/services/reels_service.dart';
import 'package:suliman/features/reels/domain/services/reels_service_interface.dart';
import 'package:suliman/features/forum/controllers/forum_controller.dart';
import 'package:suliman/features/forum/domain/repositories/forum_repository.dart';
import 'package:suliman/features/forum/domain/repositories/forum_repository_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suliman/features/forum/domain/services/forum_service.dart';
import 'package:suliman/features/forum/domain/services/forum_service_interface.dart';
import 'package:get/get.dart';

Future<Map<String, Map<String, String>>> init() async {
  /// Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);

  const flutterSecureStorage = FlutterSecureStorage();
  // Use Get.put (eager) so the instance is immediately available for Get.find().
  Get.put<FlutterSecureStorage>(flutterSecureStorage);

  // Migrate legacy 6ammart keys to suliman keys if needed
  void migrateLegacyKey(String legacyKey, String newKey) {
    if (sharedPreferences.containsKey(legacyKey) && !sharedPreferences.containsKey(newKey)) {
      var val = sharedPreferences.get(legacyKey);
      if (val is String) {
        sharedPreferences.setString(newKey, val);
      } else if (val is bool) {
        sharedPreferences.setBool(newKey, val);
      } else if (val is int) {
        sharedPreferences.setInt(newKey, val);
      } else if (val is double) {
        sharedPreferences.setDouble(newKey, val);
      } else if (val is List<String>) {
        sharedPreferences.setStringList(newKey, val);
      }
    }
  }
  migrateLegacyKey('6ammart_token', AppConstants.token);
  migrateLegacyKey('6ammart_user_address', AppConstants.userAddress);
  migrateLegacyKey('6ammart_language_code', AppConstants.languageCode);
  migrateLegacyKey('6ammart_theme', AppConstants.theme);
  migrateLegacyKey('6ammart_cart_list', AppConstants.cartList);
  migrateLegacyKey('6ammart_guest_id', AppConstants.guestId);

  // Synchronize token between FlutterSecureStorage and SharedPreferences
  String? secureToken;
  try {
    secureToken = await flutterSecureStorage.read(key: AppConstants.token);
    if (secureToken == null || secureToken.isEmpty) {
      secureToken = await flutterSecureStorage.read(key: '6ammart_token');
    }
  } catch (_) {}
  String? spToken = sharedPreferences.getString(AppConstants.token);

  if (secureToken != null && secureToken.isNotEmpty) {
    if (spToken == null || spToken.isEmpty) {
      await sharedPreferences.setString(AppConstants.token, secureToken);
    }
  } else if (spToken != null && spToken.isNotEmpty) {
    try {
      await flutterSecureStorage.write(key: AppConstants.token, value: spToken);
    } catch (_) {}
    secureToken = spToken;
  }

  // Purge any stored passwords from SharedPreferences
  if (sharedPreferences.containsKey(AppConstants.userPassword)) {
    await sharedPreferences.remove(AppConstants.userPassword);
  }

  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find(), token: secureToken));

  /// Repository interface
  // Pass flutterSecureStorage directly — avoids nullable/non-nullable type mismatch with Get.find.
  Get.put<AuthRepositoryInterface>(AuthRepository(apiClient: Get.find(), sharedPreferences: Get.find(), secureStorage: flutterSecureStorage));

  Get.lazyPut<CheckoutRepositoryInterface>(() => CheckoutRepository(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut<LocationRepositoryInterface>(() => LocationRepository(apiClient: Get.find()), fenix: true);
  Get.lazyPut<DeliverymanRegistrationRepositoryInterface>(() => DeliverymanRegistrationRepository(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut<StoreRegistrationRepositoryInterface>(() => StoreRegistrationRepository(apiClient: Get.find()), fenix: true);
  Get.lazyPut<ParcelRepositoryInterface>(() => ParcelRepository(apiClient: Get.find()));
  Get.lazyPut<AddressRepositoryInterface>(() => AddressRepository(apiClient: Get.find()));
  Get.lazyPut<OrderRepositoryInterface>(() => OrderRepository(apiClient: Get.find()));
  Get.lazyPut<PaymentRepositoryInterface>(() => PaymentRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<CampaignRepositoryInterface>(() => CampaignRepository(apiClient: Get.find()));
  Get.lazyPut<ChatRepositoryInterface>(() => ChatRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<CouponRepositoryInterface>(() => CouponRepository(apiClient: Get.find()));
  Get.lazyPut<FavouriteRepositoryInterface>(() => FavouriteRepository(apiClient: Get.find()));
  Get.lazyPut<FlashSaleRepositoryInterface>(() => FlashSaleRepository(apiClient: Get.find()));
  Get.lazyPut<HomeRepositoryInterface>(() => HomeRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<BannerRepositoryInterface>(() => BannerRepository(apiClient: Get.find()));
  Get.lazyPut<HtmlRepositoryInterface>(() => HtmlRepository(apiClient: Get.find()));
  Get.lazyPut<LanguageRepositoryInterface>(() => LanguageRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<NotificationRepositoryInterface>(() => NotificationRepository(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut<OnboardRepositoryInterface>(() => OnboardRepository());
  Get.lazyPut<ProfileRepositoryInterface>(() => ProfileRepository(apiClient: Get.find()));
  Get.lazyPut<SearchRepositoryInterface>(() => SearchRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<SplashRepositoryInterface>(() => SplashRepository(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut<ReviewRepositoryInterface>(() => ReviewRepository(apiClient: Get.find()));
  Get.lazyPut<StoreRepositoryInterface>(() => StoreRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<WalletRepositoryInterface>(() => WalletRepository(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut<ItemRepositoryInterface>(() => ItemRepository(apiClient: Get.find()));
  Get.lazyPut<CategoryRepositoryInterface>(() => CategoryRepository(apiClient: Get.find()));
  Get.lazyPut<LoyaltyRepositoryInterface>(() => LoyaltyRepository(apiClient: Get.find()));
  Get.lazyPut<ProductQuestionRepositoryInterface>(() => ProductQuestionRepository(apiClient: Get.find()));
  Get.lazyPut<SuggestionRepositoryInterface>(() => SuggestionRepository(apiClient: Get.find()));
  Get.lazyPut<ForumRepositoryInterface>(() => ForumRepository(apiClient: Get.find()));
  Get.lazyPut<ReportRepositoryInterface>(() => ReportRepository(apiClient: Get.find()));
  Get.lazyPut<ShelfRepositoryInterface>(() => ShelfRepository(apiClient: Get.find()));
  Get.lazyPut<StoreCornerRepositoryInterface>(() => StoreCornerRepository(apiClient: Get.find()));
  Get.lazyPut<SuperBannerRepositoryInterface>(() => SuperBannerRepository(apiClient: Get.find()));
  Get.lazyPut<ServiceRepositoryInterface>(() => ServiceRepository(apiClient: Get.find()));

  Get.lazyPut<CartRepositoryInterface>(() => CartRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<VerificationRepositoryInterface>(() => VerificationRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<BrandsRepositoryInterface>(() => BrandsRepository(apiClient: Get.find()));
  Get.lazyPut<BusinessRepoInterface>(() => BusinessRepo(apiClient: Get.find()));
  Get.lazyPut<AdvertisementRepositoryInterface>(() => AdvertisementRepository(apiClient: Get.find()));
  Get.lazyPut<TaxiRepositoryInterface>(() => TaxiRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<TaxiHomeRepositoryInterface>(() => TaxiHomeRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<TaxiCartRepositoryInterface>(() => TaxiCartRepository(apiClient: Get.find()));
  Get.lazyPut<TaxiVendorRepositoryInterface>(() => TaxiVendorRepository(apiClient: Get.find()));
  Get.lazyPut<TaxiOrderRepositoryInterface>(() => TaxiOrderRepository(apiClient: Get.find()));
  Get.lazyPut<TaxiFavouriteRepositoryInterface>(() => TaxiFavouriteRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.put<GlobalShoppingRepositoryInterface>(GlobalShoppingRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<ProRepositoryInterface>(() => ProRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut<ReelsRepositoryInterface>(() => ReelsRepository(apiClient: Get.find()), fenix: true);

  /// Service Interface
  Get.lazyPut<CheckoutServiceInterface>(() => CheckoutService(checkoutRepositoryInterface: Get.find()), fenix: true);
  Get.lazyPut<AuthServiceInterface>(() => AuthService(authRepositoryInterface: Get.find()));
  Get.lazyPut<LocationServiceInterface>(() => LocationService(locationRepoInterface: Get.find()), fenix: true);
  Get.lazyPut<DeliverymanRegistrationServiceInterface>(() => DeliverymanRegistrationService(deliverymanRegistrationRepoInterface: Get.find(), authRepositoryInterface: Get.find()), fenix: true);
  Get.lazyPut<StoreRegistrationServiceInterface>(() => StoreRegistrationService(deliverymanRegistrationRepositoryInterface: Get.find(), storeRegistrationRepoInterface: Get.find()), fenix: true);
  Get.lazyPut<ParcelServiceInterface>(() => ParcelService(parcelRepositoryInterface: Get.find(), checkoutRepositoryInterface: Get.find()));
  Get.lazyPut<AddressServiceInterface>(() => AddressService(addressRepoInterface: Get.find()));
  Get.lazyPut<OrderServiceInterface>(() => OrderService(orderRepositoryInterface: Get.find()));
  Get.lazyPut<PaymentServiceInterface>(() => PaymentService(paymentRepositoryInterface: Get.find()));
  Get.lazyPut<CampaignServiceInterface>(() => CampaignService(campaignRepositoryInterface: Get.find()));
  Get.lazyPut<ChatServiceInterface>(() => ChatService(chatRepositoryInterface: Get.find()));
  Get.lazyPut<CouponServiceInterface>(() => CouponService(couponRepositoryInterface: Get.find()));
  Get.lazyPut<FavouriteServiceInterface>(() => FavouriteService(favouriteRepositoryInterface: Get.find()));
  Get.lazyPut<HomeServiceInterface>(() => HomeService(homeRepositoryInterface: Get.find()));
  Get.lazyPut<FlashSaleServiceInterface>(() => FlashSaleService(flashSaleRepositoryInterface: Get.find()));
  Get.lazyPut<BannerServiceInterface>(() => BannerService(bannerRepositoryInterface: Get.find()));
  Get.lazyPut<HtmlServiceInterface>(() => HtmlService(htmlRepositoryInterface: Get.find()));
  Get.lazyPut<LanguageServiceInterface>(() => LanguageService(languageRepositoryInterface: Get.find()));
  Get.lazyPut<NotificationServiceInterface>(() => NotificationService(notificationRepositoryInterface: Get.find()));
  Get.lazyPut<OnboardServiceInterface>(() => OnboardService(onboardRepositoryInterface: Get.find()));
  Get.lazyPut<ProfileServiceInterface>(() => ProfileService(profileRepositoryInterface: Get.find()));

  Get.lazyPut<SearchServiceInterface>(() => SearchService(searchRepositoryInterface: Get.find()));
  Get.lazyPut<SplashServiceInterface>(() => SplashService(splashRepositoryInterface: Get.find()));
  Get.lazyPut<ReviewServiceInterface>(() => ReviewService(reviewRepositoryInterface: Get.find()));
  Get.lazyPut<StoreServiceInterface>(() => StoreService(storeRepositoryInterface: Get.find()));
  Get.lazyPut<WalletServiceInterface>(() => WalletService(walletRepositoryInterface: Get.find()));
  Get.lazyPut<ItemServiceInterface>(() => ItemService(itemRepositoryInterface: Get.find()));
  Get.lazyPut<CategoryServiceInterface>(() => CategoryService(categoryRepositoryInterface: Get.find()));
  Get.lazyPut<LoyaltyServiceInterface>(() => LoyaltyService(loyaltyRepositoryInterface: Get.find()));
  Get.lazyPut<ProductQuestionServiceInterface>(() => ProductQuestionService(productQuestionRepositoryInterface: Get.find()));
  Get.lazyPut<SuggestionServiceInterface>(() => SuggestionService(suggestionRepositoryInterface: Get.find()));
  Get.lazyPut<ForumServiceInterface>(() => ForumService(forumRepository: Get.find()));
  Get.lazyPut<ReportServiceInterface>(() => ReportService(reportRepositoryInterface: Get.find()));
  Get.lazyPut<ShelfServiceInterface>(() => ShelfService(shelfRepositoryInterface: Get.find()));
  Get.lazyPut<ServiceServiceInterface>(() => ServiceService(serviceRepositoryInterface: Get.find()));
  Get.lazyPut<StoreCornerServiceInterface>(() => StoreCornerService(storeCornerRepositoryInterface: Get.find()));
  Get.lazyPut<CartServiceInterface>(() => CartService(cartRepositoryInterface: Get.find()));
  Get.lazyPut<VerificationServiceInterface>(() => VerificationService(verificationRepoInterface: Get.find(), authRepoInterface: Get.find()));
  Get.lazyPut<BrandsServiceInterface>(() => BrandsService(brandsRepositoryInterface: Get.find()));
  Get.lazyPut<BusinessServiceInterface>(() => BusinessService(businessRepoInterface: Get.find()));
  Get.lazyPut<AdvertisementServiceInterface>(() => AdvertisementService(advertisementRepositoryInterface: Get.find()));
  Get.lazyPut<TaxiLocationServiceInterface>(() => TaxiLocationService(taxiRepositoryInterface: Get.find()));
  Get.lazyPut<TaxiHomeServiceInterface>(() => TaxiHomeService(taxiHomeRepositoryInterface: Get.find()));
  Get.lazyPut<TaxiCartServiceInterface>(() => TaxiCartService(taxiCartRepositoryInterface: Get.find()));
  Get.lazyPut<TaxiVendorServiceInterface>(() => TaxiVendorService(taxiVendorRepositoryInterface: Get.find()));
  Get.lazyPut<TaxiOrderServiceInterface>(() => TaxiOrderService(taxiOrderRepositoryInterface: Get.find()));
  Get.lazyPut<TaxiFavouriteServiceInterface>(() => TaxiFavouriteService(taxiFavouriteRepositoryInterface: Get.find()));
  Get.put<GlobalShoppingServiceInterface>(GlobalShoppingService(repo: Get.find<GlobalShoppingRepositoryInterface>()));
  Get.lazyPut<ProServiceInterface>(() => ProService(proRepositoryInterface: Get.find()));
  Get.lazyPut<ReelsServiceInterface>(() => ReelsService(reelsRepositoryInterface: Get.find()), fenix: true);

    Get.lazyPut(() => CustomerCreditController(customerCreditServiceInterface: Get.find()));

  /// Controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashServiceInterface: Get.find()));
  Get.lazyPut(() => ProController(proServiceInterface: Get.find()));
  Get.lazyPut(() => AddressController(addressServiceInterface: Get.find()));
  Get.lazyPut(() => LocationController(locationServiceInterface: Get.find()));
  Get.lazyPut(() => LocalizationController(languageServiceInterface: Get.find()));
  Get.lazyPut(() => OnBoardingController(onboardServiceInterface: Get.find()));
  Get.lazyPut(() => AuthController(authServiceInterface: Get.find()));
  Get.lazyPut(() => DeliverymanRegistrationController(deliverymanRegistrationServiceInterface: Get.find()), fenix: true);
  Get.lazyPut(() => StoreRegistrationController(storeRegistrationServiceInterface: Get.find(), locationServiceInterface: Get.find()), fenix: true);
  Get.lazyPut(() => ProfileController(profileServiceInterface: Get.find()));
  Get.lazyPut(() => BannerController(bannerServiceInterface: Get.find()));
  Get.lazyPut(() => CategoryController(categoryServiceInterface: Get.find()));
  Get.lazyPut(() => ItemController(itemServiceInterface: Get.find()));
  Get.lazyPut(() => CartController(cartServiceInterface: Get.find()));
  Get.lazyPut(() => StoreController(storeServiceInterface: Get.find()));
  Get.lazyPut(() => FavouriteController(favouriteServiceInterface: Get.find()));
  Get.lazyPut(() => WishListController(sharedPreferences: Get.find()));
  Get.lazyPut(() => HomeController(homeServiceInterface: Get.find()));
  Get.lazyPut(() => ReelsController(reelsServiceInterface: Get.find()), fenix: true);
  Get.lazyPut(() => SearchController(searchServiceInterface: Get.find()));
  Get.lazyPut(() => SmartShoppingListController(searchServiceInterface: Get.find()));
  Get.lazyPut(() => CouponController(couponServiceInterface: Get.find()));
  Get.lazyPut(() => OrderController(orderServiceInterface: Get.find()));
  Get.lazyPut(() => NotificationController(notificationServiceInterface: Get.find()));
  Get.lazyPut(() => CampaignController(campaignServiceInterface: Get.find()));
  Get.lazyPut(() => ParcelController(parcelServiceInterface: Get.find()));
  Get.lazyPut(() => WalletController(walletServiceInterface: Get.find()));
  Get.lazyPut(() => ChatController(chatServiceInterface: Get.find()));
  Get.lazyPut(() => FlashSaleController(flashSaleServiceInterface: Get.find()));
  Get.lazyPut(() => CheckoutController(checkoutServiceInterface: Get.find()), fenix: true);
  Get.lazyPut(() => PaymentController(paymentServiceInterface: Get.find()));
  Get.lazyPut(() => HtmlController(htmlServiceInterface: Get.find()));
  Get.lazyPut(() => ReviewController(reviewServiceInterface: Get.find()));
  Get.lazyPut(() => CategoryController(categoryServiceInterface: Get.find()));
  Get.lazyPut(() => ProductQuestionController(productQuestionServiceInterface: Get.find()));
  Get.lazyPut(() => SuggestionController(suggestionServiceInterface: Get.find()));
  Get.lazyPut(() => ForumController(forumServiceInterface: Get.find()));
  Get.lazyPut(() => ReportController(reportServiceInterface: Get.find()));
  Get.lazyPut(() => LoyaltyController(loyaltyServiceInterface: Get.find()));
  Get.lazyPut(() => VerificationController(verificationServiceInterface: Get.find()));
  Get.lazyPut(() => BrandsController(brandsServiceInterface: Get.find()));
  Get.lazyPut(() => TrendsController(apiClient: Get.find()));
  Get.lazyPut(() => BusinessController(businessServiceInterface: Get.find()));
  Get.lazyPut(() => AdvertisementController(advertisementServiceInterface: Get.find()));
  Get.lazyPut(() => ShelfController(shelfServiceInterface: Get.find()));
  Get.lazyPut(() => StoreCornerController(storeCornerRepositoryInterface: Get.find()));
  Get.lazyPut(() => SuperBannerController(superBannerRepositoryInterface: Get.find()));
  Get.lazyPut(() => ServiceController(serviceServiceInterface: Get.find()));
  Get.lazyPut(() => TaxiLocationController(taxiLocationServiceInterface: Get.find()));
  Get.lazyPut(() => TaxiHomeController(taxiHomeServiceInterface: Get.find()));
  Get.lazyPut(() => TaxiCartController(taxiCartServiceInterface: Get.find()));
  Get.lazyPut(() => TaxiVendorController(taxiVendorServiceInterface: Get.find()));
  Get.lazyPut(() => TaxiOrderController(taxiOrderServiceInterface: Get.find()));
  Get.lazyPut(() => TaxiFavouriteController(taxiFavouriteServiceInterface: Get.find()));
  Get.lazyPut(() => GlobalBrowseController(service: Get.find<GlobalShoppingServiceInterface>()));
  Get.lazyPut(() => GlobalCartController(service: Get.find<GlobalShoppingServiceInterface>()));
  Get.lazyPut(() => GlobalOrderController(service: Get.find<GlobalShoppingServiceInterface>()));
  Get.lazyPut(() => ItemHistoryController(sharedPreferences: Get.find()));
  Get.lazyPut(() => ContactShareController(apiClient: Get.find()));

  /// Retrieving localized data
  Map<String, Map<String, String>> languages = {};
  for(LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues =  await rootBundle.loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, dynamic> mappedJson = jsonDecode(jsonStringValues);
    Map<String, String> json = {};
    mappedJson.forEach((key, value) {
      json[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = json;
  }
  return languages;
}
