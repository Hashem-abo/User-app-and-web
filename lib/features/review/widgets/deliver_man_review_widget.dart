import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/review/widgets/delivery_man_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class DeliveryManReviewWidget extends StatefulWidget {
  final DeliveryMan? deliveryMan;
  final String orderID;
  final int? moduleId;
  const DeliveryManReviewWidget({super.key, required this.deliveryMan, required this.orderID, this.moduleId});

  @override
  State<DeliveryManReviewWidget> createState() => _DeliveryManReviewWidgetState();
}

class _DeliveryManReviewWidgetState extends State<DeliveryManReviewWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          widget.deliveryMan != null ? DeliveryManWidget(deliveryMan: widget.deliveryMan, moduleId: widget.moduleId) : const SizedBox(),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10, spreadRadius: 1,
              )],
            ),
            child: Column(children: [
              Text(
                'rate_his_service'.tr,
                style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color, fontSize: Dimensions.fontSizeLarge), 
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
             
              Center(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      return InkWell(
                        child:  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Icon(
                            reviewController.deliveryManRating < (i + 1) ? Icons.star_rounded : Icons.star_rounded,
                            size: 40,
                            color: reviewController.deliveryManRating < (i + 1) ? Theme.of(context).disabledColor.withOpacity(0.3)
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        onTap: () {
                          reviewController.setDeliveryManRating(i + 1);
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'share_your_opinion'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              MyTextField(
                maxLines: 5,
                capitalization: TextCapitalization.sentences,
                controller: _controller,
                hintText: 'write_your_review_here'.tr,
                fillColor: Theme.of(context).disabledColor.withOpacity(0.05),
                borderRadius: Dimensions.radiusDefault,
              ),
              const SizedBox(height: 40),

              // Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                child: Column(
                  children: [
                    !reviewController.isLoading ? CustomButton(
                      buttonText: 'submit'.tr,
                      radius: Dimensions.radiusDefault,
                      onPressed: () async {
                        if (reviewController.deliveryManRating == 0) {
                          showCustomSnackBar('give_a_rating'.tr, getXSnackBar: true);
                        } else if (_controller.text.isEmpty) {
                          showCustomSnackBar('write_a_review'.tr, getXSnackBar: true);
                        } else {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          ReviewBodyModel reviewBody = ReviewBodyModel(
                            deliveryManId: widget.deliveryMan!.id.toString(),
                            rating: reviewController.deliveryManRating.toString(),
                            comment: _controller.text,
                            orderId: widget.orderID,
                          );
                          await reviewController.submitDeliveryManReview(reviewBody).then((value) {
                            if (value.isSuccess) {
                              showCustomSnackBar(value.message, isError: false);
                              _controller.text = '';
                            } else {
                              showCustomSnackBar(value.message);
                            }
                          });
                        }
                      },
                    ) : const CustomLoaderWidget(size: 25),
                  ],
                ),
              ),
            ]),
          ),

        ]))),
      );
    });
  }
}
