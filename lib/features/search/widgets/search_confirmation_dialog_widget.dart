import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SearchConfirmationDialogWidget extends StatelessWidget {
  final String identifiedItem;
  final String moreDetails;
  final VoidCallback onConfirm;

  const SearchConfirmationDialogWidget({
    super.key,
    required this.identifiedItem,
    required this.moreDetails,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(children: [
            Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 40),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'ai_identified_item'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              identifiedItem,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            if (moreDetails.isNotEmpty && moreDetails.toLowerCase() != 'null')
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Text(
                  moreDetails,
                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  ),
                  child: Text('cancel'.tr, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color)),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Get.back();
                    onConfirm();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  ),
                  child: Text('search_now'.tr, style: robotoBold.copyWith(color: Colors.white)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
