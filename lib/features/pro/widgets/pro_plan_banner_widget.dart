import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/pro/controllers/pro_controller.dart';
import 'package:sixam_mart/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:sixam_mart/features/pro/screens/subscription_plan_screen.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class ProPlanBannerWidget extends StatelessWidget {
  final VoidCallback? onSubscribe;
  const ProPlanBannerWidget({super.key, this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    if (!Get.find<SplashController>().proStaus) return const SizedBox();

    return GetBuilder<ProfileController>(builder: (profileController) {
      final bool hasProPlan = profileController.userInfoModel?.proStatus ?? false;

      return GetBuilder<ProController>(builder: (proController) {
        final ProActiveBenefit? benefit = proController.activeOfferModel?.benefit;

        // Pro member with no active offer applicable to this module — show nothing.
        if (hasProPlan && !proController.isBenefitAllowedForCurrentModule(benefit?.type)) {
          return const SizedBox();
        }

        void handleTap() {
          if (onSubscribe != null) {
            onSubscribe!();
          } else {
            SubscriptionPlanScreen.open();
          }
        }

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: InkWell(
            onTap: handleTap,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E2B58), // Deep Royal Navy
                Color(0xFF384E96), // Rich Indigo Accent
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E2B58).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle background decorative glow
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall + 2,
                ),
                child: Row(
                  children: [
                    // Metallic Crown Badge
                    Container(
                      height: 38,
                      width: 38,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(Images.proPlanCrown, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    // Banner Text
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: hasProPlan
                              ? '${'order_now_to_enjoy_exclusive_offer_with_your'.tr} '
                              : '${'enjoy_extra_savings_on_every_order_with_a'.tr} ',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall + 1,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.25,
                          ),
                          children: [
                            TextSpan(
                              text: 'pro_plan'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall + 1,
                                color: const Color(0xFFFFD54F), // Gold Highlight
                              ),
                            ),
                            if (hasProPlan && benefit?.type != null)
                              TextSpan(
                                text: ' - ${_benefitName(benefit!.type)} ${'benefit_unlocked'.tr}',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall + 1,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Call to Action Button
                    if (!hasProPlan) ...[
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Material(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: InkWell(
                          onTap: handleTap,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'explore'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
});
  }

  String _benefitName(ProBenefitType? type) {
    switch (type) {
      case ProBenefitType.discount:
        return 'pro_discount'.tr;
      case ProBenefitType.deliveryFee:
        return 'pro_delivery_fee'.tr;
      case ProBenefitType.coupon:
        return 'pro_coupon'.tr;
      case null:
        return 'pro_benefit'.tr;
    }
  }
}