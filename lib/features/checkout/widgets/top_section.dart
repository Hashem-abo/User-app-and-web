import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/features/checkout/widgets/guest_create_account.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_dropdown.dart';
import 'package:sixam_mart/features/cart/widgets/delivery_option_button_widget.dart';
import 'package:sixam_mart/features/checkout/widgets/coupon_section.dart';
import 'package:sixam_mart/features/checkout/widgets/delivery_section.dart';
import 'package:sixam_mart/features/checkout/widgets/deliveryman_tips_section.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_section.dart';
import 'package:sixam_mart/features/checkout/widgets/time_slot_section.dart';
import 'package:sixam_mart/features/store/widgets/camera_button_sheet_widget.dart';
import 'package:sixam_mart/features/checkout/widgets/saver_delivery_time_widget.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'dart:io';

class TopSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final double charge;
  final double deliveryCharge;
  final List<DropdownItem<int>> addressList;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final  double price;
  final double discount;
  final double addOns;
  final int? storeId;
  final List<AddressModel> address;
  final List<CartModel?>? cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final bool isOfflinePaymentActive;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final JustTheController tooltipController1;
  final JustTheController tooltipController2;
  final JustTheController dmTipsTooltipController;
  final TextEditingController guestPasswordController;
  final TextEditingController guestConfirmPasswordController;
  final FocusNode guestPasswordNode;
  final FocusNode guestConfirmPasswordNode;
  final double variationPrice;
  final String deliveryChargeForView;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final bool proFreeDelivery;

  const TopSection({
    super.key, required this.deliveryCharge, required  this.charge, required this.tomorrowClosed,
    required this.todayClosed, required this.price, required this.discount, required this.addOns,
    required this.addressList, required this.checkoutController,
    this.module, this.storeId, required this.address, required this.cartList,
    required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive, required this.isWalletActive,
    required this.total, required this.isOfflinePaymentActive, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode,
    required this.guestEmailController, required this.guestEmailNode, required this.tooltipController1,
    required this.tooltipController2, required this.dmTipsTooltipController, required this.guestPasswordController, required this.guestConfirmPasswordController,
    required this.guestPasswordNode, required this.guestConfirmPasswordNode, required this.variationPrice, required this.deliveryChargeForView,
    required this.badWeatherCharge, required this.extraChargeForToolTip, this.proFreeDelivery = false,
  });

  @override
  Widget build(BuildContext context) {
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();

    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      child: Column(children: [

        (storeId != null && (cartList == null || cartList!.isEmpty)) ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              Text('your_prescription'.tr, style: robotoMedium),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: tooltipController1,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('prescription_tool_tip'.tr, style: robotoRegular.copyWith(color: Colors.white)),
                ),
                child: InkWell(
                  onTap: () => tooltipController1.showTooltip(),
                  child: const Icon(Icons.info_outline),
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: checkoutController.pickedPrescriptions.length+1,
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                itemBuilder: (context, index) {
                  XFile? file = index == checkoutController.pickedPrescriptions.length ? null : checkoutController.pickedPrescriptions[index];
                  if(index < 5 && index == checkoutController.pickedPrescriptions.length) {
                    return InkWell(
                      onTap: () {
                        if (ResponsiveHelper.isDesktop(context) || GetPlatform.isIOS){
                          checkoutController.pickPrescriptionImage(isRemove: false, isCamera: false);
                        } else {
                          Get.bottomSheet(const CameraButtonSheetWidget());
                        }
                      },
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 1,
                          strokeCap: StrokeCap.butt,
                          dashPattern: const [5, 5],
                          padding: const EdgeInsets.all(0),
                          radius: const Radius.circular(Dimensions.radiusDefault),
                        ),
                        child: Container(
                          height: 98, width: 98, alignment: Alignment.center, decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                          child:  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.cloud_upload, color: Theme.of(context).disabledColor, size: 32),
                            Text('upload_your_prescription'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,),
                          ]),
                        ),
                      ),
                    );
                  }
                  return file != null ? Container(
                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1,
                        strokeCap: StrokeCap.butt,
                        dashPattern: const [5, 5],
                        padding: const EdgeInsets.all(0),
                        radius: const Radius.circular(Dimensions.radiusDefault),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: GetPlatform.isWeb ? Image.network(
                              file.path, width: 98, height: 98, fit: BoxFit.cover,
                            ) : Image.file(
                              File(file.path), width: 98, height: 98, fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: InkWell(
                              onTap: () => checkoutController.removePrescriptionImage(index),
                              child: const Padding(
                                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Icon(Icons.delete_forever, color: Colors.red),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ) : const SizedBox();
                },
              ),
            ),
          ]),
        ) : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // delivery option
        Builder(
          builder: (context) {
            AddressModel? userAddress = AddressHelper.getUserAddressFromSharedPref();
            bool isOutZone = false;
            if (checkoutController.store != null && userAddress != null) {
              if (userAddress.zoneIds != null && userAddress.zoneIds!.isNotEmpty) {
                isOutZone = !userAddress.zoneIds!.contains(checkoutController.store!.zoneId);
              } else if (userAddress.zoneId != null) {
                isOutZone = userAddress.zoneId != checkoutController.store!.zoneId;
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
              width: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('delivery_type'.tr, style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  if (isOutZone)
                    Container(
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                      ),
                      child: Row(children: [
                        Icon(Icons.info_outline, color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            Get.find<LocalizationController>().isLtr
                                ? 'This store is outside your zone. Delivery is only available via Pickup Center.'
                                : 'هذا المتجر يقع خارج منطقتك السكنية، يتوفر التسليم عبر مركز استلام فقط.',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ]),
                    ),

                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                    (!isOutZone && Get.find<SplashController>().configModel?.homeDeliveryStatus == 1 && (checkoutController.store?.delivery ?? true)) ? DeliveryOptionButtonWidget(
                      value: 'delivery', title: 'home_delivery'.tr, charge: charge,
                      isFree: checkoutController.store?.freeDelivery ?? false,  fromWeb: true, total: total,
                      deliveryChargeForView: deliveryChargeForView, badWeatherCharge: badWeatherCharge, extraChargeForToolTip: extraChargeForToolTip,
                    ) : const SizedBox(),
                    if (!isOutZone) const SizedBox(width: Dimensions.paddingSizeDefault),

                    (!isOutZone && Get.find<SplashController>().configModel?.takeawayStatus == 1 && (checkoutController.store?.takeAway ?? true) && (storeId == null || (cartList != null && cartList!.isNotEmpty))) ? DeliveryOptionButtonWidget(
                      value: 'take_away', title: 'take_away'.tr, charge: deliveryCharge, isFree: true,  fromWeb: true, total: total,
                      deliveryChargeForView: deliveryChargeForView, badWeatherCharge: badWeatherCharge, extraChargeForToolTip: extraChargeForToolTip,
                    ) : const SizedBox(),

                    (Get.find<SplashController>().configModel?.pickupCenterStatus != 0) ? Container(
                      margin: EdgeInsets.only(right: !isOutZone ? Dimensions.paddingSizeDefault : 0, left: !isOutZone ? Dimensions.paddingSizeDefault : 0),
                      child: DeliveryOptionButtonWidget(
                        value: 'pickup_center', title: 'delivery_to_pickup_center'.tr, charge: charge,
                        isFree: false, fromWeb: true, total: total,
                        deliveryChargeForView: deliveryChargeForView, badWeatherCharge: badWeatherCharge, extraChargeForToolTip: extraChargeForToolTip,
                      ),
                    ) : const SizedBox(),
                  ]),
                  ),
                ],
              ),
            );
          }
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        /// Saver Delivery Options (Standard, Express, Slightly Delay)
        GetBuilder<CheckoutController>(builder: (controller) {
          final bool showSaver = controller.isInstantDelivery && controller.orderType != 'pickup_center' && SaverDeliveryTimeWidget.canShow(
            controller: controller, deliveryCharge: deliveryCharge, originalDeliveryCharge: charge, proFreeDelivery: proFreeDelivery,
          );

          if (!showSaver) return const SizedBox();

          return Column(children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: SaverDeliveryTimeWidget(
                checkoutController: controller, deliveryCharge: deliveryCharge, originalDeliveryCharge: charge, proFreeDelivery: proFreeDelivery,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]);
        }),

        ///delivery section
        DeliverySection(checkoutController: checkoutController, address: address, addressList: addressList,
          guestNameTextEditingController: guestNameTextEditingController, guestNumberTextEditingController: guestNumberTextEditingController,
          guestNumberNode: guestNumberNode, guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
        ),

        SizedBox(height: !takeAway ? isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall : 0),

        ///Create Account with existing info
        isGuestLoggedIn && (Get.find<SplashController>().configModel?.centralizeLoginSetup?.manualLoginStatus ?? false) &&
        (!takeAway ? checkoutController.guestAddress != null : true) ? GuestCreateAccount(
          guestPasswordController: guestPasswordController, guestConfirmPasswordController: guestConfirmPasswordController,
          guestPasswordNode: guestPasswordNode, guestConfirmPasswordNode: guestConfirmPasswordNode,
        ) : const SizedBox(),
        SizedBox(height: isGuestLoggedIn && (Get.find<SplashController>().configModel?.centralizeLoginSetup?.manualLoginStatus ?? false) ? Dimensions.paddingSizeSmall : 0),

        ///delivery instruction
        // !takeAway ? isDesktop ? const WebDeliveryInstructionView() : const DeliveryInstructionView() : const SizedBox(),
        const SizedBox(),

        /// Time Slot Section
        TimeSlotSection(
          storeId: storeId, checkoutController: checkoutController, cartList: cartList, tooltipController2: tooltipController2,
          tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, module: module,
        ),

        /// Coupon..
        !isDesktop && !isGuestLoggedIn ? CouponSection(
          storeId: storeId, checkoutController: checkoutController, total: total, price: price,
          discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, variationPrice: variationPrice,
        ) : const SizedBox(),

        ///DmTips..
        DeliveryManTipsSection(
          takeAway: takeAway, tooltipController3: dmTipsTooltipController,
          totalPrice: total, onTotalChange: (double price) => total + price, storeId: storeId,
        ),

        ///Payment..
        Container(
          decoration: isDesktop ? const BoxDecoration() : BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [

            PaymentSection(
              storeId: storeId, isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
              isWalletActive: isWalletActive, total: total, checkoutController: checkoutController, isOfflinePaymentActive: isOfflinePaymentActive,
              cartList: cartList,
            ),

          ]),
        ),
        SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),

      ]),
    );
  }
}
