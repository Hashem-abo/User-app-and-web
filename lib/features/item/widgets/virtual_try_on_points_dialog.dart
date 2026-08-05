import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';

class VirtualTryOnPointsDialog extends StatelessWidget {
  final int cost;
  final double currentPoints;

  const VirtualTryOnPointsDialog({
    super.key,
    required this.cost,
    required this.currentPoints,
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
                'insufficient_point'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Subtitle
              Text(
                '${'you_need'.tr} $cost ${'points_to_use_virtual_try_on'.tr}',
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
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // How to earn points section
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'how_to_earn_points'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    _buildPointItem(context, Icons.shopping_bag_outlined, 'place_an_order'.tr),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    _buildPointItem(context, Icons.people_outline, 'refer_friends'.tr),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    _buildPointItem(context, Icons.card_giftcard, 'welcome_gift'.tr),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Action Button
              CustomButton(
                buttonText: 'ok'.tr,
                onPressed: () => Get.back(),
                radius: Dimensions.radiusDefault,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Text(
            text,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ),
      ],
    );
  }
}
