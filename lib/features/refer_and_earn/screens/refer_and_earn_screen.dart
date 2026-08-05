import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  bool _showHowItWorks = false;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() {
    if (AuthHelper.isLoggedIn() && Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return SafeArea(
      child: GetBuilder<LocalizationController>(
        builder: (localizationController) {
          bool ltr = localizationController.isLtr;
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left button: Info icon in RTL, Back button in LTR
                    ltr
                        ? _buildCircleButton(
                            icon: Icons.arrow_back,
                            onTap: () {
                              if (_showHowItWorks) {
                                setState(() {
                                  _showHowItWorks = false;
                                });
                              } else {
                                Get.back();
                              }
                            },
                          )
                        : (_showHowItWorks
                            ? const SizedBox(width: 44)
                            : _buildCircleButton(
                                icon: Icons.priority_high_rounded,
                                onTap: () {
                                  setState(() {
                                    _showHowItWorks = true;
                                  });
                                },
                              )),

                    // Page Title
                    Text(
                      'share_and_earn'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge + 2,
                        color: const Color(0xFF1E293B),
                      ),
                    ),

                    // Right button: Back button in RTL, Info icon in LTR
                    ltr
                        ? (_showHowItWorks
                            ? const SizedBox(width: 44)
                            : _buildCircleButton(
                                icon: Icons.priority_high_rounded,
                                onTap: () {
                                  setState(() {
                                    _showHowItWorks = true;
                                  });
                                },
                              ))
                        : _buildCircleButton(
                            icon: Icons.arrow_forward,
                            onTap: () {
                              if (_showHowItWorks) {
                                setState(() {
                                  _showHowItWorks = false;
                                });
                              } else {
                                Get.back();
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
            body: isLoggedIn
                ? GetBuilder<ProfileController>(
                    builder: (profileController) {
                      if (profileController.userInfoModel == null) {
                        return const Center(child: CustomLoaderWidget());
                      }
                      return Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                            child: Column(
                              children: [
                                if (ResponsiveHelper.isDesktop(context)) ...[
                                  WebScreenTitleWidget(title: 'refer_and_earn'.tr),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),
                                ],
                                _showHowItWorks
                                    ? _buildHowItWorksScreen(profileController, ltr)
                                    : _buildMainReferralScreen(profileController, ltr),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : NotLoggedInScreen(callBack: (value) {
                    _initCall();
                    setState(() {});
                  }),
          );
        },
      ),
    );
  }

  // Helper method to build custom circular navigation/action buttons
  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1E293B), size: 22),
      ),
    );
  }

  // Screen 1: Main Referral Design
  Widget _buildMainReferralScreen(ProfileController profileController, bool ltr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Referral Illustration
        Image.asset(
          Images.referImage,
          width: 280,
          height: ResponsiveHelper.isDesktop(context) ? 220 : 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        // Bold invitation title
        Text(
          'invite_friends_and_earn_rewards'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge + 2,
            color: const Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Explanatory subtitle
        Text(
          'referral_screen_subtitle'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall + 1,
            color: const Color(0xFF64748B),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Referral Rate Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${'one_referral'.tr} = ',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                    ? Get.find<SplashController>().configModel!.refEarningExchangeRate!.toDouble()
                    : 0.0),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: Theme.of(context).primaryColor,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // "Your Referral Code" Label
        Text(
          'your_referral_code_label'.tr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Dotted Code box
        DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: Theme.of(context).primaryColor,
            strokeWidth: 1.5,
            strokeCap: StrokeCap.butt,
            dashPattern: const [6, 4],
            padding: const EdgeInsets.all(0),
            radius: const Radius.circular(12),
          ),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED), // Subtle pale orange tint matching the mockup
              borderRadius: BorderRadius.circular(12),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Expanded(
                    child: Center(
                      child: Text(
                        profileController.userInfoModel?.refCode ?? '',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge + 2,
                          color: const Color(0xFF1E293B),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (profileController.userInfoModel!.refCode!.isNotEmpty) {
                        Clipboard.setData(ClipboardData(
                          text: '${profileController.userInfoModel!.refCode}',
                        ));
                        showCustomSnackBar('referral_code_copied'.tr, isError: false);
                      }
                    },
                    child: Icon(
                      Icons.copy_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // "Click to copy and share" subtitle
        Text(
          'click_to_copy_and_share'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall + 1,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 32),

        // Stats Row (Earned & Referred)
        Row(
          children: [
            // Left Card: Earned
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      PriceConverter.convertPrice(profileController.userInfoModel?.walletBalance ?? 0.0),
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge - 1,
                        color: const Color(0xFF1E293B),
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'earned'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Right Card: People Referred
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                      ),
                      child: Icon(
                        Icons.people_outline_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      profileController.userInfoModel?.referredCount?.toString() ?? '0',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge - 1,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'people_referred'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        // Primary Share Button
        _buildShareButton(profileController),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // How Referral System Works link
        TextButton(
          onPressed: () {
            setState(() {
              _showHowItWorks = true;
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'how_does_referral_work'.tr,
            style: robotoBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
      ],
    );
  }

  // Screen 2: How Referral System Works Design
  Widget _buildHowItWorksScreen(ProfileController profileController, bool ltr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Illustration
        Image.asset(
          Images.referImage,
          width: 280,
          height: ResponsiveHelper.isDesktop(context) ? 220 : 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        // Bold Title
        Text(
          'how_does_referral_work'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge + 2,
            color: const Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Subtitle text
        Text(
          'how_referral_works_subtitle'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall + 1,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Referral Rate Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${'one_referral'.tr} = ',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                    ? Get.find<SplashController>().configModel!.refEarningExchangeRate!.toDouble()
                    : 0.0),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: Theme.of(context).primaryColor,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Vertical Steps List
        _buildStepItem(stepNumber: '1', stepText: 'referral_step_1'.tr, ltr: ltr),
        const SizedBox(height: 4),
        _buildStepItem(stepNumber: '2', stepText: 'referral_step_2'.tr, ltr: ltr),
        const SizedBox(height: 4),
        _buildStepItem(stepNumber: '3', stepText: 'referral_step_3'.tr, ltr: ltr),
        const SizedBox(height: 4),
        _buildStepItem(stepNumber: '4', stepText: 'referral_step_4'.tr, ltr: ltr),
        const SizedBox(height: 32),

        // Pink warning note banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2), // Premium light pink background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ltr
                ? [
                    const Icon(
                      Icons.report_problem_outlined,
                      color: Color(0xFFDC2626),
                      size: 22,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Text(
                        'referral_important_note'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xFFDC2626),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: Text(
                        'referral_important_note'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xFFDC2626),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    const Icon(
                      Icons.report_problem_outlined,
                      color: Color(0xFFDC2626),
                      size: 22,
                    ),
                  ],
          ),
        ),
        const SizedBox(height: 32),

        // Primary Share Button
        _buildShareButton(profileController),
        const SizedBox(height: Dimensions.paddingSizeLarge),
      ],
    );
  }

  // Helper widget to construct vertical instructions list items
  Widget _buildStepItem({required String stepNumber, required String stepText, required bool ltr}) {
    Widget numberCircle = Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor,
      ),
      child: Text(
        stepNumber,
        style: robotoBold.copyWith(
          color: Colors.white,
          fontSize: Dimensions.fontSizeSmall,
        ),
      ),
    );

    Widget textWidget = Expanded(
      child: Text(
        stepText,
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall + 1,
          color: const Color(0xFF64748B),
          height: 1.4,
        ),
        textAlign: ltr ? TextAlign.left : TextAlign.right,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: ltr
            ? [
                numberCircle,
                const SizedBox(width: Dimensions.paddingSizeDefault),
                textWidget,
              ]
            : [
                textWidget,
                const SizedBox(width: Dimensions.paddingSizeDefault),
                numberCircle,
              ],
      ),
    );
  }

  // Elegant Primary Share Code Action Button
  Widget _buildShareButton(ProfileController profileController) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.24),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: CustomInkWell(
        onTap: () {
          SharePlus.instance.share(
            ShareParams(
              text: Get.find<SplashController>().configModel?.appUrlAndroid != null
                  ? '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
                  : '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode}',
            ),
          );
        },
        radius: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'share_code'.tr,
              style: robotoBold.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
