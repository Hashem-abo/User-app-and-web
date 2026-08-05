import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ItemCouponBottomSheet extends StatelessWidget {
  final CouponModel coupon;
  const ItemCouponBottomSheet({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        
        Center(child: Container(height: 5, width: 50, decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ))),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        
        Text('coupon_details'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        
        _detailItem('coupon_code'.tr, coupon.code ?? ''),
        _detailItem('discount_type'.tr, coupon.couponType == 'free_delivery' ? 'free_delivery'.tr : coupon.discountType?.tr ?? ''),
        _detailItem('discount'.tr, coupon.couponType == 'free_delivery' ? 'free_delivery'.tr : '${coupon.discountType == 'percent' ? coupon.discount?.toInt() : PriceConverter.convertPrice(coupon.discount)}${coupon.discountType == 'percent' ? '%' : ''}'),
        _detailItem('min_purchase'.tr, PriceConverter.convertPrice(coupon.minPurchase)),
        if(coupon.maxDiscount! > 0) _detailItem('max_discount'.tr, PriceConverter.convertPrice(coupon.maxDiscount)),
        _detailItem('valid_until'.tr, DateConverter.isoStringToLocalDateOnly(coupon.expireDate!)),
        
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Text('terms_and_conditions'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          'coupon_terms_and_conditions_desc'.tr,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
        ),
        
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
      ]),
    );
  }

  Widget _detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: robotoRegular.copyWith(color: Get.context!.theme.disabledColor)),
        Text(value, style: robotoMedium),
      ]),
    );
  }
}
