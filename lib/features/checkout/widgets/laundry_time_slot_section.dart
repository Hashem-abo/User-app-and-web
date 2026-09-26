import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:suliman/common/models/config_model.dart';
import 'package:suliman/features/cart/domain/models/cart_model.dart';
import 'package:suliman/features/checkout/controllers/checkout_controller.dart';
import 'package:suliman/features/checkout/widgets/laundry_time_slot_bottom_sheet.dart';
import 'package:suliman/helper/auth_helper.dart';
import 'package:suliman/helper/responsive_helper.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';

class LaundryTimeSlotSection extends StatelessWidget {
  final int? storeId;
  final CheckoutController checkoutController;
  final List<CartModel?>? cartList;
  final JustTheController tooltipController2;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;

  const LaundryTimeSlotSection({
    super.key,
    this.storeId,
    required this.checkoutController,
    this.cartList,
    required this.tooltipController2,
    required this.tomorrowClosed,
    required this.todayClosed,
    this.module,
  });

  String _formatSlotText(int dateIndex, String timeStr) {
    String day;
    DateTime date = DateTime.now().add(Duration(days: dateIndex));
    if (dateIndex == 0) {
      day = 'today'.tr;
    } else if (dateIndex == 1) {
      day = 'tomorrow'.tr;
    } else if (dateIndex == 2) {
      day = 'day_after_tomorrow'.tr;
    } else {
      day = DateFormat('EEEE, d MMM', Get.locale?.languageCode).format(date);
    }

    if (timeStr.isNotEmpty) {
      return '$day - $timeStr';
    }
    return day;
  }

  @override
  Widget build(BuildContext context) {
    bool showSection = cartList != null && cartList!.isNotEmpty;

    if (!showSection) return const SizedBox();

    final int maxProcessingTime = checkoutController.getLaundryMaxProcessingTime(cartList);
    final int minDayOffset = (maxProcessingTime / 24).ceil();
    final bool isExpress = maxProcessingTime <= 12;

    String pickupText = _formatSlotText(
      checkoutController.selectedLaundryPickupDateSlot,
      checkoutController.preferableLaundryPickupTime,
    );

    int effectiveDeliveryDateSlot = checkoutController.selectedLaundryDeliveryDateSlot;
    if (effectiveDeliveryDateSlot < checkoutController.selectedLaundryPickupDateSlot + minDayOffset) {
      effectiveDeliveryDateSlot = checkoutController.selectedLaundryPickupDateSlot + minDayOffset;
    }

    String deliveryText = _formatSlotText(
      effectiveDeliveryDateSlot,
      checkoutController.preferableLaundryDeliveryTime,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Processing duration & turnaround summary badge
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: isExpress
                ? Colors.amber.withValues(alpha: 0.12)
                : Theme.of(context).primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(
              color: isExpress
                  ? Colors.amber.shade700.withValues(alpha: 0.4)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isExpress
                      ? Colors.amber.shade700.withValues(alpha: 0.2)
                      : Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpress ? Icons.bolt : Icons.local_laundry_service_outlined,
                  color: isExpress ? Colors.amber.shade900 : Theme.of(context).primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'مدة التجهيز المتوقعة: $maxProcessingTime ساعة',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: isExpress ? Colors.amber.shade900 : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isExpress ? Colors.amber.shade800 : Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isExpress ? 'مستعجل' : 'عادي',
                            style: robotoMedium.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'يتم احتساب موعد تسليم الملابس بناءً على مدة الغسيل والتجهيز',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Main Double Scheduling Card
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined, color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    'مواعيد الاستلام والتسليم',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const Spacer(),
                  JustTheTooltip(
                    backgroundColor: Colors.black87,
                    controller: tooltipController2,
                    preferredDirection: AxisDirection.right,
                    tailLength: 14,
                    tailBaseWidth: 20,
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'حدد موعد استلام الملابس المتسخة وموعد تسليمها بعد الغسيل',
                        style: robotoRegular.copyWith(color: Colors.white),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => tooltipController2.showTooltip(),
                      child: const Icon(Icons.info_outline, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // 1. Pickup Slot Row
              _buildSlotPickerItem(
                context: context,
                icon: Icons.outbox_rounded,
                iconColor: Colors.orange.shade700,
                title: 'موعد استلام الملابس من العميل',
                valueText: pickupText,
                onTap: () {
                  _openSlotBottomSheet(context, isPickup: true, minDayOffset: 0);
                },
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // 2. Delivery / Return Slot Row
              _buildSlotPickerItem(
                context: context,
                icon: Icons.all_inbox_rounded,
                iconColor: Colors.green.shade700,
                title: 'موعد تسليم الملابس بعد الغسيل',
                valueText: deliveryText,
                onTap: () {
                  _openSlotBottomSheet(
                    context,
                    isPickup: false,
                    minDayOffset: checkoutController.selectedLaundryPickupDateSlot + minDayOffset,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      ],
    );
  }

  Widget _buildSlotPickerItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valueText,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Icon(Icons.edit_calendar_outlined, size: 20, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  void _openSlotBottomSheet(BuildContext context, {required bool isPickup, required int minDayOffset}) {
    if (ResponsiveHelper.isDesktop(context)) {
      showDialog(
        context: context,
        builder: (con) => Dialog(
          child: LaundryTimeSlotBottomSheet(
            tomorrowClosed: tomorrowClosed,
            todayClosed: todayClosed,
            module: module,
            isPickup: isPickup,
            minDayOffset: minDayOffset,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (con) => LaundryTimeSlotBottomSheet(
          tomorrowClosed: tomorrowClosed,
          todayClosed: todayClosed,
          module: module,
          isPickup: isPickup,
          minDayOffset: minDayOffset,
        ),
      );
    }
  }
}
