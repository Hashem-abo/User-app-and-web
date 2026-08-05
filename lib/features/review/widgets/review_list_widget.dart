import 'package:flutter/cupertino.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/review/widgets/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';

class ReviewListWidget extends StatelessWidget {
  final ReviewController reviewController;
  final String? storeName;
  final List<ReviewModel>? reviewList;
  const ReviewListWidget({super.key, required this.reviewController, this.storeName, this.reviewList});

  @override
  Widget build(BuildContext context) {
    List<ReviewModel>? list = reviewList ?? reviewController.storeReviewList;

    return list != null ? ListView.builder(
      itemCount: list.length,
      physics: ResponsiveHelper.isDesktop(context) ? const ScrollPhysics() :const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 40 : 0),
      itemBuilder: (context, index) {
        return ReviewWidget(
          review: list[index],
          hasDivider: index != list.length-1,
          storeName: storeName,
        );
      },
    ) : const SizedBox();
  }
}
