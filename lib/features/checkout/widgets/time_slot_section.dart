import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/checkout/widgets/time_slot_bottom_sheet.dart';

class TimeSlotSection extends StatefulWidget {
  final int? storeId;
  final CheckoutController checkoutController;
  final List<CartModel?>? cartList;
  final JustTheController tooltipController2;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  const TimeSlotSection({super.key, this.storeId, required this.checkoutController, this.cartList, required this.tooltipController2,
    required this.tomorrowClosed, required this.todayClosed, this.module,
  });

  @override
  State<TimeSlotSection> createState() => _TimeSlotSectionState();
}

class _TimeSlotSectionState extends State<TimeSlotSection> {
  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    bool showSection = !isGuestLoggedIn &&
        (widget.checkoutController.store?.scheduleOrder ?? false) &&
        widget.cartList != null &&
        widget.cartList!.isNotEmpty &&
        widget.cartList![0]!.item!.availableDateStarts == null;

    if (!showSection) return const SizedBox();

    String selectedTimeText = widget.checkoutController.preferableTime.isNotEmpty
        ? '${widget.checkoutController.selectedDateSlot == 0 ? 'today'.tr : widget.checkoutController.selectedDateSlot == 1 ? 'tomorrow'.tr : 'day_after_tomorrow'.tr} - ${widget.checkoutController.preferableTime}'
        : 'instance'.tr;

    return Column(children: [
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: 0),
            childrenPadding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeLarge, 0, Dimensions.paddingSizeLarge, Dimensions.paddingSizeLarge,
            ),
            title: Row(children: [
              Icon(Icons.access_time_filled_outlined, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('preference_time'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: widget.tooltipController2,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('schedule_time_tool_tip'.tr, style: robotoRegular.copyWith(color: Colors.white)),
                ),
                child: InkWell(
                  onTap: () => widget.tooltipController2.showTooltip(),
                  child: const Icon(Icons.info_outline, size: 16),
                ),
              ),
            ]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(selectedTimeText, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 22),
              ],
            ),
            children: [
              InkWell(
                onTap: (){
                  if(ResponsiveHelper.isDesktop(context)){
                    showDialog(context: context, builder: (con) => Dialog(
                      child: TimeSlotBottomSheet(
                        tomorrowClosed: widget.tomorrowClosed,
                        todayClosed: widget.todayClosed, module: widget.module,
                      ),
                    ));
                  }else{
                    showModalBottomSheet(
                      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      builder: (con) => TimeSlotBottomSheet(
                        tomorrowClosed: widget.tomorrowClosed,
                        todayClosed: widget.todayClosed, module: widget.module,
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                  ),
                  height: 48,
                  child: Row(children: [
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    Expanded(
                      child: ((widget.checkoutController.selectedDateSlot == 0 && widget.todayClosed) || (widget.checkoutController.selectedDateSlot == 1 && widget.tomorrowClosed))
                        ? Center(child: Text(widget.module!.showRestaurantText! ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr))
                        : Text(selectedTimeText, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    ),

                    const Icon(Icons.arrow_drop_down, size: 24),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),
    ]);
  }
}
