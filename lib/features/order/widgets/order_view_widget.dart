import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/order/screens/order_details_screen.dart';
import 'package:sixam_mart/features/order/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart/features/review/screens/rate_review_screen.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class OrderViewWidget extends StatelessWidget {
  final bool isRunning;
  const OrderViewWidget({super.key, required this.isRunning});

  Color _getStatusColor(String? status, BuildContext context) {
    switch (status) {
      case 'pending':
        return const Color(0xFF2563EB); // Modern Royal Blue
      case 'accepted':
      case 'confirmed':
        return const Color(0xFF0D9488); // Deep Teal
      case 'processing':
        return const Color(0xFFD97706); // Amber
      case 'handover':
        return const Color(0xFF7C3AED); // Modern Violet
      case 'picked_up':
      case 'arrived_at_pickup_center':
        return const Color(0xFF0284C7); // Sky Blue
      case 'delivered':
        return const Color(0xFF10B981); // Emerald Green
      case 'canceled':
      case 'failed':
      case 'refund_requested':
      case 'refunded':
        return const Color(0xFFEF4444); // Rose Red
      default:
        return Theme.of(context).primaryColor;
    }
  }

  String _getStatusText(OrderModel order) {
    if (order.orderType == 'take_away' && (order.orderStatus == 'handover' || order.orderStatus == 'picked_up')) {
      return 'ready_for_handover'.tr;
    }
    if (order.orderType != 'pickup_center' && order.orderStatus == 'arrived_at_pickup_center') {
      return 'delivery_on_the_way'.tr;
    }
    if (order.orderStatus == 'picked_up') {
      return '${'item'.tr} ${'on_the_way'.tr}';
    }
    return (order.orderStatus ?? '').tr;
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<OrderController>(builder: (orderController) {
        PaginatedOrderModel? paginatedOrderModel = isRunning
            ? orderController.runningOrderModel
            : orderController.historyOrderModel;

        if (paginatedOrderModel == null) {
          return OrderShimmerWidget(orderController: orderController);
        }

        if (paginatedOrderModel.orders == null || paginatedOrderModel.orders!.isEmpty) {
          return NoDataScreen(text: 'no_order_found'.tr, showFooter: true);
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (isRunning) {
              await orderController.getRunningOrders(1, isUpdate: true);
            } else {
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
                  padding: EdgeInsets.only(bottom: isDesktop ? 0 : 90),
                  child: PaginatedListView(
                    scrollController: scrollController,
                    onPaginate: (int? offset) async {
                      if (isRunning) {
                        await orderController.getRunningOrders(offset!, isUpdate: true);
                      } else {
                        await orderController.getHistoryOrders(offset!, isUpdate: true);
                      }
                    },
                    totalSize: isRunning ? orderController.runningOrderModel?.totalSize : orderController.historyOrderModel?.totalSize,
                    offset: isRunning ? orderController.runningOrderModel?.offset : orderController.historyOrderModel?.offset,
                    itemView: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeDefault,
                        mainAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : 0,
                        mainAxisExtent: isDesktop
                            ? (isRunning ? 275 : 225)
                            : (isRunning ? 260 : 215),
                        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                        vertical: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
                        horizontal: isDesktop ? 0 : Dimensions.paddingSizeSmall,
                      ),
                      itemCount: paginatedOrderModel.orders!.length,
                      itemBuilder: (context, index) {
                        OrderModel order = paginatedOrderModel.orders![index];
                        return _buildOrderCard(context, order, orderController);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, OrderController orderController) {
    final bool isParcel = order.orderType == 'parcel';
    final Color statusColor = _getStatusColor(order.orderStatus, context);
    final String statusText = _getStatusText(order);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomInkWell(
        onTap: () {
          Get.toNamed(
            RouteHelper.getOrderDetailsRoute(order.id),
            arguments: OrderDetailsScreen(
              orderId: order.id,
              orderModel: order,
            ),
          );
        },
        radius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusText,
                          style: robotoBold.copyWith(
                            color: statusColor,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isParcel
                          ? 'parcel'.tr
                          : (order.orderType == 'take_away' ? 'take_away'.tr : 'delivery'.tr),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall - 1,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (order.createdAt != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateConverter.dateTimeStringToDateTime(order.createdAt!),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: CustomImage(
                            image: isParcel
                                ? (order.parcelCategory?.imageFullUrl ?? '')
                                : (order.store?.logoFullUrl ?? ''),
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '#${order.id}',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall + 1,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '•',
                                  style: TextStyle(color: Theme.of(context).hintColor),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isParcel
                                      ? 'parcel'.tr
                                      : '${order.detailsCount ?? 1} ${order.detailsCount != null && order.detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              order.store?.name ?? (isParcel ? order.parcelCategory?.name ?? '' : ''),
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            PriceConverter.convertPrice(order.orderAmount),
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault + 1,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildPaymentTag(context, order.paymentStatus),
                        ],
                      ),
                    ],
                  ),

                  // Order Progress Flow
                  if (isRunning) ...[
                    const SizedBox(height: 14),
                    _buildTracker(context, order),
                  ],

                  const SizedBox(height: 14),

                  // Actions
                  _buildCardActions(context, order, orderController, isParcel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTag(BuildContext context, String? paymentStatus) {
    Color color;
    String label;
    if (paymentStatus == 'paid') {
      color = const Color(0xFF10B981);
      label = 'paid'.tr;
    } else if (paymentStatus == 'partially_paid') {
      color = const Color(0xFFF59E0B);
      label = 'partially_paid'.tr;
    } else {
      color = const Color(0xFFEF4444);
      label = 'unpaid'.tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall - 1,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTracker(BuildContext context, OrderModel order) {
    int currentStep = 0;
    if (order.orderStatus == 'pending') {
      currentStep = 1;
    } else if (order.orderStatus == 'accepted' || order.orderStatus == 'confirmed') {
      currentStep = 2;
    } else if (order.orderStatus == 'processing') {
      currentStep = 3;
    } else if (order.orderStatus == 'handover' ||
        order.orderStatus == 'picked_up' ||
        order.orderStatus == 'arrived_at_pickup_center') {
      currentStep = 4;
    } else if (order.orderStatus == 'delivered') {
      currentStep = 5;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTrackerNode(context, 1, currentStep, Icons.receipt_rounded),
          _buildTrackerLine(context, 2, currentStep),
          _buildTrackerNode(context, 2, currentStep, Icons.thumb_up_rounded),
          _buildTrackerLine(context, 3, currentStep),
          _buildTrackerNode(context, 3, currentStep, Icons.inventory_2_rounded),
          _buildTrackerLine(context, 4, currentStep),
          _buildTrackerNode(context, 4, currentStep, Icons.moped_rounded),
          _buildTrackerLine(context, 5, currentStep),
          _buildTrackerNode(context, 5, currentStep, Icons.check_circle_rounded),
        ],
      ),
    );
  }

  Widget _buildTrackerNode(BuildContext context, int step, int currentStep, IconData iconData) {
    final bool isCompleted = step < currentStep;
    final bool isCurrent = step == currentStep;
    final bool isPastOrCurrent = step <= currentStep;

    Color nodeColor = Theme.of(context).disabledColor.withValues(alpha: 0.25);
    Color iconColor = Theme.of(context).disabledColor.withValues(alpha: 0.6);

    if (isCurrent) {
      nodeColor = Theme.of(context).primaryColor;
      iconColor = Colors.white;
    } else if (isCompleted) {
      nodeColor = const Color(0xFF10B981);
      iconColor = Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPastOrCurrent ? nodeColor : Theme.of(context).cardColor,
        border: Border.all(
          color: nodeColor,
          width: 1.4,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: nodeColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Icon(
        isCompleted ? Icons.check_rounded : iconData,
        color: iconColor,
        size: isCompleted ? 13 : 11,
      ),
    );
  }

  Widget _buildTrackerLine(BuildContext context, int step, int currentStep) {
    final bool isPassed = step <= currentStep;
    return Expanded(
      child: Container(
        height: 2.5,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isPassed ? const Color(0xFF10B981) : Theme.of(context).disabledColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildCardActions(BuildContext context, OrderModel order, OrderController orderController, bool isParcel) {
    if (isRunning) {
     return Row(
      children: [
        // View Details Button
        Expanded(
          child: SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () => Get.toNamed(
                RouteHelper.getOrderDetailsRoute(order.id),
                arguments: OrderDetailsScreen(orderId: order.id, orderModel: order),
              ),
              icon: Icon(
                Icons.receipt_long_rounded,
                size: 15,
                color: Theme.of(context).primaryColor,
              ),
              label: Text(
                'details'.tr,
                style: robotoMedium.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeSmall - 0.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Track Order Button
        Expanded(
          child: SizedBox(
            height: 36,
            child: FilledButton.icon(
              onPressed: () => Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, null)),
              icon: Image.asset(Images.tracking, height: 15, width: 15, color: Colors.white),
              label: Text(
                isParcel ? 'track_delivery'.tr : 'track_order'.tr,
                style: robotoBold.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeSmall - 0.5,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }

    bool isReviewed = order.reviews != null && order.reviews!.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () => _handleReviewOrDetails(order, orderController, isParcel),
              icon: Icon(
                isReviewed ? Icons.receipt_long_rounded : Icons.star_rounded,
                size: 15,
                color: Theme.of(context).primaryColor,
              ),
              label: Text(
                isReviewed ? 'view_details'.tr : 'rate_order'.tr,
                style: robotoMedium.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeSmall - 0.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.4), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 36,
            child: FilledButton.icon(
              onPressed: () => orderController.reorder(order.id!, order: order),
              icon: const Icon(Icons.refresh_rounded, size: 15, color: Colors.white),
              label: Text(
                'reorder'.tr,
                style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall - 0.5),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleReviewOrDetails(OrderModel order, OrderController orderController, bool isParcel) async {
    bool isReviewed = order.reviews != null && order.reviews!.isNotEmpty;
    if (isReviewed) {
      Get.toNamed(
        RouteHelper.getOrderDetailsRoute(order.id),
        arguments: OrderDetailsScreen(orderId: order.id, orderModel: order),
      );
    } else {
      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
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

        Get.toNamed(
          RouteHelper.getRateReviewRoute(),
          arguments: RateReviewScreen(
            orderDetailsList: orderDetailsList,
            deliveryMan: order.deliveryMan,
            orderID: order.id,
            reviews: order.reviews,
          ),
        );
      } else {
        showCustomSnackBar('failed_to_load_order_details'.tr);
      }
    }
  }
}