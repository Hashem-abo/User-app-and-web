import 'dart:io';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class ItemReviewWidget extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  final List<Reviews>? reviews;
  const ItemReviewWidget({super.key, required this.orderDetailsList, this.reviews});

  @override
  State<ItemReviewWidget> createState() => _ItemReviewWidgetState();
}

class _ItemReviewWidgetState extends State<ItemReviewWidget> {

  @override
  void initState() {
    super.initState();
    canReviews(widget.reviews, widget.orderDetailsList);
  }

  bool canReviews(List<Reviews>? reviews, List<OrderDetailsModel> orderDetailsList) {
    if (AuthHelper.isLoggedIn()) {
      if (reviews != null && reviews.isNotEmpty) {
        for (int i = 0; i < orderDetailsList.length; i++) {
          for (int j = 0; j < reviews.length; j++) {
            if (orderDetailsList[i].itemId == reviews[j].itemId) {
              Get.find<ReviewController>().setRating(i, reviews[j].rating ?? 0, notify: false);
              Get.find<ReviewController>().setReview(i, reviews[j].comment ?? '', notify: false);
              Future.delayed(const Duration(milliseconds: 100), () {
                Get.find<ReviewController>().update();
              });
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: ListView.builder(
          itemCount: widget.orderDetailsList.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 5)],
                color: Theme.of(context).cardColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(children: [

                // Product details
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImage(
                        height: 70, width: 85, fit: BoxFit.cover,
                        image: '${widget.orderDetailsList[index].imageFullUrl}',
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.orderDetailsList[index].itemDetails!.name!, style: robotoBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text(PriceConverter.convertPrice(widget.orderDetailsList[index].itemDetails!.price), style: robotoBlack.copyWith(fontSize: Dimensions.fontSizeLarge), textDirection: TextDirection.ltr),
                      ],
                    )),
                    Row(children: [
                      Text(
                        '${'quantity'.tr}: ',
                        style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.orderDetailsList[index].quantity.toString(),
                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  child: Divider(height: 1),
                ),

                // Rate
                Text(
                  'rate_the_item'.tr,
                  style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color, fontSize: Dimensions.fontSizeLarge), overflow: TextOverflow.ellipsis,
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(
                              reviewController.ratingList[index] < (i + 1) ? Icons.star_rounded : Icons.star_rounded,
                              size: 40,
                              color: reviewController.ratingList[index] < (i + 1) ? Theme.of(context).disabledColor.withOpacity(0.3)
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          onTap: () {
                            if(!reviewController.submitList[index]) {
                              reviewController.setRating(index, i + 1);
                            }
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
                  maxLines: 3,
                  capitalization: TextCapitalization.sentences,
                  isEnabled: !reviewController.submitList[index],
                  hintText: 'write_your_review_here'.tr,
                  fillColor: Theme.of(context).disabledColor.withOpacity(0.05),
                  onChanged: (text) => reviewController.setReview(index, text),
                  borderRadius: Dimensions.radiusDefault,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                
                // Image Picker
                Container(
                  height: 90,
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: reviewController.pickedImages[index].length + 1,
                    itemBuilder: (context, imageIndex) {
                      if (imageIndex == reviewController.pickedImages[index].length) {
                        return InkWell(
                          onTap: () => reviewController.pickImage(index, false),
                          child: Container(
                            height: 80, width: 80,
                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              border: Border.all(color: Theme.of(context).disabledColor, width: 1),
                            ),
                            child: Icon(Icons.camera_alt, color: Theme.of(context).disabledColor),
                          ),
                        );
                      }
                      return Stack(children: [
                        Container(
                          height: 80, width: 80,
                          margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Theme.of(context).disabledColor.withOpacity(0.1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: Image.file(
                              File(reviewController.pickedImages[index][imageIndex].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0, right: 0,
                          child: InkWell(
                            onTap: () => reviewController.removeImage(index, imageIndex),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.clear, color: Colors.red, size: 20),
                            ),
                          ),
                        ),
                      ]);
                    },
                  ),
                ),

                Row(
                  children: [
                    SizedBox(
                      width: 24, height: 24,
                      child: Checkbox(
                        value: reviewController.isAnonymousList[index],
                        onChanged: (value) {
                          reviewController.setAnonymous(index, value ?? false);
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text('hide_my_name'.tr, style: robotoRegular),
                  ],
                ),

                const SizedBox(height: 20),

                // Submit button
                if (canReviews(widget.reviews, widget.orderDetailsList))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: !reviewController.loadingList[index] ? CustomButton(
                    buttonText: reviewController.submitList[index] ? 'submitted'.tr : 'submit'.tr,
                    radius: Dimensions.radiusDefault,
                    onPressed: reviewController.submitList[index] ? null : () {
                      if(!reviewController.submitList[index]) {
                        if (reviewController.ratingList[index] == 0) {
                          showCustomSnackBar('give_a_rating'.tr);
                        } /*else if (reviewController.reviewList[index].isEmpty) {
                          showCustomSnackBar('write_a_review'.tr);
                        } */else {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          ReviewBodyModel reviewBody = ReviewBodyModel(
                            productId: widget.orderDetailsList[index].itemDetails!.id.toString(),
                            rating: reviewController.ratingList[index].toString(),
                            comment: reviewController.reviewList[index],
                            orderId: widget.orderDetailsList[index].orderId.toString(),
                            isAnonymous: reviewController.isAnonymousList[index],
                          );
                          reviewController.submitReview(index, reviewBody).then((value) {
                            if (value.isSuccess) {
                              showCustomSnackBar(value.message, isError: false);
                              reviewController.setReview(index, '');
                              reviewController.pickImage(index, true);
                            } else {
                              showCustomSnackBar(value.message);
                            }
                          });
                        }
                      }
                    },
                  ) : const CustomLoaderWidget(size: 25),
                ),

              ]),
            );
          },
        ))),
      );
    });
  }
}
