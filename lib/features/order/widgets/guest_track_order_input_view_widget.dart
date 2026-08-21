import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/screens/taxi_order_details_screen.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';

import 'package:sixam_mart/helper/guest_order_helper.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/util/images.dart';

class GuestTrackOrderInputViewWidget extends StatefulWidget {
  final int? selectType;
  const GuestTrackOrderInputViewWidget({super.key, this.selectType = 0});

  @override
  State<GuestTrackOrderInputViewWidget> createState() => _GuestTrackOrderInputViewWidgetState();
}

class _GuestTrackOrderInputViewWidgetState extends State<GuestTrackOrderInputViewWidget> {
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FocusNode _orderFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  String? _countryDialCode;
  bool isOrder = true;
  List<GuestOrderModel> _guestOrders = [];
  bool _showManualSearch = false;

  @override
  void initState() {
    super.initState();

    isOrder = widget.selectType! == 0;
    _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty
        ? Get.find<AuthController>().getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

    _loadGuestOrders();
  }

  void _loadGuestOrders() async {
    List<GuestOrderModel> savedOrders = GuestOrderHelper.getGuestOrders();
    setState(() {
      _guestOrders = savedOrders;
    });

    for (int i = 0; i < savedOrders.length; i++) {
      final item = savedOrders[i];
      try {
        final response = await Get.find<OrderController>().trackOrder(
          item.id.toString(), null, true, contactNumber: item.contactNumber,
        );
        if (response != null && response.isSuccess && Get.find<OrderController>().trackModel != null) {
          String? liveStatus = Get.find<OrderController>().trackModel!.orderStatus;
          if (liveStatus != null && liveStatus != item.status) {
            await GuestOrderHelper.addGuestOrder(item.id, item.contactNumber, status: liveStatus);
          }
        } else if (response != null && !response.isSuccess) {
          await GuestOrderHelper.removeGuestOrder(item.id);
        }
      } catch (e) {
        // Ignore individual network errors
      }
    }

    if (mounted) {
      setState(() {
        _guestOrders = GuestOrderHelper.getGuestOrders();
      });
    }
  }

