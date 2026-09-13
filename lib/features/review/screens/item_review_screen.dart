import 'package:flutter/material.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/review/widgets/review_widget.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/util/styles.dart';

class ItemReviewScreen extends StatelessWidget {
  final List<ReviewModel> reviewList;
  final Item? item;
  const ItemReviewScreen({super.key, required this.reviewList, this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'rate_and_review'.tr),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header: Rating summary dashboard (only when item is provided)
          if (item != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 1),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(children: [
                        Row(children: [
                          Expanded(
                            flex: 4,
                            child: Column(children: [
                              Text(
                                item!.avgRating?.toStringAsFixed(1) ?? '0.0',
                                style: robotoBold.copyWith(fontSize: 48, color: Theme.of(context).primaryColor),
                              ),
                              RatingBar(rating: item!.avgRating ?? 0, size: 18, ratingCount: null),
                              const SizedBox(height: 8),
                              Text(
                                '${item!.ratingCount ?? 0} ${'reviews'.tr}',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                              ),
                            ]),
                          ),

                          Container(height: 80, width: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.5), margin: const EdgeInsets.symmetric(horizontal: 20)),

                          Expanded(
                            flex: 6,
                            child: Column(children: List.generate(5, (index) {
                              int rating = 5 - index;
                              int count = reviewList.where((r) => r.rating == rating).length;
                              double percentage = reviewList.isNotEmpty ? (count / reviewList.length) : 0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(children: [
                                  Text('$rating', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.star, size: 12, color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: percentage,
                                        minHeight: 4,
                                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 30,
                                    child: Text('${(percentage * 100).toInt()}%', style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
                                  ),
                                ]),
                              );
                            })),
                          ),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              ),
            ),

          // Reviews list — lazy rendering via SliverList (no shrinkWrap)
          SliverPadding(
            padding: EdgeInsets.only(
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
              // Only add top padding when there's no header above
              top: item == null ? Dimensions.paddingSizeDefault : 0,
              bottom: Dimensions.paddingSizeDefault,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ReviewWidget(
                  review: reviewList[index],
                  hasDivider: index != reviewList.length - 1,
                  item: item,
                ),
                childCount: reviewList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
