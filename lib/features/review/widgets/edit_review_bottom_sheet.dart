import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/my_text_field.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/api/api_client.dart';

class EditReviewBottomSheet extends StatefulWidget {
  final ReviewModel review;
  const EditReviewBottomSheet({super.key, required this.review});

  @override
  State<EditReviewBottomSheet> createState() => _EditReviewBottomSheetState();
}

class _EditReviewBottomSheetState extends State<EditReviewBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  final List<XFile> _pickedImages = [];

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.review.comment ?? '';
    _rating = widget.review.rating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          
          Container(
            height: 5, width: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text('edit_review'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: CustomImage(image: '${widget.review.itemImageFullUrl}', height: 60, width: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: Text(widget.review.itemName ?? '', style: robotoMedium)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text('rate_the_item'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
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
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        _rating < (i + 1) ? Icons.star_rounded : Icons.star_rounded,
                        size: 40,
                        color: _rating < (i + 1) ? Theme.of(context).disabledColor.withOpacity(0.3) : Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          MyTextField(
            maxLines: 4,
            controller: _commentController,
            hintText: 'write_your_review_here'.tr,
            capitalization: TextCapitalization.sentences,
            borderRadius: Dimensions.radiusDefault,
            fillColor: Theme.of(context).disabledColor.withOpacity(0.05),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _pickedImages.length) {
                  return InkWell(
                    onTap: () async {
                      List<XFile> images = await ImagePicker().pickMultiImage(imageQuality: 30);
                      if (images.isNotEmpty) {
                        setState(() => _pickedImages.addAll(images));
                      }
                    },
                    child: Container(
                      height: 80, width: 80,
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
                      image: DecorationImage(image: FileImage(File(_pickedImages[index].path)), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 0, right: 0,
                    child: InkWell(
                      onTap: () => setState(() => _pickedImages.removeAt(index)),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.clear, color: Colors.red, size: 20),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          GetBuilder<ReviewController>(builder: (reviewController) {
            return CustomButton(
              isLoading: reviewController.isLoading,
              buttonText: 'update_review'.tr,
              onPressed: () {
                if (_rating == 0) {
                  showCustomSnackBar('give_a_rating'.tr);
                } else {
                  ReviewBodyModel reviewBody = ReviewBodyModel(
                    reviewId: widget.review.id.toString(),
                    productId: widget.review.item?.id.toString() ?? widget.review.itemId.toString(),
                    rating: _rating.toString(),
                    comment: _commentController.text,
                  );
                  
                  bool isDeliveryMan = (widget.review.item == null && widget.review.itemId == null && widget.review.storeName == null);
                  
                  List<MultipartBody> images = [];
                  for (XFile file in _pickedImages) {
                    images.add(MultipartBody('attachment[]', file));
                  }
                  
                  reviewController.updateReview(reviewBody, images, isDeliveryMan).then((value) {
                     Get.back();
                  });
                }
              },
            );
          }),
          const SizedBox(height: Dimensions.paddingSizeDefault),

        ]),
      ),
    );
  }
}
