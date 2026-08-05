import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_order_controller.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_order_model.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_order_tracking_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class GlobalOrderListScreen extends StatefulWidget {
  const GlobalOrderListScreen({super.key});

  @override
  State<GlobalOrderListScreen> createState() => _GlobalOrderListScreenState();
}

class _GlobalOrderListScreenState extends State<GlobalOrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AuthHelper.isLoggedIn()) {
        Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
        showCustomSnackBar('you_are_not_logged_in'.tr);
      } else {
        Get.find<GlobalOrderController>().getOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalOrderController>(builder: (ctrl) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('My Global Orders', style: robotoMedium.copyWith(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => ctrl.getOrders(),
            ),
          ],
        ),
        body: ctrl.isLoading
            ? const CustomLoaderWidget()
            : ctrl.orders.isEmpty
                ? NoDataScreen(text: 'no_order_found'.tr)
                : RefreshIndicator(
                    onRefresh: () => ctrl.getOrders(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      itemCount: ctrl.orders.length,
                      itemBuilder: (context, index) {
                        return _GlobalOrderCard(
                          order: ctrl.orders[index],
                          onTrack: () => Get.to(() => GlobalOrderTrackingScreen(order: ctrl.orders[index])),
                          onCancel: () {
                            final orderId = ctrl.orders[index].id;
                            if (orderId != null) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Cancel Order'),
                                  content: Text('Cancel order #${ctrl.orders[index].orderNumber}?'),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(), child: const Text('No')),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        ctrl.cancelOrder(orderId);
                                      },
                                      child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
      );
    });
  }
}

class _GlobalOrderCard extends StatelessWidget {
  final GlobalOrderModel order;
  final VoidCallback onTrack;
  final VoidCallback onCancel;

  const _GlobalOrderCard({required this.order, required this.onTrack, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final status = order.status ?? 'pending';
    final statusColor = _statusColor(status);
    final canCancel = status == 'pending' || status == 'processing';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
            ),
            child: Row(
              children: [
                Text('#${order.orderNumber ?? 'N/A'}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    status.replaceAll('_', ' ').capitalizeFirst ?? status,
                    style: robotoMedium.copyWith(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // Items preview
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.items != null && order.items!.isNotEmpty) ...[
                  ...order.items!.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 8, top: 2),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                        ),
                        Expanded(child: Text(item.title ?? 'Item', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))),
                        Text('x${item.quantity ?? 1}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      ],
                    ),
                  )),
                  if (order.items!.length > 2)
                    Text('+${order.items!.length - 2} more items', style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).disabledColor)),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                        Text('\$${(order.total ?? 0).toStringAsFixed(2)}', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                      ],
                    ),
                    const Spacer(),
                    if (order.fulfillmentProvider != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _providerColor(order.fulfillmentProvider).withOpacity(0.1),
                          border: Border.all(color: _providerColor(order.fulfillmentProvider).withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Text(
                          order.fulfillmentProvider!.toUpperCase(),
                          style: TextStyle(color: _providerColor(order.fulfillmentProvider), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                if (order.createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Placed on ${_formatDate(order.createdAt!)}',
                      style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).disabledColor),
                    ),
                  ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.track_changes, size: 16),
                    label: const Text('Track'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                    ),
                  ),
                ),
                if (canCancel) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return const Color(0xFF7B1FA2);
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _providerColor(String? provider) {
    switch (provider) {
      case 'zinc': return const Color(0xFF1565C0);
      case 'cj': return const Color(0xFFE91E63);
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
