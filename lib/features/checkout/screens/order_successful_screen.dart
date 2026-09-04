import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/helper/guest_order_helper.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final String? contactPersonNumber;
  final bool? createAccount;
  final String guestId;
  const OrderSuccessfulScreen({super.key, required this.orderID, this.contactPersonNumber, this.createAccount = false, required this.guestId});

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {

  bool? _isCashOnDeliveryActive = false;
  String? orderId;

  @override
  void initState() {
    super.initState();

    orderId = widget.orderID!;
    if(widget.orderID != null) {
      if(widget.orderID!.contains('?')){
        var parts = widget.orderID!.split('?');
        String id = parts[0].trim();
        orderId = id;
      }
    }

    if(!widget.createAccount!) {
      Get.find<OrderController>().trackOrder(orderId.toString(), null, false, contactNumber: widget.contactPersonNumber);
    }

    if(AuthHelper.isGuestLoggedIn() && orderId != null) {
      int? parsedId = int.tryParse(orderId!);
      if(parsedId != null) {
        GuestOrderHelper.addGuestOrder(parsedId, widget.contactPersonNumber);
      }
    }

    if(AuthHelper.isLoggedIn()) {
      Get.find<OrderController>().getMonthlyOrderList(notify: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await Get.offAllNamed(RouteHelper.getInitialRoute());
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        body: GetBuilder<OrderController>(builder: (orderController){
          double total = 0;
          bool success = true;
          bool parcel = false;
          bool takeAway = false;
          double? maximumCodOrderAmount;
          if(orderController.trackModel != null) {
            total = ((orderController.trackModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
            success = orderController.trackModel!.paymentStatus == 'paid' || orderController.trackModel!.paymentMethod == 'cash_on_delivery'
              || orderController.trackModel!.paymentMethod == 'partial_payment' || orderController.trackModel!.paymentMethod == 'wallet';
            parcel = orderController.trackModel!.orderType == 'parcel';
            takeAway = orderController.trackModel!.orderType == 'take_away';
            List<ZoneData>? zList = AddressHelper.getUserAddressFromSharedPref()?.zoneData;
            if (zList != null) {
              for(ZoneData zData in zList) {
                if (zData.modules != null) {
                  for(Modules m in zData.modules!) {
                    if(m.id == Get.find<SplashController>().module?.id) {
                      maximumCodOrderAmount = m.pivot?.maximumCodOrderAmount;
                      break;
                    }
                  }
                }
                if(zData.id == AddressHelper.getUserAddressFromSharedPref()?.zoneId){
                  _isCashOnDeliveryActive = zData.cashOnDelivery;
                }
              }
            }

            if (!success && !Get.isDialogOpen! && orderController.trackModel!.orderStatus != 'canceled' && Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
              Future.delayed(const Duration(seconds: 1), () {
                Get.dialog(PaymentFailedDialog(
                  orderID: orderId, isCashOnDelivery: _isCashOnDeliveryActive, orderAmount: total, maxCodOrderAmount: maximumCodOrderAmount,
                  orderType: parcel ? 'parcel' : 'delivery', guestId: widget.guestId,
                ), barrierDismissible: false);
              });
            }
          }

          return orderController.trackModel != null || widget.createAccount! ? Center(
            child: SingleChildScrollView(
              child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                const SizedBox(height: 50),
                Container(
                  height: 100, width: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(success ? Icons.check : Icons.warning_amber_rounded, color: Colors.white, size: 60),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text(
                  success ? parcel ? 'you_placed_the_parcel_request_successfully'.tr
                      : 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                widget.createAccount! ? Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      'and_create_account_successfully'.tr,
                      style: robotoMedium,
                    ),
                    InkWell(
                      onTap: () {
                        if(ResponsiveHelper.isDesktop(context)){
                          Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: false, backFromThis: false)));
                        }else{
                          Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        child: Text('sign_in'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                      ),
                    ),
                  ]),
                ) : const SizedBox(),

                AuthHelper.isGuestLoggedIn() ? SelectableText(
                  '${'order_id'.tr}: $orderId',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ) : const SizedBox(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                  child: Text(
                    success ? parcel ? 'your_parcel_request_is_placed_successfully'.tr : takeAway ? 'thank_you_for_your_order'.tr
                        : 'your_order_is_placed_successfully'.tr : 'your_order_is_failed_to_place_because'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    textAlign: TextAlign.center,
                  ),
                ),

                ResponsiveHelper.isDesktop(context) && (success && Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 && total.floor() > 0 ) && AuthHelper.isLoggedIn()  ? Column(children: [

                  Image.asset(Get.find<ThemeController>().darkTheme ? Images.congratulationDark : Images.congratulationLight, width: 150, height: 150),

                  Text('congratulations'.tr , style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Text(
                      '${'you_have_earned'.tr} ${total.floor().toString()} ${'points_it_will_add_to'.tr}',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).disabledColor),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ]) : const SizedBox.shrink() ,
                const SizedBox(height: 30),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Column(children: [
                    CustomButton(
                      buttonText: 'track_order'.tr,
                      onPressed: () {
                        String? phone = (widget.contactPersonNumber != null && widget.contactPersonNumber != 'null' && widget.contactPersonNumber!.isNotEmpty)
                            ? widget.contactPersonNumber
                            : orderController.trackModel?.deliveryAddress?.contactPersonNumber;
                        Get.offNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderId!), contactNumber: phone));
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    CustomButton(
                      buttonText: 'continue_shopping'.tr,
                      transparent: true,
                      isBorder: true,
                      onPressed: () {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    CustomButton(
                      buttonText: 'print_invoice'.tr,
                      transparent: true,
                      color: Theme.of(context).disabledColor.withOpacity(0.1),
                      textColor: Theme.of(context).disabledColor,
                      isBorder: true,
                      onPressed: () {
                        Get.toNamed(RouteHelper.getInvoiceRoute(orderId));
                      },
                    ),
                  ]),
                ),

                const SizedBox(height: 40),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('need_help'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.getChatRoute(notificationBody: NotificationBodyModel(adminId: 0)));
                    },
                    child: Text('contact_us'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  ),
                ]),
                const SizedBox(height: 50),

              ]))),
            ),
          ) : const CustomLoaderWidget();
        }),
      ),
    );
  }
}
