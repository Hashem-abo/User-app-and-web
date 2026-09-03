import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/location/widgets/dropdown_location_bottom_sheet.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class AddAddressOptionsBottomSheet extends StatelessWidget {
  final CheckoutController checkoutController;
  const AddAddressOptionsBottomSheet({super.key, required this.checkoutController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusLarge),
          topRight: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag indicator
          Center(
            child: Container(
              height: 4, width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            'add_new_address'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          // Option 1: Current Location
          _buildOptionTile(
            context: context,
            icon: Icons.my_location,
            title: 'user_current_location'.tr,
            subtitle: 'current_location_description'.tr,
            onTap: () async {
              Get.back();
              Get.find<LocationController>().checkPermission(() async {
                Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
                ZoneResponseModel response = await Get.find<LocationController>().getZone(address.latitude, address.longitude, false);
                Get.back();
                if(response.isSuccess) {
                  await AddressHelper.saveUserAddressInSharedPref(address);
                  AddressModel addressToApply = address;
                  if (AuthHelper.isLoggedIn()) {
                    await Get.find<AddressController>().addAddress(address, true, checkoutController.store?.zoneId);
                    if (Get.find<AddressController>().addressList != null && Get.find<AddressController>().addressList!.isNotEmpty) {
                      addressToApply = Get.find<AddressController>().addressList!.firstWhere(
                        (a) => a.address == address.address || (a.latitude == address.latitude && a.longitude == address.longitude),
                        orElse: () => Get.find<AddressController>().addressList!.last,
                      );
                    }
                  }
                  _applyAddressToCheckout(addressToApply);
                } else {
                  showCustomSnackBar('service_not_available_in_current_location'.tr);
                }
              });
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Option 2: Set From Map
          _buildOptionTile(
            context: context,
            icon: Icons.map,
            title: 'set_from_map'.tr,
            subtitle: 'map_location_description'.tr,
            onTap: () async {
              Get.back();
              var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, false, checkoutController.store?.zoneId));
              if(address != null) {
                _applyAddressToCheckout(address);
              }
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Option 3: Dropdown Location
          _buildOptionTile(
            context: context,
            icon: Icons.list_alt,
            title: 'select_via_dropdown'.tr,
            subtitle: 'dropdown_location_description'.tr,
            onTap: () async {
              Get.back();
              var address = await Get.bottomSheet(
                const DropdownLocationBottomSheet(fromSignUp: false, route: null, fromCheckout: true),
                isScrollControlled: true,
              );
              if(address != null) {
                _applyAddressToCheckout(address);
              }
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }

  void _applyAddressToCheckout(AddressModel address) async {
    if (address.latitude != null && address.longitude != null) {
      ZoneResponseModel zoneResponse = await Get.find<LocationController>().getZone(
        address.latitude, address.longitude, false, updateInAddress: true,
      );
      if (zoneResponse.isSuccess && zoneResponse.zoneIds.isNotEmpty) {
        address.zoneId = zoneResponse.zoneIds[0];
        address.zoneIds = [];
        address.zoneIds!.addAll(zoneResponse.zoneIds);
        address.zoneData = [];
        address.zoneData!.addAll(zoneResponse.zoneData);
        address.areaIds = [];
        address.areaIds!.addAll(zoneResponse.areaIds);
      }
    }

    await AddressHelper.saveUserAddressInSharedPref(address);
    Get.find<LocationController>().setPlaceMark(address.address ?? '');
    if (AuthHelper.isLoggedIn()) {
      Get.find<AuthController>().updateZone();
    }

    if (!AuthHelper.isLoggedIn()) {
      address.email = 'guest@mile.com';
      checkoutController.setGuestAddress(address);
    }
    if (AuthHelper.isLoggedIn()) {
      await Get.find<AddressController>().getAddressList();
    }
    int currentPaymentMethod = checkoutController.paymentMethodIndex;
    checkoutController.clearPrevData();
    if (currentPaymentMethod != -1) {
      checkoutController.setPaymentMethod(currentPaymentMethod, isUpdate: false);
    } else if (!AuthHelper.isGuestLoggedIn()) {
      checkoutController.setPaymentMethod(0, isUpdate: false);
    }
    checkoutController.setAddressIndex(0);

    double? lat = double.tryParse(address.latitude ?? '');
    double? lng = double.tryParse(address.longitude ?? '');
    
    if (lat != null && lng != null && checkoutController.store != null && checkoutController.store!.latitude != null && checkoutController.store!.longitude != null) {
      double? storeLat = double.tryParse(checkoutController.store!.latitude!);
      double? storeLng = double.tryParse(checkoutController.store!.longitude!);
      if (storeLat != null && storeLng != null) {
        await checkoutController.getDistanceInKM(
          LatLng(lat, lng),
          LatLng(storeLat, storeLng),
        );
      }
    }
    checkoutController.streetNumberController.text = address.streetNumber ?? '';
    checkoutController.houseController.text = address.house ?? '';
    checkoutController.floorController.text = address.floor ?? '';
    
    Get.find<AddressController>().update();
    Get.find<LocationController>().update();
    checkoutController.update();
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).disabledColor),
            ],
          ),
        ),
      ),
    );
  }
}
