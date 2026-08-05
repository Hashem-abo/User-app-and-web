import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/features/review/widgets/edit_review_bottom_sheet.dart';

class UserReviewWidget extends StatelessWidget {
  final ReviewModel review;
  const UserReviewWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          RatingBar(rating: review.rating!.toDouble(), ratingCount: null, size: 18),

          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(review.itemName ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (review.item != null || review.itemId != null) ? Colors.orange : (review.storeName != null ? Colors.green : Colors.blue),
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                ),
                child: Text(
                  (review.item != null || review.itemId != null) ? 'product'.tr : (review.storeName != null ? 'store'.tr : 'delivery'.tr),
                  style: robotoMedium.copyWith(color: Colors.white, fontSize: 10),
                ),
              ),
            ]),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: CustomImage(image: '${review.itemImageFullUrl}', height: 50, width: 50, fit: BoxFit.cover),
            ),
          ]),
        ]),

        Text(
          '${'purchased_since'.tr} ${DateConverter.containTAndZToUTCFormat(review.createdAt!)}',
          style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
        ),
        
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(review.comment ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
        
        if(review.reply != null) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.store, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Expanded(child: Text(review.reply ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))),
            ]),
          ),
        ],

        const SizedBox(height: Dimensions.paddingSizeSmall),
        const Divider(),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(children: [
          if (review.item != null || review.itemId != null)
          Expanded(flex: 3, child: ElevatedButton(
            onPressed: () {
              int? itemId = review.item?.id ?? review.itemId;
              String? moduleType = review.item?.moduleType ?? review.moduleType;
              if(itemId != null) {
                Get.toNamed(RouteHelper.getItemDetailsRoute(itemId, moduleType == 'food'));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              minimumSize: const Size(0, 45),
            ),
            child: Text('view'.tr, style: robotoBold.copyWith(color: Colors.white)),
          )),
          if (review.item != null || review.itemId != null)
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(flex: 3, child: OutlinedButton(
            onPressed: () {
              Get.bottomSheet(
                EditReviewBottomSheet(review: review),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            }, // Edit logic
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              minimumSize: const Size(0, 45),
            ),
            child: Text('edit'.tr, style: robotoBold.copyWith(color: Theme.of(context).disabledColor)),
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          OutlinedButton(
            onPressed: () {
              bool isDeliveryMan = (review.item == null && review.itemId == null && review.storeName == null);
              Get.dialog(ConfirmationDialog(
                icon: Images.warning,
                description: 'are_you_sure_to_delete_this_review'.tr,
                onYesPressed: () => Get.find<ReviewController>().deleteReview(review.id!, isDeliveryMan),
              ));
            }, // Delete logic
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              minimumSize: const Size(50, 45),
              padding: EdgeInsets.zero,
            ),
            child: Icon(Icons.delete_outline, color: Theme.of(context).disabledColor),
          ),
        ]),

        const SizedBox(height: Dimensions.paddingSizeSmall),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          InkWell(
            onTap: () => Get.find<ReviewController>().toggleReviewLike(review.id!),
            child: Row(children: [
              Icon(
                review.isLikedByUser == true ? Icons.thumb_up : Icons.thumb_up_off_alt,
                size: 18,
                color: review.isLikedByUser == true ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                '${review.likeCount ?? 0}',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
              ),
            ]),
          ),
        ]),

      ]),
    );
  }
}
