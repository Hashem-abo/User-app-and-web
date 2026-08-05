import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/domain/models/service_booking_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/review/widgets/service_review_dialog_widget.dart';

class ServiceBookingDetailsScreen extends StatefulWidget {
  final int bookingId;
  const ServiceBookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<ServiceBookingDetailsScreen> createState() => _ServiceBookingDetailsScreenState();
}

class _ServiceBookingDetailsScreenState extends State<ServiceBookingDetailsScreen> {
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Get.find<ServiceController>().getBookingDetails(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'booking_details'.tr),
      body: GetBuilder<ServiceController>(builder: (serviceController) {
        ServiceBooking? booking = serviceController.bookingDetails;
        
        if (booking == null) return const CustomLoaderWidget();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            
            // Booking Status
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${'booking_id'.tr}: #${booking.bookingId}', style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  if(booking.endDate != null) ...[
                    Text('${'check_in'.tr}: ${DateConverter.isoStringToDateTimeString(booking.scheduledDate ?? '')}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    Text('${'check_out'.tr}: ${DateConverter.isoStringToDateTimeString(booking.endDate ?? '')}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  ] else
                    Text(DateConverter.isoStringToDateTimeString(booking.scheduledDate ?? ''), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(booking.status?.tr ?? '', style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall)),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Service Info
            Text('service_info'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: CustomImage(image: booking.service?.imageFullUrl ?? '', height: 60, width: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(booking.service?.name ?? 'service_name'.tr, style: robotoMedium),
                  Text('${PriceConverter.convertPrice(booking.service?.price ?? booking.totalAmount)}${booking.service?.rentalUnit != null ? '/${booking.service?.rentalUnit}'.tr : ''}', style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                ])),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            if (booking.customerNote != null && booking.customerNote!.isNotEmpty) ...[
              Text('customer_note'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Text(booking.customerNote!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],

            // Provider Info
            Text('provider_info'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: CustomImage(image: booking.provider?.logoFullUrl ?? '', height: 50, width: 50, fit: BoxFit.cover),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(booking.provider?.companyName ?? 'provider_name'.tr, style: robotoMedium),
                  Text(booking.provider?.companyAddress ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                ])),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Payment Summary
            Text('payment_summary'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('service_price'.tr, style: robotoRegular),
              Text(PriceConverter.convertPrice(booking.service?.price ?? booking.totalAmount), style: robotoRegular),
            ]),
            const Divider(height: Dimensions.paddingSizeLarge),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('total_amount'.tr, style: robotoBold),
              Text(PriceConverter.convertPrice(booking.totalAmount), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            if (booking.status != 'pending' && booking.status != 'canceled')
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(RouteHelper.getServiceBookingTrackingRoute(id: booking.id!));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                child: Text('track_booking'.tr),
              )),
            if (booking.status != 'pending' && booking.status != 'canceled')
              const SizedBox(height: Dimensions.paddingSizeSmall),

            if (booking.status == 'completed')
              SizedBox(width: double.infinity, child: OutlinedButton(
                onPressed: () {
                  Get.dialog(ServiceReviewDialogWidget(booking: booking));
                },
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).primaryColor, side: BorderSide(color: Theme.of(context).primaryColor)),
                child: Text('rate_service'.tr),
              )),
            if (booking.status == 'completed')
              const SizedBox(height: Dimensions.paddingSizeSmall),

            if (booking.status == 'pending')
              SizedBox(width: double.infinity, child: OutlinedButton(
                onPressed: () {
                  serviceController.cancelBooking(booking.id!).then((status) {
                    if (status) {
                      Get.back();
                      Get.showSnackbar(GetSnackBar(message: 'booking_cancelled_successfully'.tr, duration: const Duration(seconds: 2)));
                    }
                  });
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                child: Text('cancel_booking'.tr),
              )),

          ]),
        );
      }),
    );
  }
}
