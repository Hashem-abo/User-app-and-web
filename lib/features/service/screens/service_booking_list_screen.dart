import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/domain/models/service_booking_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';

import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';

class ServiceBookingListScreen extends StatefulWidget {
  const ServiceBookingListScreen({super.key});

  @override
  State<ServiceBookingListScreen> createState() => _ServiceBookingListScreenState();
}

class _ServiceBookingListScreenState extends State<ServiceBookingListScreen> {
  
  @override
  void initState() {
    super.initState();
    if(AuthHelper.isLoggedIn()) {
      Future.delayed(Duration.zero, () {
        Get.find<ServiceController>().getBookingList(1, reload: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      appBar: CustomAppBar(title: 'my_bookings'.tr, backButton: ResponsiveHelper.isDesktop(context)),
      body: isLoggedIn ? GetBuilder<ServiceController>(builder: (serviceController) {
        return serviceController.bookings != null ? serviceController.bookings!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await serviceController.getBookingList(1, reload: true);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            itemCount: serviceController.bookings!.length,
            itemBuilder: (context, index) {
              ServiceBooking booking = serviceController.bookings![index];
              return InkWell(
                onTap: () {
                  Get.toNamed(RouteHelper.getServiceBookingDetailsRoute(booking.id));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${'booking_id'.tr}: #${booking.bookingId}', style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        DateConverter.isoStringToDateTimeString(booking.scheduledDate ?? ''),
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(PriceConverter.convertPrice(booking.totalAmount), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Text(booking.status?.tr ?? '', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)),
                      ),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ) : Center(child: Text('no_bookings_found'.tr)) : const CustomLoaderWidget();
      }) : NotLoggedInScreen(callBack: (v){
        initData();
        setState(() {});
      }),
    );
  }

  void initData() {
    if(AuthHelper.isLoggedIn()) {
      Get.find<ServiceController>().getBookingList(1, reload: true);
    }
  }
}
