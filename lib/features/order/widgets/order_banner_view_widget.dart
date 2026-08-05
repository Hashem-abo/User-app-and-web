import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class OrderBannerViewWidget extends StatelessWidget {
  final OrderModel order;
  final bool ongoing;
  final bool parcel;
  final bool prescriptionOrder;
  final OrderController orderController;
  const OrderBannerViewWidget({super.key, required this.order, required this.ongoing, required this.parcel, required this.prescriptionOrder, required this.orderController, });

  String _getStatusGif() {
    switch (order.orderStatus) {
      case 'pending':
        return order.moduleType == 'food' ? Images.pendingFoodOrderDetails : Images.pendingOrderDetails;
      case 'accepted':
      case 'confirmed':
        return Images.confirmedGif;
      case 'processing':
        if (order.moduleType == 'food') {
          return Images.preparingFoodOrderDetails;
        } else if (order.moduleType == 'grocery') {
          return Images.preparingGroceryOrderDetails;
        } else {
          return Images.processingGif;
        }
      case 'handover':
        return Images.handoverGif;
      case 'picked_up':
        return order.moduleType == 'food' ? Images.ongoingAnimation : Images.onTheWayGif;
      case 'delivered':
        return Images.checkGif;
      case 'canceled':
      case 'failed':
      case 'refund_requested':
      case 'refunded':
      case 'refund_request_canceled':
        return Images.cancelGif;
      default:
        return Images.pendingGif;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: (order.orderStatus == 'delivered' && order.store != null)
            ? CustomImage(
                image: (order.store!.coverPhotoFullUrl != null && order.store!.coverPhotoFullUrl!.isNotEmpty)
                    ? order.store!.coverPhotoFullUrl!
                    : (order.store!.logoFullUrl ?? ''),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Image.asset(
                _getStatusGif(),
                fit: BoxFit.contain,
                height: 180,
                width: double.infinity,
              ),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      DateConverter.isBeforeTime(order.scheduleAt) &&
              Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation! &&
              ongoing
          ? Column(children: [
              Text('your_food_will_delivered_within'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    DateConverter.differenceInMinute(order.store!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt) < 5 ? '1 - 5'
                        : '${DateConverter.differenceInMinute(order.store!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)-5} '
                        '- ${DateConverter.differenceInMinute(order.store!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)}',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge), textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text('min'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor)),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            ])
          : const SizedBox(),
    ]);
  }
}
