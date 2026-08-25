import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/onboard/controllers/onboard_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  static const Color _gradientTopColor = Color(0xFF9CD2FB);
  static const Color _gradientBottomColor = Color(0xFFF1FAFF);

  @override
  void initState() {
    super.initState();
    Get.find<OnBoardingController>().getOnBoardingList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // 80% من عرض الهاتف، وبحد أقصى 400 للشاشات الكبيرة.
    final double requestedImageSize = math.min(
      screenSize.width * 0.80,
      400.0,
    );

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? const WebMenuBar()
          : null,
      body: GetBuilder<OnBoardingController>(
        builder: (onBoardingController) {
          if (onBoardingController.onBoardingList.isEmpty) {
            return const SizedBox();
          }

          /*
           * الكود الأصلي يعتبر آخر عنصر صفحة وهمية،
           * لذلك عدد الصفحات الفعلية يساوي length - 1.
           */
          final int visiblePageCount =
              onBoardingController.onBoardingList.length - 1;

          if (visiblePageCount <= 0) {
            return const SizedBox();
          }

          final int selectedIndex = onBoardingController.selectedIndex
              .clamp(0, visiblePageCount - 1)
              .toInt();

          final currentPage =
              onBoardingController.onBoardingList[selectedIndex];

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _gradientTopColor,
                  _gradientBottomColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 620,
                  ),
                  child: Column(
                    children: [
                      // الجزء العلوي المتحرك: الصور فقط
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              top: 54,
                              bottom: 12,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: visiblePageCount,
                                allowImplicitScrolling: true,
                                physics: const BouncingScrollPhysics(),
                                onPageChanged: (index) {
                                  onBoardingController
                                      .changeSelectIndex(index);
                                },
                                itemBuilder: (context, index) {
                                  final onboarding =
                                      onBoardingController
                                          .onBoardingList[index];

                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      // يمنع تجاوز الصورة للمساحة المتاحة
                                      // في الهواتف القصيرة أو الوضع الأفقي.
                                      final double actualImageSize = math.min(
                                        requestedImageSize,
                                        math.min(
                                          constraints.maxWidth,
                                          constraints.maxHeight,
                                        ),
                                      );

                                      return Center(
                                        child: SizedBox(
                                          width: actualImageSize,
                                          height: actualImageSize,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(28),
                                            child: CustomImage(
                                              image: onboarding.imageUrl,
                                              width: actualImageSize,
                                              height: actualImageSize,

                                              // يحافظ على أبعاد الصورة
                                              // دون تمديد أو تشويه.
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            // زر تغيير اللغة الشفاف والأنيق
                            PositionedDirectional(
                              top: 10,
                              start: 20,
                              child: GetBuilder<LocalizationController>(
                                builder: (localizationController) {
                                  return Material(
                                    color: Colors.white.withAlpha(120),
                                    elevation: 2,
                                    shadowColor: Colors.black.withAlpha(20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(
                                        color: Colors.white.withAlpha(120),
                                        width: 1,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () {
                                        Locale newLocale = localizationController.isLtr
                                            ? const Locale('ar', 'SA')
                                            : const Locale('en', 'US');
                                        localizationController.setLanguage(newLocale);
                                        Get.find<OnBoardingController>().getOnBoardingList();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.language,
                                              size: 18,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              localizationController.isLtr ? 'العربية' : 'English',
                                              style: robotoBold.copyWith(
                                                color: Theme.of(context).colorScheme.inverseSurface,
                                                fontSize: Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // زر التخطي المحسن
                            PositionedDirectional(
                              top: 10,
                              end: 20,
                              child: Material(
                                color: Colors.white.withAlpha(100),
                                elevation: 2,
                                shadowColor: Colors.black.withAlpha(20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: Colors.white.withAlpha(100),
                                    width: 1,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: _configureToRouteInitialPage,
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.symmetric(
                                      horizontal: 16,
                                      vertical: 9,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'skip'.tr,
                                          style: robotoBold.copyWith(
                                            color: Theme.of(context).colorScheme.inverseSurface,
                                            fontSize:
                                                Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // البطاقة ثابتة خارج PageView
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          20,
                          0,
                          20,
                          18,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 280,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            22,
                            20,
                            22,
                            20,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .cardColor
                                .withOpacity(0.97),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.85),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2477A8)
                                    .withOpacity(0.14),
                                blurRadius: 28,
                                spreadRadius: 1,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // مؤشرات الصفحات داخل البطاقة
                              _buildPageIndicators(
                                context: context,
                                selectedIndex: selectedIndex,
                                pageCount: visiblePageCount,
                              ),

                              const SizedBox(height: 14),

                              // النص يتغير والبطاقة تبقى ثابتة
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 350),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (
                                    Widget child,
                                    Animation<double> animation,
                                  ) {
                                    final Animation<Offset> slideAnimation =
                                        Tween<Offset>(
                                      begin: const Offset(0, 0.08),
                                      end: Offset.zero,
                                    ).animate(animation);

                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: slideAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  layoutBuilder: (
                                    Widget? currentChild,
                                    List<Widget> previousChildren,
                                  ) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ...previousChildren,
                                        if (currentChild != null)
                                          currentChild,
                                      ],
                                    );
                                  },
                                  child: Column(
                                    key: ValueKey<int>(selectedIndex),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        currentPage.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: robotoBold.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraLarge,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color,
                                          height: 1.3,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Text(
                                        currentPage.description,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeDefault,
                                          color: Theme.of(context)
                                              .hintColor,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              _buildNavigationButtons(
                                context: context,
                                selectedIndex: selectedIndex,
                                pageCount: visiblePageCount,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicators({
    required BuildContext context,
    required int selectedIndex,
    required int pageCount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) {
          final bool isSelected = index == selectedIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: isSelected ? 24 : 7,
            height: 7,
            margin: const EdgeInsetsDirectional.only(end: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context)
                      .primaryColor
                      .withOpacity(0.20),
              borderRadius: BorderRadius.circular(50),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons({
    required BuildContext context,
    required int selectedIndex,
    required int pageCount,
  }) {
    final bool isFirstPage = selectedIndex == 0;
    final bool isLastPage = selectedIndex == pageCount - 1;

    final Widget primaryButton = SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (isLastPage) {
            _configureToRouteInitialPage();
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          isLastPage ? 'get_started'.tr : 'next'.tr,
          style: robotoBold.copyWith(
            color: Colors.white,
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
      ),
    );

    // أول شاشة: زر التالي فقط
    if (isFirstPage) {
      return SizedBox(
        width: double.infinity,
        child: primaryButton,
      );
    }

    // بقية الشاشات: السابق + التالي أو ابدأ الآن
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'previous'.tr,
                style: robotoBold.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 2,
          child: primaryButton,
        ),
      ],
    );
  }

  Future<void> _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();

    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(
        RouteHelper.getInitialRoute(fromSplash: true),
      );
      return;
    }

    await Get.find<LocationController>().navigateToLocationScreen(
      RouteHelper.onBoarding,
      offNamed: true,
    );

    if (!mounted || !_pageController.hasClients) {
      return;
    }

    final OnBoardingController onboardingController =
        Get.find<OnBoardingController>();

    if (onboardingController.onBoardingList.length > 1) {
      final int lastVisiblePage =
          onboardingController.onBoardingList.length - 2;

      onboardingController.changeSelectIndex(lastVisiblePage);
      _pageController.jumpToPage(lastVisiblePage);
    }
  }
}