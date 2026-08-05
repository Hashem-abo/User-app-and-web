import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/item/widgets/item_coupon_bottom_sheet.dart';

class ItemCouponWidget extends StatelessWidget {
  final CouponModel coupon;
  const ItemCouponWidget({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.bottomSheet(
          ItemCouponBottomSheet(coupon: coupon),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          image: const DecorationImage(
            image: AssetImage(Images.promoCodeBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Image.asset(Images.couponOfferIcon, height: 70, width: 70),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            flex: 2,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                coupon.couponType == 'free_delivery' ? 'free_delivery'.tr : '${coupon.discountType == 'percent' ? coupon.discount?.toInt() : PriceConverter.convertPrice(coupon.discount)}${coupon.discountType == 'percent' ? '%' : ''} ${'off'.tr}',
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${coupon.title ?? ''} ${'min_order_of'.tr} ${PriceConverter.convertPrice(coupon.minPurchase)}',
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1,
                  strokeCap: StrokeCap.butt,
                  dashPattern: const [5, 5],
                  padding: const EdgeInsets.all(0),
                  radius: const Radius.circular(50),
                ),
                child: Container(
                  height: 30, width: 110,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
                  child: CustomInkWell(
                    onTap: () {
                      if(coupon.code != null){
                        Clipboard.setData(ClipboardData(text: coupon.code ?? ''));
                        showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                      }
                    },
                    radius: 50,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.copy, color: Theme.of(context).primaryColor, size: 14),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Flexible(child: Text(coupon.code ?? '', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                ),
              ),

            ]),
          ),

        ]),
      ),
    );
  }
}
