import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';

class TimeSlotBottomSheet extends StatefulWidget {
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  const TimeSlotBottomSheet({super.key, required this.tomorrowClosed, required this.todayClosed, required this.module});

  @override
  State<TimeSlotBottomSheet> createState() => _TimeSlotBottomSheetState();
}

class _TimeSlotBottomSheetState extends State<TimeSlotBottomSheet> {
  int _step = 1;
  int selectedTimeSlotIndex = 0;
  String selectedTimeSlot = '';

  @override
  void initState() {
    super.initState();
    selectedTimeSlotIndex = Get.find<CheckoutController>().selectedTimeSlot;
    selectedTimeSlot = Get.find<CheckoutController>().preferableTime;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(
                  height: 4, width: 35,
                  decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Column(children: [
                    Text('تحديد موعد الطلب', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      'اختر الوقت المناسب لتنفيذ طلبك حسب أوقات عمل المتجر',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Stepper
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _stepItem(step: 1, title: 'اختيار اليوم', isActive: _step >= 1, isCompleted: _step > 1),
                      _stepDivider(isCompleted: _step > 1),
                      _stepItem(step: 2, title: 'اختيار الوقت', isActive: _step >= 2, isCompleted: _step > 2),
                      _stepDivider(isCompleted: _step > 2),
                      _stepItem(step: 3, title: 'التأكيد', isActive: _step >= 3, isCompleted: _step > 3),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    if (_step == 1) _daySelection(checkoutController),
                    if (_step == 2) _timeSelection(checkoutController, storeController),
                    if (_step == 3) _reviewSection(checkoutController),
                    
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Row(children: [
                      if (_step > 1) Expanded(child: CustomButton(
                        buttonText: 'السابق',
                        transparent: true,
                        isBorder: true,
                        radius: Dimensions.radiusDefault,
                        onPressed: () => setState(() => _step--),
                      )),
                      if (_step > 1) const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: CustomButton(
                        buttonText: _step == 3 ? 'اعتماد الموعد' : 'التالي',
                        radius: Dimensions.radiusDefault,
                        onPressed: () {
                          if (_step < 3) {
                            if (_step == 2 && (checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty)) {
                              return;
                            }
                            setState(() => _step++);
                          } else {
                            checkoutController.updateTimeSlot(selectedTimeSlotIndex);
                            checkoutController.setPreferenceTimeForView(selectedTimeSlot);

                            DateTime scheduleEndDate = DateTime.now();
                            DateTime date = checkoutController.selectedDateSlot == 0 ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
                            if (checkoutController.selectedDateSlot == 2) {
                              date = DateTime.now().add(const Duration(days: 2));
                            }
                            
                            if (checkoutController.timeSlots != null && checkoutController.timeSlots!.isNotEmpty) {
                              DateTime endTime = checkoutController.timeSlots![selectedTimeSlotIndex].endTime!;
                              scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);

                              checkoutController.getSurgePrice(
                                zoneId: checkoutController.store!.zoneId.toString(),
                                moduleId: checkoutController.store!.moduleId.toString(),
                                dateTime: DateConverter.dateToDateAndTime(scheduleEndDate),
                                guestId: AuthHelper.getGuestId(),
                              );
                            }
                            Get.back();
                          }
                        },
                      )),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ]),
                ),
              ],
            ),
          ),
        );
      });
    });
  }

  Widget _stepItem({required int step, required String title, required bool isActive, required bool isCompleted}) {
    return Column(children: [
      Container(
        height: 25, width: 25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isCompleted ? Theme.of(context).primaryColor : isActive ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
        ),
        child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : Text(
          step.toString(),
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: isActive ? Colors.white : Theme.of(context).disabledColor),
        ),
      ),
      const SizedBox(height: 4),
      Text(title, style: robotoRegular.copyWith(fontSize: 8, color: isActive ? Theme.of(context).primaryColor : Theme.of(context).disabledColor)),
    ]);
  }

  Widget _stepDivider({required bool isCompleted}) {
    return Container(
      width: 40, height: 1,
      margin: const EdgeInsets.only(bottom: 15),
      color: isCompleted ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
    );
  }

  Widget _daySelection(CheckoutController checkoutController) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('اختر يوم التنفيذ', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      Text('يمكنك اختيار اليوم الحالي أو خلال الثلاثة الأيام القادمة', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      Row(children: [
        _dayItem(title: 'اليوم', date: DateTime.now(), isSelected: checkoutController.selectedDateSlot == 0, onTap: () {
          checkoutController.updateDateSlot(0, Get.find<StoreController>().store!.orderPlaceToScheduleInterval);
        }),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        _dayItem(title: 'غداً', date: DateTime.now().add(const Duration(days: 1)), isSelected: checkoutController.selectedDateSlot == 1, onTap: () {
          checkoutController.updateDateSlot(1, Get.find<StoreController>().store!.orderPlaceToScheduleInterval);
        }),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        _dayItem(title: 'بعد غد', date: DateTime.now().add(const Duration(days: 2)), isSelected: checkoutController.selectedDateSlot == 2, onTap: () {
          checkoutController.updateDateSlot(2, Get.find<StoreController>().store!.orderPlaceToScheduleInterval);
        }),
      ]),
    ]);
  }

  Widget _dayItem({required String title, required DateTime date, required bool isSelected, required Function() onTap}) {
    return Expanded(child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: isSelected ? Theme.of(context).primaryColor : null)),
          Text('${date.day} - ${DateFormat('MMMM', Get.locale?.languageCode).format(date)}', style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
          Text(DateFormat('EEEE', Get.locale?.languageCode).format(date), style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
        ]),
      ),
    ));
  }

  Widget _timeSelection(CheckoutController checkoutController, StoreController storeController) {
    bool isClosed = (checkoutController.selectedDateSlot == 0 && widget.todayClosed) || (checkoutController.selectedDateSlot == 1 && widget.tomorrowClosed);
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('اختر وقت التنفيذ', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      Text('المواعيد المتاحة حسب ساعات عمل المتجر وسعة التوصيل', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      if (isClosed) Center(child: Text(widget.module!.showRestaurantText! ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr))
      else if (checkoutController.timeSlots == null) const CustomLoaderWidget()
      else if (checkoutController.timeSlots!.isEmpty) Center(child: Text('no_slot_available'.tr))
      else SizedBox(
        height: 250,
        child: ListWheelScrollView.useDelegate(
          itemExtent: 50,
          perspective: 0.005,
          diameterRatio: 1.5,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            String time = (index == 0 && checkoutController.selectedDateSlot == 0
                && storeController.isStoreOpenNow(storeController.store!.active!, storeController.store!.schedules)
                && (Get.find<SplashController>().configModel!.moduleConfig!.module!.orderPlaceToScheduleInterval! ? storeController.store!.orderPlaceToScheduleInterval == 0 : true))
                ? 'instance'.tr : '${DateConverter.dateToTimeOnly(checkoutController.timeSlots![index].startTime!)} '
                '- ${DateConverter.dateToTimeOnly(checkoutController.timeSlots![index].endTime!)}';
            setState(() {
              selectedTimeSlotIndex = index;
              selectedTimeSlot = time;
            });
          },
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= checkoutController.timeSlots!.length) return null;
              bool isSelected = selectedTimeSlotIndex == index;
              String time = (index == 0 && checkoutController.selectedDateSlot == 0
                  && storeController.isStoreOpenNow(storeController.store!.active!, storeController.store!.schedules)
                  && (Get.find<SplashController>().configModel!.moduleConfig!.module!.orderPlaceToScheduleInterval! ? storeController.store!.orderPlaceToScheduleInterval == 0 : true))
                  ? 'instance'.tr : '${DateConverter.dateToTimeOnly(checkoutController.timeSlots![index].startTime!)} '
                  '- ${DateConverter.dateToTimeOnly(checkoutController.timeSlots![index].endTime!)}';
              
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: isSelected ? Border(
                    top: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 1),
                    bottom: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 1),
                  ) : null,
                ),
                child: Text(
                  time,
                  style: robotoMedium.copyWith(
                    fontSize: isSelected ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault,
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                  ),
                ),
              );
            },
            childCount: checkoutController.timeSlots!.length,
          ),
        ),
      ),
    ]);
  }

  Widget _reviewSection(CheckoutController checkoutController) {
    String day = 'اليوم';
    if (checkoutController.selectedDateSlot == 1) day = 'غداً';
    if (checkoutController.selectedDateSlot == 2) day = 'بعد غد';
    
    DateTime date = DateTime.now().add(Duration(days: checkoutController.selectedDateSlot));
    String dateStr = '$day - ${date.day} ${DateFormat('MMMM', Get.locale?.languageCode).format(date)}';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('مراجعة الموعد', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      
      _reviewItem(label: 'اليوم المختار', value: dateStr),
      const Divider(),
      _reviewItem(label: 'الوقت المختار', value: selectedTimeSlot),
      
      const SizedBox(height: Dimensions.paddingSizeLarge),
      Text(
        'الموعد تقريبي وقد يتأثر بالازدحام أو ضغط الطلبات.',
        style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
        textAlign: TextAlign.center,
      ),
    ]);
  }

  Widget _reviewItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
        Text(value, style: robotoMedium),
      ]),
    );
  }
}
