import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class DropdownLocationBottomSheet extends StatefulWidget {
  final bool fromSignUp;
  final String? route;
  final bool fromCheckout;
  const DropdownLocationBottomSheet({super.key, required this.fromSignUp, this.route, this.fromCheckout = false});

  @override
  State<DropdownLocationBottomSheet> createState() => _DropdownLocationBottomSheetState();
}

class _DropdownLocationBottomSheetState extends State<DropdownLocationBottomSheet> {
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _subNeighborhoodController = TextEditingController();
  final TextEditingController _customAddressTypeController = TextEditingController();
  String? _selectedCity;
  String? _selectedNeighborhood;
  ZoneData? _selectedZone;
  int _selectedAddressTypeIndex = 0;

  List<String> _cities = [];
  Map<String, List<String>> _cityToNeighborhoods = {};
  Map<String, Map<String, List<ZoneData>>> _cityNeighborhoodToZones = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    _subNeighborhoodController.dispose();
    _customAddressTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    final locationController = Get.find<LocationController>();
    await locationController.getZoneList();
    if (locationController.zoneList != null) {
      _parseZones(locationController.zoneList!);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _parseZones(List<ZoneData> zoneList) {
    _cities = [];
    _cityToNeighborhoods = {};
    _cityNeighborhoodToZones = {};

    for (var zone in zoneList) {
      String zoneName = zone.name ?? '';
      if (zoneName.isEmpty) continue;

      String city = '';
      String neighborhood = '';
      String subNeighborhood = '';

      if (zoneName.contains('-')) {
        var parts = zoneName.split('-');
        if (parts.length >= 3) {
          city = parts[0].trim();
          neighborhood = parts[1].trim();
          subNeighborhood = parts[2].trim();
        } else if (parts.length == 2) {
          city = parts[0].trim();
          neighborhood = parts[1].trim();
          subNeighborhood = parts[1].trim();
        } else {
          city = zoneName;
          neighborhood = zoneName;
          subNeighborhood = zoneName;
        }
      } else if (zoneName.contains('/')) {
        var parts = zoneName.split('/');
        if (parts.length >= 3) {
          city = parts[0].trim();
          neighborhood = parts[1].trim();
          subNeighborhood = parts[2].trim();
        } else if (parts.length == 2) {
          city = parts[0].trim();
          neighborhood = parts[1].trim();
          subNeighborhood = parts[1].trim();
        } else {
          city = zoneName;
          neighborhood = zoneName;
          subNeighborhood = zoneName;
        }
      } else {
        city = zoneName;
        neighborhood = zoneName;
        subNeighborhood = zoneName;
      }

      if (!_cities.contains(city)) {
        _cities.add(city);
      }

      _cityToNeighborhoods.putIfAbsent(city, () => []);
      if (!_cityToNeighborhoods[city]!.contains(neighborhood)) {
        _cityToNeighborhoods[city]!.add(neighborhood);
      }

      ZoneData parsedZone = ZoneData(
        id: zone.id,
        name: subNeighborhood,
        status: zone.status,
        cashOnDelivery: zone.cashOnDelivery,
        digitalPayment: zone.digitalPayment,
        offlinePayment: zone.offlinePayment,
        modules: zone.modules,
        formatedCoordinates: zone.formatedCoordinates,
      );

      _cityNeighborhoodToZones.putIfAbsent(city, () => {});
      _cityNeighborhoodToZones[city]!.putIfAbsent(neighborhood, () => []).add(parsedZone);
    }

    _cities.sort();
    _selectedCity = null;
    _selectedNeighborhood = null;
    _selectedZone = null;
  }

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
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
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
                'select_via_dropdown'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              if (_isLoading)
                const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_cities.isEmpty)
                SizedBox(
                  height: 150,
                  child: Center(child: Text('service_not_available_in_current_location'.tr)),
                )
              else ...[
                 // City Dropdown
                Text('select_city'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCity,
                      hint: Text('select_city'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCity = newValue;
                          _selectedNeighborhood = null;
                          _selectedZone = null;
                        });
                      },
                      items: _cities.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: robotoRegular),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Neighborhood / District Dropdown
                Text('select_neighborhood'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedNeighborhood,
                      hint: Text('select_neighborhood'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: _selectedCity == null ? null : (String? newValue) {
                        setState(() {
                          _selectedNeighborhood = newValue;
                          if (newValue != null &&
                              _cityNeighborhoodToZones[_selectedCity] != null &&
                              _cityNeighborhoodToZones[_selectedCity]![newValue] != null &&
                              _cityNeighborhoodToZones[_selectedCity]![newValue]!.isNotEmpty) {
                            _selectedZone = _cityNeighborhoodToZones[_selectedCity]![newValue]!.first;
                          } else {
                            _selectedZone = null;
                          }
                        });
                      },
                      items: (_selectedCity != null && _cityToNeighborhoods[_selectedCity] != null)
                          ? _cityToNeighborhoods[_selectedCity]!.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: robotoRegular),
                              );
                            }).toList()
                          : [],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Sub-neighborhood / Street Input (replaced dropdown with textfield)
                Text('select_sub_neighborhood'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                TextField(
                  controller: _subNeighborhoodController,
                  decoration: InputDecoration(
                    hintText: 'select_sub_neighborhood'.tr,
                    hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
                  ),
                  style: robotoRegular,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Nearest Landmark Input
                Text('nearest_landmark'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                TextField(
                  controller: _landmarkController,
                  decoration: InputDecoration(
                    hintText: 'nearest_landmark'.tr,
                    hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
                  ),
                  style: robotoRegular,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Address Type Selection (Label as)
                Text('label_as'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      String labelName = index == 0 ? 'home'.tr : index == 1 ? 'office'.tr : 'others'.tr;
                      IconData labelIcon = index == 0 ? Icons.home : index == 1 ? Icons.work : Icons.more_horiz;
                      bool isSelected = _selectedAddressTypeIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAddressTypeIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
                              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  labelIcon,
                                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                  size: 20,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  labelName,
                                  style: robotoRegular.copyWith(
                                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
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
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Custom Address Type TextField (if Others is selected)
                if (_selectedAddressTypeIndex == 2) ...[
                  Text('${'level_name'.tr} (${'optional'.tr})', style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  TextField(
                    controller: _customAddressTypeController,
                    decoration: InputDecoration(
                      hintText: 'write_level_name'.tr,
                      hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
                    ),
                    style: robotoRegular,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Confirm Button
                CustomButton(
                  buttonText: 'confirm'.tr,
                  onPressed: () async {
                    String subNeighborhood = _subNeighborhoodController.text.trim();
                    if (_selectedCity == null || _selectedNeighborhood == null || _selectedZone == null || subNeighborhood.isEmpty) {
                      showCustomSnackBar('please_enter_sub_neighborhood'.tr);
                      return;
                    }
                    
                    String landmark = _landmarkController.text.trim();
                    String finalAddress = "$_selectedCity - $_selectedNeighborhood - $subNeighborhood\u200b\u200b\u200b";
                    if (landmark.isNotEmpty) {
                      finalAddress += " ($landmark)";
                    }

                    Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);

                    String contactPersonName = 'Customer';
                    String contactPersonNumber = '0000000000';
                    if (AuthHelper.isLoggedIn()) {
                      final profileController = Get.find<ProfileController>();
                      if (profileController.userInfoModel != null) {
                        if (profileController.userInfoModel!.fName != null) {
                          contactPersonName = "${profileController.userInfoModel!.fName} ${profileController.userInfoModel!.lName ?? ''}".trim();
                        }
                        if (profileController.userInfoModel!.phone != null) {
                          contactPersonNumber = profileController.userInfoModel!.phone!;
                        }
                      }
                    }

                    String lat = '0';
                    String lng = '0';
                    if (_selectedZone!.formatedCoordinates != null && _selectedZone!.formatedCoordinates!.isNotEmpty) {
                      double sumLat = 0;
                      double sumLng = 0;
                      for (var coord in _selectedZone!.formatedCoordinates!) {
                        sumLat += coord.latitude;
                        sumLng += coord.longitude;
                      }
                      lat = (sumLat / _selectedZone!.formatedCoordinates!.length).toString();
                      lng = (sumLng / _selectedZone!.formatedCoordinates!.length).toString();
                    }

                    if (lat == '0' || lng == '0' || (lat == '15.369445' && lng == '44.191006')) {
                      AddressModel? currentPrefAddress = AddressHelper.getUserAddressFromSharedPref();
                      if (currentPrefAddress != null && currentPrefAddress.latitude != null && currentPrefAddress.latitude != '0' && !(currentPrefAddress.latitude == '15.369445' && currentPrefAddress.longitude == '44.191006')) {
                        lat = currentPrefAddress.latitude!;
                        lng = currentPrefAddress.longitude!;
                      } else if (Get.isRegistered<CheckoutController>() && Get.find<CheckoutController>().store != null && Get.find<CheckoutController>().store!.latitude != null) {
                        Store store = Get.find<CheckoutController>().store!;
                        double storeLat = double.parse(store.latitude!);
                        double storeLng = double.parse(store.longitude!);
                        lat = (storeLat + 0.008).toString();
                        lng = (storeLng + 0.008).toString();
                      } else {
                        lat = '15.3554';
                        lng = '44.2082';
                      }
                    }

                    String addressType = 'others';
                    if (_selectedAddressTypeIndex == 0) {
                      addressType = 'home';
                    } else if (_selectedAddressTypeIndex == 1) {
                      addressType = 'office';
                    } else if (_selectedAddressTypeIndex == 2) {
                      addressType = _customAddressTypeController.text.trim().isNotEmpty
                          ? _customAddressTypeController.text.trim()
                          : 'others';
                    }

                    // Fetch complete ZoneData from API (/api/v1/zone/check) to populate modules, cashOnDelivery, digitalPayment etc.
                    ZoneData zoneDataToSave = _selectedZone!;
                    try {
                      ZoneResponseModel response = await Get.find<LocationController>().getZone(lat, lng, false);
                      if (response.isSuccess && response.zoneData.isNotEmpty) {
                        zoneDataToSave = response.zoneData.firstWhere(
                          (element) => element.id == _selectedZone!.id,
                          orElse: () => response.zoneData.first,
                        );
                      }
                    } catch (e) {
                      debugPrint('Failed to fetch full zone details: $e');
                    }

                    AddressModel address = AddressModel(
                      latitude: lat,
                      longitude: lng,
                      address: finalAddress,
                      zoneId: zoneDataToSave.id,
                      zoneIds: [zoneDataToSave.id!],
                      zoneData: [zoneDataToSave],
                      addressType: addressType,
                      contactPersonName: contactPersonName,
                      contactPersonNumber: contactPersonNumber,
                      house: 'manual',
                    );

                    await AddressHelper.saveUserAddressInSharedPref(address);

                    AddressModel addressToReturn = address;
                    if (AuthHelper.isLoggedIn()) {
                      await Get.find<AddressController>().addAddress(address, widget.fromCheckout, null);
                      if (Get.find<AddressController>().addressList != null && Get.find<AddressController>().addressList!.isNotEmpty) {
                        AddressModel serverAddress = Get.find<AddressController>().addressList!.first;
                        if (serverAddress.latitude != null && serverAddress.latitude != '0' && serverAddress.latitude != '15.369445') {
                          addressToReturn = serverAddress;
                        } else {
                          serverAddress.latitude = address.latitude;
                          serverAddress.longitude = address.longitude;
                          addressToReturn = serverAddress;
                        }
                      }
                    }

                    Get.back(); // Dismiss CustomLoaderWidget dialog

                    if (widget.fromCheckout) {
                      Get.back(result: addressToReturn); // Dismiss BottomSheet and return server-saved address
                    } else {
                      await Get.find<LocationController>().setManualZone(zoneDataToSave.id!);
                    }
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
