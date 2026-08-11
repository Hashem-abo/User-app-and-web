import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountTag extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double? fontSize;
  final bool inLeft;
  final bool? freeDelivery;
  final bool? isFloating;
  final bool? fromTaxi;
  const DiscountTag({
    super.key,
    required this.discount,
    required this.discountType,
    this.fromTop = 10,
    this.fontSize,
    this.freeDelivery = false,
    this.inLeft = true,
    this.isFloating = true,
    this.fromTaxi = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String currencySymbol =
        Get.find<SplashController>().configModel!.currencySymbol!;
    bool isLtr = Get.find<LocalizationController>().isLtr;

    return (discount! > 0 || freeDelivery!)
        ? Positioned(
            top: fromTop,
            left: inLeft
                ? isFloating!
                    ? Dimensions.paddingSizeSmall
                    : 0
                : null,
            right: inLeft ? null : 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: fromTaxi!
                    ? const BorderRadiusDirectional.all(
                        Radius.circular(Dimensions.radiusDefault))
                    : BorderRadiusDirectional.circular(
                        Dimensions.radiusLarge),
              ),
              child: Text(
                discount! > 0
                    ? (!isLtr
                        ? '${'off'.tr} ${(isRightSide || discountType == 'percent') ? '' : currencySymbol}${discount! == discount!.truncate() ? discount!.truncate() : discount}${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''}'
                        : '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}${discount! == discount!.truncate() ? discount!.truncate() : discount}${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}')
                    : 'free_delivery'.tr,
                style: robotoBold.copyWith(
                  color: Colors.white,
                  fontSize:
                      fontSize ?? (ResponsiveHelper.isMobile(context) ? 8 : 12),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : const SizedBox();
  }
}
