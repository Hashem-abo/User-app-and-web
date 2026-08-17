import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/menu/widgets/menu_button.dart';
import 'package:sixam_mart/features/pro/widgets/pro_badge_avatar_widget.dart';
import 'package:sixam_mart/common/widgets/login_suggestion_bottomsheet.dart';
// import 'package:sixam_mart/features/profile/screens/size_information_screen.dart';
// import 'package:sixam_mart/features/profile/screens/edit_size_screen.dart';
// import 'package:sixam_mart/features/profile/screens/preference_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<ProfileController>().loadSizeAndPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final bool isLoggedIn = AuthHelper.isLoggedIn();

        return Column(children: [

          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  title: Text(
                    'my_account'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Get.find<ThemeController>().toggleTheme();
                      },
                      icon: Get.find<ThemeController>().darkTheme ? Icon(Icons.sunny, color: Theme.of(context).textTheme.bodyLarge?.color) : Image.asset(Images.moon, height: 24, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                
                // Profile Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Row(
                    children: [
                      // Right side: Avatar (will be on the right in RTL)
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.orange, width: 2),
                            ),
                            child: ProBadgeAvatarWidget(
                              badgeSize: 18,
                              child: ClipOval(
                                child: CustomImage(
                                  placeholder: Images.guestIconLight,
                                  image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                                  height: 50, width: 50, fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          if(isLoggedIn) Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).cardColor, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      
                      // Middle: Name and Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Aligns to right edge in RTL
                          children: [
                            Text(
                              isLoggedIn ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}' : 'guest_user'.tr,
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              isLoggedIn ? profileController.userInfoModel?.email ?? '' : 'for_more_personalised_and_smooth_experience'.tr,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      
                      // Left side: Status tags or Login button (will be on the left in RTL)
                      isLoggedIn ? Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end, // Aligns to left edge in RTL
                          children: [
                            InkWell(
                              onTap: () {
                                if (profileController.userInfoModel?.refCode != null) {
                                  Clipboard.setData(ClipboardData(text: profileController.userInfoModel!.refCode!));
                                  showCustomSnackBar('referral_code_copied'.tr, isError: false);
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      profileController.userInfoModel?.refCode ?? '',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.copy, size: 12, color: Theme.of(context).disabledColor),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              AddressHelper.getUserAddressFromSharedPref()?.address ?? 'صنعاء',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ) : InkWell(
                        onTap: () async {
                          if(!ResponsiveHelper.isDesktop(context)) {
                            await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                            if(AuthHelper.isLoggedIn()) {
                              profileController.getUserInfo();
                            }
                          }else{
                            Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: true, backFromThis: true)));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text('sign_in'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
            child: Column(children: [

              if(isLoggedIn && profileController.userInfoModel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(children: [
                    infoCard(profileController, context, Images.loyaltyIcon, double.tryParse(profileController.userInfoModel!.loyaltyPoint.toString()) ?? 0, 'loyalty_points'.tr, titleColor: Theme.of(context).secondaryHeaderColor, onTap: () => Get.toNamed(RouteHelper.getLoyaltyRoute())),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    infoCard(profileController, context, Images.coupon, Get.isRegistered<CouponController>() ? (Get.find<CouponController>().couponList?.length.toDouble() ?? 0) : 0, 'coupon'.tr, titleColor: Theme.of(context).secondaryHeaderColor, onTap: () => Get.toNamed(RouteHelper.getCouponRoute())),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    infoCard(profileController, context, Images.orderProfile, double.tryParse(profileController.userInfoModel!.orderCount.toString()) ?? 0, 'orders'.tr, titleColor: Theme.of(context).secondaryHeaderColor, onTap: () => Get.toNamed(RouteHelper.getOrderRoute())),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    infoCard(profileController, context, Images.walletProfile, double.tryParse(profileController.userInfoModel!.walletBalance.toString()) ?? 0, 'my_balance'.tr, titleColor: Theme.of(context).secondaryHeaderColor, isAmount: true, onTap: () => Get.toNamed(RouteHelper.getWalletRoute())),
                  ]),
                ),


              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
                  child: Text(
                    'general'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Column(
                    children: [
                      MenuButton(icon: 'assets/svg/icons/linear/user-edit.svg', title: 'edit_profile'.tr, route: RouteHelper.getUpdateProfileRoute()),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/shopping-cart.svg', title: 'my_carts'.tr, route: RouteHelper.getMyCartsRoute()),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/heart.svg', title: 'favourite'.tr, route: RouteHelper.getFavouriteScreen()),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/shop.svg', title: 'followed_stores'.tr, route: RouteHelper.getFollowedStoresRoute()),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/my-order.svg', title: 'orders'.tr, route: RouteHelper.getOrderRoute()),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/location.svg', title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),
                      if(Get.find<SplashController>().configModel?.monthlyOrderRemainder == 1) ...[
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        MenuButton(icon: 'assets/svg/icons/linear/my-order.svg', title: 'my_items'.tr, onTap: () {
                          if(AuthHelper.isLoggedIn()) {
                            Get.toNamed(RouteHelper.getMyItemsRoute());
                          } else {
                            Get.bottomSheet(const LoginSuggestionBottomSheet(), isScrollControlled: true);
                          }
                        }),
                      ],
                      if(Get.find<SplashController>().proStaus) ...[
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        MenuButton(icon: 'assets/svg/icons/linear/crown.svg', title: 'my_subscription'.tr, route: RouteHelper.getSubscriptionPlanRoute()),
                      ],
                      // const Divider(height: 1, indent: 20, endIndent: 20),
                      // MenuButton(icon: Images.location, title: 'select_zone'.tr, onTap: () {
                      //   Get.bottomSheet(const ZoneSelectionBottomSheet(), isScrollControlled: true);
                      // }),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/message.svg', title: 'my_questions'.tr, onTap: () {
                        if(AuthHelper.isLoggedIn()) {
                          Get.toNamed(RouteHelper.getMyQuestionsRoute());
                        } else {
                          Get.bottomSheet(const LoginSuggestionBottomSheet(), isScrollControlled: true);
                        }
                      }),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/user-tick.svg', title: 'my_reviews'.tr, onTap: () {
                        if(AuthHelper.isLoggedIn()) {
                          Get.toNamed(RouteHelper.getUserReviewRoute());
                        } else {
                          Get.bottomSheet(const LoginSuggestionBottomSheet(), isScrollControlled: true);
                        }
                      }),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      if(Get.find<SplashController>().module?.moduleType == 'services') ...[
                        MenuButton(icon: 'assets/svg/icons/linear/document-text.svg', title: 'my_quotations'.tr, onTap: () {
                          if(AuthHelper.isLoggedIn()) {
                            Get.toNamed(RouteHelper.getServiceQuotationListRoute());
                          } else {
                            Get.bottomSheet(const LoginSuggestionBottomSheet(), isScrollControlled: true);
                          }
                        }),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                      ],
                      MenuButton(icon: 'assets/svg/icons/linear/setting.svg', title: 'settings'.tr, route: RouteHelper.getSettingScreen()),

                    ],
                  ),
                )

              ]),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
                  child: Text(
                    'promotional_activity'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Column(
                    children: [
                      MenuButton(icon: 'assets/svg/icons/linear/ticket-star.svg', title: 'coupon'.tr, route: RouteHelper.getCouponRoute()),
                      
                      if(Get.find<SplashController>().configModel!.loyaltyPointStatus == 1) ...[
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        MenuButton(icon: 'assets/svg/icons/linear/coin.svg', title: 'loyalty_points'.tr, route: RouteHelper.getLoyaltyRoute()),
                      ],
                      
                      if(Get.find<SplashController>().configModel!.customerWalletStatus == 1) ...[
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        MenuButton(icon: 'assets/svg/icons/linear/wallet.svg', title: 'my_wallet'.tr, route: RouteHelper.getWalletRoute()),
                      ],
                    ],
                  ),
                )
              ]),

              (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) || (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ||
                  (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ?
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
                  child: Text(
                    'earnings'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Column(
                    children: [
                      if(Get.find<SplashController>().configModel!.refEarningStatus == 1)
                        MenuButton(icon: 'assets/svg/icons/linear/people.svg', title: 'refer_and_earn'.tr, route: RouteHelper.getReferAndEarnRoute()),
                      
                      if(Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ...[
                        if(Get.find<SplashController>().configModel!.refEarningStatus == 1) const Divider(height: 1, indent: 20, endIndent: 20),
                        MenuButton(icon: 'assets/svg/icons/linear/user-octagon.svg', title: 'join_as_a_delivery_man'.tr, route: RouteHelper.getDeliverymanRegistrationRoute()),
                      ],
                      
                      if(Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ...[
                        if(Get.find<SplashController>().configModel!.refEarningStatus == 1 || (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context))) const Divider(height: 1, indent: 20, endIndent: 20),
                        MenuButton(icon: 'assets/svg/icons/linear/shop-add.svg', title: 'open_vendor'.tr, route: RouteHelper.getRestaurantRegistrationRoute()),
                      ],
                    ],
                  ),
                )
              ]) : const SizedBox(),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
                  child: Text(
                    'help_and_support'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Column(
                    children: [
                      MenuButton(icon: 'assets/svg/icons/linear/messages.svg', title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/24-support.svg', title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/buildings.svg', title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/document-text.svg', title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      MenuButton(icon: 'assets/svg/icons/linear/document-text.svg', title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
 
                      if(Get.find<SplashController>().configModel!.refundPolicyStatus == 1) ...[
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        MenuButton(icon: 'assets/svg/icons/linear/return.svg', title: 'refund_policy'.tr, route: RouteHelper.getHtmlRoute('refund-policy')),
                      ],
 
                      if(Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1) ...[
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        MenuButton(icon: Images.cancelationIcon, title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy')),
                      ],
 
                      if(Get.find<SplashController>().configModel!.shippingPolicyStatus == 1) ...[
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        MenuButton(icon: Images.shippingIcon, title: 'shipping_policy'.tr, route: RouteHelper.getHtmlRoute('shipping-policy')),
                      ],
                    ],
                  ),
                )
              ]),

              InkWell(
                onTap: () async {
                  if(AuthHelper.isLoggedIn()) {
                    Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () async {
                      Get.find<AuthController>().resetOtpView();
                      Get.find<ProfileController>().clearUserInfo();
                      Get.find<AuthController>().socialLogout();
                      Get.find<CartController>().clearCartList(canRemoveOnline: false);
                      Get.find<FavouriteController>().removeFavourite();
                      await Get.find<AuthController>().clearSharedData();
                      Get.find<HomeController>().forcefullyNullCashBackOffers();
                      if(Get.find<SplashController>().module != null) {
                        Get.find<TaxiCartController>().getCarCartList();
                      }
                      Get.offAllNamed(RouteHelper.getInitialRoute());
                      showCustomSnackBar('logout_successful'.tr, isError: false);
                    }), useSafeArea: false);
                  }else {
                    Get.find<FavouriteController>().removeFavourite();
                    await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                    if(AuthHelper.isLoggedIn()) {
                      await Get.find<FavouriteController>().getFavouriteList();
                      profileController.getUserInfo();
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).colorScheme.error, width: 1),
                  ),
                  child: ListTile(
                    leading: SvgPicture.asset(AuthHelper.isLoggedIn() ? 'assets/svg/icons/linear/logout.svg' : 'assets/svg/icons/linear/logout.svg',
                    colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.error, BlendMode.srcIn),),
                    title: Text(
                      AuthHelper.isLoggedIn() ? 'logout'.tr : 'sign_in'.tr,
                      style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeDefault),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),



              SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : 100),

            ]),
          )),
        ]);
      }),
    );
  }

  Widget infoCard(ProfileController profileController, BuildContext context, String image, double value, String title, {bool isAmount = false, Color? titleColor, Function()? onTap}) {
    return  Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Column(children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Image.asset(image, height: 50, width: 50),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  child: Text(
                    isAmount ? PriceConverter.convertPrice(value, forMenuWallet: true) : value.toStringAsFixed(0),
                    style: robotoBold.copyWith(
                      fontSize: (title == 'my_balance'.tr || isAmount) ? Dimensions.fontSizeSmall : Dimensions.fontSizeSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Text(
                    title,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: titleColor),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

}
