import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/order/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/order/screens/order_details_screen.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/review/screens/rate_review_screen.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderViewWidget extends StatelessWidget {
  final bool isRunning;
  const OrderViewWidget({super.key, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<OrderController>(builder: (orderController) {
        PaginatedOrderModel? paginatedOrderModel;
        if(isRunning) {
          paginatedOrderModel = orderController.runningOrderModel;
        }else {
          paginatedOrderModel = orderController.historyOrderModel;
        }

        return paginatedOrderModel != null ? paginatedOrderModel.orders!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            if(isRunning) {
              await orderController.getRunningOrders(1, isUpdate: true);
            }else {
              await orderController.getHistoryOrders(1, isUpdate: true);
            }
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 0 : 100),
                  child: PaginatedListView(
                    scrollController: scrollController,
                    onPaginate: (int? offset) async {
                      if(isRunning) {
                        await orderController.getRunningOrders(offset!, isUpdate: true);
                      }else {
                        await orderController.getHistoryOrders(offset!, isUpdate: true);
                      }
                    },
                    totalSize: isRunning ? orderController.runningOrderModel?.totalSize : orderController.historyOrderModel?.totalSize,
                    offset: isRunning ? orderController.runningOrderModel?.offset : orderController.historyOrderModel?.offset,
                    itemView: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : Dimensions.paddingSizeLarge,
                        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : 0,
                        mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 210 : 230,
                        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      itemCount: paginatedOrderModel.orders!.length,
                      itemBuilder: (context, index) {
                        OrderModel order = paginatedOrderModel!.orders![index];
                        bool isParcel = order.orderType == 'parcel';
                        bool isPrescription = order.prescriptionOrder!;

                        return Container(
                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                            border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), width: 1),
                          ),
                          child: Column(children: [

                            CustomInkWell(
                              onTap: () {
                                Get.toNamed(
                                  RouteHelper.getOrderDetailsRoute(order.id),
                                  arguments: OrderDetailsScreen(
                                    orderId: order.id,
                                    orderModel: order,
                                  ),
                                );
                              },
                              radius: Dimensions.radiusDefault,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              child: Column(children: [

                                Row(children: [

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                    decoration: BoxDecoration(
                                      color: (order.orderStatus == 'delivered' || order.orderStatus == 'picked_up') ? Colors.green.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                    ),
                                    child: Row(children: [
                                      Icon(Icons.access_time_rounded, size: 15, color: (order.orderStatus == 'delivered' || order.orderStatus == 'picked_up' || order.orderStatus == 'arrived_at_pickup_center') ? Colors.green : Theme.of(context).primaryColor),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        (order.orderType == 'take_away' && (order.orderStatus == 'handover' || order.orderStatus == 'picked_up') ? 'ready_for_handover'
                                        : (order.orderType != 'pickup_center' && order.orderStatus == 'arrived_at_pickup_center' ? 'delivery_on_the_way' : order.orderStatus!)).tr,
                                        style: robotoBold.copyWith(color: (order.orderStatus == 'delivered' || order.orderStatus == 'picked_up' || order.orderStatus == 'arrived_at_pickup_center') ? Colors.green : Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                                      ),
                                    ]),
                                  ),

                                  const Spacer(),

                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Row(children: [
                                      Text(isParcel ? 'delivery_id'.tr : 'order_id'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text('#${order.id}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                    Text(order.store?.name ?? (isParcel ? order.parcelCategory?.name ?? '' : ''), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ]),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    child: CustomImage(
                                      image: isParcel ? order.parcelCategory?.imageFullUrl ?? '' : order.store?.logoFullUrl ?? '',
                                      height: 50, width: 50, fit: BoxFit.cover,
                                    ),
                                  ),

                                ]),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                Row(children: [
                                  Text(
                                    isParcel ? 'parcel'.tr : '${order.detailsCount} ${order.detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text('|', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    DateConverter.dateTimeStringToDateTime(order.createdAt!),
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                  ),
                                ]),

                                const Divider(),

                                Row(children: [
                                  Text('view_details'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                                  const Spacer(),
                                  Text(
                                    PriceConverter.convertPrice(order.orderAmount),
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  ),
                                ]),

                              ]),
                            ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, 0, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall),
                              child: isRunning ? Row(children: [
                                Expanded(child: ElevatedButton(
                                  onPressed: () => Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, null)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  ),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Image.asset(Images.tracking, height: 15, width: 15, color: Colors.white),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    Text(isParcel ? 'track_delivery'.tr : 'track_order'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
                                  ]),
                                )),
                              ]) : Row(children: [
                                Expanded(child: OutlinedButton(
                                  onPressed: () async {
                                    bool isReviewed = order.reviews != null && order.reviews!.isNotEmpty;
                                    if (isReviewed) {
                                      Get.toNamed(
                                        RouteHelper.getOrderDetailsRoute(order.id),
                                        arguments: OrderDetailsScreen(
                                          orderId: order.id,
                                          orderModel: order,
                                        ),
                                      );
                                    } else {
                                      Get.dialog(CustomLoaderWidget(), barrierDismissible: false);
                                      List<OrderDetailsModel>? detailsList = await orderController.getOrderDetails(order.id.toString());
                                      Get.back();

                                      if (detailsList != null && (detailsList.isNotEmpty || isParcel)) {
                                        final orderDetailsList = <OrderDetailsModel>[];
                                        final orderDetailsIdList = <int?>[];

                                        if (detailsList.isNotEmpty) {
                                          for (var orderDetail in detailsList) {
                                            if (orderDetail.itemDetails != null && !orderDetailsIdList.contains(orderDetail.itemDetails!.id)) {
                                              orderDetailsList.add(orderDetail);
                                              orderDetailsIdList.add(orderDetail.itemDetails!.id);
                                            }
                                          }
                                        }

                                        Get.toNamed(RouteHelper.getRateReviewRoute(), arguments: RateReviewScreen(
                                          orderDetailsList: orderDetailsList,
                                          deliveryMan: order.deliveryMan,
                                          orderID: order.id,
                                          reviews: order.reviews,
                                        ));
                                      } else {
                                        showCustomSnackBar('failed_to_load_order_details'.tr);
                                      }
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Theme.of(context).primaryColor),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  ),
                                  child: Text(
                                    (order.reviews != null && order.reviews!.isNotEmpty) ? 'view_details'.tr : 'rate_order'.tr,
                                    style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                                  ),
                                )),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(child: ElevatedButton(
                                  onPressed: () {
                                    orderController.reorder(order.id!, order: order);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  ),
                                  child: Text('reorder'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
                                )),
                              ]),
                            ),

                          ]),
                        );
                      },
),
                  ),
                ),
              ),
            ),
          ),
        ) : NoDataScreen(text: 'no_order_found'.tr, showFooter: true) : OrderShimmerWidget(orderController: orderController);
      }),
    );
  }
}
