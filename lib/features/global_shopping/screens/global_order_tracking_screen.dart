import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_order_controller.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_order_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class GlobalOrderTrackingScreen extends StatefulWidget {
  final GlobalOrderModel order;

  const GlobalOrderTrackingScreen({super.key, required this.order});

  @override
  State<GlobalOrderTrackingScreen> createState() => _GlobalOrderTrackingScreenState();
}

class _GlobalOrderTrackingScreenState extends State<GlobalOrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.order.id != null) {
        Get.find<GlobalOrderController>().trackOrder(widget.order.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalOrderController>(builder: (ctrl) {
      final tracking = ctrl.trackingData;
      final status = widget.order.status ?? 'pending';

      final steps = [
        _TrackingStep(label: 'Order Placed', icon: Icons.receipt_outlined, status: _stepStatus('pending', status)),
        _TrackingStep(label: 'Processing', icon: Icons.settings_outlined, status: _stepStatus('processing', status)),
        _TrackingStep(label: 'Shipped', icon: Icons.local_shipping_outlined, status: _stepStatus('shipped', status)),
        _TrackingStep(label: 'Delivered', icon: Icons.check_circle_outline, status: _stepStatus('delivered', status)),
      ];

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Track Order', style: robotoMedium.copyWith(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                if (widget.order.id != null) {
                   ctrl.trackOrder(widget.order.id!);
                }
              },
            ),
          ],
        ),
        body: ctrl.isLoading
            ? const CustomLoaderWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info Card
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long_outlined, color: Theme.of(context).primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text('Order #${widget.order.orderNumber ?? 'N/A'}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                ),
                                child: Text(status.replaceAll('_', ' ').capitalizeFirst ?? status, style: robotoMedium.copyWith(color: Colors.white, fontSize: 11)),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              _InfoItem(label: 'Total', value: '\$${(widget.order.total ?? 0).toStringAsFixed(2)}'),
                              _InfoItem(label: 'Items', value: '${widget.order.items?.length ?? 0}'),
                              _InfoItem(label: 'Provider', value: (widget.order.fulfillmentProvider ?? 'N/A').toUpperCase()),
                            ],
                          ),
                          if (widget.order.externalOrderId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('External ID: ${widget.order.externalOrderId}', style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).disabledColor)),
                            ),
                          if (widget.order.externalTracking != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_shipping_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Tracking: ${widget.order.externalTracking}', style: robotoMedium.copyWith(fontSize: 11, color: Theme.of(context).primaryColor)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tracking Timeline
                    Text('Tracking Status', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: 16),

                    if (status != 'cancelled')
                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          children: List.generate(steps.length, (i) {
                            return _TrackingStepWidget(
                              step: steps[i],
                              isLast: i == steps.length - 1,
                            );
                          }),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: Colors.red.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cancel_outlined, color: Colors.red, size: 32),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order Cancelled', style: robotoMedium.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeDefault)),
                                Text('This order has been cancelled.', style: robotoRegular.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeSmall)),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // External tracking info from API
                    if (tracking != null && tracking.isNotEmpty) ...[
                      Text('Provider Updates', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: tracking.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${entry.key}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                  Expanded(child: Text('${entry.value}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    // Order Items
                    if (widget.order.items != null && widget.order.items!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('Order Items', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: 12),
                      ...widget.order.items!.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1))],
                          ),
                          child: Row(
                            children: [
                              if (item.image != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Image.network(
                                    item.image!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 60, height: 60,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image_outlined, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              if (item.image != null) const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title ?? 'Item', maxLines: 2, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                    if (item.variant != null && item.variant!.isNotEmpty)
                                      Text(item.variant!, style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).disabledColor)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Qty: ${item.quantity ?? 1}', style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).disabledColor)),
                                        Text('\$${((item.unitPrice ?? 0) * (item.quantity ?? 1)).toStringAsFixed(2)}', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      );
    });
  }

  String _stepStatus(String step, String currentStatus) {
    const order = ['pending', 'processing', 'shipped', 'delivered'];
    final stepIdx = order.indexOf(step);
    final currentIdx = order.indexOf(currentStatus);
    if (currentIdx < 0) return 'pending';
    if (stepIdx < currentIdx) return 'done';
    if (stepIdx == currentIdx) return 'active';
    return 'pending';
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
}

class _TrackingStep {
  final String label;
  final IconData icon;
  final String status; // 'done', 'active', 'pending'
  const _TrackingStep({required this.label, required this.icon, required this.status});
}

class _TrackingStepWidget extends StatelessWidget {
  final _TrackingStep step;
  final bool isLast;
  const _TrackingStepWidget({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (step.status == 'done') {
      color = Colors.green;
    } else if (step.status == 'active') {
      color = Theme.of(context).primaryColor;
    } else {
      color = Theme.of(context).disabledColor;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: step.status == 'pending' ? Colors.transparent : color,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                step.status == 'done' ? Icons.check : step.icon,
                color: step.status == 'pending' ? color : Colors.white,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: step.status == 'done' ? Colors.green : Theme.of(context).disabledColor.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            step.label,
            style: (step.status == 'pending' ? robotoRegular : robotoMedium).copyWith(color: color, fontSize: Dimensions.fontSizeSmall),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).disabledColor)),
          Text(value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ],
      ),
    );
  }
}
