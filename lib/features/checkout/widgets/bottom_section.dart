import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_tool_tip_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/checkout/widgets/extra_discount_view_widget.dart';
import 'package:sixam_mart/features/checkout/widgets/prescription_image_picker_widget.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/checkout/widgets/animated_calculating_widget.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/checkout/widgets/condition_check_box.dart';
import 'package:sixam_mart/features/checkout/widgets/coupon_section.dart';
import 'package:sixam_mart/features/checkout/widgets/note_prescription_section.dart';
import 'package:sixam_mart/features/checkout/widgets/partial_pay_view.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/cart/widgets/add_to_monthly_widget.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class BottomSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final double total;
  final Module module;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? maxCodOrderAmount;
  final int? storeId;
  final double? taxPercent;
  final  double price;
  final double addOns;
  final Widget? checkoutButton;
  final bool isPrescriptionRequired;
  final double referralDiscount;
  final double proDiscount;
  final double proDeliveryDiscount;
  final double variationPrice;
  final double extraDiscount;
  final List<CartModel?>? cartList;

  const BottomSection({super.key, required this.checkoutController, required this.total, required this.module, required this.subTotal,
    required this.discount, required this.couponController, required this.taxIncluded, required this.tax,
    required this.deliveryCharge, required this.todayClosed, required this.tomorrowClosed,
    required this.orderAmount, this.maxCodOrderAmount, this.storeId, this.taxPercent, required this.price,
    required this.addOns, this.checkoutButton, required this.isPrescriptionRequired, required this.referralDiscount,
    required this.proDiscount, required this.proDeliveryDiscount,
    required this.variationPrice, required this.extraDiscount, this.cartList});

  @override
  Widget build(BuildContext context) {
    bool takeAway = checkoutController.orderType == 'take_away';
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [

        isDesktop ? pricingView(context: context, takeAway: takeAway) : const SizedBox(),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        /// Coupon
        isDesktop && !isGuestLoggedIn ? CouponSection(
          storeId: storeId, checkoutController: checkoutController, total: total, price: price,
          discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, variationPrice: variationPrice,
        ) : const SizedBox(),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            ///Additional Note & prescription..
            NoteAndPrescriptionSection(checkoutController: checkoutController, storeId: storeId),

            isDesktop && !isGuestLoggedIn ? PartialPayView(totalPrice: total, isPrescription: storeId != null) : const SizedBox(),

            !isDesktop ? pricingView(context: context, takeAway: takeAway) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            PrescriptionImagePickerWidget(checkoutController: checkoutController, storeId: storeId, isPrescriptionRequired: isPrescriptionRequired),

            const CheckoutCondition(),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            ExtraDiscountViewWidget(extraDiscount: extraDiscount),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            ResponsiveHelper.isDesktop(context) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text( 'total_amount'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                      storeId == null ? const SizedBox() : Text(
                        'Once_your_order_is_confirmed_you_will_receive'.tr,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeOverSmall, color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                  storeId == null ? const SizedBox() : Text(
                    'a_notification_with_your_bill_total'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeOverSmall, color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
              PriceConverter.convertAnimationPrice(
                checkoutController.viewTotalPrice,
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: checkoutController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              ),
            ]) : const SizedBox(),
          ]),
        ),

        ResponsiveHelper.isDesktop(context) ? Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: checkoutButton,
        ) : const SizedBox(),

      ]),
    );
  }

  Widget pricingView({required BuildContext context, required bool takeAway}) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool hasUnit = cartList != null && cartList!.any((cart) => cart?.item?.unitType != null && cart?.item?.unitType?.isNotEmpty == true);

    final saverDeliveryOption = checkoutController.selectedSaverDeliveryOption;
    final String? saverDeliveryType = saverDeliveryOption?.deliveryType;
    final bool showSaverDeliveryOption = !takeAway && checkoutController.orderType != 'dine_in' && checkoutController.orderType != 'pickup_center'
        && (saverDeliveryType == 'express' || saverDeliveryType == 'slightly_delay');
    final double saverDeliveryAdjustment = checkoutController.getSaverDeliveryChargeAdjustment(deliveryOption: saverDeliveryOption).abs();
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : 0),
      child: Column(children: [

      if(cartList != null && cartList!.isNotEmpty) Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
          ),
          child: ExpansionTile(
            title: Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 'meals_summary'.tr : 'products_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault))),
            collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault))),
            iconColor: Theme.of(context).primaryColor,
            children: [
              Table(
                columnWidths: hasUnit ? const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(2),
                } : const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Theme.of(context).disabledColor.withOpacity(0.05)),
                    children: [
                      Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 'meal'.tr : 'product'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall))),
                      if (hasUnit) Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text('unit'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall))),
                      Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text('price'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall))),
                      Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text('quantity'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall))),
                      Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text('total'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall))),
                    ],
                  ),
                  ...cartList!.map((cart) {
                    String variationStr = '';
                    if (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food') {
                      if (cart!.item != null && cart.item!.foodVariations != null) {
                        for (int i = 0; i < cart.item!.foodVariations!.length; i++) {
                          final foodVar = cart.item!.foodVariations![i];
                          if (cart.foodVariations != null && i < cart.foodVariations!.length) {
                            final selectedValues = cart.foodVariations![i];
                            for (int j = 0; j < foodVar.variationValues!.length; j++) {
                              if (j < selectedValues.length && selectedValues[j] == true) {
                                if (variationStr.isNotEmpty) variationStr += ', ';
                                variationStr += foodVar.variationValues![j].level ?? '';
                              }
                            }
                          }
                        }
                      }
                    } else {
                      if (cart!.variation != null && cart.variation!.isNotEmpty) {
                        variationStr = cart.variation!.where((v) => v.type != null).map((v) => v.type!).join(', ');
                      }
                    }

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cart.item!.name!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (variationStr.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(variationStr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
                              ],
                            ],
                          ),
                        ),
                        if (hasUnit) Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text(cart.item!.unitType ?? '-', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), textAlign: TextAlign.center)),
                        Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text(PriceConverter.convertPrice(cart.price ?? cart.item!.price), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), textDirection: TextDirection.rtl)),
                        Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text(cart.quantity.toString(), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), textAlign: TextAlign.center)),
                        Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall), child: Text(PriceConverter.convertPrice((cart.price ?? cart.item!.price!) * cart.quantity!), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), textDirection: TextDirection.rtl)),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      if(cartList != null && cartList!.isNotEmpty) const SizedBox(height: Dimensions.paddingSizeDefault),

      if (_isGroceryOrPharmacy(cartList) && !_hasCampaignOrFlashSaleItem(cartList) && (AuthHelper.isLoggedIn() && Get.find<SplashController>().configModel?.monthlyOrderRemainder == 1)) ...[
        const MonthlyReorderSection(),
        const SizedBox(height: Dimensions.paddingSizeDefault),
      ],

      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          _priceRow(
            label: storeId == null ? (module.addOn! ? 'subtotal'.tr : 'item_price'.tr) : 'item_price'.tr,
            value: PriceConverter.convertPrice(subTotal),
            context: context,
          ),

          if(discount > 0) _priceRow(
            label: 'discount'.tr,
            value: '(-) ${PriceConverter.convertPrice(discount)}',
            context: context,
          ),

          if(proDiscount > 0) _priceRow(
            label: 'discount_pro'.tr,
            value: '(-) ${PriceConverter.convertPrice(proDiscount)}',
            context: context,
          ),

          if(couponController.discount! > 0 || couponController.freeDelivery) _priceRow(
            label: couponController.coupon?.couponType == 'pro_customer' ? 'coupon_discount_pro'.tr : 'coupon_discount'.tr,
            value: (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery') ? 'free_delivery'.tr : '(-) ${PriceConverter.convertPrice(couponController.discount)}',
            valueColor: (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery') ? Theme.of(context).primaryColor : null,
            context: context,
          ),

          if(referralDiscount > 0) _priceRow(
            label: 'referral_discount'.tr,
            value: '(-) ${PriceConverter.convertPrice(referralDiscount)}',
            context: context,
          ),

          if(!((checkoutController.taxIncluded == null) || taxIncluded || (checkoutController.orderTax == 0))) _priceRow(
            label: 'vat_tax'.tr,
            value: '(+) ${PriceConverter.convertPrice(tax)}',
            context: context,
          ),

          if(!takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1) _priceRow(
            label: 'delivery_man_tips'.tr,
            value: '(+) ${PriceConverter.convertPrice(checkoutController.tips)}',
            context: context,
          ),

          if(storeId == null && (checkoutController.store!.extraPackagingStatus! && Get.find<CartController>().needExtraPackage)) _priceRow(
            label: 'extra_packaging'.tr,
            value: '(+) ${PriceConverter.convertPrice(checkoutController.store!.extraPackagingAmount!)}',
            context: context,
          ),

          if(!(AuthHelper.isGuestLoggedIn() && checkoutController.guestAddress == null)) _priceRow(
            label: 'delivery_fee'.tr,
            customValue: (checkoutController.distance == -1 || deliveryCharge == -1)
                ? const AnimatedCalculatingWidget()
                : null,
            value: (deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery')) ? 'free'.tr : '(+) ${PriceConverter.convertPrice(deliveryCharge)}',
            valueColor: (deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery')) ? Theme.of(context).primaryColor : null,
            badge: checkoutController.isAiBatched ? _smartBatchBadge(context) : null,
            context: context,
          ),

          if(proDeliveryDiscount > 0 && !takeAway && checkoutController.orderType != 'dine_in') _priceRow(
            label: 'delivery_fee_discount_pro'.tr,
            value: '(-) ${PriceConverter.convertPrice(proDeliveryDiscount)}',
            context: context,
          ),

          if(showSaverDeliveryOption) _priceRow(
            label: ' ${'delivery'.tr} ${saverDeliveryType!.replaceAll('_', ' ').capitalize}',
            value: '${saverDeliveryType == 'express' ? '(+) ' : '(-) '}${PriceConverter.convertPrice(saverDeliveryAdjustment)}',
            context: context,
          ),

          if(Get.find<SplashController>().configModel!.additionalChargeStatus! && !(AuthHelper.isGuestLoggedIn() && checkoutController.guestAddress == null)) _priceRow(
            label: Get.find<SplashController>().configModel!.additionalChargeName!,
            value: '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.additionCharge)}',
            context: context,
          ),

          if(checkoutController.isPartialPay) _priceRow(
            label: 'paid_by_wallet'.tr,
            value: '(-) ${PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance!)}',
            context: context,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Divider(thickness: 0.5, color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
          ),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('total_amount'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
            PriceConverter.convertAnimationPrice(
              checkoutController.viewTotalPrice,
              textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      ]),
    );
  }

  Widget _priceRow({required String label, required String value, Color? valueColor, Widget? badge, Widget? customValue, required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Text(label, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
          if(badge != null) Padding(padding: const EdgeInsets.only(left: 5), child: badge),
        ]),
        customValue ?? Text(value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: valueColor), textDirection: TextDirection.rtl),
      ]),
    );
  }

  Widget _smartBatchBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Colors.purpleAccent]),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text('smart_batch'.tr, style: robotoBold.copyWith(fontSize: 10, color: Colors.white)),
        ],
      ),
    );
  }

  bool _isGroceryOrPharmacy(List<CartModel?>? cartList) {
    final item = (cartList != null && cartList.isNotEmpty) ? cartList[0]?.item : null;
    return ModuleHelper.isGroceryOrPharmacy(
      item: item,
      moduleId: item?.moduleId ?? checkoutController.store?.moduleId,
      moduleType: item?.moduleType ?? checkoutController.store?.module?.moduleType,
    );
  }

  bool _hasCampaignOrFlashSaleItem(List<CartModel?>? cartList) {
    return cartList != null && cartList.any((cart) => (cart?.isCampaign ?? false) || (cart?.item?.flashSale ?? 0) > 0);
  }
}