  @override
  void didUpdateWidget(covariant GuestTrackOrderInputViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    isOrder = widget.selectType! == 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_guestOrders.isNotEmpty && !_showManualSearch) {
      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          itemCount: _guestOrders.length,
          itemBuilder: (context, index) {
            final guestOrder = _guestOrders[index];
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
                    Get.toNamed(RouteHelper.getOrderDetailsRoute(guestOrder.id, contactNumber: guestOrder.contactNumber));
                  },
                  radius: Dimensions.radiusDefault,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(children: [
                    Row(children: [
                      Builder(builder: (context) {
                        bool isDone = guestOrder.status == 'delivered' || guestOrder.status == 'picked_up';
                        Color statusColor = isDone ? Colors.green : Theme.of(context).primaryColor;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          ),
                          child: Row(children: [
                            Icon(Icons.access_time_rounded, size: 15, color: statusColor),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Text((guestOrder.status ?? 'pending').tr, style: robotoBold.copyWith(color: statusColor, fontSize: Dimensions.fontSizeExtraSmall)),
                          ]),
                        );
                      }),
                      const Spacer(),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Row(children: [
                          Text('order_id'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text('#${guestOrder.id}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        ]),
                        if (guestOrder.contactNumber != null && guestOrder.contactNumber!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(guestOrder.contactNumber!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                        ],
                      ]),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Container(
                        height: 45, width: 45,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).primaryColor, size: 24),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    const Divider(),
                    Row(children: [
                      Text('view_details'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                      const Spacer(),
                    ]),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, 0, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall),
                  child: Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(RouteHelper.getOrderTrackingRoute(guestOrder.id, guestOrder.contactNumber));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Image.asset(Images.tracking, height: 15, width: 15, color: Colors.white),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text('track_order'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ]),
            );
          },
        ),
      );
    }

    return ResponsiveHelper.isDesktop(context) ? Expanded(
      child: Padding(
        padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.radiusExtraLarge, vertical: Dimensions.paddingSizeLarge),
        child: Center(
          child: SingleChildScrollView(
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(children: [

                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? 100 : 0),

                  CustomTextField(
                    labelText: 'order_id'.tr,
                    titleText: 'write_order_id'.tr,
                    controller: _orderIdController,
                    focusNode: _orderFocus,
                    nextFocus: _phoneFocus,
                    inputType: TextInputType.number,
                    showTitle: ResponsiveHelper.isDesktop(context),
                    required: true,
                    validator: (value) => ValidateCheck.validateEmptyText(value, null),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  CustomTextField(
                    titleText: 'enter_phone_number'.tr,
                    labelText: 'phone'.tr,
                    controller: _phoneNumberController,
                    focusNode: _phoneFocus,
                    inputType: TextInputType.phone,
                    inputAction: TextInputAction.done,
                    isPhone: true,
                    showTitle: ResponsiveHelper.isDesktop(context),
                    onCountryChanged: (CountryCode countryCode) {
                      _countryDialCode = countryCode.dialCode;
                    },
                    countryDialCode: _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
                    required: true,
                    validator: (value) => ValidateCheck.validateEmptyText(value, null),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  GetBuilder<OrderController>(
                    builder: (orderController) {
                      return CustomButton(
                        buttonText: 'track_order'.tr,
                        isLoading: orderController.isLoading,
                        width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                        onPressed: () async {
                          String phone = _phoneNumberController.text.trim();
                          String orderId = _orderIdController.text.trim();
                          String numberWithCountryCode = _countryDialCode! + phone;
                          PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
                          numberWithCountryCode = phoneValid.phone;

                          if(orderId.isEmpty) {
                            showCustomSnackBar('please_enter_order_id'.tr);
                          } else if (phone.isEmpty) {
                            showCustomSnackBar('enter_phone_number'.tr);
                          }else if (!phoneValid.isValid) {
                            showCustomSnackBar('invalid_phone_number'.tr);
                          } else {
                            orderController.trackOrder(orderId, null, false, contactNumber: numberWithCountryCode, fromGuestInput: true).then((response) {
                              if(response!.isSuccess) {
                                Get.toNamed(RouteHelper.getGuestTrackOrderScreen(orderId, numberWithCountryCode));
                              }
                            });
                          }
                        },
                      );
                    }
                  )

                ]),
              ),
            ),
          ),
        ),
      ),
    ) : SingleChildScrollView(
      child: Padding(
        padding:  const EdgeInsets.symmetric(horizontal: Dimensions.radiusExtraLarge, vertical: Dimensions.paddingSizeLarge),
        child: Column(children: [

          CustomTextField(
            labelText: isOrder ? 'order_id'.tr : 'trip_id'.tr,
            titleText: isOrder ? 'write_order_id'.tr : 'write_trip_id'.tr,
            controller: _orderIdController,
            focusNode: _orderFocus,
            nextFocus: _phoneFocus,
            inputType: TextInputType.number,
            showTitle: ResponsiveHelper.isDesktop(context),
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, null),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          CustomTextField(
            titleText: 'enter_phone_number'.tr,
            labelText: 'phone'.tr,
            controller: _phoneNumberController,
            focusNode: _phoneFocus,
            inputType: TextInputType.phone,
            inputAction: TextInputAction.done,
            isPhone: true,
            showTitle: ResponsiveHelper.isDesktop(context),
            onCountryChanged: (CountryCode countryCode) {
              _countryDialCode = countryCode.dialCode;
            },
            countryDialCode: _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, null),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          GetBuilder<OrderController>(builder: (orderController) {
            return GetBuilder<TaxiOrderController>(
              builder: (taxiOrderController) {
                return CustomButton(
                  buttonText: isOrder ? 'track_order'.tr : 'track_trip'.tr,
                  isLoading: orderController.isLoading || taxiOrderController.isLoading,
                  width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                  onPressed: () async {
                    String phone = _phoneNumberController.text.trim();
                    String orderId = _orderIdController.text.trim();
                    String numberWithCountryCode = _countryDialCode! + phone;
                    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
                    numberWithCountryCode = phoneValid.phone;

                    if(orderId.isEmpty) {
                      showCustomSnackBar(isOrder ? 'please_enter_order_id'.tr : 'please_enter_order_id'.tr);
                    } else if (phone.isEmpty) {
                      showCustomSnackBar('enter_phone_number'.tr);
                    }else if (!phoneValid.isValid) {
                      showCustomSnackBar('invalid_phone_number'.tr);
                    } else {
                      if(isOrder) {
                        orderController.trackOrder(orderId, null, false, contactNumber: numberWithCountryCode, fromGuestInput: true).then((response) {
                          if (response!.isSuccess) {
                            Get.toNamed(RouteHelper.getGuestTrackOrderScreen(orderId, numberWithCountryCode));
                          }
                        });
                      } else {
                        taxiOrderController.getTripDetails(int.parse(orderId), phone: numberWithCountryCode).then((success) {
                          if(success) {
                            Get.to(()=> TaxiOrderDetailsScreen(tripId: int.parse(orderId), phone: numberWithCountryCode));
                          }
                        });
                      }
                    }
                  },
                );
              }
            );
          }),

        ]),
      ),
    );
  }
}
