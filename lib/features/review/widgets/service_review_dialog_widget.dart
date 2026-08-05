import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/domain/models/service_booking_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';

class ServiceReviewDialogWidget extends StatefulWidget {
  final ServiceBooking booking;
  const ServiceReviewDialogWidget({super.key, required this.booking});

  @override
  State<ServiceReviewDialogWidget> createState() => _ServiceReviewDialogWidgetState();
}

class _ServiceReviewDialogWidgetState extends State<ServiceReviewDialogWidget> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GetBuilder<ServiceController>(builder: (serviceController) {
        return SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.clear),
                ),
              ),

              Text(
                'rate_service'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(
                widget.booking.service!.name ?? '',
                style: robotoBold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return InkWell(
                    onTap: () => setState(() => _rating = index + 1),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 30,
                      color: index < _rating ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    ),
                  );
                }),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomTextField(
                controller: _reviewController,
                maxLines: 3,
                capitalization: TextCapitalization.sentences,
                hintText: 'write_your_review_here'.tr,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomButton(
                buttonText: 'submit'.tr,
                isLoading: serviceController.isLoading,
                onPressed: () {
                  if (_rating == 0) {
                    showCustomSnackBar('give_a_rating'.tr);
                  } else {
                    serviceController.submitServiceReview({
                      'service_id': widget.booking.serviceId,
                      'booking_id': widget.booking.id,
                      'rating': _rating,
                      'comment': _reviewController.text,
                    }).then((response) {
                      if (response.isSuccess) {
                        Get.back();
                        showCustomSnackBar(response.message, isError: false);
                      } else {
                        showCustomSnackBar(response.message);
                      }
                    });
                  }
                },
              ),

            ]),
          ),
        );
      }),
    );
  }
}
