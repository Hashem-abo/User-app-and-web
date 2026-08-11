import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/home/widgets/components/flash_sale_card_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/flash_sale/widgets/timer_widget.dart';

class FlashSaleViewWidget extends StatefulWidget {
  final String? title;
  const FlashSaleViewWidget({super.key, this.title});

  @override
  State<FlashSaleViewWidget> createState() => _FlashSaleViewWidgetState();
}

class _FlashSaleViewWidgetState extends State<FlashSaleViewWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlashSaleController>(builder: (flashSaleController) {
      int days = 0, hours = 0, minutes = 0, seconds = 0;
      if (flashSaleController.duration != null) {
        Duration duration = flashSaleController.duration!;
        days = duration.inDays;
        hours = duration.inHours - days * 24;
        minutes = duration.inMinutes - (days * 24 * 60) - (hours * 60);
        seconds = duration.inSeconds -
            (days * 24 * 60 * 60) -
            (hours * 60 * 60) -
            (minutes * 60);
      }

      return flashSaleController.flashSaleModel != null &&
              flashSaleController.flashSaleModel!.activeProducts != null &&
              flashSaleController.duration!.inSeconds > 1
          ? Container(
              width: Get.width,
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .primaryColor
                    .withValues(alpha: 0.1), // Use primary color with opacity
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Title and Timer
                  Padding(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title & Subtitle (Right in RTL, Left in LTR)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title ??
                                  'تخفيضات حصرية', // Use widget.title if available, else hardcoded
                              style: robotoBold.copyWith(
                                  fontSize: 18, color: Colors.black),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'limited_time_offer'.tr,
                              style: robotoRegular.copyWith(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),

                        // Timer (Left in RTL, Right in LTR)
                        Row(
                          children: [
                            _buildTimerBox(days, 'days'.tr),
                            const SizedBox(width: 6),
                            _buildTimerBox(hours, 'hours'.tr),
                            const SizedBox(width: 6),
                            _buildTimerBox(minutes, 'mins'.tr),
                            const SizedBox(width: 6),
                            _buildTimerBox(seconds, 'sec'.tr),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Content: FlashSaleCard (Carousel)
                  flashSaleController.flashSaleModel!.activeProducts != null
                      ? FlashSaleCard(
                          activeProducts: flashSaleController
                              .flashSaleModel!.activeProducts!,
                        )
                      : const SizedBox(),

                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ],
              ),
            )
          : const SizedBox(); // Remove shimmer fallback to prevent flashing
    });
  }

  Widget _buildTimerBox(int value, String unit) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                spreadRadius: 1,
              )
            ],
          ),
          child: Text(
            value > 9 ? value.toString() : '0$value',
            style: robotoBold.copyWith(fontSize: 14, color: Colors.black),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: robotoRegular.copyWith(
              fontSize: 10,
              color: const Color(0xFF8BA850),
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class FlashSaleShimmerView extends StatelessWidget {
  const FlashSaleShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: ResponsiveHelper.isDesktop(context) ? 330 : 350,
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('flash_sale'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    ResponsiveHelper.isDesktop(context)
                        ? const SizedBox()
                        : Text('limited_time_offer'.tr,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor)),
                  ],
                ),
                const Spacer(),
                Row(children: [
                  TimerWidget(
                    timeCount: 00,
                    timeUnit: 'days'.tr,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  TimerWidget(
                    timeCount: 00,
                    timeUnit: 'hours'.tr,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  TimerWidget(
                    timeCount: 00,
                    timeUnit: 'mins'.tr,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  TimerWidget(
                    timeCount: 00,
                    timeUnit: 'sec'.tr,
                  ),
                ])
              ]),
            ),
            Container(
              height: ResponsiveHelper.isDesktop(context) ? 150 : 170,
              width: Get.width * 0.7,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Container(
              height: 10,
              width: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              height: 10,
              width: 200,
              color: Colors.grey[300],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              height: 10,
              width: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),
      ),
    );
  }
}
