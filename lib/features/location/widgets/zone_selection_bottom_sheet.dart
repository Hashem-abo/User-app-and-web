import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ZoneSelectionBottomSheet extends StatefulWidget {
  const ZoneSelectionBottomSheet({super.key});

  @override
  State<ZoneSelectionBottomSheet> createState() => _ZoneSelectionBottomSheetState();
}

class _ZoneSelectionBottomSheetState extends State<ZoneSelectionBottomSheet> {
  @override
  void initState() {
    super.initState();
    Get.find<LocationController>().getZoneList();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 5, width: 50,
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Text(
              'select_zone'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          GetBuilder<LocationController>(builder: (locationController) {
            return locationController.zoneList != null ? ListView.builder(
              shrinkWrap: true,
              itemCount: locationController.zoneList!.length,
              itemBuilder: (context, index) {
                ZoneData zone = locationController.zoneList![index];
                bool isSelected = locationController.zoneID == zone.id;

                return ListTile(
                  title: Text(zone.name ?? 'Zone ${zone.id}', style: robotoMedium),
                  trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                  onTap: () {
                    locationController.setManualZone(zone.id!);
                    Get.back();
                  },
                );
              },
            ) : const Center(child: Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: CircularProgressIndicator(),
            ));
          }),
          const SizedBox(height: Dimensions.paddingSizeExtremeLarge),
        ],
      ),
    );
  }
}
