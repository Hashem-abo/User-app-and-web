import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/features/cart/controllers/cart_controller.dart';
import 'package:suliman/features/cart/domain/models/cart_model.dart';
import 'package:suliman/features/pro/controllers/pro_controller.dart';
import 'package:suliman/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:suliman/features/pro/screens/subscription_plan_screen.dart';
import 'package:suliman/features/pro/widgets/pro_benefit_banner_widget.dart';
import 'package:suliman/features/pro/widgets/pro_plan_banner_widget.dart';
import 'package:suliman/features/profile/controllers/profile_controller.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';
import 'package:suliman/helper/price_converter.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/images.dart';
import 'package:suliman/util/styles.dart';

class ProCartBannerWidget extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double couponDiscount;
  final String? redirectRoute;
  final List<CartModel?>? cartList;

  const ProCartBannerWidget({
    super.key,
    required this.subtotal,
    this.discount = 0,
    this.couponDiscount = 0,
    this.redirectRoute,
    this.cartList,
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.find<SplashController>().proStaus) return const SizedBox();
    return GetBuilder<ProfileController>(builder: (profileController) {
      final bool isPro = profileController.userInfoModel?.proStatus ?? false;
      if (!isPro) {
        return ProPlanBannerWidget(onSubscribe: () {
          Get.find<ProController>().saveCurrentPath(route: redirectRoute);
          SubscriptionPlanScreen.open();
        });
      }
      return GetBuilder<ProController>(builder: (proController) {
        final ProActiveBenefit? benefit = proController.activeOfferModel?.benefit;
        if (benefit == null || !proController.isBenefitAllowedForCurrentModule(benefit.type)) return const SizedBox();

        final effectiveCartList = cartList ?? (Get.isRegistered<CartController>() ? Get.find<CartController>().cartList : null);
        Map<int, List<CartModel>> storeMap = {};
        if (effectiveCartList != null && effectiveCartList.isNotEmpty) {
          for (var cart in effectiveCartList) {
            if (cart?.item != null) {
              int storeId = cart!.item!.storeId ?? 0;
              storeMap.putIfAbsent(storeId, () => []).add(cart);
            }
          }
        }

        if (storeMap.length > 1) {
          return _buildMultiStoreBanner(context, benefit, storeMap);
        }

        return ProBenefitBannerWidget(benefit: benefit, subtotal: subtotal, discount: discount, couponDiscount: couponDiscount);
      });
    });
  }

  Widget _buildMultiStoreBanner(BuildContext context, ProActiveBenefit benefit, Map<int, List<CartModel>> storeMap) {
    final TextStyle titleStyle = robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall);
    final TextStyle storeNameStyle = robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall);
    final TextStyle infoStyle = robotoMedium.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: Dimensions.fontSizeExtraSmall);
    final TextStyle boldHighlightStyle = robotoBold.copyWith(color: const Color(0xFFFFE082), fontSize: Dimensions.fontSizeExtraSmall);

    final double minOrder = benefit.minOrderAmount ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: const Color(0xFF4B6CE0),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Image.asset(Images.proPlanCrown, height: 18, width: 18),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(
                '${'discount_pro'.tr} (${'min_order'.tr}: ${PriceConverter.convertPrice(minOrder)} ${'per_store'.tr})',
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 8),
          ...storeMap.entries.map((entry) {
            final List<CartModel> storeCarts = entry.value;
            String storeName = storeCarts.first.item?.storeName ?? 'store'.tr;
            double storeSubtotal = 0;
            for (var c in storeCarts) {
              double price = (c.discountedPrice ?? c.price ?? c.item?.price ?? 0);
              storeSubtotal += price * (c.quantity ?? 1);
            }

            final bool meetsMin = benefit.minOrderStatus != true || storeSubtotal >= minOrder;
            final double remaining = (minOrder - storeSubtotal).clamp(0, double.infinity);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Icon(
                    meetsMin ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: meetsMin ? const Color(0xFF69F0AE) : const Color(0xFFFFE082),
                    size: 14,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '$storeName: ', style: storeNameStyle),
                        if (meetsMin) ...[
                          TextSpan(text: '${'pro_discount_applied'.tr} ✅', style: boldHighlightStyle),
                        ] else ...[
                          TextSpan(text: '${PriceConverter.convertPrice(remaining)} ', style: boldHighlightStyle),
                          TextSpan(text: 'more_to_unlock_pro_discount'.tr, style: infoStyle),
                        ],
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
