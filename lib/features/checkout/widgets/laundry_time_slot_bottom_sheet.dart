import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:suliman/common/models/config_model.dart';
import 'package:suliman/common/widgets/custom_button.dart';
import 'package:suliman/features/checkout/controllers/checkout_controller.dart';
import 'package:suliman/features/store/controllers/store_controller.dart';
import 'package:suliman/helper/date_converter.dart';
import 'package:suliman/helper/responsive_helper.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';

class LaundryTimeSlotBottomSheet extends StatefulWidget {
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final bool isPickup;
  final int minDayOffset;

  const LaundryTimeSlotBottomSheet({
    super.key,
    required this.tomorrowClosed,
    required this.todayClosed,
    required this.module,
    required this.isPickup,
    this.minDayOffset = 0,
  });

  @override
  State<LaundryTimeSlotBottomSheet> createState() => _LaundryTimeSlotBottomSheetState();
}

class _LaundryTimeSlotBottomSheetState extends State<LaundryTimeSlotBottomSheet> {
  int _selectedDateSlot = 0;
  int _selectedTimeSlotIndex = 0;
  String _selectedTimeSlot = '';

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CheckoutController>();
    if (widget.isPickup) {
      _selectedDateSlot = controller.selectedLaundryPickupDateSlot;
      _selectedTimeSlotIndex = controller.selectedLaundryPickupTimeSlot;
      _selectedTimeSlot = controller.preferableLaundryPickupTime;
    } else {
      _selectedDateSlot = controller.selectedLaundryDeliveryDateSlot < widget.minDayOffset
          ? widget.minDayOffset
          : controller.selectedLaundryDeliveryDateSlot;
      _selectedTimeSlotIndex = controller.selectedLaundryDeliveryTimeSlot;
      _selectedTimeSlot = controller.preferableLaundryDeliveryTime;
    }
  }

  String _getDateTitle(int dateIndex) {
    DateTime date = DateTime.now().add(Duration(days: dateIndex));
    if (dateIndex == 0) {
      return 'today'.tr;
    } else if (dateIndex == 1) {
      return 'tomorrow'.tr;
    } else if (dateIndex == 2) {
      return 'day_after_tomorrow'.tr;
    } else {
      return DateFormat('EEEE, d MMM', Get.locale?.languageCode).format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return GetBuilder<StoreController>(builder: (storeController) {
        return Container(
          width: ResponsiveHelper.isDesktop(context) ? 550 : context.width,
          constraints: BoxConstraints(maxHeight: context.height * 0.85, minHeight: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Container(
                    height: 4,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(
                    widget.isPickup
                        ? 'موعد استلام الملابس (من العميل)'
                        : 'موعد تسليم الملابس النظيفة',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    widget.isPickup
                        ? 'حدد الوقت المناسب لاستلام الملابس المتسخة من قبل المندوب'
                        : 'حدد الوقت المناسب لتسليم ملابسك بعد الانتهاء من الغسيل',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Day Selection
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'select_day'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        int actualDayIndex = widget.isPickup ? index : (widget.minDayOffset + index);
                        bool isSelected = _selectedDateSlot == actualDayIndex;
                        DateTime date = DateTime.now().add(Duration(days: actualDayIndex));

                        return Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDateSlot = actualDayIndex;
                                _selectedTimeSlotIndex = 0;
                                _selectedTimeSlot = '';
                              });
                              if (checkoutController.store != null) {
                                if (widget.isPickup) {
                                  checkoutController.updateLaundryPickupDateSlot(
                                    actualDayIndex,
                                    checkoutController.store!.orderPlaceToScheduleInterval,
                                  );
                                } else {
                                  checkoutController.updateLaundryDeliveryDateSlot(actualDayIndex);
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeExtraSmall,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getDateTitle(actualDayIndex),
                                    style: robotoMedium.copyWith(
                                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('d MMM', Get.locale?.languageCode).format(date),
                                    style: robotoRegular.copyWith(
                                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : Theme.of(context).disabledColor,
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Time Selection
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'select_time'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Flexible(
                    child: (checkoutController.timeSlots != null && checkoutController.timeSlots!.isNotEmpty)
                        ? GridView.builder(
                            shrinkWrap: true,
                            itemCount: checkoutController.timeSlots!.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                              childAspectRatio: 2.8,
                            ),
                            itemBuilder: (context, index) {
                              String time =
                                  '${DateConverter.dateToTimeOnly(checkoutController.timeSlots![index].startTime!)} - ${DateConverter.dateToTimeOnly(checkoutController.timeSlots![index].endTime!)}';
                              bool isSelected = _selectedTimeSlotIndex == index;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTimeSlotIndex = index;
                                    _selectedTimeSlot = time;
                                  });
                                },
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                        : Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).disabledColor,
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        time,
                                        style: robotoMedium.copyWith(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).textTheme.bodyLarge?.color,
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge),
                            child: Text(
                              'لا توجد فترات زمنية متاحة لهذا اليوم',
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  CustomButton(
                    buttonText: 'confirm'.tr,
                    radius: Dimensions.radiusDefault,
                    onPressed: () {
                      if (_selectedTimeSlot.isEmpty &&
                          checkoutController.timeSlots != null &&
                          checkoutController.timeSlots!.isNotEmpty) {
                        _selectedTimeSlot =
                            '${DateConverter.dateToTimeOnly(checkoutController.timeSlots![_selectedTimeSlotIndex].startTime!)} - ${DateConverter.dateToTimeOnly(checkoutController.timeSlots![_selectedTimeSlotIndex].endTime!)}';
                      }

                      if (widget.isPickup) {
                        checkoutController.updateLaundryPickupDateSlot(
                          _selectedDateSlot,
                          checkoutController.store?.orderPlaceToScheduleInterval,
                        );
                        checkoutController.updateLaundryPickupTimeSlot(_selectedTimeSlotIndex);
                        checkoutController.setPreferableLaundryPickupTime(_selectedTimeSlot);

                        // Ensure delivery date is at or after earliest return date
                        if (checkoutController.selectedLaundryDeliveryDateSlot < _selectedDateSlot + widget.minDayOffset) {
                          checkoutController.updateLaundryDeliveryDateSlot(_selectedDateSlot + widget.minDayOffset);
                        }
                      } else {
                        checkoutController.updateLaundryDeliveryDateSlot(_selectedDateSlot);
                        checkoutController.updateLaundryDeliveryTimeSlot(_selectedTimeSlotIndex);
                        checkoutController.setPreferableLaundryDeliveryTime(_selectedTimeSlot);
                      }
                      Get.back();
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          ),
        );
      });
    });
  }
}
