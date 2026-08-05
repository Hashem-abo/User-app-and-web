import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/domain/models/service_booking_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class ServiceBookingTrackingScreen extends StatefulWidget {
  final int bookingId;
  const ServiceBookingTrackingScreen({super.key, required this.bookingId});

  @override
  State<ServiceBookingTrackingScreen> createState() => _ServiceBookingTrackingScreenState();
}

class _ServiceBookingTrackingScreenState extends State<ServiceBookingTrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget.bookingId == -1) {
        Get.find<ServiceController>().getBookingList(1);
      } else {
        Get.find<ServiceController>().getBookingDetails(widget.bookingId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'track_booking'.tr),
      body: GetBuilder<ServiceController>(builder: (serviceController) {
        if (widget.bookingId == -1) {
          List<ServiceBooking>? bookings = serviceController.bookings;
          if (bookings == null) return const CustomLoaderWidget();
          
          List<ServiceBooking> activeBookings = bookings.where((b) => b.status != 'completed' && b.status != 'canceled').toList();
          
          if (activeBookings.isEmpty) {
            return Center(child: Text('no_active_bookings_found'.tr, style: robotoMedium));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            itemCount: activeBookings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                child: _buildTrackingCard(context, activeBookings[index]),
              );
            },
          );
        } else {
          ServiceBooking? booking = serviceController.bookingDetails;
          if (booking == null) return const CustomLoaderWidget();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: _buildTrackingCard(context, booking),
          );
        }
      }),
    );
  }

  Widget _buildTrackingCard(BuildContext context, ServiceBooking booking) {
    bool isRental = booking.service?.serviceMode == 'rental';
    
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${'booking_id'.tr}: #${booking.bookingId}', style: robotoBold),
          if (widget.bookingId == -1)
            InkWell(
              onTap: () => Get.toNamed(RouteHelper.getServiceBookingTrackingRoute(id: booking.id!)),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).primaryColor),
            ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          DateConverter.isoStringToDateTimeString(booking.scheduledDate ?? ''),
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        _StatusItem(
          title: isRental ? 'waiting_for_approval' : 'pending',
          time: booking.createdAt,
          isCompleted: true,
          isCurrent: booking.status == 'pending',
          isLast: false,
        ),
        _StatusItem(
          title: isRental ? 'reserved' : 'confirmed',
          time: booking.confirmedAt,
          isCompleted: ['confirmed', 'ongoing', 'completed'].contains(booking.status),
          isCurrent: booking.status == 'confirmed',
          isLast: false,
        ),
        _StatusItem(
          title: isRental ? 'usage_in_progress' : 'ongoing',
          time: booking.ongoingAt,
          isCompleted: ['ongoing', 'completed'].contains(booking.status),
          isCurrent: booking.status == 'ongoing',
          isLast: false,
        ),
        _StatusItem(
          title: isRental ? 'returned_and_finished' : 'completed',
          time: booking.completedAt,
          isCompleted: booking.status == 'completed',
          isCurrent: booking.status == 'completed',
          isLast: true,
        ),

        if (booking.status == 'canceled')
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
            child: _StatusItem(
              title: 'canceled',
              time: booking.canceledAt,
              isCompleted: true,
              isCurrent: true,
              isLast: true,
              color: Colors.red,
            ),
          ),
      ]),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String title;
  final String? time;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final Color? color;

  const _StatusItem({
    required this.title,
    this.time,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor = color ?? Theme.of(context).primaryColor;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          height: 20, width: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
            border: isCurrent ? Border.all(color: primaryColor, width: 2) : null,
          ),
          child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
        ),
        if (!isLast)
          Container(
            height: 50, width: 2,
            color: isCompleted ? primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
          ),
      ]),
      const SizedBox(width: Dimensions.paddingSizeDefault),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.tr, style: isCurrent ? robotoBold : robotoRegular),
        if (time != null)
          Text(
            DateConverter.isoStringToDateTimeString(time!),
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
          ),
      ])),
    ]);
  }
}
