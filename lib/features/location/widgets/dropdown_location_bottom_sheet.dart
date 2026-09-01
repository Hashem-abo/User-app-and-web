import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/location/domain/models/prediction_model.dart';
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

  String _normalizeArabicText(String text) {
    return text
        .replaceAll(RegExp(r'[أإآA]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();
  }

  String _transliterateYemeniLocation(String text) {
    String clean = _normalizeArabicText(text);
    Map<String, String> dictionary = {
      'صنعاء': 'Sanaa',
      'عدن': 'Aden',
      'تعز': 'Taiz',
      'الحديديه': 'Hodeidah',
      'المكلا': 'Mukalla',
      'إب': 'Ibb',
      'ذمار': 'Dhamar',
      'مأرب': 'Marib',
      'السبعين': 'Al Sabeen',
      'حده': 'Hadda',
      'حداء': 'Hadda',
      'معين': 'Maain',
      'شعوب': 'Shuayb',
      'الثوره': 'Al Thawrah',
      'الصافيه': 'Al Safiyah',
      'التحرير': 'Al Tahrir',
      'الوحده': 'Al Wahdah',
      'عصر': 'Asar',
      'عمران': 'Amran',
      'شارع صخر': 'Sakhr Street',
      'شارع حدة': 'Hadda Street',
      'شارع الستين': '60th Street',
      'شارع الخمسين': '50th Street',
      'شارع الزبيري': 'Zubeiry Street',
      'شارع تعز': 'Taiz Street',
      'شارع بغداد': 'Baghdad Street',
      'شارع الجزائر': 'Algeria Street',
    };

    dictionary.forEach((key, val) {
      if (clean.contains(key)) {
        clean = clean.replaceAll(key, val);
      }
    });

    return clean;
  }

  Future<LatLng?> _aiSmartGeocodeAddress(String city, String? neighborhood, String subNeighborhood, String landmark) async {
    List<String> queries = [];

    String normCity = _normalizeArabicText(city);
    String? normNeigh = neighborhood != null ? _normalizeArabicText(neighborhood) : null;
    String normSub = _normalizeArabicText(subNeighborhood);
    String normLandmark = _normalizeArabicText(landmark)
        .replaceAll('بالقرب من', '')
        .replaceAll('بجوار', '')
        .replaceAll('قريب من', '')
        .replaceAll('مقابل', '')
        .replaceAll('خلف', '')
        .replaceAll('امام', '')
        .replaceAll('أمام', '')
        .trim();

    if (normLandmark.isNotEmpty && normSub.isNotEmpty && normNeigh != null && normNeigh.isNotEmpty) {
      queries.add("$normLandmark, $normSub, $normNeigh, $normCity, Yemen");
    }

    if (normLandmark.isNotEmpty && normNeigh != null && normNeigh.isNotEmpty) {
      queries.add("$normLandmark, $normNeigh, $normCity, Yemen");
    }

    if (normSub.isNotEmpty && normNeigh != null && normNeigh.isNotEmpty) {
      queries.add("$normSub, $normNeigh, $normCity, Yemen");
    }

    String transCity = _transliterateYemeniLocation(city);
    String? transNeigh = neighborhood != null ? _transliterateYemeniLocation(neighborhood) : null;
    String transSub = _transliterateYemeniLocation(subNeighborhood);
    String transLandmark = _transliterateYemeniLocation(landmark);

    if (transLandmark.isNotEmpty && transNeigh != null && transNeigh.isNotEmpty) {
      queries.add("$transLandmark, $transNeigh, $transCity, Yemen");
    }
    if (transSub.isNotEmpty && transNeigh != null && transNeigh.isNotEmpty) {
      queries.add("$transSub, $transNeigh, $transCity, Yemen");
    }
    if (transNeigh != null && transNeigh.isNotEmpty) {
      queries.add("$transNeigh, $transCity, Yemen");
    }

    if (normSub.isNotEmpty) {
      queries.add("$normSub, $normCity, Yemen");
    }
    if (normLandmark.isNotEmpty) {
      queries.add("$normLandmark, $normCity, Yemen");
    }

    if (normNeigh != null && normNeigh.isNotEmpty) {
      queries.add("$normNeigh, $normCity, Yemen");
    }

    queries.add("$normCity, Yemen");

    for (String q in queries) {
      try {
        final uri = Uri.parse("https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&limit=1");
        final response = await http.get(uri, headers: {'User-Agent': 'SixamMartAIApp/1.0'}).timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            double? lat = double.tryParse(data[0]['lat'].toString());
            double? lon = double.tryParse(data[0]['lon'].toString());
            if (lat != null && lon != null && lat != 0 && lon != 0) {
              debugPrint('AI Geocoded successfully for "$q": lat=$lat, lon=$lon');
              return LatLng(lat, lon);
            }
          }
        }
      } catch (e) {
        debugPrint('AI Geocoding query "$q" failed: $e');
      }
    }
    return null;
  }

  Future<LatLng?> _googleMapsSmartGeocode(String city, String? neighborhood, String subNeighborhood, String landmark) async {
    List<String> queries = [];

    String normCity = _normalizeArabicText(city);
    String? normNeigh = neighborhood != null ? _normalizeArabicText(neighborhood) : null;
    String normSub = _normalizeArabicText(subNeighborhood);
    String normLandmark = _normalizeArabicText(landmark)
        .replaceAll('بالقرب من', '')
        .replaceAll('بجوار', '')
        .replaceAll('قريب من', '')
        .replaceAll('مقابل', '')
        .replaceAll('خلف', '')
        .replaceAll('امام', '')
        .replaceAll('أمام', '')
        .trim();

    if (normLandmark.isNotEmpty && normSub.isNotEmpty && normNeigh != null && normNeigh.isNotEmpty) {
      queries.add("$normLandmark $normSub $normNeigh $normCity");
    }

    if (normLandmark.isNotEmpty && normNeigh != null && normNeigh.isNotEmpty) {
      queries.add("$normLandmark $normNeigh $normCity");
    }

    if (normSub.isNotEmpty && normNeigh != null && normNeigh.isNotEmpty) {
      queries.add("$normSub $normNeigh $normCity");
    }

    if (normLandmark.isNotEmpty) {
      queries.add("$normLandmark $normCity");
    }

    if (normSub.isNotEmpty) {
      queries.add("$normSub $normCity");
    }

    if (normNeigh != null && normNeigh.isNotEmpty) {
      queries.add("$normNeigh $normCity");
    }

    for (String q in queries) {
      try {
        List<PredictionModel> predictions = await Get.find<LocationController>().searchLocation(context, q);
        if (predictions.isNotEmpty && predictions.first.placeId != null) {
          String placeId = predictions.first.placeId!;
          Response response = await Get.find<ApiClient>().getData('${AppConstants.placeDetailsUri}?placeid=$placeId');
          if (response.statusCode == 200 && response.body != null) {
            double? lat;
            double? lng;

            if (response.body['location'] != null) {
              lat = double.tryParse(response.body['location']['latitude'].toString());
              lng = double.tryParse(response.body['location']['longitude'].toString());
            } else if (response.body['result'] != null && response.body['result']['geometry'] != null) {
              var loc = response.body['result']['geometry']['location'];
              lat = double.tryParse(loc['lat'].toString());
              lng = double.tryParse(loc['lng'].toString());
            }

            if (lat != null && lng != null && lat != 0 && lng != 0) {
              debugPrint('Google Maps Geocoded successfully for "$q": lat=$lat, lng=$lng');
              return LatLng(lat, lng);
            }
          }
        }
      } catch (e) {
        debugPrint('Google Maps Geocoding query "$q" failed: $e');
      }
    }

    return await _aiSmartGeocodeAddress(city, neighborhood, subNeighborhood, landmark);
  }
  final TextEditingController _customAddressTypeController = TextEditingController();
  String? _selectedCity;
  String? _selectedNeighborhood;
  ZoneData? _selectedZone;
  int _selectedAddressTypeIndex = 0;

  List<String> _cities = [];
  Map<String, List<String>> _cityToNeighborhoods = {};
  Map<String, Map<String, List<ZoneData>>> _cityNeighborhoodToZones = {};
  Map<String, ZoneData> _cityToZone = {};
  bool _isLoading = true;
  bool _hasError = false;

  bool _hasHomeAddress() {
    List<AddressModel> list = [];
    if (Get.isRegistered<AddressController>() && Get.find<AddressController>().addressList != null) {
      list.addAll(Get.find<AddressController>().addressList!);
    }
    AddressModel? pref = AddressHelper.getUserAddressFromSharedPref();
    if (pref != null) list.add(pref);
    return list.any((a) {
      String t = (a.addressType ?? '').trim().toLowerCase();
      return t == 'home' || t == 'المنزل' || t == 'الرئيسية' || t == 'home'.tr.toLowerCase();
    });
  }

  bool _hasOfficeAddress() {
    List<AddressModel> list = [];
    if (Get.isRegistered<AddressController>() && Get.find<AddressController>().addressList != null) {
      list.addAll(Get.find<AddressController>().addressList!);
    }
    AddressModel? pref = AddressHelper.getUserAddressFromSharedPref();
    if (pref != null) list.add(pref);
    return list.any((a) {
      String t = (a.addressType ?? '').trim().toLowerCase();
      return t == 'office' || t == 'مكتب' || t == 'العمل' || t == 'office'.tr.toLowerCase();
    });
  }

  @override
  void initState() {
    super.initState();
    if (_hasHomeAddress()) {
      if (_hasOfficeAddress()) {
        _selectedAddressTypeIndex = 2;
      } else {
        _selectedAddressTypeIndex = 1;
      }
    } else {
      _selectedAddressTypeIndex = 0;
    }
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
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final locationController = Get.find<LocationController>();
    await locationController.getZoneList();
    if (locationController.zoneList != null) {
      _parseZones(locationController.zoneList!);
      _hasError = false;
    } else {
      _hasError = true;
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

      String city = zoneName; // The zone name itself is the city (e.g. Sana'a)

      if (!_cities.contains(city)) {
        _cities.add(city);
      }

      _cityToNeighborhoods.putIfAbsent(city, () => []);
      _cityNeighborhoodToZones.putIfAbsent(city, () => {});

      if (zone.districts != null && zone.districts!.isNotEmpty) {
        for (var district in zone.districts!) {
          String neighborhood = district.trim();
          if (neighborhood.isEmpty) continue;

          if (!_cityToNeighborhoods[city]!.contains(neighborhood)) {
            _cityToNeighborhoods[city]!.add(neighborhood);
          }

          ZoneData parsedZone = ZoneData(
            id: zone.id,
            name: neighborhood,
            status: zone.status,
            cashOnDelivery: zone.cashOnDelivery,
            digitalPayment: zone.digitalPayment,
            offlinePayment: zone.offlinePayment,
            modules: zone.modules,
            formatedCoordinates: zone.formatedCoordinates,
            districts: zone.districts,
          );

          _cityNeighborhoodToZones[city]!.putIfAbsent(neighborhood, () => []).add(parsedZone);
        }
      }
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
              else if (_hasError)
                SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('connection_to_api_failed'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextButton(
                        onPressed: _loadZones,
                        child: Text('retry'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                      ),
                    ],
                  ),
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
                          if (newValue != null) {
                            final locationController = Get.find<LocationController>();
                            if (locationController.zoneList != null) {
                              for (var zone in locationController.zoneList!) {
                                if (zone.name == newValue) {
                                  _selectedZone = zone;
                                  break;
                                }
                              }
                            }
                          }
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
                      hint: Text(
                        (_selectedCity != null && (_cityToNeighborhoods[_selectedCity] == null || _cityToNeighborhoods[_selectedCity]!.isEmpty))
                            ? 'no_districts_in_zone'.tr
                            : 'select_neighborhood'.tr,
                        style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                      ),
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (_selectedCity == null || _cityToNeighborhoods[_selectedCity] == null || _cityToNeighborhoods[_selectedCity]!.isEmpty) ? null : (String? newValue) {
                        setState(() {
                          _selectedNeighborhood = newValue;
                          if (newValue != null &&
                              _cityNeighborhoodToZones[_selectedCity] != null &&
                              _cityNeighborhoodToZones[_selectedCity]![newValue] != null &&
                              _cityNeighborhoodToZones[_selectedCity]![newValue]!.isNotEmpty) {
                            _selectedZone = _cityNeighborhoodToZones[_selectedCity]![newValue]!.first;
                          } else {
                            _selectedZone = null;
                            if (_selectedCity != null) {
                              final locationController = Get.find<LocationController>();
                              if (locationController.zoneList != null) {
                                for (var zone in locationController.zoneList!) {
                                  if (zone.name == _selectedCity) {
                                    _selectedZone = zone;
                                    break;
                                  }
                                }
                              }
                            }
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
                            if (index == 0 && _hasHomeAddress()) {
                              showCustomSnackBar('home_address_already_added_choose_another'.tr);
                              return;
                            }
                            if (index == 1 && _hasOfficeAddress()) {
                              showCustomSnackBar('work_address_already_added_choose_another'.tr);
                              return;
                            }
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
                  Text('address_label_required'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
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
                    if (_selectedCity == null) {
                      showCustomSnackBar('please_select_city'.tr);
                      return;
                    }
                    bool hasDistricts = _cityToNeighborhoods[_selectedCity] != null &&
                        _cityToNeighborhoods[_selectedCity]!.isNotEmpty;
                    if (hasDistricts && _selectedNeighborhood == null) {
                      showCustomSnackBar('please_select_neighborhood'.tr);
                      return;
                    }
                    if (_selectedZone == null) {
                      showCustomSnackBar('please_select_city'.tr);
                      return;
                    }
                    if (subNeighborhood.isEmpty) {
                      showCustomSnackBar('please_enter_sub_neighborhood'.tr);
                      return;
                    }
                    if (_selectedAddressTypeIndex == 2 && _customAddressTypeController.text.trim().isEmpty) {
                      showCustomSnackBar('please_enter_address_label'.tr);
                      return;
                    }
                    
                    String landmark = _landmarkController.text.trim();
                    String finalAddress = _selectedNeighborhood != null
                        ? "$_selectedCity - $_selectedNeighborhood - $subNeighborhood\u200b\u200b\u200b"
                        : "$_selectedCity - $subNeighborhood\u200b\u200b\u200b";
                    if (landmark.isNotEmpty) {
                      finalAddress += " ($landmark)";
                    }

                    Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);

                    String contactPersonName = 'Customer';
                    String contactPersonNumber = '';
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

                    LatLng? geocodedPos = await _googleMapsSmartGeocode(_selectedCity!, _selectedNeighborhood, subNeighborhood, landmark);
                    String lat = '0';
                    String lng = '0';
                    if (geocodedPos != null) {
                      lat = geocodedPos.latitude.toString();
                      lng = geocodedPos.longitude.toString();
                    } else if (_selectedZone!.formatedCoordinates != null && _selectedZone!.formatedCoordinates!.isNotEmpty) {
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
                      int? storeZoneId = Get.isRegistered<CheckoutController>() ? Get.find<CheckoutController>().store?.zoneId : null;
                      await Get.find<AddressController>().addAddress(address, widget.fromCheckout, storeZoneId);
                      if (Get.find<AddressController>().addressList != null && Get.find<AddressController>().addressList!.isNotEmpty) {
                        AddressModel serverAddress = Get.find<AddressController>().addressList!.firstWhere(
                          (a) => a.address == address.address || (a.latitude == address.latitude && a.longitude == address.longitude),
                          orElse: () => Get.find<AddressController>().addressList!.last,
                        );
                        if (serverAddress.latitude != null && serverAddress.latitude != '0' && serverAddress.latitude != '15.369445') {
                          addressToReturn = serverAddress;
                        } else {
                          serverAddress.latitude = address.latitude;
                          serverAddress.longitude = address.longitude;
                          addressToReturn = serverAddress;
                        }
                      }
                    }

                    await AddressHelper.saveUserAddressInSharedPref(addressToReturn);

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
