import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/widgets/location_search_dialog_widget.dart';
import 'package:sixam_mart/features/location/widgets/serach_location_widget.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/debouncer.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class PickMapScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromAddAddress;
  final bool canRoute;
  final String? route;
  final GoogleMapController? googleMapController;
  final Function(AddressModel address)? onPicked;
  final bool fromLandingPage;
  final bool fromGuestCheckout;
  final LatLng? initialPosition;
  final String? initialAddress;

  const PickMapScreen({
    super.key,
    required this.fromSignUp,
    required this.fromAddAddress,
    required this.canRoute,
    required this.route,
    this.googleMapController,
    this.onPicked,
    this.fromLandingPage = false,
    this.fromGuestCheckout = false,
    this.initialPosition,
    this.initialAddress,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;
  bool locationAlreadyAllow = false;
  double _currentZoomLevel = 18.0;

  // Active Map Type State (Defaults to normal: Satellite + Street Labels)
  MapType _currentMapType = MapType.normal;

  // Set of Google Map Markers containing our Draggable Marker
  Set<Marker> _markers = {};

  final Debouncer _idleDebouncer = Debouncer(
    delay: const Duration(milliseconds: AppConstants.idleDebounceDuration),
  );

  @override
  void initState() {
    super.initState();

    if (widget.fromAddAddress) {
      Get.find<LocationController>().setPickData();
    }
    if (widget.initialPosition != null) {
      _initialPosition = widget.initialPosition!;
    } else {
      _initialPosition = LatLng(
        double.parse(
          Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0',
        ),
        double.parse(
          Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0',
        ),
      );
    }

    _cameraPosition = CameraPosition(
      target: _initialPosition,
      zoom: _currentZoomLevel,
      tilt: 0.0,
    );

    _updateDraggableMarker(_initialPosition);
    _checkAlreadyLocationEnable();
  }

  @override
  void dispose() {
    _idleDebouncer.dispose();
    super.dispose();
  }

  Future<void> _checkAlreadyLocationEnable() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse) {
      locationAlreadyAllow = true;
    }
  }

  // Updates the draggable marker position and binds drag events
  void _updateDraggableMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('draggable_picker_pin'),
          position: position,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'is_this_your_location'.tr),
          onDragStart: (LatLng newPos) {
            Get.find<LocationController>().updateCameraMovingStatus(true);
            Get.find<LocationController>().disableButton();
          },
          onDragEnd: (LatLng newPosition) {
            Get.find<LocationController>().updateCameraMovingStatus(false);
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(newPosition),
            );
            _cameraPosition = CameraPosition(
              target: newPosition,
              zoom: _currentZoomLevel,
              tilt: 0.0,
            );
            _idleDebouncer.run(() {
              if (!mounted) return;
              Get.find<LocationController>().updatePosition(_cameraPosition, false);
            });
          },
        ),
      };
    });
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = (_currentMapType == MapType.normal)
          ? MapType.satellite
          : MapType.normal;
    });
  }

  IconData _getMapTypeIcon() {
    return _currentMapType == MapType.normal
        ? Icons.satellite_alt
        : Icons.map_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context)
          ? Colors.transparent
          : Theme.of(context).cardColor,
      appBar: widget.fromGuestCheckout && !ResponsiveHelper.isDesktop(context)
          ? CustomAppBar(title: 'delivery_address'.tr)
          : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: Center(
          child: Container(
            height: ResponsiveHelper.isDesktop(context) ? 600 : null,
            width: ResponsiveHelper.isDesktop(context)
                ? 700
                : Dimensions.webMaxWidth,
            decoration: context.width > 700
                ? BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  )
                : null,
            child: GetBuilder<LocationController>(
              builder: (locationController) {
                return ResponsiveHelper.isDesktop(context)
                    ? _buildDesktopView(locationController)
                    : _buildMobileView(locationController);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopView(LocationController locationController) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.clear),
            ),
          ),
          Text(
            'type_your_address_here_to_pick_form_map'.tr,
            style: robotoBold,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SearchLocationWidget(
            mapController: _mapController,
            pickedAddress: locationController.pickAddress,
            isEnabled: null,
            fromDialog: true,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            height: 350,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: GoogleMap(
                      mapType: _currentMapType,
                      markers: _markers,
                      tiltGesturesEnabled: false,
                      buildingsEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: widget.fromAddAddress
                            ? LatLng(
                                locationController.position.latitude,
                                locationController.position.longitude,
                              )
                            : _initialPosition,
                        zoom: _currentZoomLevel,
                        tilt: 0.0,
                      ),
                    minMaxZoomPreference: const MinMaxZoomPreference(0, 20),
                    myLocationButtonEnabled: false,
                    onMapCreated: (GoogleMapController mapController) async {
                      _mapController = mapController;
                      if (!widget.fromAddAddress &&
                          widget.route != 'splash' &&
                          widget.initialPosition == null) {
                        Get.find<LocationController>()
                            .getCurrentLocation(false, mapController: mapController)
                            .then((value) async {
                          if (widget.fromLandingPage &&
                              !locationAlreadyAllow &&
                              await _locationCheck()) {
                            _onPickAddressButtonPressed(locationController);
                          }
                        });
                      }
                    },
                    scrollGesturesEnabled: !Get.isDialogOpen!,
                    zoomControlsEnabled: false,
                    onTap: (LatLng position) {
                      _updateDraggableMarker(position);
                      locationController.updatePosition(
                        CameraPosition(target: position, zoom: _currentZoomLevel, tilt: 0.0),
                        false,
                      );
                    },
                    onCameraMove: (CameraPosition cameraPosition) {
                      _cameraPosition = cameraPosition;
                    },
                    onCameraIdle: () {
                      if (_cameraPosition != null) {
                        _updateDraggableMarker(_cameraPosition!.target);
                        _idleDebouncer.run(() {
                          if (!mounted) return;
                          Get.find<LocationController>().updatePosition(_cameraPosition, false);
                        });
                      }
                    },
                    style: Get.isDarkMode
                        ? Get.find<ThemeController>().darkMap
                        : Get.find<ThemeController>().lightMap,
                  ),
                ),
                Positioned(
                  bottom: 15,
                  right: Dimensions.paddingSizeSmall,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'desktop_layer_toggle',
                        mini: true,
                        backgroundColor: Theme.of(context).cardColor,
                        onPressed: _toggleMapType,
                        child: Icon(_getMapTypeIcon(), color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'desktop_my_location',
                        mini: true,
                        backgroundColor: Theme.of(context).cardColor,
                        onPressed: () => Get.find<LocationController>().checkPermission(() {
                          Get.find<LocationController>().getCurrentLocation(
                            false,
                            mapController: _mapController,
                          );
                        }),
                        child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          Row(
            children: [
              const Spacer(),
              CustomButton(
                isBold: false,
                width: 120,
                radius: Dimensions.radiusSmall,
                buttonText: 'cancel'.tr,
                isLoading: locationController.isLoading,
                color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Flexible(
                child: CustomButton(
                  isBold: false,
                  radius: Dimensions.radiusSmall,
                  buttonText: locationController.inZone
                      ? widget.fromAddAddress
                          ? 'pick_address'.tr
                          : 'pick_location'.tr
                      : 'service_not_available_in_this_area'.tr,
                  isLoading: locationController.isLoading,
                  onPressed: locationController.isLoading
                      ? () {}
                      : (locationController.buttonDisabled || locationController.loading)
                          ? null
                          : () => _onPickAddressButtonPressed(locationController),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView(LocationController locationController) {
    return Stack(
      children: [
        GoogleMap(
          mapType: _currentMapType,
          markers: _markers,
          tiltGesturesEnabled: false,
          buildingsEnabled: false,
          initialCameraPosition: CameraPosition(
            target: widget.fromAddAddress
                ? LatLng(
                    locationController.position.latitude,
                    locationController.position.longitude,
                  )
                : _initialPosition,
            zoom: _currentZoomLevel,
            tilt: 0.0,
          ),
          minMaxZoomPreference: const MinMaxZoomPreference(0, 20),
          myLocationButtonEnabled: false,
          onMapCreated: (GoogleMapController mapController) {
            _mapController = mapController;

            if (!widget.fromAddAddress &&
                widget.route != RouteHelper.onBoarding &&
                widget.initialPosition == null) {
              Get.find<LocationController>()
                  .getCurrentLocation(false, mapController: mapController);
            }
          },
          scrollGesturesEnabled: !Get.isDialogOpen!,
          zoomControlsEnabled: false,
          onTap: (LatLng position) {
            _updateDraggableMarker(position);
            locationController.updatePosition(
              CameraPosition(target: position, zoom: _currentZoomLevel, tilt: 0.0),
              false,
            );
          },
          onCameraMove: (CameraPosition cameraPosition) {
            _cameraPosition = cameraPosition;
          },
          onCameraIdle: () {
            if (_cameraPosition != null) {
              _updateDraggableMarker(_cameraPosition!.target);
              _idleDebouncer.run(() {
                if (!mounted) return;
                Get.find<LocationController>().updatePosition(_cameraPosition, false);
              });
            }
          },
          style: Get.isDarkMode
              ? Get.find<ThemeController>().darkMap
              : Get.find<ThemeController>().lightMap,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _MapTopSearchBar(
            mapController: _mapController,
            pickedAddress: locationController.pickAddress,
            showBackButton: widget.route != RouteHelper.onBoarding,
          ),
        ),
        Positioned(
          bottom: 80,
          right: Dimensions.paddingSizeLarge,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: FloatingActionButton(
                  heroTag: 'mobile_my_location',
                  mini: true,
                  backgroundColor: Theme.of(context).cardColor,
                  onPressed: () => Get.find<LocationController>().checkPermission(() {
                    Get.find<LocationController>().getCurrentLocation(
                      false,
                      mapController: _mapController,
                    );
                  }),
                  child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Change Map View',
                      icon: Icon(_getMapTypeIcon(), size: 22, color: Theme.of(context).primaryColor),
                      onPressed: _toggleMapType,
                    ),
                    const Divider(height: 1, indent: 8, endIndent: 8),
                    IconButton(
                      icon: const Icon(Icons.add, size: 24),
                      onPressed: () {
                        if (_currentZoomLevel < 20) {
                          setState(() {
                            _currentZoomLevel++;
                          });
                          _mapController?.animateCamera(
                            CameraUpdate.zoomTo(_currentZoomLevel),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 24),
                      onPressed: () {
                        if (_currentZoomLevel > 0) {
                          setState(() {
                            _currentZoomLevel--;
                          });
                          _mapController?.animateCamera(
                            CameraUpdate.zoomTo(_currentZoomLevel),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: Dimensions.paddingSizeLarge,
          left: Dimensions.paddingSizeLarge,
          right: Dimensions.paddingSizeLarge,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: locationController.isLoading
                ? () {}
                : (locationController.buttonDisabled || locationController.loading)
                    ? null
                    : () => _onPickAddressButtonPressed(locationController),
            child: Builder(
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(
                    locationController.loading
                        ? Dimensions.paddingSizeExtraSmall
                        : Dimensions.paddingSizeDefault - 2,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: locationController.loading
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
                        : locationController.buttonDisabled
                            ? Theme.of(context).disabledColor.withValues(alpha: 0.7)
                            : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: locationController.loading
                      ? Center(
                          child: LoadingAnimationWidget.waveDots(
                            color: Colors.white,
                            size: 40,
                          ),
                        )
                      : Text(
                          locationController.inZone
                              ? widget.fromAddAddress
                                  ? 'confirm_location'.tr
                                  : widget.fromGuestCheckout
                                      ? 'confirm_address'.tr
                                      : 'confirm_location'.tr
                              : 'service_not_available_in_this_area'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onPickAddressButtonPressed(LocationController locationController) {
    if (locationController.pickPosition.latitude != 0 &&
        locationController.pickAddress!.isNotEmpty) {
      if (widget.onPicked != null) {
        AddressModel address = AddressModel(
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          addressType: '',
          address: locationController.pickAddress,
          contactPersonName:
              AddressHelper.getUserAddressFromSharedPref()?.contactPersonName,
          contactPersonNumber:
              AddressHelper.getUserAddressFromSharedPref()?.contactPersonNumber,
        );
        widget.onPicked!(address);
        Get.back();
      } else if (widget.fromAddAddress) {
        if (widget.googleMapController != null) {
          widget.googleMapController!.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  locationController.pickPosition.latitude,
                  locationController.pickPosition.longitude,
                ),
                zoom: 16,
              ),
            ),
          );
          locationController.setAddAddressData();
        }
        Get.back();
      } else {
        AddressModel address = AddressModel(
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          addressType: '',
          address: locationController.pickAddress,
        );

        if (widget.fromLandingPage) {
          if (!AuthHelper.isGuestLoggedIn() && !AuthHelper.isLoggedIn()) {
            Get.find<AuthController>().guestLogin().then((response) {
              if (response.isSuccess) {
                Get.find<ProfileController>().setForceFullyUserEmpty();
                Get.back();
                locationController.saveAddressAndNavigate(
                  address,
                  widget.fromSignUp,
                  widget.route,
                  widget.canRoute,
                  ResponsiveHelper.isDesktop(Get.context),
                );
              }
            });
          } else {
            Get.back();
            locationController.saveAddressAndNavigate(
              address,
              widget.fromSignUp,
              widget.route,
              widget.canRoute,
              ResponsiveHelper.isDesktop(context),
            );
          }
        } else {
          locationController.saveAddressAndNavigate(
            address,
            widget.fromSignUp,
            widget.route,
            widget.canRoute,
            ResponsiveHelper.isDesktop(context),
          );
        }
      }
    } else {
      showCustomSnackBar('pick_an_address'.tr);
    }
  }

  Future<bool> _locationCheck() async {
    bool locationServiceEnabled = true;
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      locationServiceEnabled = false;
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      locationServiceEnabled = false;
    }
    return locationServiceEnabled;
  }
}

class _MapTopSearchBar extends StatelessWidget {
  final GoogleMapController? mapController;
  final String? pickedAddress;
  final bool showBackButton;

  const _MapTopSearchBar({
    required this.mapController,
    required this.pickedAddress,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAddress = pickedAddress != null && pickedAddress!.isNotEmpty;
    final Color midDisabledColor =
        Theme.of(context).disabledColor.withValues(alpha: 0.4);
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: LocationSearchDialogWidget(
        mapController: mapController,
        pickedLocation: pickedAddress,
        fullWidthBar: true,
        leading: showBackButton
            ? _CircleIconButton(
                icon: Icons.arrow_back,
                backgroundColor:
                    Theme.of(context).disabledColor.withValues(alpha: 0.1),
                onTap: () => Get.back(),
              )
            : null,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: midDisabledColor),
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.placemark, size: 22),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text(
                  hasAddress ? pickedAddress! : 'search_location'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: hasAddress
                        ? Theme.of(context).textTheme.bodyLarge!.color
                        : Theme.of(context).hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Icon(
                hasAddress ? Icons.close : Icons.search,
                size: 22,
                color: Theme.of(context).hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ),
    );
  }
}