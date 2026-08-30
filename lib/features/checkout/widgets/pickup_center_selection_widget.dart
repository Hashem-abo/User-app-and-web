import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/pickup_center_model.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class PickupCenterSelectionWidget extends StatefulWidget {
  final CheckoutController checkoutController;
  const PickupCenterSelectionWidget({super.key, required this.checkoutController});

  @override
  State<PickupCenterSelectionWidget> createState() => _PickupCenterSelectionWidgetState();
}

class _PickupCenterSelectionWidgetState extends State<PickupCenterSelectionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locController = Get.find<LocationController>();
      if (locController.zoneList == null || locController.zoneList!.isEmpty) {
        locController.getZoneList().then((_) {
          _initializeDefaults();
        });
      } else {
        _initializeDefaults();
      }
    });
  }

  void _initializeDefaults() {
    final locController = Get.find<LocationController>();
    if (locController.zoneList != null && locController.zoneList!.isNotEmpty) {
      if (widget.checkoutController.selectedPickupZone == null) {
        widget.checkoutController.setPickupZone(locController.zoneList!.first);
      } else {
        widget.checkoutController.recalculatePickupDistance();
      }
    }
  }

  void _onCenterSelected(PickupCenterModel? center) async {
    widget.checkoutController.setPickupCenter(center);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController) {
      List<ZoneData> zones = locationController.zoneList ?? [];
      ZoneData? currentZone = widget.checkoutController.selectedPickupZone ?? (zones.isNotEmpty ? zones.first : null);
      List<PickupCenterModel> centers = currentZone?.pickupCenters ?? [];
      PickupCenterModel? currentCenter = widget.checkoutController.selectedPickupCenter ?? (centers.isNotEmpty ? centers.first : null);

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.store_mall_directory_rounded, color: Theme.of(context).primaryColor),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('select_pickup_center'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Dropdown 1: Zone Selection
            Text('select_zone'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ZoneData>(
                  isExpanded: true,
                  value: currentZone,
                  hint: Text('select_zone'.tr, style: robotoRegular),
                  items: zones.map((zone) {
                    return DropdownMenuItem<ZoneData>(
                      value: zone,
                      child: Text(zone.name ?? 'Zone ${zone.id}', style: robotoRegular),
                    );
                  }).toList(),
                  onChanged: (zone) {
                    if (zone != null) {
                      widget.checkoutController.setPickupZone(zone);
                      List<PickupCenterModel> newCenters = zone.pickupCenters ?? [];
                      _onCenterSelected(newCenters.isNotEmpty ? newCenters.first : null);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Dropdown 2: Pickup Center Selection
            Text('select_center'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<PickupCenterModel>(
                  isExpanded: true,
                  value: centers.contains(currentCenter) ? currentCenter : (centers.isNotEmpty ? centers.first : null),
                  hint: Text(centers.isEmpty ? 'no_pickup_centers_available'.tr : 'select_center'.tr, style: robotoRegular),
                  items: centers.map((center) {
                    return DropdownMenuItem<PickupCenterModel>(
                      value: center,
                      child: Text('${center.name ?? ''} ${center.address != null ? "(${center.address})" : ""}', style: robotoRegular, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (center) {
                    _onCenterSelected(center);
                  },
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Display Selected Center Details Card
            if (currentCenter != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentCenter.name ?? '', style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                    if (currentCenter.address != null && currentCenter.address!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.location_on_outlined, size: 16, color: Theme.of(context).disabledColor),
                        const SizedBox(width: 4),
                        Expanded(child: Text(currentCenter.address!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))),
                      ]),
                    ],
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
