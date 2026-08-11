import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class DropdownLocationBottomSheet extends StatefulWidget {
  final bool fromSignUp;
  final String? route;
  const DropdownLocationBottomSheet({super.key, required this.fromSignUp, this.route});

  @override
  State<DropdownLocationBottomSheet> createState() => _DropdownLocationBottomSheetState();
}

class _DropdownLocationBottomSheetState extends State<DropdownLocationBottomSheet> {
  final TextEditingController _landmarkController = TextEditingController();
  String? _selectedCity;
  String? _selectedNeighborhood;
  ZoneData? _selectedZone;

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
                          _selectedZone = null;
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

                // Sub-neighborhood Dropdown
                Text('select_sub_neighborhood'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ZoneData>(
                      value: _selectedZone,
                      hint: Text('select_sub_neighborhood'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: _selectedNeighborhood == null ? null : (ZoneData? newValue) {
                        setState(() {
                          _selectedZone = newValue;
                        });
                      },
                      items: (_selectedNeighborhood != null &&
                              _cityNeighborhoodToZones[_selectedCity] != null &&
                              _cityNeighborhoodToZones[_selectedCity]![_selectedNeighborhood] != null)
                          ? _cityNeighborhoodToZones[_selectedCity]![_selectedNeighborhood]!.map<DropdownMenuItem<ZoneData>>((ZoneData value) {
                              return DropdownMenuItem<ZoneData>(
                                value: value,
                                child: Text(value.name ?? '', style: robotoRegular),
                              );
                            }).toList()
                          : [],
                    ),
                  ),
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
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Confirm Button
                CustomButton(
                  buttonText: 'confirm'.tr,
                  onPressed: () async {
                    if (_selectedCity == null || _selectedNeighborhood == null || _selectedZone == null) return;
                    
                    String landmark = _landmarkController.text.trim();
                    String finalAddress = "$_selectedCity - $_selectedNeighborhood - ${_selectedZone!.name}\u200b\u200b\u200b";
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
                      lat = _selectedZone!.formatedCoordinates![0].latitude.toString();
                      lng = _selectedZone!.formatedCoordinates![0].longitude.toString();
                    }

                    AddressModel address = AddressModel(
                      latitude: lat,
                      longitude: lng,
                      address: finalAddress,
                      zoneId: _selectedZone!.id,
                      zoneIds: [_selectedZone!.id!],
                      zoneData: [_selectedZone!],
                      addressType: 'Others',
                      contactPersonName: contactPersonName,
                      contactPersonNumber: contactPersonNumber,
                      house: 'manual',
                    );

                    await AddressHelper.saveUserAddressInSharedPref(address);

                    if (AuthHelper.isLoggedIn()) {
                      await Get.find<AddressController>().addAddress(address, false, null);
                    }

                    await Get.find<LocationController>().setManualZone(_selectedZone!.id!);
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
