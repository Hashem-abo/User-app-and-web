import 'package:sixam_mart/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/profile/widgets/profile_button_widget.dart';
import 'package:sixam_mart/features/profile/widgets/profile_card_widget.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/widgets/web_profile_widget.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/profile/widgets/profile_header_card_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    if(AuthHelper.isLoggedIn() && Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showWalletCard = Get.find<SplashController>().configModel!.customerWalletStatus == 1 || Get.find<SplashController>().configModel!.loyaltyPointStatus == 1;
    bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: isDesktop ? const WebMenuBar() : CustomAppBar(title: 'profile'.tr, backButton: true),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        if (isLoggedIn && profileController.userInfoModel == null) {
          return const CustomLoaderWidget();
        }

        return isDesktop ? SingleChildScrollView(
          child: FooterView(
            minHeight: isLoggedIn ? 0.6 : 0.35,
            child: const WebProfileWidget(),
          ),
        ) : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(children: [
                  const ProfileHeaderCardWidget(),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                (showWalletCard && isLoggedIn) ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(children: [

                    Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ? Expanded(child: ProfileCardWidget(
                      image: Images.loyaltyIcon,
                      title: 'loyalty_points'.tr,
                      data: profileController.userInfoModel!.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0',
                      onTap: () => Get.toNamed(RouteHelper.getLoyaltyRoute()),
                    )) : const SizedBox(),

                    SizedBox(width: Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ? Dimensions.paddingSizeSmall : 0),

                    isLoggedIn ? Expanded(child: ProfileCardWidget(
                      image: Images.shoppingBagIcon,
                      title: 'total_order'.tr,
                      data: profileController.userInfoModel!.orderCount.toString(),
                      onTap: () => Get.toNamed(RouteHelper.getOrderRoute()),
                    )) : const SizedBox(),

                    SizedBox(width: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? Dimensions.paddingSizeSmall : 0),

                    Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? Expanded(child: ProfileCardWidget(
                      image: Images.walletProfile,
                      title: 'wallet_balance'.tr,
                      data: PriceConverter.convertPrice(profileController.userInfoModel!.walletBalance),
                      onTap: () => Get.toNamed(RouteHelper.getWalletRoute()),
                    )) : const SizedBox(),

                  ]),
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    (isLoggedIn && Get.find<SplashController>().proStaus) ? ProfileButtonWidget(
                      iconImage: Images.proPlanCrown,
                      title: 'my_subscription'.tr,
                      onTap: () => Get.toNamed(RouteHelper.getSubscriptionPlanRoute()),
                    ) : const SizedBox(),
                    SizedBox(height: (isLoggedIn && Get.find<SplashController>().proStaus) ? Dimensions.paddingSizeSmall : 0),

                    isLoggedIn ? ProfileButtonWidget(icon: Icons.copy, title: 'my_quotations'.tr, onTap: () {
                      Get.toNamed(RouteHelper.getServiceQuotationListRoute());
                    }) : const SizedBox(),
                    SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

                    (isLoggedIn && Get.find<SplashController>().configModel?.monthlyOrderRemainder == 1) ? ProfileButtonWidget(
                      icon: Icons.calendar_month_outlined, title: 'my_items'.tr,
                      onTap: () => Get.toNamed(RouteHelper.getMyItemsRoute()),
                    ) : const SizedBox(),
                    SizedBox(height: (isLoggedIn && Get.find<SplashController>().configModel?.monthlyOrderRemainder == 1) ? Dimensions.paddingSizeSmall : 0),

                    isLoggedIn ? ProfileButtonWidget(
                      icon: Icons.person_off, title: 'anonymous_reviews'.tr,
                      isButtonActive: profileController.userInfoModel!.isAnonymous ?? false,
                      onTap: () {
                        profileController.toggleAnonymity();
                      },
                    ) : const SizedBox(),
                    SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

                    ProfileButtonWidget(icon: Icons.tonality_outlined, title: 'dark_mode'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                      Get.find<ThemeController>().toggleTheme();
                    }),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
                      return ProfileButtonWidget(
                        icon: Icons.notifications, title: 'notification'.tr,
                        isButtonActive: authController.notification,
                        onTap: () {
                          Get.bottomSheet(const NotificationStatusChangeBottomSheet());
                        },
                      );
                    }) : const SizedBox(),
                    SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

                    isLoggedIn && Get.find<SplashController>().configModel!.centralizeLoginSetup!.manualLoginStatus! ? ProfileButtonWidget(icon: Icons.lock, title: 'change_password'.tr, onTap: () {
                      Get.toNamed(RouteHelper.getResetPasswordRoute(phone: '', email: '', token: '', page: 'password-change'));
                    }) : const SizedBox(),
                    SizedBox(height: isLoggedIn && Get.find<SplashController>().configModel!.centralizeLoginSetup!.manualLoginStatus! ? Dimensions.paddingSizeSmall : 0),

                    isLoggedIn ? ProfileButtonWidget(
                      icon: Icons.delete, title: 'delete_account'.tr,
                      iconImage: Images.profileDelete,
                      color: Theme.of(context).colorScheme.error,
                      onTap: () {
                        Get.dialog(ConfirmationDialog(icon: Images.support,
                          title: 'are_you_sure_to_delete_account'.tr,
                          description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
                          onYesPressed: () => profileController.deleteUser(),
                        ), useSafeArea: false);
                      },
                    ) : const SizedBox(),
                    SizedBox(height: isLoggedIn ? Dimensions.paddingSizeLarge : 0),

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(AppConstants.appVersion.toStringAsFixed(1), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                    ]),

                  ]),
                ),

              ]),
            ),
          ),
        ],
      );
    }),
  );
}
}
