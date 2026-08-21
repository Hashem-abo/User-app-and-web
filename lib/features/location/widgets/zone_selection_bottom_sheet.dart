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
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, -3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 5, width: 45,
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.location_city_rounded, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  'select_zone'.tr == 'select_zone' ? 'اختر المدينة / المنطقة' : 'select_zone'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              ]),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(height: Dimensions.paddingSizeSmall),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          GetBuilder<LocationController>(builder: (locationController) {
            return locationController.zoneList != null ? (locationController.zoneList!.isNotEmpty ? ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: locationController.zoneList!.length,
              separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              itemBuilder: (context, index) {
                ZoneData zone = locationController.zoneList![index];
                bool isSelected = locationController.zoneID == zone.id;

                return InkWell(
                  onTap: () {
                    locationController.setManualZone(zone.id!);
                    Get.back();
                  },
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(
                            zone.name ?? 'Zone ${zone.id}',
                            style: isSelected
                                ? robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)
                                : robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                          ),
                        ]),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 22),
                      ],
                    ),
                  ),
                );
              },
            ) : Center(child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Text('no_zone_found'.tr, style: robotoMedium),
            ))) : const Center(child: Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeExtremeLarge),
              child: CircularProgressIndicator(),
            ));
          }),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }
}
