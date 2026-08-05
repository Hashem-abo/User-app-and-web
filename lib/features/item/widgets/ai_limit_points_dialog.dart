import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';

class AiLimitPointsDialog extends StatelessWidget {
  final int cost;
  final double currentPoints;
  final Function() onAccept;

  const AiLimitPointsDialog({
    super.key,
    required this.cost,
    required this.currentPoints,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(Images.loyaltyIcon, width: 60, height: 60),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Title
              Text(
                'free_limit_reached'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Subtitle
              Text(
                '${'continue_for'.tr} $cost ${'points'.tr}?',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Stats Box
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('your_points'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Text(currentPoints.toInt().toString(), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Theme.of(context).disabledColor.withOpacity(0.2)),
                    Column(
                      children: [
                        Text('required_points'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Text(cost.toString(), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: 'cancel'.tr,
                      transparent: true,
                      onPressed: () => Get.back(),
                      radius: Dimensions.radiusDefault,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: CustomButton(
                      buttonText: 'continue'.tr,
                      onPressed: () {
                        Get.back();
                        onAccept();
                      },
                      radius: Dimensions.radiusDefault,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
