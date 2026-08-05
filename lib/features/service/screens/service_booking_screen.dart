import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class ServiceBookingScreen extends StatefulWidget {
  final int serviceId;
  const ServiceBookingScreen({super.key, required this.serviceId});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 10, minute: 0);
  int _selectedAddressIndex = 0;

  @override
  void initState() {
    super.initState();
    if (Get.find<AddressController>().addressList == null) {
      Get.find<AddressController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'booking_info'.tr),
      body: GetBuilder<ServiceController>(builder: (serviceController) {
        Service? service = serviceController.serviceDetails;
        if (service == null) return const CustomLoaderWidget();

        return GetBuilder<AddressController>(builder: (addressController) {
          return Column(children: [
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(service.serviceMode == 'rental' ? 'check_in_date_and_time'.tr : 'select_date_and_time'.tr, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(children: [
                  Expanded(child: InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          if (_selectedEndDate.isBefore(_selectedDate)) {
                            _selectedEndDate = _selectedDate.add(const Duration(days: 1));
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(DateConverter.dateTimeStringToDateOnly(_selectedDate.toString())),
                      ]),
                    ),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: InkWell(
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Row(children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(_selectedTime.format(context)),
                      ]),
                    ),
                  )),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                if (service.serviceMode == 'rental') ...[
                  Text('check_out_date_and_time'.tr, style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Row(children: [
                    Expanded(child: InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                        initialDate: _selectedEndDate.isBefore(_selectedDate) ? _selectedDate : _selectedEndDate,
                        firstDate: _selectedDate,
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (picked != null) setState(() => _selectedEndDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Row(children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.orange),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(DateConverter.dateTimeStringToDateOnly(_selectedEndDate.toString())),
                        ]),
                      ),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: InkWell(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedEndTime,
                        );
                        if (picked != null) setState(() => _selectedEndTime = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Row(children: [
                          const Icon(Icons.access_time, size: 20, color: Colors.orange),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(_selectedEndTime.format(context)),
                        ]),
                      ),
                    )),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],

                if (service.serviceMode == 'at_home' || service.serviceMode == 'on_demand') ...[
                  Text('delivery_address'.tr, style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  addressController.addressList != null ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addressController.addressList!.length,
                    itemBuilder: (context, index) {
                      AddressModel addr = addressController.addressList![index];
                      bool isSelected = _selectedAddressIndex == index;
                      return InkWell(
                        onTap: () => setState(() => _selectedAddressIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : null,
                          ),
                          child: Row(children: [
                            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(addr.addressType!.tr, style: robotoMedium),
                              Text(addr.address!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ])),
                          ]),
                        ),
                      );
                    },
                  ) : const CustomLoaderWidget(),
                ] else if (service.serviceMode == 'at_provider') ...[
                  Text('provider_location'.tr, style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Row(children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: Text(service.provider?.companyAddress ?? 'N/A')),
                    ]),
                  ),
                ],

                const SizedBox(height: Dimensions.paddingSizeLarge),
                Text('customer_note'.tr, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                  ),
                  child: TextField(
                    controller: serviceController.customerNoteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'add_a_note_for_the_provider'.tr,
                      hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    ),
                  ),
                ),

              ]),
            )),

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -1))],
              ),
              child: Column(children: [
                _PriceBreakdown(service: service, startDate: _selectedDate, startTime: _selectedTime, endDate: _selectedEndDate, endTime: _selectedEndTime),

                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('total_amount'.tr, style: robotoMedium),
                  Text(PriceConverter.convertPrice(_calculateTotal(service)), style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                CustomButton(
                  buttonText: 'confirm_booking'.tr,
                  isLoading: serviceController.isLoading,
                  onPressed: () {
                    if ((service.serviceMode == 'at_home' || service.serviceMode == 'on_demand') && (addressController.addressList == null || addressController.addressList!.isEmpty)) {
                      showCustomSnackBar('please_add_address_first'.tr);
                      return;
                    }
                    
                    DateTime bookingTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
                    DateTime? endBookingTime;
                    if(service.serviceMode == 'rental') {
                      endBookingTime = DateTime(_selectedEndDate.year, _selectedEndDate.month, _selectedEndDate.day, _selectedEndTime.hour, _selectedEndTime.minute);
                      if(endBookingTime.isBefore(bookingTime)) {
                        showCustomSnackBar('check_out_time_cannot_be_before_check_in_time'.tr);
                        return;
                      }
                    }
                    
                    serviceController.placeBooking(
                      serviceId: service.id!,
                      providerId: service.providerId!,
                      bookingDate: bookingTime,
                      endDate: endBookingTime,
                      addressId: (service.serviceMode == 'at_home' || service.serviceMode == 'on_demand') 
                          ? addressController.addressList![_selectedAddressIndex].id 
                          : null,
                    ).then((status) {
                      if (status.isSuccess) {
                        Get.back();
                        showCustomSnackBar('booking_placed_successfully'.tr, isError: false);
                      } else {
                        showCustomSnackBar(status.message);
                      }
                    });
                  },
                ),
              ]),
            ),
          ]);
        });
      }),
    );
  }
  double _calculateTotal(Service service) {
    if (service.serviceMode == 'rental') {
      DateTime start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
      DateTime end = DateTime(_selectedEndDate.year, _selectedEndDate.month, _selectedEndDate.day, _selectedEndTime.hour, _selectedEndTime.minute);
      
      if (service.rentalUnit == 'hour') {
        int hours = end.difference(start).inHours;
        if (hours <= 0) hours = 1;
        return (service.price ?? 0) * hours;
      } else {
        int days = end.difference(start).inDays;
        if (days <= 0) days = 1;
        return (service.price ?? 0) * days;
      }
    }
    return service.price ?? 0;
  }
}

class _PriceBreakdown extends StatelessWidget {
  final Service service;
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime endDate;
  final TimeOfDay endTime;
  const _PriceBreakdown({required this.service, required this.startDate, required this.startTime, required this.endDate, required this.endTime});

  @override
  Widget build(BuildContext context) {
    if (service.serviceMode != 'rental') return const SizedBox();

    DateTime start = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
    DateTime end = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    
    int duration = service.rentalUnit == 'hour' ? end.difference(start).inHours : end.difference(start).inDays;
    if (duration <= 0) duration = 1;
    String unit = (service.rentalUnit ?? 'day').tr;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${'price'.tr} (${'per'.tr} $unit)', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
          Text(PriceConverter.convertPrice(service.price), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ]),
        const SizedBox(height: 2),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${'duration'.tr} ($unit)', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
          Text('$duration $unit', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ]),
        const Divider(height: 10),
      ]),
    );
  }
}
