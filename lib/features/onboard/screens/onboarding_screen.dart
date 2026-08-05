import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/onboard/controllers/onboard_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    Get.find<OnBoardingController>().getOnBoardingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: GetBuilder<OnBoardingController>(
        builder: (onBoardingController) {
          return onBoardingController.onBoardingList.isNotEmpty ? SafeArea(
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Stack(children: [

              PageView.builder(
                itemCount: onBoardingController.onBoardingList.length,
                controller: _pageController,
                allowImplicitScrolling: true,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  onBoardingController.changeSelectIndex(index);
                  if(onBoardingController.selectedIndex == onBoardingController.onBoardingList.length - 1) {
                    _configureToRouteInitialPage();
                  }
                },
                itemBuilder: (context, index) {
                  bool isLast = index == onBoardingController.onBoardingList.length - 1;
                  if(isLast) return const SizedBox();

                  return Stack(children: [
                    // Top 70% Image Container
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: MediaQuery.of(context).size.height * 0.70,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: CustomImage(
                          image: onBoardingController.onBoardingList[index].imageUrl,
                          fit: BoxFit.fill,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      ),
                    ),

                    // Skip Button
                    Positioned(
                      top: 20, right: 20,
                      child: InkWell(
                        onTap: () => _configureToRouteInitialPage(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'skip'.tr,
                            style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                          ),
                        ),
                      ),
                    ),

                    // Content Card at Bottom
                    Positioned(
                      bottom: 40, left: 20, right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
                        ),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            onBoardingController.onBoardingList[index].title,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(
                            onBoardingController.onBoardingList[index].description,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          CustomButton(
                            buttonText: onBoardingController.selectedIndex != onBoardingController.onBoardingList.length - 2 ? 'next'.tr : 'get_started'.tr,
                            onPressed: () {
                              if(onBoardingController.selectedIndex != onBoardingController.onBoardingList.length - 2) {
                                _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                              } else {
                                _configureToRouteInitialPage();
                              }
                            },
                            radius: 15,
                          ),
                        ]),
                      ),
                    ),
                  ]);
                },
              ),

              // Page Indicators at the very bottom
              Positioned(
                bottom: 20, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _pageIndicators(onBoardingController, context),
                ),
              ),

            ]))),
          ) : const SizedBox();
        },
      ),
    );
  }

  List<Widget> _pageIndicators(OnBoardingController onBoardingController, BuildContext context) {
    List<Widget> indicators = [];
    int length = onBoardingController.onBoardingList.length - 1;

    for (int i = 0; i < length; i++) {
      indicators.add(
        Container(
          width: i == onBoardingController.selectedIndex ? 15 : 7,
          height: 7,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            color: i == onBoardingController.selectedIndex ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      );
    }
    return indicators;
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>().navigateToLocationScreen(RouteHelper.onBoarding, offNamed: true).then((v) {
        if(Get.find<OnBoardingController>().onBoardingList.isNotEmpty) {
           _pageController.jumpToPage(Get.find<OnBoardingController>().onBoardingList.length - 2);
        }
      });
    }
  }
}

