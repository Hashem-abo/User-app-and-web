import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/address_widget.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_dropdown.dart';
import 'package:sixam_mart/features/checkout/widgets/guest_delivery_address.dart';
import 'package:sixam_mart/features/checkout/widgets/add_address_options_bottom_sheet.dart';

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
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Column(children: [
      isGuestLoggedIn ? GuestDeliveryAddress(
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.location_off, size: 40, color: Theme.of(context).disabledColor),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text('please_setup_your_delivery_address_first'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                ],
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
                child: PopupMenuButton(
                    position: PopupMenuPosition.under,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onSelected: (value) {},
                    itemBuilder: (context)  => List.generate(
                      address.length, (index) => PopupMenuItem(
                      child: InkWell(
                        onTap: () {
                          double? lat = double.tryParse(address[index].latitude ?? '');
                          double? lng = double.tryParse(address[index].longitude ?? '');
                          if (lat != null && lng != null && checkoutController.store != null && checkoutController.store!.latitude != null && checkoutController.store!.longitude != null) {
                            double? storeLat = double.tryParse(checkoutController.store!.latitude!);
                            double? storeLng = double.tryParse(checkoutController.store!.longitude!);
                            if (storeLat != null && storeLng != null) {
                              checkoutController.getDistanceInKM(
                                LatLng(lat, lng),
                                LatLng(storeLat, storeLng),
                              );
                            }
                          }
                          checkoutController.setAddressIndex(index);
                          int addrIndex = (checkoutController.addressIndex != null && checkoutController.addressIndex! < address.length) ? checkoutController.addressIndex! : 0;
                          checkoutController.streetNumberController.text = address[addrIndex].streetNumber ?? '';
                          checkoutController.houseController.text = address[addrIndex].house ?? '';
                          checkoutController.floorController.text = address[addrIndex].floor ?? '';
                          Navigator.pop(context);
                        },
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

              onChange: (int? value, int index) {
                double? lat = double.tryParse(address[index].latitude ?? '');
                double? lng = double.tryParse(address[index].longitude ?? '');
                if (lat != null && lng != null && checkoutController.store != null && checkoutController.store!.latitude != null && checkoutController.store!.longitude != null) {
                  double? storeLat = double.tryParse(checkoutController.store!.latitude!);
                  double? storeLng = double.tryParse(checkoutController.store!.longitude!);
                  if (storeLat != null && storeLng != null) {
                    checkoutController.getDistanceInKM(
                      LatLng(lat, lng),
                      LatLng(storeLat, storeLng),
                    );
                  }
                }
                checkoutController.setAddressIndex(index);

                int addrIndex = (checkoutController.addressIndex != null && checkoutController.addressIndex! < address.length) ? checkoutController.addressIndex! : 0;
                checkoutController.streetNumberController.text = address[addrIndex].streetNumber ?? '';
                checkoutController.houseController.text = address[addrIndex].house ?? '';
                checkoutController.floorController.text = address[addrIndex].floor ?? '';

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
          const SizedBox(height: Dimensions.paddingSizeLarge),

        ]),
      ) : const SizedBox(),
    ]);
  }
}
