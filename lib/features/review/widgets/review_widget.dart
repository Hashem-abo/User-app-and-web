import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/common/widgets/readmore_widget.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/report/widgets/report_bottom_sheet.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';

class ReviewWidget extends StatelessWidget {
  final ReviewModel review;
  final bool hasDivider;
  final String? storeName;
  final Item? item;
  const ReviewWidget({super.key, required this.review, required this.hasDivider, this.storeName, this.item});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, size: 24, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.customerName ?? 'guest'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingBar(rating: (review.rating ?? 0).toDouble(), ratingCount: null, size: 14),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      DateConverter.stringToLocalDateOnly(review.createdAt ?? ''),
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        ReadMoreText(
          review.comment ?? '',
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.8),
            height: 1.5,
          ),
          trimMode: TrimMode.Line,
          trimLines: 3,
          colorClickableText: Theme.of(context).primaryColor,
          lessStyle: robotoBold.copyWith(color: Theme.of(context).primaryColor),
          trimCollapsedText: 'show_more'.tr,
          trimExpandedText: ' ${'show_less'.tr}',
          moreStyle: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        if (review.attachment != null && review.attachment!.isNotEmpty) ...[
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: review.attachment!.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (review.item != null || item != null) ? () {
                    Get.toNamed(RouteHelper.getReviewImageViewerRoute(review, review.item ?? item!, index));
                  } : null,
                  child: Container(
                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImage(
                        image: '${Get.find<SplashController>().configModel?.baseUrls?.reviewImageUrl}/${review.attachment![index]}',
                        height: 70, width: 70, fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],

        GetBuilder<ReviewController>(builder: (reviewController) {
          return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            InkWell(
              onTap: () {
                if(Get.find<AuthController>().isLoggedIn()) {
                  reviewController.toggleReviewLike(review.id!);
                } else {
                  showCustomSnackBar('you_must_login_to_like_review'.tr);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 6),
                decoration: BoxDecoration(
                  color: (review.isLikedByUser == true ? Theme.of(context).primaryColor : Theme.of(context).disabledColor).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
                child: Row(children: [
                  Icon(
                    review.isLikedByUser == true ? Icons.thumb_up : Icons.thumb_up_off_alt,
                    size: 16,
                    color: review.isLikedByUser == true ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    '${review.likeCount ?? 0}',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: review.isLikedByUser == true ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            InkWell(
              onTap: () {
                if(Get.find<AuthController>().isLoggedIn()) {
                  Get.bottomSheet(ReportBottomSheet(reportableId: review.id!, reportableType: 'review'));
                } else {
                  showCustomSnackBar('you_must_login_to_report'.tr);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.report_gmailerrorred, size: 18, color: Colors.red.withOpacity(0.6)),
              ),
            ),
          ]);
        }),

        if (review.reply != null) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1), width: 0.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(storeName ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                Text(
                  DateConverter.stringToLocalDateOnly(review.updatedAt!),
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                ),
              ]),
              const SizedBox(height: 8),
              Text(
                review.reply ?? '',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.7), height: 1.4),
              ),
            ]),
          ),
        ],

      ]),
    );
  }
}
