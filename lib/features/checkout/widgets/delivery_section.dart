import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:suliman/common/widgets/address_widget.dart';
import 'package:suliman/common/widgets/custom_text_field.dart';
import 'package:suliman/features/address/controllers/address_controller.dart';
import 'package:suliman/features/address/domain/models/address_model.dart';
import 'package:suliman/features/checkout/controllers/checkout_controller.dart';
import 'package:suliman/features/language/controllers/language_controller.dart';
import 'package:suliman/features/location/controllers/location_controller.dart';
import 'package:suliman/features/location/domain/models/zone_response_model.dart';
import 'package:suliman/features/profile/controllers/profile_controller.dart';
import 'package:suliman/helper/auth_helper.dart';
import 'package:suliman/features/auth/controllers/auth_controller.dart';
import 'package:suliman/helper/address_helper.dart';
import 'package:suliman/helper/responsive_helper.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';
import 'package:suliman/common/widgets/custom_dropdown.dart';
import 'package:suliman/features/checkout/widgets/guest_delivery_address.dart';
import 'package:suliman/features/checkout/widgets/add_address_options_bottom_sheet.dart';
import 'package:suliman/features/checkout/widgets/pickup_center_selection_widget.dart';

class DeliverySection extends StatelessWidget {
  final CheckoutController checkoutController;
  final List<AddressModel> address;
  final List<DropdownItem<int>> addressList;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  const DeliverySection({super.key, required this.checkoutController, required this.address, required this.addressList, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode, required this.guestEmailController, required this.guestEmailNode,
  });

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isPickupCenter = (checkoutController.orderType == 'pickup_center');
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<ProfileController>(builder: (profileController) {
      final String? profilePhone = profileController.userInfoModel?.phone;
      final bool hasProfilePhone = !isGuestLoggedIn &&
          profilePhone != null &&
          profilePhone.trim().isNotEmpty &&
          profilePhone.trim() != 'null' &&
          profilePhone.trim() != '0000000000';

      if (!hasProfilePhone && guestNumberTextEditingController.text.trim().isEmpty && address.isNotEmpty) {
        int addrIndex = (checkoutController.addressIndex != null && checkoutController.addressIndex! < address.length) ? checkoutController.addressIndex! : 0;
        String? addrPhone = address[addrIndex].contactPersonNumber;
        if (addrPhone != null && addrPhone.isNotEmpty && addrPhone != 'null' && addrPhone != '0000000000') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (guestNumberTextEditingController.text.isEmpty) {
              guestNumberTextEditingController.text = addrPhone;
            }
          });
        }
      }

      return Column(children: [
        isPickupCenter
            ? Column(children: [
                PickupCenterSelectionWidget(checkoutController: checkoutController),
                if (!hasProfilePhone && !isGuestLoggedIn)
                  _buildPhoneInputField(context),
              ])
            : isGuestLoggedIn ? GuestDeliveryAddress(
          checkoutController: checkoutController, guestNumberNode: guestNumberNode,
          guestNameTextEditingController: guestNameTextEditingController, guestNumberTextEditingController: guestNumberTextEditingController,
          guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
        ) : !takeAway ? Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('deliver_to'.tr, style: robotoMedium),
            TextButton.icon(
              onPressed: () {
                Get.bottomSheet(
                  AddAddressOptionsBottomSheet(checkoutController: checkoutController),
                  isScrollControlled: true,
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: Text('add_new'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ),
          ]),


          address.isEmpty ? Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
            child: InkWell(
              onTap: () {
                Get.bottomSheet(
                  AddAddressOptionsBottomSheet(checkoutController: checkoutController),
                  isScrollControlled: true,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ),
                child: Column(
                  children: [
                    Icon(Icons.location_on_outlined, size: 40, color: Theme.of(context).primaryColor),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text('please_setup_your_delivery_address_first'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),
            ),
          ) : isDesktop ?  Stack(children: [
            Container(
              constraints: const BoxConstraints(minHeight:  90),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeExtraSmall,
                  horizontal: Dimensions.paddingSizeExtraSmall,
                ),
                child: AddressWidget(
                  address: address[(checkoutController.addressIndex != null && checkoutController.addressIndex! < address.length) ? checkoutController.addressIndex! : 0],
                  fromAddress: false, fromCheckout: true,
                ),
              ),
            ),

            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<int>(
                    position: PopupMenuPosition.under,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onSelected: (int index) async {
                      AddressModel selectedAddress = address[index];
                      if (selectedAddress.latitude != null && selectedAddress.longitude != null) {
                        ZoneResponseModel zoneResponse = await Get.find<LocationController>().getZone(
                          selectedAddress.latitude, selectedAddress.longitude, false, updateInAddress: true,
                        );
                        if (zoneResponse.isSuccess && zoneResponse.zoneIds.isNotEmpty) {
                          selectedAddress.zoneId = zoneResponse.zoneIds[0];
                          selectedAddress.zoneIds = [];
                          selectedAddress.zoneIds!.addAll(zoneResponse.zoneIds);
                          selectedAddress.zoneData = [];
                          selectedAddress.zoneData!.addAll(zoneResponse.zoneData);
                          selectedAddress.areaIds = [];
                          selectedAddress.areaIds!.addAll(zoneResponse.areaIds);
                        }
                      }
                      await AddressHelper.saveUserAddressInSharedPref(selectedAddress);
                      Get.find<LocationController>().setPlaceMark(selectedAddress.address ?? '');
                      if (AuthHelper.isLoggedIn()) {
                        Get.find<AuthController>().updateZone();
                      }

                      int currentPaymentMethod = checkoutController.paymentMethodIndex;
                      checkoutController.clearPrevData();
                      if (currentPaymentMethod != -1) {
                        checkoutController.setPaymentMethod(currentPaymentMethod, isUpdate: false);
                      } else if (!AuthHelper.isGuestLoggedIn()) {
                        checkoutController.setPaymentMethod(0, isUpdate: false);
                      }
                      checkoutController.setAddressIndex(0);
                      checkoutController.streetNumberController.text = selectedAddress.streetNumber ?? '';
                      checkoutController.houseController.text = selectedAddress.house ?? '';
                      checkoutController.floorController.text = selectedAddress.floor ?? '';

                      double? lat = double.tryParse(selectedAddress.latitude ?? '');
                      double? lng = double.tryParse(selectedAddress.longitude ?? '');
                      if (lat != null && lng != null && checkoutController.store != null && checkoutController.store!.latitude != null && checkoutController.store!.longitude != null) {
                        double? storeLat = double.tryParse(checkoutController.store!.latitude!);
                        double? storeLng = double.tryParse(checkoutController.store!.longitude!);
                        if (storeLat != null && storeLng != null) {
                          await checkoutController.getDistanceInKM(
                            LatLng(lat, lng),
                            LatLng(storeLat, storeLng),
                          );
                          if (checkoutController.store!.id != null && checkoutController.distance != null && checkoutController.distance! > 0) {
                            await checkoutController.calculateFbsDeliveryFee(
                              storeId: checkoutController.store!.id!,
                              latitude: lat.toString(),
                              longitude: lng.toString(),
                              distance: checkoutController.distance!,
                            );
                          }
                          await checkoutController.fetchDeliveryFeeFromServer(customAddress: selectedAddress);
                        }
                      }
                      checkoutController.update();
                      Get.find<AddressController>().update();
                      Get.find<LocationController>().update();
                    },
                    itemBuilder: (context) => List.generate(
                      address.length, (index) => PopupMenuItem<int>(
                        value: index,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 20, width: 20,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: checkoutController.addressIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                                ),
                                child: checkoutController.addressIndex == index ? Container(
                                  height: 15, width: 15,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                                ) : const SizedBox(),
                              ),

                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text((address[index].addressType ?? 'others').tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    Text(
                                      address[index].address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                      ),
                    )
                ),
              ),
            ),
          ]) : Container(
            constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? 90 : 75),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            child: CustomDropdown<int>(
              key: ValueKey('checkout_dropdown_${checkoutController.addressIndex}_${address.isNotEmpty ? (address[0].id ?? address[0].address ?? address[0].latitude) : ''}_${address.length}'),

              onChange: (int? value, int index) async {
                AddressModel selectedAddress = address[index];
                if (selectedAddress.latitude != null && selectedAddress.longitude != null) {
                  ZoneResponseModel zoneResponse = await Get.find<LocationController>().getZone(
                    selectedAddress.latitude, selectedAddress.longitude, false, updateInAddress: true,
                  );
                  if (zoneResponse.isSuccess && zoneResponse.zoneIds.isNotEmpty) {
                    selectedAddress.zoneId = zoneResponse.zoneIds[0];
                    selectedAddress.zoneIds = [];
                    selectedAddress.zoneIds!.addAll(zoneResponse.zoneIds);
                    selectedAddress.zoneData = [];
                    selectedAddress.zoneData!.addAll(zoneResponse.zoneData);
                    selectedAddress.areaIds = [];
                    selectedAddress.areaIds!.addAll(zoneResponse.areaIds);
                  }
                }
                await AddressHelper.saveUserAddressInSharedPref(selectedAddress);
                Get.find<LocationController>().setPlaceMark(selectedAddress.address ?? '');
                if (AuthHelper.isLoggedIn()) {
                  Get.find<AuthController>().updateZone();
                }

                int currentPaymentMethod = checkoutController.paymentMethodIndex;
                checkoutController.clearPrevData();
                if (currentPaymentMethod != -1) {
                  checkoutController.setPaymentMethod(currentPaymentMethod, isUpdate: false);
                } else if (!AuthHelper.isGuestLoggedIn()) {
                  checkoutController.setPaymentMethod(0, isUpdate: false);
                }
                checkoutController.setAddressIndex(0);

                checkoutController.streetNumberController.text = selectedAddress.streetNumber ?? '';
                checkoutController.houseController.text = selectedAddress.house ?? '';
                checkoutController.floorController.text = selectedAddress.floor ?? '';

                double? lat = double.tryParse(selectedAddress.latitude ?? '');
                double? lng = double.tryParse(selectedAddress.longitude ?? '');
                if (lat != null && lng != null && checkoutController.store != null && checkoutController.store!.latitude != null && checkoutController.store!.longitude != null) {
                  double? storeLat = double.tryParse(checkoutController.store!.latitude!);
                  double? storeLng = double.tryParse(checkoutController.store!.longitude!);
                  if (storeLat != null && storeLng != null) {
                    await checkoutController.getDistanceInKM(
                      LatLng(lat, lng),
                      LatLng(storeLat, storeLng),
                    );
                    if (checkoutController.store!.id != null && checkoutController.distance != null && checkoutController.distance! > 0) {
                      await checkoutController.calculateFbsDeliveryFee(
                        storeId: checkoutController.store!.id!,
                        latitude: lat.toString(),
                        longitude: lng.toString(),
                        distance: checkoutController.distance!,
                      );
                    }
                    await checkoutController.fetchDeliveryFeeFromServer(customAddress: selectedAddress);
                  }
                }
                checkoutController.update();
                Get.find<AddressController>().update();
                Get.find<LocationController>().update();
              },
              dropdownButtonStyle: DropdownButtonStyle(
                height: 45,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeExtraSmall,
                  horizontal: Dimensions.paddingSizeExtraSmall,
                ),
                primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              dropdownStyle: DropdownStyle(
                elevation: 10,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              ),
              items: addressList,
              child: AddressWidget(
                address: address[(checkoutController.addressIndex != null && checkoutController.addressIndex! < address.length) ? checkoutController.addressIndex! : 0],
                fromAddress: false, fromCheckout: true,
              ),
            ),
          ),
          if (!hasProfilePhone) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomTextField(
              labelText: 'contact_person_number'.tr,
              titleText: 'write_number'.tr,
              controller: guestNumberTextEditingController,
              focusNode: guestNumberNode,
              inputType: TextInputType.phone,
              isPhone: true,
              onCountryChanged: (CountryCode countryCode) {
                checkoutController.countryDialCode = countryCode.dialCode;
              },
              countryDialCode: checkoutController.countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
            ),
          ],
          const SizedBox(height: Dimensions.paddingSizeLarge),

        ]),
      ) : (!hasProfilePhone) ? _buildPhoneInputField(context) : const SizedBox(),
      ]);
    });
  }

  Widget _buildPhoneInputField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.phone_outlined, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text('contact_information'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, bottom: Dimensions.paddingSizeDefault),
            child: Divider(color: Theme.of(context).disabledColor),
          ),
          CustomTextField(
            labelText: 'contact_person_number'.tr,
            titleText: 'write_number'.tr,
            controller: guestNumberTextEditingController,
            focusNode: guestNumberNode,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: (CountryCode countryCode) {
              checkoutController.countryDialCode = countryCode.dialCode;
            },
            countryDialCode: checkoutController.countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
          ),
        ],
      ),
    );
  }
}
