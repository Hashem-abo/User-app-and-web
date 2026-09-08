import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallHelper {
  /// Directly calls the delivery man via in-app VoIP (Zego).
  /// If any problem occurs (no internet, service inactive, offline, call failure),
  /// a dialog is presented offering direct contact with customer support.
  static Future<void> callDeliveryMan(BuildContext? context, DeliveryMan deliveryMan) async {
    // 1. Check if user is logged in or guest
    if (!AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
      showCallProblemDialog(
        title: 'call_service_not_available'.tr,
        message: 'call_service_guest_msg'.tr,
      );
      return;
    }

    // 2. Check internet connection
    if (!kIsWeb) {
      bool hasConnection = true;
      try {
        final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          hasConnection = false;
        }
      } catch (_) {
        hasConnection = false;
      }

      if (!hasConnection) {
        showCallProblemDialog(
          title: 'no_internet_connection'.tr,
          message: 'call_failed_no_internet_msg'.tr,
        );
        return;
      }
    }

    // 3. Check if Zego invitation service is initialized
    if (!ZegoUIKitPrebuiltCallInvitationService().isInit) {
      showCallProblemDialog(
        title: 'call_service_not_available'.tr,
        message: 'call_service_disabled_msg'.tr,
      );
      return;
    }

    // 4. Send Zego in-app call invitation directly (no cellular vs online choices)
    try {
      bool success = await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [
          ZegoCallUser(
            'delivery_${deliveryMan.id}',
            '${deliveryMan.fName ?? ''} ${deliveryMan.lName ?? ''}'.trim(),
          )
        ],
        isVideoCall: false,
      );

      if (!success) {
        showCallProblemDialog(
          title: 'call_failed'.tr,
          message: 'delivery_man_unreachable_contact_support'.tr,
        );
      }
    } catch (e) {
      showCallProblemDialog(
        title: 'call_failed'.tr,
        message: 'call_failed_error_msg'.tr,
      );
    }
  }

  /// Displays a dialog when in-app call encounters an issue,
  /// providing an option to contact customer support.
  static void showCallProblemDialog({BuildContext? context, String? title, String? message}) {
    BuildContext? ctx = context ?? Get.context;
    if (ctx == null) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_disabled_rounded,
                size: 40,
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text(
              title ?? 'call_failed'.tr,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              message ?? 'delivery_man_unreachable_contact_support'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(ctx).disabledColor,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomButton(
              buttonText: 'call_customer_service'.tr,
              icon: Icons.headset_mic_rounded,
              onPressed: () async {
                Get.back();
                String? phone = Get.find<SplashController>().configModel?.phone;
                if (phone != null && phone.isNotEmpty && await canLaunchUrlString('tel:$phone')) {
                  launchUrlString('tel:$phone', mode: LaunchMode.externalApplication);
                } else {
                  Get.toNamed(RouteHelper.getSupportRoute());
                }
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'close'.tr,
                style: robotoMedium.copyWith(color: Theme.of(ctx).disabledColor),
              ),
            ),
          ]),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
